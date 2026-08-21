public import Array_Primitives
public import Buffer_Linear_Primitive
public import Buffer_Linear_Primitives
public import Byte_Parser_Primitives
public import Ownership_Shared_Primitive
internal import Parser_Primitives

extension Version.Calendar: Parseable {

    @_implements(Parseable,Parser)
    public typealias _ParseableParser = Version_Primitives.Version.Calendar.Parser<Byte.Input>

    @inlinable
    public static var parser: _ParseableParser { _ParseableParser() }
}
