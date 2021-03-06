when not defined(cpp):
  import std/[macros]
  static:
    error "This library needs to be compiled with the cpp backend."

import std/[strformat]

{.push header: "<vector>".}

# https://forum.nim-lang.org/t/3401
type
  Vector*[T] {.importcpp: "std::vector".} = object
  # https://nim-lang.github.io/Nim/manual.html#importcpp-pragma-importcpp-for-objects
  VectorIter*[T] {.importcpp: "std::vector<'0>::iterator".} = object
  VectorConstIter*[T] {.importcpp: "std::vector<'0>::const_iterator".} = object

# https://nim-lang.github.io/Nim/manual.html#importcpp-pragma-importcpp-for-procs
proc newVector*[T](): Vector[T] {.importcpp: "std::vector<'*0>()", constructor.}
# https://github.com/numforge/agent-smith/blob/a2d9251e/third_party/std_cpp.nim#L23-L31
proc newVector*[T](size: int): Vector[T] {.importcpp: "std::vector<'*0>(#)", constructor.}

# http://www.cplusplus.com/reference/vector/vector/size/
proc size*(v: Vector): int {.importcpp: "#.size()".}
proc len*(v: Vector): int {.importcpp: "#.size()".}

# https://en.cppreference.com/w/cpp/container/vector/empty
proc empty*(v: Vector): bool {.importcpp: "empty".}

# https://github.com/nim-lang/Nim/issues/9685#issue-379682147
# http://www.cplusplus.com/reference/vector/vector/push_back/
proc pushBack*[T](v: var Vector[T]; elem: T) {.importcpp: "#.push_back(#)".}
proc add*[T](v: var Vector[T], elem: T){.importcpp: "#.push_back(#)".}
# http://www.cplusplus.com/reference/vector/vector/pop_back/
proc popBack*[T](v: var Vector[T]) {.importcpp: "pop_back".}

# https://en.cppreference.com/w/cpp/container/vector/front
proc front*[T](v: Vector[T]): T {.importcpp: "front".}
proc first*[T](v: Vector[T]): T {.importcpp: "front".}

# http://www.cplusplus.com/reference/vector/vector/back/
proc back*[T](v: Vector[T]): T {.importcpp: "back".}
proc last*[T](v: Vector[T]): T {.importcpp: "back".}

# http://www.cplusplus.com/reference/vector/vector/begin/
proc begin*[T](v: Vector[T]): VectorIter[T] {.importcpp: "begin".}
proc cBegin*[T](v: Vector[T]): VectorConstIter[T] {.importcpp: "cbegin".}

# http://www.cplusplus.com/reference/vector/vector/end/
proc `end`*[T](v: Vector[T]): VectorIter[T] {.importcpp: "end".}
proc cEnd*[T](v: Vector[T]): VectorConstIter[T] {.importcpp: "cend".}

# https://github.com/numforge/agent-smith/blob/a2d9251e/third_party/std_cpp.nim#L23-L31
proc `[]`*[T](v: Vector[T], idx: int): T {.importcpp: "#[#]".}
proc `[]`*[T](v: var Vector[T], idx: int): var T {.importcpp: "#[#]".}

# https://en.cppreference.com/w/cpp/container/vector/assign
proc assign*[T](v: var Vector[T], idx: int, val: T) {.importcpp: "#.assign(@)".}

# https://github.com/BigEpsilon/nim-cppstl/blob/de045c27dbbcf193081de5ea2b62f50751bf24fc/src/cppstl/vector.nim#L171
# Relational operators
proc `==`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# == #".}
proc `!=`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# != #".}
proc `<`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# < #".}
proc `<=`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# <= #".}
proc `>`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# > #".}
proc `>=`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# >= #".}

# Converter: VecIterator -> VecConstIterator
converter VectorIterToVectorConstIter*[T](x: VectorIter[T]): VectorConstIter[T] {.importcpp: "#".}

proc insert*[T](v: var Vector[T], pos: VectorConstIter[T], val: T): VectorIter[T] {.importcpp: "insert".}
  ## Inserts ``val`` before ``pos``.

proc insert*[T](v: var Vector[T], pos: VectorConstIter[T], count: int, val: T): VectorIter[T] {.importcpp: "insert".}
  ## Inserts ``count`` copies of ``val`` before ``pos``.

proc insert*[T](v: var Vector[T], pos, first, last: VectorConstIter[T]): VectorIter[T] {.importcpp: "insert".}
  ## Inserts elements from range ``first`` ..< ``last`` before ``pos``.

# https://github.com/BigEpsilon/nim-cppstl/blob/master/src/cppstl/private/utils.nim
# Iterator Arithmetic
proc `+`*[T: VectorIter|VectorConstIter](iter: T, offset: int): T {.importcpp: "# + #"}
proc `-`*[T: VectorIter|VectorConstIter](iter: T, offset: int): T {.importcpp: "# - #"}

{.pop.} # {.push header: "<vector>".}


proc `[]=`*[T](v: var Vector[T], idx: int, val: T) {.inline.} =
  # v[idx] = val # <-- This will not work because that will result in recursive calls of `[]=`.
  # So first get the elem using `[]`, then get its addr and then deref it.
  (unsafeAddr v[idx])[] = val

# Iterators
iterator items*[T](v: Vector[T]): T=
  for idx in 0 ..< v.len():
    yield v[idx]

iterator pairs*[T](v: Vector[T]): (int, T) =
  for idx in 0 ..< v.len():
    yield (idx, v[idx])

# To and from seq
proc toSeq*[T](v: Vector[T]): seq[T] =
  ## Convert a Vector to a sequence.
  for elem in v:
    result.add(elem)

proc toVector*[T](s: openArray[T]): Vector[T] =
  ## Convert an array/sequence to a Vector.
  for elem in s:
    result.add(elem)

