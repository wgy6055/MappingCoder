<p align="center" >
  <img src="MappingCoder_Logo.png" title="logo" float=left>
</p>

[![Platform](https://img.shields.io/badge/platform-macos-brightgreen)](https://img.shields.io/badge/platform-macos-brightgreen)
[![Platform](https://img.shields.io/badge/macos-10.15-brightgreen)](https://img.shields.io/badge/macos-10.15-brightgreen)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/wgy6055/MappingCoder?color=brightgreen)
[![GitHub license](https://img.shields.io/github/license/wgy6055/MappingCoder?color=brightgreen)](https://github.com/wgy6055/MappingCoder/blob/master/LICENSE)
[![Swift version](https://img.shields.io/badge/swift-5.0-brightgreen)](https://swift.org/)
![GitHub all releases](https://img.shields.io/github/downloads/wgy6055/MappingCoder/total?color=brightgreen)

English | [中文](README_CN.md)

🧑🏼‍💻 An Xcode Source Editor extension for [ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper) user to convert JSON into Swift code.

⏬ [Download](https://github.com/wgy6055/MappingCoder/releases/download/v1.0.2/MappingCoder.zip)

## Features

- Convert JSON to `Mappable`
- Convert JSON to `ImmutableMappable`
- Auto Complete Mapping Methods
  - Custom mapping with attribute `@map`
- Support converting nested type
- Use lower camel case for property names
- Use `Int64` for property named `xxx(ID|Id|id)`

## Install

- macOS 10.15+
- Drag `MappingCoder.app` into `Applications` folder. 
- Open it. The extension will be installed on Xcode when the app is opened for the first time.
- In `System Preferences > Extensions > Xcode Source Editor`, selecting `MappingCoder` to activate it.

## Uninstall

Moving `MappingCoder.app` to Trash.

> Killing Xcode if there is a pop up showing "some of its extensions are in use".

## Usage

In Xcode, selecting JSON or Class/Struct Declaration. And choosing `Editor > MappingCoder > ...` to use.

## Examples

### Convert JSON to Mappable

<p align="center" >
  <img src="json-to-mappable.gif" title="json-to-mappable" float=left width=800>
</p>

### Convert JSON to ImmutableMappable

<p align="center" >
  <img src="json-to-immutablemappable.gif" title="json-to-immutablemappable" float=left width=800>
</p>

### Auto Complete Mapping Methods

Sometimes, there is no need to convert whole JSON to Swift code. So you can simply define properties and use `Auto Complete Mapping Methods` to generate `init(map:)` & `mapping(map:)`. If you want to customize the mapping, attribute `@map()` is provided to determine `key` & `default` for each property. 

Here is the declaration of `@map` in Swift Style.

```swift
@map(key: String? = nil, default: Any? = nil)
```

You can use it like this.

```swift
// Typing your declaration with @map in line comment

struct Person: ImmutableMappable {

    // @map(key: "all_skills", default: [])
    let skills: [Any]
    // @map(key: "user-name", default: "")
    let name: String
    // @map(default: [:])
    let profile: [String : Any]
    // @map(key: "math score")
    let mathScore: Int
}

// Run Auto Complete Mapping Methods

struct Person: ImmutableMappable {

    // @map(key: "all_skills", default: [])
    let skills: [Any]
    // @map(key: "user-name", default: "")
    let name: String
    // @map(default: [:])
    let profile: [String : Any]
    // @map(key: "math score")
    let mathScore: Int

    init(map: Map) throws {
        skills = (try? map.value("all_skills")) ?? []
        name = (try? map.value("user-name")) ?? ""
        profile = (try? map.value("profile")) ?? [:]
        mathScore = (try? map.value("math score")) ?? <#defaultValue#>
    }

    func mapping(map: Map) {
        skills >>> map["all_skills"]
        name >>> map["user-name"]
        profile >>> map["profile"]
        mathScore >>> map["math score"]
    }
}
```

This feature is powered by [SwiftSyntax](https://github.com/apple/swift-syntax).

### Use Lower Camel Case & Int64

`MappingCoder` names property using lower camel case automatically. And also, defines property named `xxx(ID|Id|id)` as `Int64`.

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

## Settings

In Xcode, choosing `Editor > MappingCoder > Settings...` to open Settings.

<p align="left" >
  <img src="settings.png" title="settings" float=left width=400>
</p>

## Inspired By

- [JSON-to-Swift-Converter](https://github.com/mrlegowatch/JSON-to-Swift-Converter)
- [SwiftSyntax](https://github.com/apple/swift-syntax)
- [SwiftSemantics](https://github.com/SwiftDocOrg/SwiftSemantics)

## License

[MIT](LICENSE)
