# swift-version-primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Typed versioning primitives — the whole versioning domain encoded
under one namespace. The package implements:

- **Semantic Versioning 2.0.0** (per [semver.org](https://semver.org/)) as `Version.Semantic`
- **Calendar Versioning** (per [calver.org](https://calver.org/)) as `Version.Calendar`
- **SwiftPM Tools Version** (per [SE-0152](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0152-package-manager-tools-version.md)) as `Version.Tools`
- **Generic interval ranges** as `Version.Range<V>` (works over any versioning kind)
- **Algebraic version-sets** as `Version.Set<V>` (`.empty / .any / .exact / .range / .union`)

The package follows the institute's typed-identifier-naming framework
(see `swift-institute/Research/2026-05-12-typed-identifier-naming-framework.md`):
the namespace is the generic English noun (`Version`) rather than a
spec-flavored `SemVer.*`. Cross-ecosystem reuse is the design intent —
the same `Version.Semantic` powers NPM bridges, Cargo bridges,
registry tooling, the Swift Package Index, and SwiftPM consumers.

## Quick Start

```swift
import Version_Primitives

let v = try Version.Semantic("1.2.3-rc.1+build.456")

// SemVer §11 precedence:
let pre = try Version.Semantic("1.0.0-alpha")
let rel = try Version.Semantic("1.0.0")
#expect(pre < rel)  // pre-release has lower precedence than release

// SemVer §10 equality (build metadata excluded):
let a = try Version.Semantic("1.0.0+a")
let b = try Version.Semantic("1.0.0+b")
#expect(a == b)  // equal — build metadata is excluded
```

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-version-primitives.git", from: "0.1.0"),
]
```

```swift
.target(
    name: "YourPackage",
    dependencies: [
        .product(name: "Version Primitives", package: "swift-version-primitives"),
    ]
)
```

## What's in the namespace

### Versioning kinds

| Type | Purpose |
|------|---------|
| `Version` | Top-level namespace for versioning kinds. |
| `Version.Semantic` | SemVer 2.0.0 typed representation. Five components (MAJOR.MINOR.PATCH plus optional pre-release and build-metadata). Sendable, Hashable, Equatable, Comparable, LosslessStringConvertible, CustomStringConvertible. |
| `Version.Tools` | SwiftPM tools-version per SE-0152 — `MAJOR.MINOR[.PATCH]` with optional patch. Strict SemVer subset (no pre-release / build-metadata). |
| `Version.Calendar` | CalVer per calver.org — three-case enum (`yearOnly` / `yearMonth` / `full`) preserving scheme identity through round-trips. Optional modifier suffix. |

### Set-theoretic types (generic over versioning kind)

| Type | Purpose |
|------|---------|
| `Version.Range<V>` | Half-open / closed / unbounded interval with optional inclusive or exclusive bounds. Convenience constructors `upToNextMajor(from:)` and `upToNextMinor(from:)` for the caret / tilde semantics consumers expect from SwiftPM and npm. Algebra: `isEmpty`, `intersection(_:)`, `overlaps(_:)`, `isSubset(of:)`, `isSuperset(of:)`, `contains(_:)` (range and version overloads). Generic over any `Comparable` versioning kind. `CustomStringConvertible` in mathematical interval notation (`[1.0.0, 2.0.0)`). |
| `Version.Range.Bound` | `.unbounded` / `.inclusive(V)` / `.exclusive(V)` boundary case. |
| `Version.Set<V>` | Algebraic version-set — `.empty / .any / .exact(V) / .range(Range) / .union([Set])`. Mirrors SwiftPM's internal `VersionSetSpecifier`. Algebra: `isEmpty`, `normalized()`, `union(_:)`, `intersection(_:)`. `CustomStringConvertible` in set-theoretic notation (`∅`, `*`, `{v}`, `(a ∪ b)`); `CustomDebugStringConvertible` preserves case structure. |

### Semantic-only accessors

| Type | Purpose |
|------|---------|
| `Version.Semantic.Phase` | `.initial` (MAJOR == 0 per SemVer §4) or `.stable` (MAJOR >= 1 per §5). Reach via `version.phase`. |
| `Version.Semantic.Bumped` | Nested accessor producing the next version on each SemVer axis. Reach via `version.bumped.major / .minor / .patch` (per `[API-NAME-002]` — no compound `bumpedMajor()` method). |

### Per-version component types

| Type | Purpose |
|------|---------|
| `Version.Semantic.Identifier` | Pre-release identifier — `.numeric(UInt)` or `.alphanumeric(String)`, with §11.4 precedence. |
| `Version.Semantic.Major` / `.Minor` / `.Patch` (plus `.Value`) | Phantom tag namespaces; the `.Value` typealias is `Tagged<Self, Swift.UInt>`. Components are type-distinct so swaps are caught at compile time. |
| `Version.Tools.Major` / `.Minor` / `.Patch` (plus `.Value`) | Same pattern for tools-version components. |
| `Version.Calendar.Micro` (plus `.Value`) | Tagged<Micro, UInt> for the MICRO component. YEAR and MONTH delegate to `Time.Year` and `Time.Month` from `swift-time-primitives` — `Time.Month` is a 1–12 refinement type, so impossible months are rejected at construction. |

### Per-version Parser / Serializer / Error

Each versioning kind ships its own three-piece accessory set:

| Kind | Error | Parser | Serializer |
|---|---|---|---|
| `Semantic` | `Version.Semantic.Error` | `Version.Semantic.Parser` | `Version.Semantic.Serializer` |
| `Tools` | `Version.Tools.Error` | `Version.Tools.Parser` | `Version.Tools.Serializer` |
| `Calendar` | `Version.Calendar.Error` | `Version.Calendar.Parser` | `Version.Calendar.Serializer` |

Parsers conform to `Parser_Primitives.Parser.Protocol` over `UInt8`
byte streams; Serializers conform to
`Serializer_Primitives.Serializer.Protocol`. Errors carry a
`range: Text.Range` field locating the offending byte span for
IDE / tooling consumers.

All three kinds also conform to `Codable` outside Embedded Swift
(`#if !hasFeature(Embedded)`) — encoded as the canonical string
form via a single-value container. Embedded consumers use the
byte-stream `Serializer` instead.

## Embedded Swift

Version-primitives' own source follows the `[PKG-BUILD-007]`
source-guard discipline: every Embedded-incompatible surface
(`Codable`) is wrapped in `#if !hasFeature(Embedded)`. The package
imports no Foundation per `[PRIM-FOUND-001]` and uses no
`_Concurrency` features. Building under
`-Xswiftc -enable-experimental-feature -Xswiftc Embedded` is
currently blocked by transitive dependencies that ship
`@TaskLocal` without Embedded guards; once those dependencies
adopt the source-guard pattern, the package itself is ready.

## Spec compliance

Implements the spec at https://semver.org/. Every parser-time
validation rule maps to a `Version.Semantic.Error` case:

- §2 (version-core integers, no leading zeros)
- §9 (pre-release identifier character class, no leading zeros in
  numeric identifiers, non-empty)
- §10 (build-metadata identifier character class, non-empty,
  excluded from precedence)
- §11 (precedence: numeric < alphanumeric pre-release; pre-release <
  release; left-to-right identifier comparison with shorter-wins on
  common prefix)

The package mirrors the validation surface of
`swiftlang/swift-package-manager`'s `PackageDescription.Version`
and `swift-tools-support-core`'s `TSCUtility.Version` — both
implement the same spec — without depending on either.

## Foundation-clean

Foundation-clean per `[PRIM-FOUND-001]`. Uses Swift
standard-library types and the institute ASCII / Parser /
Serializer primitives — never `Foundation.Data`, `Date`, etc.

## Ecosystem integration

| Dependency | Use |
|------------|-----|
| `swift-ascii-primitives` | `ASCII.Classification` predicates drive identifier character-class checks (`isAlphanumeric`, `isDigit`); `ASCII.Serialization.serializeDecimal` writes MAJOR/MINOR/PATCH bytes. No hand-rolled byte arithmetic. |
| `swift-ascii-parser-primitives` | `ASCII.Decimal.Parser` consumes each numeric component inside `Version.Semantic.Parser`'s body — leveraging the canonical decimal parser with overflow checking. |
| `swift-carrier-primitives` | `Version.Semantic` conforms to `Carrier.Protocol` as a trivial self-carrier — `Underlying = Self`. Lets the type participate in `Carrier.Protocol`-bound generic code (registry encoders, hashing pipelines, transport bridges) without wrap/unwrap ceremony. |
| `swift-parser-primitives` | `Version.Semantic.Parser` conforms to `Parser_Primitives.Parser.Protocol<Input, Version.Semantic, Version.Semantic.Error>` over `UInt8` byte streams. The Parser is the canonical source of SemVer validation — `init(parsing:)` is a thin String adapter that runs it and asserts the input is exhausted. |
| `swift-serializer-primitives` | `Version.Semantic.Serializer` conforms to `Serializer_Primitives.Serializer.Protocol<Version.Semantic, Buffer, Never>`. Single source of truth for canonical formatting — `description` delegates to this Serializer for Parser/Serializer round-trip symmetry. |
| `swift-tagged-primitives` | All component `.Value` typealiases (`Semantic.Major.Value`, `Tools.Patch.Value`, `Calendar.Year.Value`, etc.) are `Tagged<_, Swift.UInt>`. The phantom tags give each component a distinct type so positional swaps are caught at compile time — `Version.Semantic(major: 1, minor: 2, patch: 3)` still reads naturally via `ExpressibleByIntegerLiteral`. |
| `swift-text-primitives` | `Text.Range` powers the `range:` field carried on every `Error` case — byte-offset spans within the parsed input for IDE / tooling consumers. |
| `swift-ordinal-primitives` | `Ordinal` is the underlying carrier of `Text.Position`; used internally to construct byte-offset positions for error ranges. |
| `swift-time-primitives` | `Time.Year` and `Time.Month` are the typed YEAR and MONTH components of `Version.Calendar` — `Time.Month`'s 1–12 refinement constraint rejects impossible months at parse time. |

## Design

- Research: `swift-institute/Research/2026-05-12-swift-package-and-version-primitives-design.md` v1.0.0 RECOMMENDATION
- Framework: `swift-institute/Research/2026-05-12-typed-identifier-naming-framework.md` v1.0.0 RECOMMENDATION

## License

Apache 2.0 — see `LICENSE.md`.
