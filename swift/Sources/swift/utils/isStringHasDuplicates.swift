func isStringHasDuplicates(string: String) -> Bool {
    let hasDuplicates = string.count != Set(string).count
    if hasDuplicates {
        return true
    } else {
        return false
    }
}
