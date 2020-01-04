//
//  main.swift
//  AOC1917
//
//  Created by Heiko Goes on 29.12.19.
//  Copyright © 2019 Heiko Goes. All rights reserved.
//

import Foundation

enum Opcode: Int {
    case Add = 1
    case Multiply = 2
    case Halt = 99
    case Input = 3
    case Output = 4
    case JumpIfTrue = 5
    case JumpIfFalse = 6
    case LessThan = 7
    case Equals = 8
    case AdjustRelativeBase = 9
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

struct ParameterModes {
    let digits: String
    private var parameterPointer: Int
    
    init(digits: String) {
        self.digits = digits
        parameterPointer = digits.count - 1
    }
    
    mutating func getNext() -> ParameterMode {
        let digit = parameterPointer >= 0 ? digits[parameterPointer...parameterPointer] : "0"
        parameterPointer -= 1
        
        return ParameterMode(rawValue: Int(digit)!)!
    }
}

enum ParameterMode: Int {
    case Position = 0
    case Immediate = 1
    case Relative = 2
}

struct Program {
    private(set) var memory: [Int]
    private var instructionPointer = 0
    private let input: Int
    private var relativeBase = 0
    
    public mutating func getNextParameter(parameterMode: ParameterMode) -> Int {
        var parameter: Int
        switch parameterMode {
            case .Position:
                parameter = memory[memory[instructionPointer]]
            case .Immediate:
                parameter = memory[instructionPointer]
            case .Relative:
                parameter = memory[memory[instructionPointer] + relativeBase]
        }
        
        instructionPointer += 1
        return parameter
    }
    
    public mutating func run() -> String {
        var result = ""
        repeat {
            var startString = String(memory[instructionPointer])
            if startString.count == 1 {
                startString = "0" + startString
            }
            
            instructionPointer += 1
            
            let opcode = Opcode(rawValue: Int(startString[startString.count - 2...startString.count - 1])!)!
            if opcode == .Halt {
                return result
            }
            
            var parameterModes = startString.count >= 3 ? ParameterModes(digits: startString[0...startString.count - 3]) : ParameterModes(digits: "")
            
            switch opcode {
                case .Add:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                    let parameter3 = getNextParameter(parameterMode: .Immediate)
                    
                    let parameterMode = parameterModes.getNext()
                    if parameterMode == .Relative {
                        memory[parameter3 + relativeBase] = parameter1 + parameter2
                    } else {
                        memory[parameter3] = parameter1 + parameter2
                    }
                case .Multiply:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                    let parameter3 = getNextParameter(parameterMode: .Immediate)
                    
                    let parameterMode = parameterModes.getNext()
                    if parameterMode == .Relative {
                        memory[parameter3 + relativeBase] = parameter1 * parameter2
                    } else {
                        memory[parameter3] = parameter1 * parameter2
                    }
                case .Halt: ()
                case .Input:
                    let parameter = getNextParameter(parameterMode: .Immediate)
                    let parameterMode = parameterModes.getNext()
                    if parameterMode == .Relative {
                        memory[parameter + relativeBase] = input
                    } else {
                        memory[parameter] = input
                    }
                case .Output:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    result = result + String(Character(UnicodeScalar(parameter1)!))
                case .JumpIfTrue:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    if parameter1 != 0 {
                        let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                        instructionPointer = parameter2
                    } else {
                        instructionPointer += 1
                    }
                case .JumpIfFalse:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    if parameter1 == 0 {
                        let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                        instructionPointer = parameter2
                    } else {
                        instructionPointer += 1
                    }
                case .LessThan:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                    let parameter3 = getNextParameter(parameterMode: .Immediate)
                    
                    let parameterMode = parameterModes.getNext()
                    let value = parameter1 < parameter2 ? 1 : 0
                    if parameterMode == .Relative {
                        memory[parameter3 + relativeBase] = value
                    } else {
                        memory[parameter3] = value
                    }
                case .Equals:
                   let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                   let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                   let parameter3 = getNextParameter(parameterMode: .Immediate)
                   
                   let parameterMode = parameterModes.getNext()
                   let value = parameter1 == parameter2 ? 1 : 0
                   if parameterMode == .Relative {
                        memory[parameter3 + relativeBase] = value
                   } else {
                        memory[parameter3] = value
                    }
                case .AdjustRelativeBase:
                   let parameter = getNextParameter(parameterMode: parameterModes.getNext())
                   relativeBase += parameter
            }
        } while true
    }
    
