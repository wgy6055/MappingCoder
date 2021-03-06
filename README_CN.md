<p align="center" >
  <img src="MappingCoder_Logo.png" title="logo" float=left>
</p>

[![Platform](https://img.shields.io/badge/platform-macos-brightgreen)](https://img.shields.io/badge/platform-macos-brightgreen)
[![Platform](https://img.shields.io/badge/macos-10.15-brightgreen)](https://img.shields.io/badge/macos-10.15-brightgreen)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/wgy6055/MappingCoder?color=brightgreen)
[![GitHub license](https://img.shields.io/github/license/wgy6055/MappingCoder?color=brightgreen)](https://github.com/wgy6055/MappingCoder/blob/master/LICENSE)
[![Swift version](https://img.shields.io/badge/swift-5.0-brightgreen)](https://swift.org/)
![GitHub all releases](https://img.shields.io/github/downloads/wgy6055/MappingCoder/total?color=brightgreen)

[English](README.md) | ä¸­æ

ð§ð¼âð» ä¸º [ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper) ä½¿ç¨èæä¾ JSON è½¬ Swift Model ç Xcode æä»¶ã

â¬ [ç¹å»ä¸è½½](https://github.com/wgy6055/MappingCoder/releases/download/v1.0.2/MappingCoder.zip)

## åè½

- JSON è½¬ `Mappable`
- JSON è½¬ `ImmutableMappable`
- èªå¨è¡¥å¨ `mapping` ç­æ¹æ³
  - æ¯æä½¿ç¨ `@map` å³é®å­å®ç°èªå®ä¹æ å°
- æ¯æååµç»æ
- èªå¨çæç¬¦åå°é©¼å³°å½åè§èçåéå
- èªå¨å¯¹åä¸º `xxx(ID|Id|id)` çåéä½¿ç¨ `Int64`

## å®è£

- macOS 10.15+
- å° `MappingCoder.app` æå° `åºç¨ç¨åº` ç®å½ä¸
- è¿è¡ Appãç¬¬ä¸æ¬¡è¿è¡ä¼å°æä»¶å®è£å° Xcode ä¸ã
- å¨ `ç³»ç»è®¾ç½® > æ©å± > Xcode Source Editor` ä¸­ï¼éä¸­ `MappingCoder` æ¥å°å¶æ¿æ´»ã

## å¸è½½

å° `MappingCoder.app` ç§»å¥ `åå¾æ¡¶`ã

> å¦æåºç°âæ©å±æ­£å¨è¢«ä½¿ç¨âçå¼¹çªï¼å¯ä»¥å°è¯éåº Xcode è¿ç¨ã

## ä½¿ç¨æ¹æ³

å¨ Xcode ä¸­ï¼å¨æºç ç¼è¾åºåéä¸­ JSON æ Class/Struct çå®ä¹ä»£ç ãç¹å» `Editor > MappingCoder > ...` æ¥è¿è¡ã

## ç¤ºä¾

### JSON è½¬ Mappable

<p align="center" >
  <img src="json-to-mappable.gif" title="json-to-mappable" float=left width=800>
</p>

### JSON è½¬ ImmutableMappable

<p align="center" >
  <img src="json-to-immutablemappable.gif" title="json-to-immutablemappable" float=left width=800>
</p>

### èªå¨è¡¥å¨ mapping ç­æ¹æ³

ææ¶æä»¬å¹¶ä¸éè¦å°æ´ä¸ª JSON é½è½¬æ Modelãæä»¥ä½ å¯ä»¥åªæ Model åçå±æ§å®ä¹å¥½ï¼ç¶åæ§è¡ `Auto Complete Mapping Methods` æ¥èªå¨çæ `init(map:)` å `mapping(map:)` çä»£ç ãå¦æä½ æ³èªå®ä¹æ å°å³ç³»ï¼å¯ä»¥ä½¿ç¨ `@map()` å³é®å­ä¸ºæ¯ä¸ªå±æ§æå® `key` å `default`ã

ä»¥ä¸æ¯ Swift é£æ ¼ç `@map` æ¹æ³å®ä¹ã

```swift
@map(key: String? = nil, default: Any? = nil)
```

ä½ å¯ä»¥è¿æ ·ä½¿ç¨å®ã

```swift
// è¾å¥ä½ çç±»å£°æï¼å¹¶ä¸å¨å±æ§çè¡æ³¨ééä½¿ç¨ @map

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

// æ§è¡ Auto Complete Mapping Methods

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

è¿ä¸ªåè½åºäº [SwiftSyntax](https://github.com/apple/swift-syntax) å®ç°ã

### é©¼å³°å½å & Int64

`MappingCoder` èªå¨ä½¿ç¨å°é©¼å³°å½åæ³å½åææåéãèä¸ï¼ä¼å°åä¸º `xxx(ID|Id|id)` çåéç±»åå®ä¹ä¸º `Int64`ã

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

## è®¾ç½®

å¨ Xcode ä¸­ï¼ç¹å» `Editor > MappingCoder > Settings...` æ¥æå¼è®¾ç½®ã

<p align="left" >
  <img src="settings.png" title="settings" float=left width=400>
</p>

## çµææºå¤´

- [JSON-to-Swift-Converter](https://github.com/mrlegowatch/JSON-to-Swift-Converter)
- [SwiftSyntax](https://github.com/apple/swift-syntax)
- [SwiftSemantics](https://github.com/SwiftDocOrg/SwiftSemantics)

## å¼æºåè®®

[MIT](LICENSE)
