//
//  WheelView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-06-02.
//

import SwiftUI

struct WheelView: View {
    
    let segments = ["100", "200", "300", "400", "500", "600", "700", "800", "900", "1000"]
    
    @State var rotation : Double = 0.0
    @State var isSpinning = false
    
    var body: some View {
        
        VStack(spacing: 30){
           
            ZStack{
                ForEach(0..<segments.count, id: \.self) { i in
                    SegmentView(label: segments[i], index: i, totalSegments: segments.count)
                }
                Button("Spin"){
                    if !isSpinning {
                        isSpinning = true
                        let randomRotation = Double.random(in: 1720...11440)
                        rotation += randomRotation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
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
            .animation(.interpolatingSpring(stiffness: 10, damping: 10), value: rotation)
            .clipShape(Circle())
            
            
        }
    }
}


struct SegmentView : View {
    
    let label : String
    let index : Int
    let totalSegments : Int
    
    var body : some View {
        
                
                let segmentAngle =  360.0 / Double(totalSegments)
                let rotation = Angle(degrees: Double(index) * segmentAngle)
                
                ZStack{
                    SegmentShape(startAngle: .degrees(-segmentAngle / 2), endAngle: .degrees(segmentAngle / 2))
                        .fill(Color(hue: Double(index) / Double(totalSegments), saturation: 0.5, brightness: 1.0))
                    
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


#Preview {
    WheelView()
}

