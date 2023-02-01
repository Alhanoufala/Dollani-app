//
//  PathMapper.swift
//  Dollani
//
//  Created by Alhanouf Alawwad on 16/06/1444 AH.
//

import SwiftUI

struct PathMapperContentView: View {
    init(place_:Place,hallways_:[DirectionalHallway],source_:CGPoint) {
        self.hallways = hallways_
       
        self.selectedClassroom = Classroom(name: place_.name, entrancePoint: CGPoint(x: place_.x, y: place_.y))
       
            youAreHerePoint = source_
        
        if let route = self.shortestRouteTo(classroom: self.selectedClassroom) {
            withAnimation {
                self.resultDistance = route.distance
                self.mapPathVertices = route.path
                self.mapPathDrawnPercentage = 1
            }
        }
    }
    // MARK: - Constants

    let youAreHerePoint : CGPoint
    
    /// ### 3B i. (Row 2) - list of hallways
    var hallways = [DirectionalHallway]()
       
   
    // MARK: - User Input Storage

    let selectedClassroom:Classroom
    
    // MARK: - Output Storage

     var resultDistance = CGFloat(0)
     var mapPathVertices = [Vertex]()
     var mapPathDrawnPercentage = CGFloat(0)
    
    // MARK: - User Interface

    var body: some View {
        VStack {
            
            
        
            ZStack {
                Image("Ground floor").resizable() /// the map image (made by myself)
                    
                // MARK: - Visual Output, path drawn on top of map
              

                Path { path in
                    if mapPathVertices.isEmpty == false {
                        path.move(to: mapPathVertices.first!.point)
                        
                        for vertex in mapPathVertices {
                            path.addLine(to: vertex.point)
                        }
                    }
                }
                .trim(from: 0, to: 0.01) /// animate path drawing
                .stroke(Color.red, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .shadow(color: Color.black.opacity(0.3), radius: 3).overlay(
                    Path { path in
                        if mapPathVertices.isEmpty == false {
                            path.move(to: mapPathVertices.first!.point)
                            
                            for vertex in mapPathVertices {
                                path.addLine(to: vertex.point)
                            }
                        }
                    }
                        .trim(from: 0.02, to: mapPathDrawnPercentage)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth:6))
                )
            }
            
            
            VStack {
                HStack {
                    Text("\(selectedClassroom.name)\n").lineLimit(2).accessibility(label: Text("\(selectedClassroom.name)"))
                    Spacer()
Text("وجهتك المختارة:").accessibility(label: Text("وجهتك المختارة:"))

                    // MARK: - Text Input via dropdown

                  
                }.accessibilityElement(children: .combine)
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
                // MARK: - Text Output, show the distance and approximate time needed
                
                if resultDistance != 0 {
                    HStack {
                        Text("\(numberToFeet(number: resultDistance)) قدم (~\(numberToMinutes(number: resultDistance)) دقيقة)").accessibility(label: Text("\(numberToFeet(number: resultDistance)) قدم (~\(numberToMinutes(number: resultDistance)) دقيقة)"))// Concatenate strings
                    
                        Spacer()
                        Text("المسافة:").fontWeight(.bold).accessibility(label: Text("المسافة:"))
                    }.accessibilityElement(children: .combine)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                }
                
                /// tap button to call main procedure
              
            }
            .font(.system(size: 20, weight: .medium))
            .padding(.horizontal, 20)
            
            Spacer()
        }
        /// remove results if selected classroom changed
        
    }
    
    // MARK: - Procedures
    
    /// get list of vertices (represents all possible paths) to a destination
    func getVerticesTo(destinationPoint: CGPoint) -> [Vertex] {
        /// ### 3B ii. (Row 2) - create `vertices` list from `hallways` list
        var vertices = [Vertex]()
        
        /// get and append a hallway's corresponding vertex to `vertices`, then append the hallway to the vertex's `touchingHallways`
        func configureVertexWith(hallway: DirectionalHallway) {
            var vertex: Vertex
            if let existingVertex = vertices.first(where: { $0.point == hallway.start }) {
                vertex = existingVertex /// prevent duplicates, get existing vertex in the `vertices` list
            } else {
                vertex = Vertex(point: hallway.start) /// create new vertex
                vertices.append(vertex) /// append to `vertices` list
            }
            vertex.touchingHallways.append(hallway)
        }
        
        var hallwaysCopy = hallways /// create mutable copy
        for i in hallwaysCopy.indices {
            if PointIsOnLine(lineStart: hallwaysCopy[i].start, lineEnd: hallwaysCopy[i].end, point: destinationPoint) {
                hallwaysCopy[i] = DirectionalHallway(start: hallwaysCopy[i].start, end: destinationPoint) /// replace full hallway with a portion
                configureVertexWith(hallway: DirectionalHallway(start: destinationPoint, end: destinationPoint)) /// final hallway, length of 0
            }
            configureVertexWith(hallway: hallwaysCopy[i])
        }
        
        return vertices
    }
    
    /// ### 3C i. (Row 4) - main procedure, get shortest route (distance and path) to classroom
    func shortestRouteTo(classroom: Classroom) -> Route? {
   if classroom != nil { /// classroom name is made of numbers (normal classroom)
            /// **sequencing**
            let vertices = getVerticesTo(destinationPoint: classroom.entrancePoint)
            if let shortestRoute = ShortestRouteFromVertices(vertices: vertices, start: youAreHerePoint, end: classroom.entrancePoint) {
                return shortestRoute
            }
        } else { /// no classroom was selected
            let alert = UIAlertController(title: "Select a classroom", message: "You must select a classroom first", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.present(alert, animated: true) /// present error alert
        }
        
        return nil /// return nothing when if check fell through - no shortest path was found
    }
}

