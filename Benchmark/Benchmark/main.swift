import Foundation

func sqrtWithFloat(x: Double, accuracy: Double = 0.005) -> Double? {
	guard accuracy > 0 else {
		return nil
	}
	var result: Double = 1

	while abs(result * result - x) > accuracy {
		result = (result + (x / result)) / 2
	}

	return result;
}

func sqrtWithSFloat(x: SDouble, accuracy: SDouble = 0.005) -> SDouble? {
	guard accuracy > 0 else {
		return nil
	}
	var result: SDouble? = 1

	while let check = result, abs(check * check - x) > accuracy {
		result = (check + (x / check)) / 2
	}

	return result;
}

let t0 = CFAbsoluteTimeGetCurrent()
var sSum = 0 as SDouble
for x in stride(from: 1 as SDouble, to: 1000000 as SDouble, by: 2) {
	sSum += sqrtWithSFloat(x: x) ?? 0
}
let t1 = CFAbsoluteTimeGetCurrent()
var sum = 0 as Double
for x in stride(from: 1 as Double, to: 1000000 as Double, by: 2) {
	sum += sqrtWithFloat(x: x) ?? 0
}
let t2 = CFAbsoluteTimeGetCurrent()

let d0 = t1 - t0
let d1 = t2 - t1
print("Native: \(d1)s; result = \(sum)")
print("New: \(d0)s; result = \(sSum)")
print("Slowdown: \(d0 / d1)")
