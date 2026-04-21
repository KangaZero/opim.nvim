import Foundation

//INFO: There is also this way of formatting: https://stackoverflow.com/questions/50712354/converting-utc-date-time-to-local-date-time-in-ios
private func formatDateToLocaleTime(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.timeStyle = .medium
    return dateFormatter.string(from: date)
}

func debug(_ message: Any...) {
    let date = Date()
    let formattedDate = formatDateToLocaleTime(date: date)
    print("date: \(formattedDate)\n", message)
}