    init(memory: String, input: Int) {
        self.memory = memory
            .split(separator: ",")
            .map{ Int($0)! }
        self.input = input
    }
}

//let memoryString = """
//109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99
//"""
let memoryString = """
1,330,331,332,109,3274,1102,1182,1,15,1101,1489,0,24,1001,0,0,570,1006,570,36,101,0,571,0,1001,570,-1,570,1001,24,1,24,1106,0,18,1008,571,0,571,1001,15,1,15,1008,15,1489,570,1006,570,14,21102,58,1,0,1106,0,786,1006,332,62,99,21101,333,0,1,21101,73,0,0,1106,0,579,1101,0,0,572,1102,0,1,573,3,574,101,1,573,573,1007,574,65,570,1005,570,151,107,67,574,570,1005,570,151,1001,574,-64,574,1002,574,-1,574,1001,572,1,572,1007,572,11,570,1006,570,165,101,1182,572,127,1002,574,1,0,3,574,101,1,573,573,1008,574,10,570,1005,570,189,1008,574,44,570,1006,570,158,1106,0,81,21101,0,340,1,1106,0,177,21101,0,477,1,1106,0,177,21102,1,514,1,21101,176,0,0,1105,1,579,99,21101,0,184,0,1105,1,579,4,574,104,10,99,1007,573,22,570,1006,570,165,1002,572,1,1182,21101,0,375,1,21102,1,211,0,1106,0,579,21101,1182,11,1,21101,0,222,0,1105,1,979,21101,0,388,1,21102,1,233,0,1105,1,579,21101,1182,22,1,21101,0,244,0,1106,0,979,21102,1,401,1,21102,255,1,0,1105,1,579,21101,1182,33,1,21102,266,1,0,1105,1,979,21102,1,414,1,21102,277,1,0,1105,1,579,3,575,1008,575,89,570,1008,575,121,575,1,575,570,575,3,574,1008,574,10,570,1006,570,291,104,10,21102,1182,1,1,21102,1,313,0,1105,1,622,1005,575,327,1101,0,1,575,21102,1,327,0,1105,1,786,4,438,99,0,1,1,6,77,97,105,110,58,10,33,10,69,120,112,101,99,116,101,100,32,102,117,110,99,116,105,111,110,32,110,97,109,101,32,98,117,116,32,103,111,116,58,32,0,12,70,117,110,99,116,105,111,110,32,65,58,10,12,70,117,110,99,116,105,111,110,32,66,58,10,12,70,117,110,99,116,105,111,110,32,67,58,10,23,67,111,110,116,105,110,117,111,117,115,32,118,105,100,101,111,32,102,101,101,100,63,10,0,37,10,69,120,112,101,99,116,101,100,32,82,44,32,76,44,32,111,114,32,100,105,115,116,97,110,99,101,32,98,117,116,32,103,111,116,58,32,36,10,69,120,112,101,99,116,101,100,32,99,111,109,109,97,32,111,114,32,110,101,119,108,105,110,101,32,98,117,116,32,103,111,116,58,32,43,10,68,101,102,105,110,105,116,105,111,110,115,32,109,97,121,32,98,101,32,97,116,32,109,111,115,116,32,50,48,32,99,104,97,114,97,99,116,101,114,115,33,10,94,62,118,60,0,1,0,-1,-1,0,1,0,0,0,0,0,0,1,26,0,0,109,4,2101,0,-3,586,21002,0,1,-1,22101,1,-3,-3,21101,0,0,-2,2208,-2,-1,570,1005,570,617,2201,-3,-2,609,4,0,21201,-2,1,-2,1105,1,597,109,-4,2105,1,0,109,5,2102,1,-4,629,21001,0,0,-2,22101,1,-4,-4,21101,0,0,-3,2208,-3,-2,570,1005,570,781,2201,-4,-3,652,21002,0,1,-1,1208,-1,-4,570,1005,570,709,1208,-1,-5,570,1005,570,734,1207,-1,0,570,1005,570,759,1206,-1,774,1001,578,562,684,1,0,576,576,1001,578,566,692,1,0,577,577,21102,702,1,0,1105,1,786,21201,-1,-1,-1,1105,1,676,1001,578,1,578,1008,578,4,570,1006,570,724,1001,578,-4,578,21102,1,731,0,1106,0,786,1106,0,774,1001,578,-1,578,1008,578,-1,570,1006,570,749,1001,578,4,578,21101,756,0,0,1106,0,786,1105,1,774,21202,-1,-11,1,22101,1182,1,1,21102,1,774,0,1106,0,622,21201,-3,1,-3,1106,0,640,109,-5,2106,0,0,109,7,1005,575,802,21001,576,0,-6,21002,577,1,-5,1105,1,814,21101,0,0,-1,21102,1,0,-5,21101,0,0,-6,20208,-6,576,-2,208,-5,577,570,22002,570,-2,-2,21202,-5,35,-3,22201,-6,-3,-3,22101,1489,-3,-3,1201,-3,0,843,1005,0,863,21202,-2,42,-4,22101,46,-4,-4,1206,-2,924,21102,1,1,-1,1106,0,924,1205,-2,873,21102,35,1,-4,1105,1,924,1201,-3,0,878,1008,0,1,570,1006,570,916,1001,374,1,374,2101,0,-3,895,1101,2,0,0,1202,-3,1,902,1001,438,0,438,2202,-6,-5,570,1,570,374,570,1,570,438,438,1001,578,558,922,20101,0,0,-4,1006,575,959,204,-4,22101,1,-6,-6,1208,-6,35,570,1006,570,814,104,10,22101,1,-5,-5,1208,-5,51,570,1006,570,810,104,10,1206,-1,974,99,1206,-1,974,1102,1,1,575,21102,1,973,0,1106,0,786,99,109,-7,2105,1,0,109,6,21102,1,0,-4,21102,1,0,-3,203,-2,22101,1,-3,-3,21208,-2,82,-1,1205,-1,1030,21208,-2,76,-1,1205,-1,1037,21207,-2,48,-1,1205,-1,1124,22107,57,-2,-1,1205,-1,1124,21201,-2,-48,-2,1106,0,1041,21101,-4,0,-2,1106,0,1041,21102,1,-5,-2,21201,-4,1,-4,21207,-4,11,-1,1206,-1,1138,2201,-5,-4,1059,1202,-2,1,0,203,-2,22101,1,-3,-3,21207,-2,48,-1,1205,-1,1107,22107,57,-2,-1,1205,-1,1107,21201,-2,-48,-2,2201,-5,-4,1090,20102,10,0,-1,22201,-2,-1,-2,2201,-5,-4,1103,2102,1,-2,0,1105,1,1060,21208,-2,10,-1,1205,-1,1162,21208,-2,44,-1,1206,-1,1131,1105,1,989,21101,439,0,1,1105,1,1150,21101,0,477,1,1105,1,1150,21101,514,0,1,21102,1149,1,0,1105,1,579,99,21101,1157,0,0,1105,1,579,204,-2,104,10,99,21207,-3,22,-1,1206,-1,1138,2102,1,-5,1176,2101,0,-4,0,109,-6,2105,1,0,16,11,24,1,34,1,34,1,34,1,34,1,34,1,34,1,34,1,34,1,28,7,28,1,34,1,34,1,34,1,34,1,34,1,34,1,34,1,34,1,34,11,34,1,34,1,34,1,28,13,22,1,5,1,5,1,16,13,5,1,16,1,5,1,11,1,16,1,5,1,11,1,16,1,5,1,11,1,8,13,1,11,1,1,8,1,7,1,3,1,11,1,1,1,8,1,5,13,5,1,1,1,8,1,5,1,1,1,3,1,5,1,5,1,1,1,8,1,5,1,1,1,3,1,5,1,5,1,1,1,1,8,5,1,1,1,3,1,5,1,5,1,1,1,1,1,6,1,5,1,1,1,3,1,1,13,1,1,6,1,5,1,1,1,3,1,1,1,3,1,5,1,3,1,6,1,5,1,1,13,3,1,1,7,2,1,5,1,5,1,1,1,3,1,1,1,3,1,1,1,1,1,3,1,2,1,5,1,5,1,1,1,3,1,1,1,3,1,1,1,1,1,3,1,2,1,5,1,5,1,1,1,3,1,1,1,3,1,1,1,1,1,3,1,2,7,5,13,1,1,1,1,3,1,16,1,3,1,1,1,5,1,1,1,3,1,16,1,3,11,3,1,16,1,5,1,5,1,5,1,16,1,5,1,5,1,5,1,16,1,5,1,5,1,5,1,16,13,5,1,22,1,11,1,22,13,2
"""
    + String(repeating: ",0", count: 10000)

var program = Program(memory: memoryString, input: 1)

//let input = """
//..#..........
//..#..........
//#######...###
//#.#...#...#.#
//#############
//..#...#...#..
//..#####...^..
//"""

//let input = """
//#######...#####
//#.....#...#...#
//#.....#...#...#
//......#...#...#
//......#...###.#
//......#.....#.#
//^########...#.#
//......#.#...#.#
//......#########
//........#...#..
//....#########..
//....#...#......
//....#...#......
//....#...#......
//....#####......
//"""

let input = program.run()
print(input)

enum Direction: Int, CaseIterable {
    case north = 0
    case east = 1
    case south = 2
    case west = 3
    
