import Foundation

struct Calculation {
    var target = 0
    var nums: [Int] = []
}

func isCalculationValid(calc: Calculation, withConcat: Bool = false) -> Bool {
    var results = [Int]()
    results.append(calc.nums[0])
    for i in 1..<calc.nums.count {
        let currentNum = calc.nums[i]
        var newResults = [Int]()
        for result in results {
            newResults.append(result + currentNum)
            newResults.append(result * currentNum)
            if withConcat {
                newResults.append(concatNums(a: result, b: currentNum))
            }
        }
        results = newResults
    }
    for result in results {
        if result == calc.target {
            return true
        }
    }
    return false
}

/* Calculate a * 10^k + b, where k is the number of digits in B */
func concatNums(a: Int, b: Int) -> Int {
    let powerOfTen = Int(pow(10.0, Double(countDigits(of: b))))
    return (a * powerOfTen) + b
}

func countDigits(of number: Int) -> Int {
    if number < 10 {
        return 1
    }
    var count = 0
    var n = number
    while n > 0 {
        n /= 10
        count += 1
    }
    return count
}

func main() {
    let filePath = FileManager.default.currentDirectoryPath.appendingPathComponent("input.txt")
    let result = parse(filePath: filePath)
                    .filter { isCalculationValid(calc: $0, withConcat: true) }
                    .map { $0.target }
                    .reduce(0, +)
    print("result :: \(result)")
}

func parse(filePath: String) -> [Calculation] {
    var calcs: [Calculation] = []
    do {
        let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
        for line in (fileContents.split{ $0.isNewline }) {
            let parts = line.split { $0 == ":" }
            if parts.count != 2 {
                print("There is something wrong with the file contents!")
                continue
            }
            var calc = Calculation()
            calc.target = Int(parts[0])!
            calc.nums = parts[1].split { $0 == " " }.map { Int($0)! }
            calcs.append(calc)
        }
    } catch {
        print("Error reading file: \(error.localizedDescription)")
    }
    return calcs
}

main()
