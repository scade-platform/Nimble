import Cocoa

struct OutlineViewUpdater<Data: Sequence>
where Data.Element: Identifiable {
    /// Perform updates on the outline view based on the change in state.
    /// - NOTE: Calls to this method must be surrounded by
    ///  `NSOutlineView.beginUpdates` and `NSOutlineView.endUpdates`.
    ///  `OutlineViewDataSource.items` should be updated to the new state before calling this method.
    func performUpdates(
        outlineView: NSOutlineView,
        oldState: [OutlineViewItem<Data>]?,
        newState: [OutlineViewItem<Data>]?,
        parent: OutlineViewItem<Data>?
    ) {
        let oldNonOptionalState = oldState ?? []
        let newNonOptionalState = newState ?? []

        guard oldState != nil || newState != nil else {
            return
        }

        let diff = newNonOptionalState.difference(
            from: oldNonOptionalState, by: { $0.value.id == $1.value.id })

        if !diff.isEmpty || oldState != newState {
            // Parent needs to be update as the children have changed.
            // Children are not reloaded to allow animation.
            outlineView.reloadItem(parent, reloadChildren: false)
        }

        var removedElements = [OutlineViewItem<Data>]()

        for change in diff {
            switch change {
            case .insert(offset: let offset, _, _):
                outlineView.insertItems(
                    at: IndexSet([offset]),
                    inParent: parent,
                    withAnimation: .effectFade)

            case .remove(offset: let offset, element: let element, _):
                removedElements.append(element)
                outlineView.removeItems(
                    at: IndexSet([offset]),
                    inParent: parent,
                    withAnimation: .effectFade)
            }
        }

        var oldUnchangedElements = oldNonOptionalState.dictionaryFromIdentity()
        removedElements.forEach { oldUnchangedElements.removeValue(forKey: $0.id) }

        let newStateDict = newNonOptionalState.dictionaryFromIdentity()

        oldUnchangedElements
            .keys
            .map { (oldUnchangedElements[$0].unsafelyUnwrapped, newStateDict[$0].unsafelyUnwrapped) }
            .map { (outlineView, $0.0.children, $0.1.children, $0.1) }
            .forEach(performUpdates)
    }
}

fileprivate extension Sequence where Element: Identifiable {
    func dictionaryFromIdentity() -> [Element.ID: Element] {
        Dictionary(map { ($0.id, $0) }, uniquingKeysWith: { _, latest in latest })
    }
}