    func opposite() -> Direction {
        switch self {
            case .north: return .south
            case .east: return .west
            case .south: return .north
            case .west: return .east
        }
    }
}

struct Point: Hashable {
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
           self.x = x
           self.y = y
       }
    
    init(point: Point, direction: Direction) {
        switch direction {
            case .north:
                x = point.x
                y = point.y - 1
            case .east:
                x = point.x + 1
                y = point.y
            case .south:
                x = point.x
                y = point.y + 1
            case .west:
                x = point.x - 1
                y = point.y
        }
    }
}

extension Point {
    func getNeighbors() -> Set<Point> {
        return Set([
            Point(x: self.x - 1, y: self.y),
            Point(x: self.x + 1, y: self.y),
            Point(x: self.x,     y: self.y - 1),
            Point(x: self.x,     y: self.y + 1),
        ])
    }
}

let maze = input
    .split(separator: "\n")
let scaffoldPoints: Set<Point> = zip(maze, 0..<maze.count)
    .reduce(Set<Point>()) { accu, current in
        let charaterPairs = zip(current.0, 0..<current.0.count)
        let scaffoldCharaterPairs = charaterPairs.filter{ $0.0 == "#" }
        let scaffoldPoints = scaffoldCharaterPairs.map{ Point(x: $0.1, y: current.1)}
        return accu.union(scaffoldPoints)
    }

