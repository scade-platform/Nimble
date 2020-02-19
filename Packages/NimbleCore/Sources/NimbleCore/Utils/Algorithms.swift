public struct Algorithms {

  // C3 linearization algorithm
  // https://en.wikipedia.org/wiki/C3_linearization
  public static func c3Merge<Element>(_ items: [ArraySlice<Element>]) -> [Element] where Element : Equatable {
    return merge(slices: items, acc: [])
  }

  fileprivate static func merge<Element>(slices: [ArraySlice<Element>], acc: [Element]) ->
    [Element] where Element : Equatable {

    var checkedItems: [Element] = []

    for slice in slices {
      guard let item = slice.first else { continue }

      if checkedItems.contains(item) { continue }

      let nextSlices = slices.map { $0.dropFirst(1) }

      if notContains(item: item, slices: nextSlices) {
        return merge(slices: slices.map {
                       if let sliceFirstItem = $0.first, sliceFirstItem == item {
                         return $0.dropFirst(1)
                       }
                       return $0
                     }, acc: acc + [item])
      }

      checkedItems.append(item)
    }

    return checkedItems.count <= 1 ? (acc + checkedItems) : []
  }

  fileprivate static func notContains<Element>(item: Element, slices: [ArraySlice<Element>]) ->
    Bool where Element : Equatable {

    return slices.allSatisfy { !$0.contains(item) }
  }
}
