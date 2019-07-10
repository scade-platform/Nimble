#!/usr/bin/swift
// a comment
/* a block comment */noLongerAComment()
/*/ still just a block comment */noLongerAComment()
/**/thatWasATinyBlockComment()
/* block comments /* can be nested, */ like this! */noLongerAComment()

import Foo   // whitespace ok
import Foo.Submodule
import func Foo.Submodule.`func`
import func Control.Monad.>>=

// MARK: Conditional compilation / compiler directives

#if false // a comment
  This is not code.
#elseif false // a comment
  This isn't either.
#else // a comment
  thisIsCode() // a comment
#elseif os(macOS) || os(Linux) || foo_flag || arch(x86_64) && 1+2 && swift(>=4.2.6) //a comment
#endif
#sourceLocation(file: "foo", line: 123) // a comment
if #available(macOS 10.12, iOS 9.1.2, *) {}
#selector(MyClass.func)
#selector(getter: MyClass.func) #selector(setter: MyClass.func)
#keyPath(self.parent.name)
#colorLiteral(), #imageLiteral(), #fileLiteral()
#file, #line, #function, #dsohandle
__FILE__, __LINE__, __FUNCTION__, __DSO_HANDLE__

// MARK: Attributes

@available(
  macOS 1.2, macOSApplicationExtension 1.2, OSX, tvOS 1.4, iOS, watchOS,
  introduced, introduced: 1,
  deprecated, deprecated: 1,
  obsoleted, obsoleted: 1,
  message, message: "don't use this",
  renamed, renamed: "somethingElse",
  *, unavailable: no args)

@objc(thisIs:aSelector:) @objc(forgotAColon:afterThis)
@arbitraryAttr(with args)


// MARK: Builtins

x.dropFirst, x.dropFirst(3), x.dropFirst { /* no closure param */ }
x.contains, x.contains(y), x.contains { $0 == y }
autoreleasepool { }
withExtendedLifetime { /* requires an arg */ }
withExtendedLifetime(x) { }
Process.foo, Process.argc, Process.unsafeArgv, Foo.argc
obj+startIndex, obj.startIndex
func foo() -> Never { fatalError() }

// MARK: Types

func foo(
  builtin: Int, x: String, x: Sequence,
  optional: Int!, x: Int?, x: Int!?!,
  collection: Int, x: [Int], x: [Int: String], x: [Int: String: Invalid],
  tuple: (Int, [Int], [Int: String], [Int: String: Invalid]),
  boundGeneric: Any<Int, String, (Int, Never)>, differsFrom invalid: Int, String,
  function: Int -> Void, x: (Int) throws -> String, x: (@escaping (Int) throws -> Void) rethrows -> Int,
  writeback: inout Int,
  variadic: Int...,
  composition: Sequence & Collection, oldStyle: protocol<Sequence, Collection>,
  metatype: Foo.Type, x: Foo.Protocol
){}

// MARK: Type definitions

struct Foo { }
class Foo { }
class Foo: Bar { }
class Foo<T where T: Equatable>: Bar { }
class Foo<T>: Bar where T: Equatable { }
class `var` {}
class var x: Int

protocol Foo {
  associatedtype T: Equatable
  associatedtype T = Int
  associatedtype T: Equatable = Int
  func f<T: P3>(_: T) where T.A == Self.A, T.A: C // trailing comment still allows where to end
  func functionBodyNotAllowedHere<T>() throws -> Int {}
  init(norHere: Int) throws {}
}
protocol Foo: Equatable {}
protocol Foo: Equatable, Indexable {}
protocol Foo: class, Equatable {}
protocol SE0142 : Sequence where Iterator.Element == Int { associatedtype Foo }
protocol SE0142 {
  associatedtype Iterator : IteratorProtocol
  associatedtype SubSequence : Sequence where SubSequence.Iterator.Element == Iterator.Element
}
protocol Foo { init(x: Int) }
func bar() { /* this is valid */ }

enum Foo {
  case foo
  case foo, bar baz
  case foo,
  bar
  case foo(Int), bar(val: Int, labelNotAllowed val2: Int), baz(val: Int)
  indirect case foo
  case rawValue = 42, xx = "str", xx = true, xx = [too, complex], xx
}

typealias Foo = Bar
typealias Foo<T> = Bar<T, Int> // comment

// MARK: Extensions

extension T {}
extension String {}
extension Array: Equatable {}
extension Array where Element: Equatable, Foo == Int {}
extension Array: Equatable, Foo where Element: Equatable, Foo == Int {}

// MARK: Functions

func something(
  _ unlabeledArg: Int,
  label separateFromInternalName: Int,
  labelSameAsInternalName: Int
  missed: a comma,
  foo: bar,
){}
func foo() -> Int {}
func foo() throws -> (Int, String) {}
func foo() rethrows {}
func +++(arg: Int) {}
func `func`(arg: Int){}
func generic<T>(arg: Int){}
func ++<T>(arg: Int){}
func < <T>(arg: Int){}
func  <<T>(arg: Int){}
func <+<<T>(arg: Int){}

init(arg: Value) {}
init<T>(arg: Value) {}

func generic<A, B, C>() {}
func generic<OldStyle where T: Equatable>(arg: Int) throws -> Int {}
func generic<NewStyle>(arg: Int) throws -> Int where T: Equatable, T == Int {}

// MARK: Operators

x+y, x++y, x +++ y
x...y  // TODO: probably shouldn't be variable
x..<y
x<<.y  // not a dot operator
x?.y, x!.y

// old style
infix operator *.* { associativity left precedence 100 assignment }
// new style
infix operator *.* : AssignmentPrecedence { invalid }
precedencegroup ExamplePrecedence {
  higherThan: LogicalConjunctionPrecedence
  lowerThan: SomeOtherPrecedence
  associativity: left assignment: true
}

// MARK: Other expressions

compoundFunctionName(_:arg1:arg2:), #selector(foo(bar:))
functionCall(arg1: "stuff", labels notRecognized: "stuff")
let tuple = (arg1: "stuff", labels notRecognized: "stuff")
subscriptCall[arg1: "stuff", labels notRecognized: "stuff"]

foo(a ?  b : c)
foo(a ?, b : c)
foo(flag ? foo as Bar : nil)
foo(flag ? foo : nil, bar: nil)
foo(
  flag ?
  foo :
  nil,
  bar: nil
)
foo(
  flag
  ? foo
  : nil,
  bar: nil
)

0.1, -4_2.5, 6.022e23, 10E-5
-0x1.ap2_3, 0x31p-4
0b010, 0b1_0
0o1, 0o7_3
02, 3_456
0x4, 0xF_7
0x1p, 0x1p_2, 0x1.5pa, 0x1.1p+1f, 0x1pz, 0x1.5w
0x1.f, 0x1.property
-.5, .2f
1.-.5
0b_0_1, 0x_1p+3q
tuple.0, tuple.42
0b12.5, 0xG

"string \(interpolation)"
"string \(1 + foo(x: 4))"
"nested: \(1+"string"+2)"
print("nested: \(1+"string"+2)")

let SE0168 = """   illegal
        my, what a large…
    \(1 + foo(x: 4))
        …string you have!
    illegal"""

associatedtype, class, deinit, enum, extension, func, import, init, inout,
let, operator, $123, precedencegroup, protocol, struct, subscript, typealias,
var, fileprivate, internal, private, public, static, defer, if, guard, do,
repeat, else, for, in, while, return, break, continue, as?, fallthrough,
switch, case, default, where, catch, as, Any, false, is, nil, rethrows,
super, self, Self, throw, true, try, throws, nil
