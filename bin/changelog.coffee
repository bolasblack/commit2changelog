#!/usr/bin/env coffee

# TODO(vojta): pre-commit hook for validating messages
# TODO(vojta): report errors, currently Q silence everything which really sucks

child = require 'child_process'
path = require 'path'
util = require 'util'
fs = require 'fs'
{docopt} = require 'docopt'
q = require 'qq'

help = """
Usage: changelog [options] [<range>]

Options:
  -p, --exec-path=<project path>    Set target project path, [default ./].
  -v, --version                     Show version.
  -h, --help                        Show this.
"""

binFilePath = path.dirname process.argv[1]
packageInfo = JSON.parse fs.readFileSync path.resolve binFilePath, '../package.json'
options = docopt help, argv: process.argv[2..], help: true, version: packageInfo.version

GIT_DIR = '--git-dir=' + (options['--exec-path'] or process.cwd()).replace /\/?$/, '/.git'
GIT_HOST = ''

# 如果没有传 commit 的 range，就只看今天的
COMMIT_RANGE = if options['<commit_range>'] then "#{options['<commit_range>']}...HEAD" else '--after="yesterday"'

GIT_HOST_CMD = "git #{GIT_DIR} config remote.origin.url | sed -E 's/git@(.*):(.*)\\.git/\\1\\/\\2/g'"
GIT_LOG_CMD = "git #{GIT_DIR} log --grep='%s' -E --format=%s #{COMMIT_RANGE}"
GIT_TAG_CMD = "git #{GIT_DIR} describe --tags --abbrev=0"

HEADER_TPL = '<a name="%s"></a>\n# %s (%s)\n\n'
LINK_ISSUE = '[#%s](%s/issues/%s)'
LINK_COMMIT = '[%s](%s/commit/%s)'

EMPTY_COMPONENT = '$$'
MAX_SUBJECT_LENGTH = 80

warn = ->
  console.log 'WARNING:', util.format.apply null, arguments

parseRawCommit = (raw) ->
  return null unless raw

  lines = raw.split '\n'
  msg = {}
  match = null

  msg.hash = lines.shift()
  msg.subject = lines.shift()
  msg.closes = []
  msg.breaks = []

  lines.forEach (line) ->
    match = line.match /(?:Closes|Fixes)\s#(\d+)/
    msg.closes.push(parseInt match[1]) if match

  match = raw.match /BREAKING CHANGE:([\s\S]*)/
  msg.breaking = match[1] if match

  msg.body = lines.join '\n'

  # match: ...(...): ...
  match = msg.subject.match /^(.*)\((.*)\)\:\s(.*)$/

  incorrectMessage = match and match[1] and match[3]
  unless incorrectMessage
    warn 'Incorrect message: %s %s', msg.hash, msg.subject
    return null

  if match[3].length > MAX_SUBJECT_LENGTH
    warn 'Too long subject: %s %s', msg.hash, msg.subject
    match[3] = match[3].substr 0, MAX_SUBJECT_LENGTH

  msg.type = match[1]
  msg.component = match[2]
  msg.subject = match[3]

  msg


linkToIssue = (issue) ->
  util.format LINK_ISSUE, issue, GIT_HOST, issue


linkToCommit = (hash) ->
  util.format LINK_COMMIT, hash.substr(0, 8), GIT_HOST, hash


currentDate = ->
  now = new Date
  pad = (i) ->
    ('0' + i).substr -2

  util.format '%d-%s-%s', now.getFullYear(), pad(now.getMonth() + 1), pad(now.getDate())


printSection = (stream, title, section, printCommitLinks) ->
  printCommitLinks = if printCommitLinks is undefined then true else printCommitLinks
  components = Object.getOwnPropertyNames(section).sort()

  return if !components.length

  stream.write util.format '\n## %s\n\n', title

  components.forEach (name) ->
    prefix = '-'
    nested = section[name].length > 1

    if name isnt EMPTY_COMPONENT
      if nested
        stream.write util.format '- **%s:**\n', name
        prefix = '  -'
      else
        prefix = util.format '- **%s:**', name

    section[name].forEach (commit) ->
      if printCommitLinks
        stream.write(util.format('%s %s\n  (%s', prefix, commit.subject, linkToCommit(commit.hash)));
        if commit.closes.length
          stream.write(',\n   ' + commit.closes.map(linkToIssue).join(', '))
        stream.write(')\n')
      else
        stream.write(util.format('%s %s', prefix, commit.subject))

  stream.write('\n')


readGitLog = (grep) ->
  deferred = q.defer()

  # TODO(vojta): if it's slow, use spawn and stream it instead
  endStr = '%H%n%s%n%b%n==END=='
  child.exec util.format(GIT_LOG_CMD, grep, endStr), (code, stdout, stderr) ->
    commits = []

    stdout.split('\n==END==\n').forEach (rawCommit) ->
      commit = parseRawCommit rawCommit
      commits.push commit if commit

    deferred.resolve commits

  deferred.promise


writeChangelog = (stream, commits, version) ->
  sections =
    fix: {}
    feat: {}
    breaks: {}

  sections.breaks[EMPTY_COMPONENT] = []

  commits.forEach (commit) ->
    section = sections[commit.type]
    component = commit.component or EMPTY_COMPONENT

    if section
      section[component] = section[component] || []
      section[component].push(commit)

    if commit.breaking
      sections.breaks[component] = sections.breaks[component] || []
      sections.breaks[component].push
        subject: util.format("due to %s,\n %s", linkToCommit(commit.hash), commit.breaking)
        hash: commit.hash
        closes: []

  stream.write(util.format(HEADER_TPL, version, version, currentDate()))
  printSection(stream, 'Bug Fixes', sections.fix)
  printSection(stream, 'Features', sections.feat)
  printSection(stream, 'Breaking Changes', sections.breaks, false)


generate = (version, file) ->
  console.log 'Reading git log in range', COMMIT_RANGE
  readGitLog('^fix|^feat|Breaks').then (commits) ->
    console.log 'Parsed', commits.length, 'commits'
    console.log 'Generating changelog to', file or 'stdout', '(', version, ')'
    stream = if file then fs.createWriteStream(file) else process.stdout
    writeChangelog stream, commits, version


# publish for testing
exports.parseRawCommit = parseRawCommit


# hack for git repo host addr
child.exec GIT_HOST_CMD, (error, stdout, stderr) ->
  GIT_HOST = 'http://' + stdout.replace /\n?$/, ''
  generate()


