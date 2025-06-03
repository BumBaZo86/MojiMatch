//
//  WheelView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-06-02.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct WheelView: View {
    
    let segments = ["100", "300", "600", "400", "900", "500", "200", "700", "1000","800"]
    
    @State var rotation : Double = 0.0
    @State var isSpinning = false
    @State var winnerIndex : Int?
    @State var winner : Int?
    @State var showWinning = false
    
    var body: some View {
        
        VStack(spacing: 30){
            
            ZStack{
                VStack{
                    
                    if showWinning {
                        Text("You won \(winner ?? 0)!")
                            .offset(y: -80)
                            .foregroundStyle(.white)
                            .font(.title2)
                            .fontDesign(.monospaced)
                    } else {
                        Text("Have a spin!")
                            .offset(y: -80)
                            .foregroundStyle(.white)
                            .font(.title2)
                            .fontDesign(.monospaced)
                    }
                }
            }
            
            ZStack{
                
                Triangle()
                    .fill(Color.red)
                    .frame(width: 30, height: 50)
                    .rotationEffect(.degrees(180))
                    .offset(y: -200)
                
                
                ZStack{
                    ForEach(0..<segments.count, id: \.self) { i in
                        SegmentView(label: segments[i], index: i, totalSegments: segments.count, winnerIndex: $winnerIndex)
                    }
                    Button("Spin"){
                        if !isSpinning {
                            isSpinning = true
                            let randomRotation = Double.random(in: 1720...2440)
                            rotation += randomRotation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.7) {
                                
                                let normalizedRotation = rotation.truncatingRemainder(dividingBy: 360)
                                let anglePerSegment = 360 / Double(segments.count)
                                
                                let adjustRotation = (360 - normalizedRotation + anglePerSegment / 2).truncatingRemainder(dividingBy: 360)
                                
                                let index = Int(adjustRotation / anglePerSegment) % segments.count
                                winnerIndex = index
                                
                                print("Winner \(segments[index])")
                                
                                winner = Int(segments[index])
                                
                                saveWheelWin()
                                showWinning = true
                                
                                isSpinning = false
                            }
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .disabled(isSpinning)
                    
                }
                .frame(width: 350, height: 350)
                .rotationEffect(.degrees(rotation))
                .animation(.easeOut(duration: 4), value: rotation)
                .clipShape(Circle())
                
            }
        }
    }

    
    func saveWheelWin() {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No logged in user.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userEmail)
        
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                let previousPoints = document["points"] as? Int ?? 0
                userRef.updateData(["points": previousPoints + (winner ?? 0)]) { err in
                    if let err = err {
                        print("Error updating points: \(err.localizedDescription)")
                    }
                }
            } else {
                userRef.setData(["points": winner ?? 0], merge: true) { err in
                    if let err = err {
                        print("Error setting points: \(err.localizedDescription)")
                    }
                }
            }
        }
    }
}

struct SegmentView : View {
    
    let label : String
    let index : Int
    let totalSegments : Int
    @Binding var winnerIndex: Int?
    
    @State var isVisible = true
    
    var body : some View {
        let segmentAngle =  360.0 / Double(totalSegments)
        let rotation = Angle(degrees: Double(index) * segmentAngle)
        
        ZStack{
            SegmentShape(startAngle: .degrees(-segmentAngle / 2), endAngle: .degrees(segmentAngle / 2))
                .fill(Color(hue: Double(index) / Double(totalSegments), saturation: 0.9, brightness: 1.0))
                .opacity(shouldBlink ? (isVisible ? 1.0 : 0.2) : 1.0)
            
            Text(label)
                .foregroundStyle(.black)
                .font(.system(size: 16, weight: .bold))
                .rotationEffect(.degrees(-90))
                .offset(y: -100)
            
        }
        .rotationEffect(rotation)
        .frame(width: 350, height: 350)
        .compositingGroup()
        .onChange(of: winnerIndex) {
            if shouldBlink {
                blink()
            }
        }
    }
    
    var shouldBlink: Bool {
        winnerIndex == index
        
    }
    
    func blink() {
        withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
            isVisible.toggle()
        }
    }
}

struct SegmentShape : Shape {
    
    let startAngle: Angle
    let endAngle : Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(center: center,
                    radius: rect.width / 2,
                    startAngle: .degrees(-90) + startAngle,
                               endAngle: .degrees(-90) + endAngle,
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY)) // Topp
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Höger hörn
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // Vänster hörn
        path.closeSubpath()
        return path
    }
}


struct SegmentViewButton : View {
    
    let label : String
    let index : Int
    let totalSegments : Int
    
    @State var isVisible = true
    
    var body : some View {
        let segmentAngle =  360.0 / Double(totalSegments)
        let rotation = Angle(degrees: Double(index) * segmentAngle)
        
        ZStack{
            SegmentShape(startAngle: .degrees(-segmentAngle / 2), endAngle: .degrees(segmentAngle / 2))
                .fill(Color(hue: Double(index) / Double(totalSegments), saturation: 0.9, brightness: 1.0))
            
            Text(label)
                .foregroundStyle(.black)
                .font(.system(size: 16, weight: .bold))
                .rotationEffect(.degrees(-90))
                .offset(y: -100)
            
        }
        .rotationEffect(rotation)
        .frame(width: 350, height: 350)
        .compositingGroup()
    }
}

#Preview {
    WheelView()
}

