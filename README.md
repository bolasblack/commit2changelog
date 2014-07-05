# Commit2Changelog
## Intro

本工具的目标是根据[指定的 commit 格式](https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/edit)生成 markdown 格式的 changelog 。

感谢 [AngularJS 项目](https://github.com/angular/angular.js)的[代码](https://github.com/angular/angular.js/blob/master/changelog.js)。

## Output

```
Reading git log in range 4a00e4fd805f693f71178d813fcb8b7d97731686..
Parsed 8 commits
Generating changelog to stdout ( undefined )
<a name="undefined"></a>
# undefined (2013-07-26)


## Features

- **推荐位:**
  - 完成推荐位的提交相关逻辑
  ([314b9170](...))
  - 删除操作添加了一个confirm确认提示
  ([e88b55d3](...))
  - 完成创建推荐位功能
  ([63777eb9](...))
  - 推荐位完成上传图片功能
  ([f4296069](...))
  - 推荐位增加删除功能
  ([2c5a0b04](...))
  - 增加了推荐位的创建、修改和删除的Resource
  ([0947dc44](...))
  - 完成推荐位部分跳转类型和跳转至的相关逻辑
  ([eea939d2](...))
- **登录:** 暂时取消现有的登录功能
  ([1ea3f701](...))


## Breaking Changes


```

## Install

```bash
npm install bolasblack/commit2changelog -g
```

## Usage

```bash
changelog -h
```

