public protocol NumberContainer: Comparable, Numeric {
	associatedtype Wrapped: Numeric & Comparable
	var value: Wrapped { get }
	init?(_: Wrapped)
	init(integerLiteral value: Int)
}

public func < <T: NumberContainer>(lhs: T, rhs: T) -> Bool {
	return lhs.value < rhs.value
}

public struct SFloatingPoint<F: FloatingPoint>: NumberContainer, CustomStringConvertible where F: ExpressibleByFloatLiteral {
	public typealias IntegerLiteralType = Int
	public typealias FloatLiteralType = F

	fileprivate(set) public var value: FloatLiteralType

	public var description: String {
		return "S\(F.self) (\(value))"
	}
	public var magnitude: SFloatingPoint<FloatLiteralType> {
		return self
	}

	static func limit(_ value: FloatLiteralType) -> FloatLiteralType {
		return max(min(value, F.greatestFiniteMagnitude), -F.greatestFiniteMagnitude)
	}

	public init?<T>(exactly source: T) where T : BinaryInteger {
		guard let value = FloatLiteralType(exactly: source), value.isFinite else {
			return nil
		}
		self.value = value
	}

	public init(integerLiteral value: Int) {
		self.value = FloatLiteralType(value)
	}

	public init(floatLiteral value: FloatLiteralType) {
		self.value = SFloatingPoint.limit(value)
	}

	public init?(_ value: F) {
		guard !value.isNaN else {
			return nil
		}
		self.init(value: value)
	}

	/// `value` should never be nan.
	private init(value: F) {
		self.value = SFloatingPoint.limit(value)
	}

	static public func + (lhs: SFloatingPoint, rhs: SFloatingPoint) -> SFloatingPoint {
		return SFloatingPoint(value: lhs.value + rhs.value)
	}

	static public func += (lhs: inout SFloatingPoint, rhs: SFloatingPoint) {
		lhs.value = SFloatingPoint.limit(lhs.value + rhs.value)
	}

	static public func - (lhs: SFloatingPoint, rhs: SFloatingPoint) -> SFloatingPoint {
		return SFloatingPoint(value: lhs.value - rhs.value)
	}

	static public func -= (lhs: inout SFloatingPoint, rhs: SFloatingPoint) {
		lhs.value = SFloatingPoint.limit(lhs.value - rhs.value)
	}

	static public func * (lhs: SFloatingPoint, rhs: SFloatingPoint) -> SFloatingPoint {
		return SFloatingPoint(value: lhs.value * rhs.value)
	}

	static public func *= (lhs: inout SFloatingPoint, rhs: SFloatingPoint) {
		lhs.value = SFloatingPoint.limit(lhs.value * rhs.value)
	}

	static public func / (lhs: SFloatingPoint, rhs: SFloatingPoint) -> SFloatingPoint? {
		return SFloatingPoint(lhs.value / rhs.value)
	}

	static public prefix func -(value: SFloatingPoint) -> SFloatingPoint {
		return SFloatingPoint(value: -value.value)
	}

	public func squareRoot() -> SFloatingPoint? {
		return SFloatingPoint(value.squareRoot())
	}
}

extension Optional: ExpressibleByIntegerLiteral where Wrapped: NumberContainer {
	public typealias IntegerLiteralType = Int

	public init(integerLiteral value: Int) {
		self = .some(Wrapped(integerLiteral: value))
	}
}

extension Optional: Comparable, Numeric, CustomStringConvertible where Wrapped: NumberContainer {
	public init?<T>(exactly source: T) where T : BinaryInteger {
		self = Wrapped(exactly: source)
	}

	public var magnitude: Wrapped? {
		return self
	}

	public typealias Magnitude = Wrapped?

	public var description: String {
		return self.map {
			return "S\(Wrapped.Wrapped.self)? (\($0.value))"
		} ?? "SFloatingPoint nil"
	}

	public static func < <T: NumberContainer>(lhs: T?, rhs: T?) -> Bool {
		guard let l = lhs?.value else {
			return false
		}
		guard let r = rhs?.value else {
			return true
		}
		return l < r
	}

	public static func -= (lhs: inout Optional<Wrapped>, rhs: Optional<Wrapped>) {
		lhs = lhs - rhs
	}

	public static func += (lhs: inout Optional<Wrapped>, rhs: Optional<Wrapped>) {
		lhs = lhs + rhs
	}

	public static func *= (lhs: inout Optional<Wrapped>, rhs: Optional<Wrapped>) {
		lhs = lhs * rhs
	}
}

public func + <T: NumberContainer>(lhs: T?, rhs: T?) -> T? {
	guard let l = lhs?.value, let r = rhs?.value else {
		return nil
	}
	return T(l + r)
}

public func - <T: NumberContainer>(lhs: T?, rhs: T?) -> T? {
	guard let l = lhs?.value, let r = rhs?.value else {
		return nil
	}
	return T(l + r)
}


public func * <T: NumberContainer>(lhs: T?, rhs: T?) -> T? {
	guard let l = lhs?.value, let r = rhs?.value else {
		return nil
	}
	return T(l * r)
}

public func / <T: NumberContainer>(lhs: T?, rhs: T?) -> T? where T.Wrapped: FloatingPoint {
	guard let l = lhs?.value, let r = rhs?.value else {
		return nil
	}
	return T(l / r)
}

public typealias SDouble = SFloatingPoint<Double>
public typealias SFloat = SFloatingPoint<Float>

let x: SDouble = 5
let y = x * x
let z = x / x
let yy = y + y
let c = y - z / yy
let zz: SDouble? = z + z
print(x, y, z as Any, yy, zz as Any, separator: "\n")
print(z == 1)

let a = -25 as SFloat
let f: Float = -a.value

a.squareRoot()

a < 4
