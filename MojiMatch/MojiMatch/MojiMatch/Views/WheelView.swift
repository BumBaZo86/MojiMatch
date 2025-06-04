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
    
    @StateObject var wheelViewModel = WheelViewModel()
    
    var body: some View {
        
        VStack(spacing: 30){
            Spacer()
            ZStack{
                HStack{
                    Spacer()
                    
                    VStack{
                        VStack(alignment: .leading, spacing: 8){
                            Text("⭐: \(wheelViewModel.stars ?? 0)")
                            Text("💰: \(wheelViewModel.points ?? 0)")
                        }
                        .frame(width: 130, height: 50)
                        .font(.subheadline)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.black)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 5)
                        )
                        .offset(y: -80)
                    }
                    .padding()
                }
                
                VStack{
                    
                    if wheelViewModel.showWinning {
                        Text("You won \(wheelViewModel.winner ?? 0)!")
                        
                    } else if !wheelViewModel.hasSpunToday {
                        Text("Have a spin!")
                        
                    }
                }
                .foregroundStyle(.white)
                .font(.title2)
                .fontDesign(.monospaced)
            }
            
            ZStack{
                
                Triangle()
                    .fill(Color.red)
                    .frame(width: 30, height: 50)
                    .rotationEffect(.degrees(180))
                    .offset(y: -200)
                
                
                ZStack{
                    ForEach(0..<wheelViewModel.segments.count, id: \.self) { i in
                        SegmentView(label: wheelViewModel.segments[i], index: i, totalSegments: wheelViewModel.segments.count, winnerIndex: $wheelViewModel.winnerIndex)
                    }
                    Button("Spin"){
                        if !wheelViewModel.isSpinning && !wheelViewModel.hasSpunToday {
                            wheelViewModel.spinWheel(isFreeSpin: true)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .disabled(wheelViewModel.isSpinning || wheelViewModel.hasSpunToday)
                    .opacity(wheelViewModel.hasSpunToday ? 0.5 : 1.0)
                        
                }
                .frame(width: 350, height: 350)
                .rotationEffect(.degrees(wheelViewModel.rotation))
                .animation(.easeOut(duration: 4), value: wheelViewModel.rotation)
                .clipShape(Circle())
                    
            }
            .onAppear {
                wheelViewModel.checkSpinStatus()
            }
                
            VStack {
                    
                Group {
                    Text("Buy another spin?")
                        .foregroundStyle(.white)
                        .font(.title2)
                        .fontDesign(.monospaced)
                        
                        
                    Button("20 ⭐") {
                        if let currentStars = wheelViewModel.stars, currentStars >= 20 {
                            wheelViewModel.buyASpin()
                        }
                    }
                    .frame(width: 100, height: 30)
                    .font(.title2)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.black)
                    .padding(8)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 5)
                    )
                        
                }
                .opacity(wheelViewModel.hasSpunToday ? 1 : 0)
            }
            .padding()
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

