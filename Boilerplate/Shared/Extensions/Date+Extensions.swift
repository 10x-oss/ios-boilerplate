import Foundation

// MARK: - Date Extensions

extension Date {
    // MARK: - Relative Formatting

    /// Format date as relative string (e.g., "2 hours ago", "Yesterday")
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Format date as short relative string (e.g., "2h ago", "1d ago")
    var shortRelativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    // MARK: - Standard Formatting

    /// Format as "January 1, 2024"
    var longFormatted: String {
        formatted(date: .long, time: .omitted)
    }

    /// Format as "Jan 1, 2024"
    var mediumFormatted: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    /// Format as "1/1/24"
    var shortFormatted: String {
        formatted(date: .numeric, time: .omitted)
    }

    /// Format as "2:30 PM"
    var timeFormatted: String {
        formatted(date: .omitted, time: .shortened)
    }

    /// Format as "Jan 1, 2024 at 2:30 PM"
    var dateTimeFormatted: String {
        formatted(date: .abbreviated, time: .shortened)
    }

    // MARK: - Custom Formatting

    /// Format with a custom format string
    func formatted(with format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    // MARK: - Date Components

    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Check if date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Check if date is tomorrow
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    /// Check if date is in the past
    var isPast: Bool {
        self < Date()
    }

    /// Check if date is in the future
    var isFuture: Bool {
        self > Date()
    }

    /// Check if date is in the current week
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    /// Check if date is in the current month
    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }

    /// Check if date is in the current year
    var isThisYear: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }

    // MARK: - Component Extraction

    /// Get the year component
    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    /// Get the month component (1-12)
    var month: Int {
        Calendar.current.component(.month, from: self)
    }

    /// Get the day component (1-31)
    var day: Int {
        Calendar.current.component(.day, from: self)
    }

    /// Get the hour component (0-23)
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }

    /// Get the minute component (0-59)
    var minute: Int {
        Calendar.current.component(.minute, from: self)
    }

    /// Get the weekday (1 = Sunday, 7 = Saturday)
    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }

    // MARK: - Date Manipulation

    /// Start of the day (midnight)
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// End of the day (23:59:59)
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    /// Add days to the date
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self)!
    }

    /// Add weeks to the date
    func adding(weeks: Int) -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self)!
    }

    /// Add months to the date
    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self)!
    }

    /// Add years to the date
    func adding(years: Int) -> Date {
        Calendar.current.date(byAdding: .year, value: years, to: self)!
    }

    // MARK: - Comparisons

    /// Check if two dates are on the same day
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    /// Days between this date and another
    func days(to other: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startOfDay, to: other.startOfDay)
        return components.day ?? 0
    }
}

// MARK: - TimeInterval Extensions

extension TimeInterval {
    /// Format as "1:30:45" or "30:45"
    var formattedDuration: String {
        let hours = Int(self) / 3600
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    /// Format as human readable string (e.g., "2 hours, 30 minutes")
    var humanReadable: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        return formatter.string(from: self) ?? ""
    }

    /// Common time intervals
    static let minute: TimeInterval = 60
    static let hour: TimeInterval = 60 * 60
    static let day: TimeInterval = 60 * 60 * 24
    static let week: TimeInterval = 60 * 60 * 24 * 7
}