let intersectingPoints = scaffoldPoints.filter{ $0.getNeighbors().isSubset(of: scaffoldPoints) }
let result = intersectingPoints.reduce(0){ accu, current in
    accu + current.x * current.y
}

print()
print(result)

// ---------------------------------------------------------

class Node<T> {
    var value: T? = nil
    var next: Node<T>? = nil
    var prev: Node<T>? = nil

    init() {
    }

    init(value: T) {
        self.value = value
    }
}

class Queue<T> {

var count: Int = 0

var head: Node<T> = Node<T>()

var tail: Node<T> = Node<T>()

var currentNode : Node<T> = Node<T>()

    init() {
    }

    func isEmpty() -> Bool {
        return self.count == 0
    }

    func next(index:Int) -> T? {

        if isEmpty() {
            return nil
        } else if self.count == 1 {
            let temp: Node<T> = currentNode
            return temp.value
        } else if index == self.count{
            return currentNode.value

        }else {
            let temp: Node<T> = currentNode
            currentNode = currentNode.next!
            return temp.value
        }

    }

    func setCurrentNode(){
        currentNode = head
    }

    func enQueue(key: T) {
        let node = Node<T>(value: key)
        if self.isEmpty() {
            self.head = node
            self.tail = node
        } else {
            node.next = self.head
            self.head.prev = node
            self.head = node
        }

        self.count += 1
    }

