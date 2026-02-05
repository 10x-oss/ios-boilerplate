import CoreGraphics

// MARK: - CGPoint Extensions

extension CGPoint {
    // MARK: - Arithmetic Operations

    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
        CGPoint(x: point.x * scalar, y: point.y * scalar)
    }

    static func * (scalar: CGFloat, point: CGPoint) -> CGPoint {
        point * scalar
    }

    static func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
        CGPoint(x: point.x / scalar, y: point.y / scalar)
    }

    static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs - rhs
    }

    static func *= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs * rhs
    }

    static func /= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs / rhs
    }

    // MARK: - Distance Calculations

    /// Calculate the distance to another point
    func distance(to other: CGPoint) -> CGFloat {
        sqrt(pow(x - other.x, 2) + pow(y - other.y, 2))
    }

    /// Calculate the squared distance to another point (faster than distance)
    func distanceSquared(to other: CGPoint) -> CGFloat {
        pow(x - other.x, 2) + pow(y - other.y, 2)
    }

    /// Distance from origin (0, 0)
    var magnitude: CGFloat {
        sqrt(x * x + y * y)
    }

    /// Squared distance from origin (faster than magnitude)
    var magnitudeSquared: CGFloat {
        x * x + y * y
    }

    // MARK: - Normalization

    /// Return a normalized (unit) vector
    var normalized: CGPoint {
        let mag = magnitude
        guard mag > 0 else { return .zero }
        return self / mag
    }

    // MARK: - Midpoint

    /// Calculate the midpoint between this point and another
    func midpoint(to other: CGPoint) -> CGPoint {
        CGPoint(x: (x + other.x) / 2, y: (y + other.y) / 2)
    }

    // MARK: - Angle

    /// Angle from origin in radians
    var angle: CGFloat {
        atan2(y, x)
    }

    /// Angle to another point in radians
    func angle(to other: CGPoint) -> CGFloat {
        (other - self).angle
    }

    // MARK: - Rotation

    /// Rotate the point around origin by angle in radians
    func rotated(by angle: CGFloat) -> CGPoint {
        CGPoint(
            x: x * cos(angle) - y * sin(angle),
            y: x * sin(angle) + y * cos(angle)
        )
    }

    /// Rotate the point around a center point by angle in radians
    func rotated(by angle: CGFloat, around center: CGPoint) -> CGPoint {
        let translated = self - center
        let rotated = translated.rotated(by: angle)
        return rotated + center
    }

    // MARK: - Clamping

    /// Clamp the point within a rectangle
    func clamped(to rect: CGRect) -> CGPoint {
        CGPoint(
            x: min(max(x, rect.minX), rect.maxX),
            y: min(max(y, rect.minY), rect.maxY)
        )
    }

    // MARK: - Lerp (Linear Interpolation)

    /// Linearly interpolate between this point and another
    func lerp(to other: CGPoint, t: CGFloat) -> CGPoint {
        CGPoint(
            x: x + (other.x - x) * t,
            y: y + (other.y - y) * t
        )
    }
}

// MARK: - CGPoint Hashable

extension CGPoint: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

// MARK: - CGSize Extensions

extension CGSize {
    // MARK: - Arithmetic Operations

    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    static func * (size: CGSize, scalar: CGFloat) -> CGSize {
        CGSize(width: size.width * scalar, height: size.height * scalar)
    }

    static func / (size: CGSize, scalar: CGFloat) -> CGSize {
        CGSize(width: size.width / scalar, height: size.height / scalar)
    }

    // MARK: - Properties

    /// The aspect ratio (width / height)
    var aspectRatio: CGFloat {
        guard height > 0 else { return 0 }
        return width / height
    }

    /// The area of the size
    var area: CGFloat {
        width * height
    }

    /// Convert to CGPoint
    var asPoint: CGPoint {
        CGPoint(x: width, y: height)
    }

    // MARK: - Scaling

    /// Scale to fit within a maximum size while maintaining aspect ratio
    func scaledToFit(in maxSize: CGSize) -> CGSize {
        let widthRatio = maxSize.width / width
        let heightRatio = maxSize.height / height
        let scale = min(widthRatio, heightRatio)
        return self * scale
    }

    /// Scale to fill a minimum size while maintaining aspect ratio
    func scaledToFill(in minSize: CGSize) -> CGSize {
        let widthRatio = minSize.width / width
        let heightRatio = minSize.height / height
        let scale = max(widthRatio, heightRatio)
        return self * scale
    }
}

// MARK: - CGSize Hashable

extension CGSize: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }
}
