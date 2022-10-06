/// Mangle a string by offsetting the numeric value of each character by `-1`.
/// Useful for computing a mangled version of the objc private API strings to evade static detection of private API use.
func mangle(_ string: String) -> String {
    String(string.utf16.map { $0 - 1 }.compactMap(UnicodeScalar.init).map(Character.init))
}

/// Unmangle a string by offsetting the numeric value of each character by `+1`.
/// Useful for unmangling a mangled version of the objc private API strings to evade static detection of private API use.
func unmangle(_ string: String) -> String {
    String(string.utf16.map { $0 + 1 }.compactMap(UnicodeScalar.init).map(Character.init))
}