    func deQueue() -> T? {
        if self.isEmpty() {
            return nil
        } else if self.count == 1 {
            let temp: Node<T> = self.tail
            self.count -= 1
            return temp.value
        } else {
            let temp: Node<T> = self.tail
            self.tail = self.tail.prev!
            self.count -= 1
            return temp.value
        }
    }



    //retrieve the top most item
    func peek() -> T? {
        if isEmpty() {
            return nil
        }

        return head.value!
    }

    func poll() -> T? {
        if isEmpty() {
            return nil
        } else{
            let temp:T = head.value!
            let _ = deQueue()
            return temp
        }
    }

    func offer( key:T)->Bool{
        var status:Bool = false;

        self.enQueue(key: key)
        status = true

        return status
    }
}

program = Program(memory: "2" + memoryString.dropFirst(), input: 1)

let input2 = program.run()

print(input2)

enum Command {
    case forward
    case left
    case right
}

struct Visit: Hashable {
    let point: Point
    let fromDirection: Direction
}

struct Path {
    let point: Point
    let commands: [Command]
}

func toCommand(fromDirection: Direction, toDirection: Direction) -> [Command] {
    if fromDirection == toDirection {
        return [.forward]
    }
    
    if fromDirection.opposite() == toDirection {
        return [.left, .left, .forward]
    }
    
    if fromDirection == .west && toDirection == .north {
        return [.right, .forward]
    }
 
    if fromDirection == .north && toDirection == .west {
         return [.left, .forward]
     }
    
    if fromDirection.rawValue < toDirection.rawValue {
        return [.right, .forward]
    }
    
    return [.left, .forward]
}

struct RobotState {
    let direction: Direction
    let point: Point
    let paths: [Path]
    let visited: Set<Visit>
    
    func getNextPoints() -> [(point: Point, direction: Direction)] {
        return Direction
            .allCases
            .filter{ $0 != direction.opposite() }
            .sorted(by: { d1, _ in d1 == direction })
            .map{ (point: Point(point: point, direction: $0), direction: $0) }
            .filter{ scaffoldPoints.contains($0.point) && !visited.contains(Visit(point: $0.point, fromDirection: $0.direction))}
    }
    
    func getNextStates() -> [RobotState] {
        getNextPoints()
            .map {
                let (toPoint, toDirection) = $0
                let commands = toCommand(fromDirection: direction, toDirection: toDirection)
                let path = Path(point: toPoint, commands: commands)
                let newVisits = [
                    Visit(point: toPoint, fromDirection: toDirection)]
                return RobotState(
                    direction: toDirection,
                    point: toPoint,
                    paths: paths + [path],
                    visited: visited.union(newVisits))
            }
    }
}

