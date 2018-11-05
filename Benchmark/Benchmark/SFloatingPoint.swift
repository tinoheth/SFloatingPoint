public protocol NumberContainer: Comparable, Numeric {
	associatedtype Wrapped: Numeric & Comparable
	var value: Wrapped { get }
	init?(_: Wrapped)
	init(integerLiteral value: Int)
}

public struct SFloatingPoint<F: FloatingPoint>: NumberContainer, SignedNumeric, Strideable, ExpressibleByFloatLiteral, CustomStringConvertible where F: _ExpressibleByBuiltinFloatLiteral, F.Stride == F {
	public typealias Exponent = F
	public typealias Stride = SFloatingPoint<F>
	public typealias IntegerLiteralType = Int

//	public static func / (lhs: SFloatingPoint<F>, rhs: SFloatingPoint<F>) -> SFloatingPoint<F> {
//		return (lhs / rhs)!
//	}
//
	fileprivate(set) public var value: F

	public var description: String {
		return "S\(F.self) (\(value))"
	}

	public var magnitude: SFloatingPoint<F> {
		return self
	}

	static func limit(_ value: F) -> F {
		return max(min(value, F.greatestFiniteMagnitude), -F.greatestFiniteMagnitude)
	}

	public init?<T>(exactly source: T) where T : BinaryInteger {
		guard let value = F(exactly: source), value.isFinite else {
			return nil
		}
		self.value = value
	}

	public init(integerLiteral value: Int) {
		self.value = F(value)
	}

	public init(floatLiteral value: F) {
		self.value = SFloatingPoint.limit(value)
	}

	public init?(_ value: F) {
		guard !value.isNaN else {
			return nil
		}
		self.init(value: value)
	}

	public func distance(to other: SFloatingPoint) -> SFloatingPoint {
		let dist = self.value.distance(to: other.value)
		return SFloatingPoint(value: dist)
	}

	public func advanced(by n: SFloatingPoint) -> SFloatingPoint<F> {
		return self + n
	}

	/// `value` should never be nan.
	fileprivate init(value: F) {
		self.value = SFloatingPoint.limit(value)
	}

	static public func == (lhs: SFloatingPoint, rhs: SFloatingPoint) -> Bool {
		return lhs.value == rhs.value
	}

	static public func < (lhs: SFloatingPoint, rhs: SFloatingPoint) -> Bool {
		return lhs.value < rhs.value
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

func abs<F: FloatingPoint>(_ value: SFloatingPoint<F>) -> SFloatingPoint<F> {
	return SFloatingPoint<F>(value: abs(value.value))
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

