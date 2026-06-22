// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-version-primitives open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-version-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Array_Primitives
public import Byte_Parser_Primitives
public import Parser_Primitives
public import Shared_Primitive
public import Buffer_Linear_Primitive
public import Buffer_Linear_Primitives

extension Version.Calendar: Parseable {
    /// Pin the `Parseable.Parser` associatedtype to the canonical
    /// CalVer byte-stream parser instantiation.
    ///
    /// Uses `@_implements(Parseable, Parser)` to bind the
    /// protocol's `Parser` associated type to a differently-named
    /// typealias (`_ParseableParser`). Without `@_implements` the
    /// existing nested generic ``Version/Calendar/Parser`` collides
    /// with the protocol's `Parser` associated-type-name slot at
    /// synthesis time ("invalid redeclaration of synthesized
    /// implementation for protocol requirement 'Parser'"), because
    /// the nested type is generic over `Input` and cannot bind to
    /// `Parseable.Parser` as a single concrete witness.
    ///
    /// `@_implements(Protocol, Name)` is a `BASELINE_LANGUAGE_FEATURE`
    /// in the Swift compiler — always-on, stable in practice though
    /// underscored. Documented in
    /// `swift-institute/Blog/Published/2026-04-20-associated-type-trap.md`
    /// for the parallel `Body`-associated-type case in HTML rendering;
    /// adopted here for the Parser case in version-primitives.
    /// Empirically validated by
    /// `swift-institute/Experiments/parseable-associatedtype-implements/`
    /// (2026-05-14).
    @_implements(Parseable, Parser)
    public typealias _ParseableParser = Version_Primitives.Version.Calendar.Parser<Byte.Input>

    /// The canonical CalVer byte-stream parser instance.
    ///
    /// Conforming to ``Parseable`` from `swift-parser-primitives`
    /// declares ``Version/Calendar/Parser`` (instantiated over
    /// `Byte.Input`) as the type's
    /// canonical parser, which enables generic parser-discovery
    /// algorithms over `Parseable` types AND surfaces the free
    /// `init(ascii:)` initializer from `Parseable`'s byte-input
    /// extension:
    ///
    /// ```swift
    /// let version = try Version.Calendar(ascii: Swift.Array("2026.05.14".utf8))
    /// ```
    ///
    /// `init(ascii:)` does NOT assert input exhaustion — the parser
    /// is greedy over the CalVer character class and stops at the
    /// first non-matching byte; trailing bytes are silently dropped.
    /// For one-shot string parsing with non-ASCII detection AND
    /// trailing-bytes assertion baked in, use ``init(parsing:)`` —
    /// the String adapter — instead.
    @inlinable
    public static var parser: _ParseableParser { _ParseableParser() }
}