let startPoint: Point? = zip(maze, 0..<maze.count)
    .reduce(nil) { accu, current in
        if accu != nil {
            return accu
        }
        
        let charaterPairs = zip(current.0, 0..<current.0.count)
        let startPointPair = charaterPairs.filter{ $0.0 == "^" }.first
        
        return startPointPair == nil
            ? nil
            : Point(x: startPointPair!.1, y: current.1)
    }

func compressPaths(_ paths: [Path]) -> String {
    let commands: [Command] = paths
        .map{ $0.commands }
        .flatMap{ $0 }
    
    return commands.reduce((string: "", forwardCount: 0)){ accu, current in
        switch current {
            case .left: return accu.forwardCount == 0
                            ? (accu.string + "L", 0)
                            : (accu.string + String(accu.forwardCount) + " L", 0)
            case .right: return accu.forwardCount == 0
                            ? (accu.string + "R", 0)
                            : (accu.string + String(accu.forwardCount) + " R", 0)
            case .forward:
                return (accu.string, accu.forwardCount + 1)
        }
    }.string
}

// Depth-First
//func visitNextStates(_ state: RobotState, commandString: inout String?) {
//    let points = Set(state.visited.map{ $0.point })
//    if points.count == scaffoldPoints.count {
//        let result = compressPaths(state.paths)
//
//        if commandString != nil {
//            let c = Set(commandString!.split(separator: " ").map{String($0)})
//            let r = Set(result.split(separator: " ").map{String($0)})
//            if  r.count < c.count {
//                commandString = result
//            }
//        } else {
//            commandString = result
//        }
//    }
//
//    for nextState in state.getNextStates() {
//        visitNextStates(nextState, commandString: &commandString)
//    }
//}
//
//var commandString: String?
//let state = RobotState(direction: .north, point: startPoint!, paths: [], visited: [])
//visitNextStates(state, commandString: &commandString)

// Breadth first
//var queue = Queue<RobotState>()
//var successPaths = [[Path]]()
//var steps = 0
//
//queue.enQueue(key: RobotState(direction: .north, point: startPoint!, paths: [], visited: []))
//
//repeat {
//    steps += 1
//    print(queue.count)
//
//    let robotState = queue.deQueue()!
//
//   // print(robotState)
//
//    for robotState in robotState.getNextStates() {
//        let points = Set(robotState.visited.map{ $0.point })
//        if points.count == scaffoldPoints.count {
//            successPaths.append(robotState.paths)
//        } else
//        {
//            queue.enQueue(key: robotState)
//        }
//    }
//} while !queue.isEmpty()
//
//print(steps)
//print(successPaths)


// --------------------------------
// Lösung:
// L10 L10 R6 L10 L10 R6 R12 L12 L12 R12 L12 L12 L6 L10 R12 R12 R12 L12 L12 L6 L10 R12 R12 R12 L12 L12 L6 L10 R12 R12 L10 L10

//L10 L10 R6
//L10 L10 R6
//R12 L12 L12
//R12 L12 L12 L6 L10 R12 R12
//R12 L12 L12 L6 L10 R12 R12
//R12 L12 L12 L6 L10 R12 R12
//L10 L10 (R6)

//A: L10 L10 R6
//B: R12 L12 L12
//C: R12 L12 L12 L6 L10 R12 R12
//
//Main Routine: A ,  A  ,  B  ,  B  ,  C. ,  C.  , C
//ASCII Input: 65,44,65,44,66,44,66,44,67,44,67,44,67,10)

func toAscii(_ str: String) -> [Int] {
    return (str + "\n")
        .map{ Int($0.asciiValue!) }
}

let mainRoutine = toAscii("A,A,B,B,C,C,C")
let functionA = toAscii("L,1,0,L,1,0,R,6")
let functionB = toAscii("R,1,2,L,1,2,L,12")
let functionC = toAscii("R,1,2,L,1,2,L,1,2,L,6,L,1,0,R,1,2,R,1,2")

print()


