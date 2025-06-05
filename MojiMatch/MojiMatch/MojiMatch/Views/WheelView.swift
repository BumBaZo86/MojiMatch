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
import AVFoundation

struct WheelView: View {
    
    @StateObject var wheelViewModel = WheelViewModel()
    @State private var showPlusAnimation = false
    @State private var showMinusAnimation = false
    
    @State private var audioPlayer: AVAudioPlayer?
    
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
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 5)

                                if showMinusAnimation {
                                    Text("-20 ⭐")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.yellow)
                                        .shadow(radius: 3)
                                        .offset(y: -40)
                                        .opacity(showMinusAnimation ? 1 : 0)
                                        .scaleEffect(showMinusAnimation ? 1.3 : 1.0)
                                        .animation(.easeOut(duration: 1.5), value: showMinusAnimation)
                                }
                            }
                        )
                        .offset(y: -80)
                    }
                    .padding()
                }
                
                VStack {
                    if wheelViewModel.showWinning {
                        VStack(spacing: 10) {
                            if let winner = wheelViewModel.winner {
                                Text("+\(winner)")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(.green)
                                    .offset(y: showPlusAnimation ? -60 : 0)
                                    .opacity(showPlusAnimation ? 0 : 1)
                                    .scaleEffect(showPlusAnimation ? 1.3 : 1.0)
                                    .onAppear {
                                        withAnimation(.easeOut(duration: 1.5)) {
                                            showPlusAnimation = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                            showPlusAnimation = false
                                        }
                                    }
                            }
                            Text("You won \(wheelViewModel.winner ?? 0)!")
                        }
                    } else if !wheelViewModel.hasSpunToday {
                        Text("Have a spin!")
                    }
                }
                .foregroundStyle(.white)
                .font(.title2)
                .fontDesign(.monospaced)
            }
            
            ZStack {
                Triangle()
                    .fill(Color.red)
                    .frame(width: 30, height: 50)
                    .rotationEffect(.degrees(180))
                    .offset(y: -200)
                
                ZStack {
                    ForEach(0..<wheelViewModel.segments.count, id: \.self) { i in
                        SegmentView(label: wheelViewModel.segments[i], index: i, totalSegments: wheelViewModel.segments.count, winnerIndex: $wheelViewModel.winnerIndex)
                    }
                    Button("Spin") {
                        if !wheelViewModel.isSpinning && !wheelViewModel.hasSpunToday {
                            playSpinSound()
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
                            withAnimation(.easeOut(duration: 1.5)) {
                                showMinusAnimation = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                showMinusAnimation = false
                            }
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
    
    func playSpinSound() {
        guard let url = Bundle.main.url(forResource: "wheelspinsound", withExtension: "wav") else {
            print("Ljudfilen hittades inte!")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer?.play()
        } catch {
            print("Kunde inte spela upp ljudet: \(error.localizedDescription)")
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
        
        ZStack {
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
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
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
        
        ZStack {
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
