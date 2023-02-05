//
//  CGpathMapper.swift
//  Dollani
//
//  Created by Layan Alwadie on 27/06/1444 AH.
//

import SwiftUI

//
//  CGPathMapper.swift
//  Dollani
//
//  Created by Layan Alwadie on 27/06/1444 AH.
//



import SwiftUI

struct CGPathMapperContentView: View {
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
                Image("مبنى كلية الحاسب الدور الأرضي").resizable() /// the map image (made by myself)
                    
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
                    Text("\(selectedClassroom.name)\n").lineLimit(2)
                    Spacer()
                    Text("الوجهة المختارة:").fontWeight(.bold)

                    // MARK: - Text Input via dropdown

                  
                }
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
                // MARK: - Text Output, show the distance and approximate time needed
                
                if resultDistance != 0 {
                    HStack {
                        Text("\(numberToFeet(number: resultDistance)) قدم (~\(numberToMinutes(number: resultDistance)) دقيقة)")// Concatenate strings
                    
                        Spacer()
                        Text("المسافة:").fontWeight(.bold)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                }
                
                
                /// tap button to call main procedure
               
               
            }
//            VStack{
//                Text(" ")
//
//            }
//            VStack{
//                Text(" ")
//
//            }
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
