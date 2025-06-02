//
//  WheelView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-06-02.
//

import SwiftUI

struct WheelView: View {
    
    let segments = ["hej", "hej", "hej igen", "hallå"]
    
    @State var rotation : Double = 0.0
    @State var isSpinning = false
    
    var body: some View {
        
        VStack(spacing: 30){
           
            ZStack{
                ForEach(0..<segments.count, id: \.self) { i in
                    SegmentView(label: segments[i], index: i, totalSegments: segments.count)
                }
            }
            .frame(width: 300, height: 300)
            .rotationEffect(.degrees(rotation))
            .animation(.easeOut(duration: 3), value: rotation)
            .clipShape(Circle())
            
            
            Button("Spin"){
                if !isSpinning {
                    isSpinning = true
                    let randomRotation = Double.random(in: 720...1440)
                    rotation += randomRotation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isSpinning = false
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .clipShape(Capsule())
            .disabled(isSpinning)
        }
    }
}


struct SegmentView : View {
    
    let label : String
    let index : Int
    let totalSegments : Int
    
    var body : some View {
        
        GeometryReader { geo in
            
            let segmentAngle =  360.0 / Double(totalSegments)
            let rotation = Angle(degrees: Double(index) * segmentAngle)
            
            ZStack{
                SegmentShape(startAngle: .degrees(-segmentAngle/2), endAngle: .degrees(segmentAngle/2))
                    .fill(Color(hue: Double(index) / Double(totalSegments), saturation: 0.4, brightness: 1.0))
                
                Text(label)
                    .rotationEffect(.degrees(-rotation.degrees))
                    .offset(y: -geo.size.height * 0.25)
            }
            .rotationEffect(rotation)
        }
        .frame(width: 300, height: 300)
    }
}

struct SegmentShape : Shape {
    
    let startAngle: Angle
    let endAngle : Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(center: center, radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}


#Preview {
    WheelView()
}

