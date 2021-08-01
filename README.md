<p align="center" >
  <img src="https://github.com/wgy6055/MappingCoder/raw/master/MappingCoder_Logo.png" title="logo" float=left>
</p>

🧑🏼‍💻 An Xcode source editor extension for [ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper) user to convert JSON into Swift code.

## Features

- Convert JSON to Mappable
- Convert JSON to ImmutableMappable
- Auto Complete Mapping Methods
- Use lower camel case for property names
- Use Int64 for property named xxx(ID|Id|id)

## Usage

Before usage, the host app needs to be run at least once.
In Xcode, selecting JSON or Class/Struct Declaration. And choosing `Editor > MappingCoder > ...` to use.

### Convert JSON to Mappable

<p align="center" >
  <img src="https://github.com/wgy6055/MappingCoder/raw/master/json-to-mappable.gif" title="json-to-mappable" float=left>
</p>

### Convert JSON to ImmutableMappable

<p align="center" >
  <img src="https://github.com/wgy6055/MappingCoder/raw/master/json-to-immutablemappable.gif" title="json-to-immutablemappable" float=left>
</p>

### Auto Complete Mapping Methods

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

