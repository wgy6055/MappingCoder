<p align="center" >
  <img src="MappingCoder_Logo.png" title="logo" float=left>
</p>

[![Platform](https://img.shields.io/badge/platform-macos-brightgreen)](https://img.shields.io/badge/platform-macos-brightgreen)
[![Platform](https://img.shields.io/badge/macos-10.15-brightgreen)](https://img.shields.io/badge/macos-10.15-brightgreen)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/wgy6055/MappingCoder?color=brightgreen)
[![GitHub license](https://img.shields.io/github/license/wgy6055/MappingCoder?color=brightgreen)](https://github.com/wgy6055/MappingCoder/blob/master/LICENSE)
[![Swift version](https://img.shields.io/badge/swift-5.0-brightgreen)](https://swift.org/)

[English](README.md) | 中文

🧑🏼‍💻 为 [ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper) 使用者提供 JSON 转 Swift Model 的 Xcode 插件。

⏬ [点击下载](https://github.com/wgy6055/MappingCoder/releases/download/v1.0.1/MappingCoder.zip)

## 功能

- JSON 转 `Mappable`
- JSON 转 `ImmutableMappable`
- 自动补全 `mapping` 等方法
  - 支持使用 `@map` 关键字实现自定义映射
- 支持内嵌结构
- 自动生成符合小驼峰命名规范的变量名
- 自动对名为 `xxx(ID|Id|id)` 的变量使用 `Int64`

## 安装

- macOS 10.15+
- 将 `MappingCoder.app` 拖到 `应用程序` 目录下
- 运行 App。第一次运行会将插件安装到 Xcode 上。
- 在 `系统设置 > 扩展 > Xcode Source Editor` 中，选中 `MappingCoder` 来将其激活。

## 卸载

将 `MappingCoder.app` 移入 `垃圾桶`。

> 如果出现“扩展正在被使用”的弹窗，可以尝试退出 Xcode 进程。

## 使用方法

在 Xcode 中，在源码编辑区域选中 JSON 或 Class/Struct 的定义代码。点击 `Editor > MappingCoder > ...` 来运行。

## 示例

### JSON 转 Mappable

<p align="center" >
  <img src="json-to-mappable.gif" title="json-to-mappable" float=left width=800>
</p>

### JSON 转 ImmutableMappable

<p align="center" >
  <img src="json-to-immutablemappable.gif" title="json-to-immutablemappable" float=left width=800>
</p>

### 自动补全 mapping 等方法

有时我们并不需要将整个 JSON 都转成 Model。所以你可以只把 Model 内的属性定义好，然后执行 `Auto Complete Mapping Methods` 来自动生成 `init(map:)` 和 `mapping(map:)` 的代码。如果你想自定义映射关系，可以使用 `@map()` 关键字为每个属性指定 `key` 和 `default`。

```swift
// @map(key: String?, default: Any?)

// @map(key: "all_skills", default: [])
var skills: [Skill]
// @map(key: "user-name", default: "")
var name: String
// @map(default: [:])
var profile: [String : Any]
// @map(key: "math score")
var mathScore: Int
```

这个功能基于 [SwiftSyntax](https://github.com/apple/swift-syntax) 实现。

<p align="center" >
  <img src="auto-complete-mapping-methods.gif" title="auto-complete-mapping-methods" float=left width=800>
</p>

### 驼峰命名 & Int64

`MappingCoder` names property using lower camel case automatically. And also, defines property named `xxx(ID|Id|id)` as `Int64`.
`MappingCoder` 自动使用小驼峰命名法命名所有变量。而且，会将名为 `xxx(ID|Id|id)` 的变量类型定义为 `Int64`。

```swift
//{
//    "user_name": "jack",
//    "user-id": 123456789
//}

class <#name#>: Mappable {

    var userId: Int64 = <#defaultValue#>
    var userName: String = <#defaultValue#>

    required init?(map: Map) {}

    func mapping(map: Map) {
        userId <- map["user-id"]
        userName <- map["user_name"]
    }
}
```

## 设置

在 Xcode 中，点击 `Editor > MappingCoder > Settings...` 来打开设置。

<p align="left" >
  <img src="settings.png" title="settings" float=left width=400>
</p>

## 灵感源头

- [JSON-to-Swift-Converter](https://github.com/mrlegowatch/JSON-to-Swift-Converter)
- [SwiftSyntax](https://github.com/apple/swift-syntax)
- [SwiftSemantics](https://github.com/SwiftDocOrg/SwiftSemantics)

## 开源协议

[MIT](LICENSE)