# Display the content of a Vector
# https://github.com/BigEpsilon/nim-cppstl/blob/de045c27dbbcf193081de5ea2b62f50751bf24fc/src/cppstl/vector.nim#L197
proc `$`*[T](v: Vector[T]): string {.noinit.} =
  if v.empty():
    result = "v[]"
  else:
    result = "v["
    for idx in 0 ..< v.size()-1:
      result.add($v[idx] & ", ")
    result.add($v.last() & "]")

when isMainModule:
  import std/[unittest, sequtils]

  suite "constructor, size/len, empty":
    setup:
      var
        v1 = newVector[int]()
        v2 = newVector[int](10)

    test "size/len":
      check v1.size() == 0
      check v2.len() == 10

    test "empty":
      check v1.empty() == true
      check v2.empty() == false

  suite "push, pop":
    setup:
      var
        v = newVector[int]()

    test "push/add, pop, front/first, back/last":
      v.pushBack(100)
      check v.size() == 1

      v.add(200)
      check v.size() == 2

      v.popBack()
      check v.size() == 1

      v.add(300)
      v.add(400)
      v.add(500)

      for idx in 0 ..< v.len():
        echo &"  v[{idx}] = {v[idx]}"

      check v.size() == 4

      check v.first() == 100
      check v.front() == 100

      check v.last() == 500
      check v.back() == 500

  suite "iterators, $":
    setup:
      var
        v = newVector[cstring]()

      v.add("hi")
      v.add("there")
      v.add("bye")

      echo "Testing items iterator:"
      for elem in v:
        echo &" {elem}"
      echo ""

      echo "Testing pairs iterator:"
      for idx, elem in v:
        echo &" v[{idx}] = {elem}"

    test "$":
      check $v == "v[hi, there, bye]"

  suite "converting to/from a Vector/mutable sequence":
    setup:
      var
        s = @[1.1, 2.2, 3.3, 4.4, 5.5]
        v: Vector[float]

    test "mut seq -> mut Vector -> mut seq":
      v = s.toVector()
      check v.toSeq() == s


  suite "converting from an immutable sequence":
    setup:
      let
        s = @[1.1, 2.2, 3.3, 4.4, 5.5]
      var
        v: Vector[float]

    test "immut seq -> mut Vector -> mut seq":
      v = s.toVector()
      check v.toSeq() == s

  suite "converting array -> Vector -> sequence":
    setup:
      let
        a = [1.1, 2.2, 3.3, 4.4, 5.5]
        v = a.toVector()
        s = a.toSeq()

    test "immut array -> immut vector -> immut seq":
      check v.toSeq() == s

  suite "assign":
    setup:
      var
        v: Vector[char]

    test "assign":
      check v.len() == 0

      v.assign(4, '.')
      check v.toSeq() == @['.', '.', '.', '.']

  suite "set an element value":
    setup:
      var
        v = newVector[int](5)

    test "[]=":
      v[1] = 100
      v[3] = 300
      check v.toSeq() == @[0, 100, 0, 300, 0]

  suite "relational operators":
    setup:
      let
        v1 = @[1, 2, 3].toVector()

    test "==, <=, >=":
      let
        v2 = v1
      check v1 == v2
      check v1 <= v2
      check v1 >= v2

    test ">, >=":
      let
        v2 = @[1, 2, 4].toVector()
      check v2 > v1
      check v2 >= v1

    test ">, unequal vector lengths":
      let
        v2 = @[1, 2, 4].toVector()
        v3 = @[1, 2, 3, 0].toVector()
      check v3 > v1
      check v2 > v3

    test "<, <=":
      let
        v2 = @[1, 2, 4].toVector()
      check v1 < v2
      check v1 <= v2

    test "<, unequal vector lengths":
      let
        v2 = @[1, 2, 4].toVector()
        v3 = @[1, 2, 3, 0].toVector()
      check v1 < v3
      check v3 < v2

  suite "(c)begin, (c)end, insert":
    setup:
      var
        v = @[1, 2, 3].toVector()

    test "insert elem at the beginning":
      discard v.insert(v.cBegin(), 9)
      check v == @[9, 1, 2, 3].toVector()

      # Below, using .begin() instead of .cBegin() also
      # works.. because of the VectorIterToVectorConstIter converter.
      discard v.insert(v.begin(), 10)
      check v == @[10, 9, 1, 2, 3].toVector()

    test "insert elem at the end":
      discard v.insert(v.cEnd(), 9)
      check v == @[1, 2, 3, 9].toVector()

      # Below, using .`end`() instead of .cEnd() also
      # works.. because of the VectorIterToVectorConstIter converter.
      discard v.insert(v.`end`(), 10)
      check v == @[1, 2, 3, 9, 10].toVector()

    test "insert copies of a val":
      discard v.insert(v.cEnd(), 3, 111)
      check v == @[1, 2, 3, 111, 111, 111].toVector()

    test "insert elements from a Vector range":
      # Below copies the whole vector and appends to itself at the end.
      discard v.insert(v.cEnd(), v.cBegin(), v.cEnd())
      check v == @[1, 2, 3, 1, 2, 3].toVector()

      # Below is a long-winded way to copy one Vector to another.
      var
        v2: Vector[int]
      discard v2.insert(v2.cEnd(), v.cBegin(), v.cEnd())
      check v2 == v

  suite "iterator arithmetic":
    setup:
      var
        v = @[1, 2, 3].toVector()

    test "insert elem after the first element":
      discard v.insert(v.cBegin()+1, 9)
      check v == @[1, 9, 2, 3].toVector()

    test "insert elem before the last element":
      discard v.insert(v.cEnd()-1, 9)
      check v == @[1, 2, 9, 3].toVector()
