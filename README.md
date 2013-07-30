# Commit2Changelog

## Intro

本工具的目标是根据既定的 commit 格式生成 markdown 格式的 changelog 。

## 目标生成结果

```
Reading git log in range 4a00e4fd805f693f71178d813fcb8b7d97731686..
Parsed 8 commits
Generating changelog to stdout ( undefined )
<a name="undefined"></a>
# undefined (2013-07-26)


## Features

- **推荐位:**
  - 完成推荐位的提交相关逻辑
  ([314b9170](http://code.gezbox.com/frontend/ntcloud/commit/314b9170e90bde6f200e9cd98875eecee42b312c))
  - 删除操作添加了一个confirm确认提示
  ([e88b55d3](http://code.gezbox.com/frontend/ntcloud/commit/e88b55d3d24dd9698c49959a88fb93b717b366a7))
  - 完成创建推荐位功能
  ([63777eb9](http://code.gezbox.com/frontend/ntcloud/commit/63777eb974f00301d0be068824f9a0d3f5afda95))
  - 推荐位完成上传图片功能
  ([f4296069](http://code.gezbox.com/frontend/ntcloud/commit/f4296069c1a1dd3fa1603e4f3d0de4b731950442))
  - 推荐位增加删除功能
  ([2c5a0b04](http://code.gezbox.com/frontend/ntcloud/commit/2c5a0b04dd913eb0332cd0ebcaff7bc3006a56ed))
  - 增加了推荐位的创建、修改和删除的Resource
  ([0947dc44](http://code.gezbox.com/frontend/ntcloud/commit/0947dc446c30476c84bdc64deda1f7d5c456da2b))
  - 完成推荐位部分跳转类型和跳转至的相关逻辑
  ([eea939d2](http://code.gezbox.com/frontend/ntcloud/commit/eea939d243e1c1ffeaa529fe61c84e18b64c3b9d))
- **登录:** 暂时取消现有的登录功能
  ([1ea3f701](http://code.gezbox.com/frontend/ntcloud/commit/1ea3f701c96e04c024b818c74c8326d04c36ceea))


## Breaking Changes


```

## 使用方法

```bash
# 首先安装依赖
npm install

# 然后使用
node changelog.js [Git 项目路径] [Git log 日志的范围，如果不传则过滤出今日的 commit]
```

