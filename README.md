<p align="center" >
  <img src="https://github.com/wgy6055/MappingCoder/raw/master/MappingCoder_Logo.png" title="logo" float=left>
</p>

🧑🏼‍💻 An Xcode Source Editor extension for [ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper) user to convert JSON into Swift code.

## Features

- Convert JSON to Mappable
- Convert JSON to ImmutableMappable
- Auto Complete Mapping Methods
- Support converting nested type
- Use lower camel case for property names
- Use Int64 for property named xxx(ID|Id|id)

## Usage

Dragging `MappingCoder.app` into `Applications` folder. 

> Before usage, the host app needs to be run at least once. 

In `System Preferences > Extensions > Xcode Source Editor`, selecting `MappingCoder` to activate it.

In Xcode, selecting JSON or Class/Struct Declaration. And choosing `Editor > MappingCoder > ...` to use.

## Examples

### Convert JSON to Mappable

<p align="center" >
  <img src="https://github.com/wgy6055/MappingCoder/raw/master/json-to-mappable.gif" title="json-to-mappable" float=left>
</p>

### Convert JSON to ImmutableMappable

<p align="center" >
  <img src="https://github.com/wgy6055/MappingCoder/raw/master/json-to-immutablemappable.gif" title="json-to-immutablemappable" float=left>
</p>

### Auto Complete Mapping Methods

Sometimes, there is no need to convert whole JSON to Swift code. So you can simply define properties and use `Auto Complete Mapping Methods` to generate `init(map:)` & `mapping(map:)` automatically. This feature is powered by [SwiftSyntax](https://github.com/apple/swift-syntax).

<p align="center" >
  <img src="https://github.com/wgy6055/MappingCoder/raw/master/auto-complet-mapping-method.gif" title="auto-complet-mapping-method" float=left>
</p>

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

## Inspired By

- [JSON-to-Swift-Converter](https://github.com/mrlegowatch/JSON-to-Swift-Converter)
- [SwiftSyntax](https://github.com/apple/swift-syntax)
- [SwiftSemantics](https://github.com/SwiftDocOrg/SwiftSemantics)