// MARK: - Helper Procedures

/// the distance formula
func DistanceFormula(from: CGPoint, to: CGPoint) -> CGFloat {
    let squaredDistance = (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    return sqrt(squaredDistance)
}

/// check if a point falls on the line between 2 points
func PointIsOnLine(lineStart: CGPoint, lineEnd: CGPoint, point: CGPoint) -> Bool {
    let xAreSame = (point.x == lineStart.x && point.x == lineEnd.x)
    let yAreSame = (point.y == lineStart.y && point.y == lineEnd.y)
    
    if xAreSame {
        let maxY = max(lineStart.y, lineEnd.y)
        let minY = min(lineStart.y, lineEnd.y)
        if point.y <= maxY, point.y >= minY { /// compare Y coordinates
            return true
        }
    } else if yAreSame {
        let maxX = max(lineStart.x, lineEnd.x)
        let minX = min(lineStart.x, lineEnd.x)
        if point.x <= maxX, point.x >= minX { /// compare X coordinates
            return true
        }
    }
    return false /// not on the line
}

/// calculate the shortest route from a list of vertices
/// adapted from https://codereview.stackexchange.com/a/212585 (CC BY-SA 4.0)
/// reference: https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm (CC BY-SA 3.0)
func ShortestRouteFromVertices(vertices: [Vertex], start: CGPoint, end: CGPoint) -> Route? {
    /// use built-in `first(where:)` procedure to get vertex at point
    let startVertex = vertices.first(where: { $0.point == start })!
    let endVertex = vertices.first(where: { $0.point == end })
    
    for vertex in vertices { vertex.visited = false; vertex.distance = CGFloat.infinity }
    var verticesToVisit: [Vertex] = [startVertex]
    startVertex.distance = 0 /// set the first vertex's distance to 0
    
    while verticesToVisit.isEmpty == false {
        /// inside `verticesToVisit`, use vertex with smallest distance
        let currentVisitingVertex = verticesToVisit.min(by: { a, b in a.distance < b.distance })!
        if currentVisitingVertex == endVertex { /// if vertex is at destination, done!
            var path = [currentVisitingVertex]
            func getPreviousVertex(currentVertex: Vertex) { /// recursive procedure to trace path backwards
                if let previousHallway = currentVertex.previousHallway {
                    let previousVertex = vertices.first(where: { $0.point == previousHallway.start })!
                    path.insert(previousVertex, at: 0) /// insert previous vertex at beginning of list
                    getPreviousVertex(currentVertex: previousVertex)
                }
            }
            getPreviousVertex(currentVertex: currentVisitingVertex)
            return Route(distance: currentVisitingVertex.distance, path: path) /// exit the `while` loop and return the shortest distance and path
        }
        
        /// set vertex to visited
        currentVisitingVertex.visited = true
        if let firstIndex = verticesToVisit.firstIndex(of: currentVisitingVertex) { verticesToVisit.remove(at: firstIndex) }
        
        for touchingHallway in currentVisitingVertex.touchingHallways { /// calculate distances of touching hallways
            let endVertex = vertices.first(where: { $0.point == touchingHallway.end })!
            if endVertex.visited == false {
                verticesToVisit.append(endVertex)
                let totalDistance = currentVisitingVertex.distance + touchingHallway.length
                if totalDistance < endVertex.distance { endVertex.distance = totalDistance; endVertex.previousHallway = touchingHallway }
            }
        }
    }
    
    return nil /// if no shortest path found, return nothing
}

/// convert on-screen distance to feet
func numberToFeet(number: CGFloat) -> String {
    //let feetConversionFactor = CGFloat(1) / CGFloat(2) /// 1 pixel = half feet
    let feet = number / 5
    let feetRounded = Int(feet) /// round to nearest integer
    let arfeet = String(feetRounded)
    let arabicSteps = stepsToArabic(feets: arfeet)
    return "\(arabicSteps)"
}

func stepsToArabic(feets: String) -> String{
    var steps = ""
    for ch in feets {
        switch ch{
        case "0":
            steps = steps + "٠"
        case "1":
            steps = steps + "١"
        case "2":
            steps = steps + "٢"
        case "3":
            steps = steps + "٣"
        case "4":
            steps = steps + "٤"
        case "5":
            steps = steps + "٥"
        case "6":
            steps = steps + "٦"
        case "7":
            steps = steps + "٧"
        case "8":
            steps = steps + "٨"
        case "9":
            steps = steps + "٩"
        case ".":
            steps = steps + "."
        default:
            steps = steps + ""
        }
    }
    return "\(steps)"
}

/// convert on-screen distance to average walking duration
func numberToMinutes(number: CGFloat) -> String {
    let minuteConversionFactor = CGFloat(1) / CGFloat(276) /// average walking speed is 276 feet per minute
    let minutes = number * minuteConversionFactor
    let minutesFormatted = String(format: "%.2f", minutes)
    /// format with 1 decimal place
    let arMin = String(minutesFormatted)
    let arabicMin = stepsToArabic(feets: arMin)
    return "\(arabicMin)"
}

// MARK: - Custom Data Types

class Vertex: Equatable {
    let point: CGPoint
    var distance = CGFloat.infinity
    var touchingHallways = [DirectionalHallway]()
    
    var visited = false
    var previousHallway: DirectionalHallway?
    
    init(point: CGPoint) { self.point = point }
    static func == (l: Vertex, r: Vertex) -> Bool { return l === r }
}

struct DirectionalHallway {
    let start: CGPoint
    let end: CGPoint
    var length: CGFloat { DistanceFormula(from: start, to: end) } /// calculate length
}

struct Classroom: Identifiable, Hashable {
    var name: String
    var entrancePoint: CGPoint /// normal classroom made of numbers (e.g. 403)
    
   
    
    init(name: String, entrancePoint: CGPoint) { self.name = name;  self.entrancePoint = entrancePoint } 
    
    let id = UUID() /// boilerplate protocol requirements
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct Route {
    var distance: CGFloat
    var path: [Vertex]
}




