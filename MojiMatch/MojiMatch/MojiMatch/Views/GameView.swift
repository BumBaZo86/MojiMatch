//
//  GameView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.
//
import SwiftUI
import Firebase
import FirebaseFirestore

struct GameView: View {
    
    @ObservedObject var firebaseViewModel = FirebaseViewModel()
    
    @Binding var category: String
    @Binding var time: Double // (Difficulty)
    @Binding var noOfQuestions: Int
    @Binding var maxPoints : Int 
    @Binding var showGameView: Bool
    
    @State var questionCount = 0 //keeps track on how many questions that has been shown.
    @State var score = 0
    @State private var isGameOver = false
    @State var timeRemaining = 10.0
    @State var timer: Timer?
    
    //Affects if the stars are grey or yellow.
    @State var starOne : Bool = false
    @State var starTwo : Bool = false
    @State var starThree : Bool = false
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                Color(red: 113/256, green: 162/256, blue: 114/256)
                    .ignoresSafeArea()
                
                VStack {
                    
                        VStack{
                            
                            Text("Score: \(score)")
                            
                            ZStack {
                                
                                               //current score               // eg. 15 * 20 = 300 points available
                                ProgressView(value: Double(score), total: Double(noOfQuestions * maxPoints))
                                        .progressViewStyle(LinearProgressViewStyle())
                                        .tint(Color(red: 113/256, green: 162/256, blue: 114/256))
                                        .scaleEffect(y: 2) // thinkness of progressbar.
                                        .padding(.horizontal)
                                       
                                //Reads the width of the progress bar so we know where to put the stars. Reads all type of measurements if need be.
                                GeometryReader { geometry in
                                    
                                    let progressViewWidth = geometry.size.width
                                    
                                    Group {
                                        
                                        Image(systemName: "star.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame( //if star is true, it is bigger, false is smaller.
                                                width: starOne ? 45 : 25,
                                                height: starOne ? 45 : 25)
                                        
                                            .position(x: progressViewWidth * 0.2, y: 7)
                                            .foregroundStyle(starOne ? Color.yellow : Color.gray) //Changes color if the star depending if its true or false.
                                            
                                        Image(systemName: "star.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(starTwo ? Color.yellow : Color.gray)
                                            .frame(
                                                width: starTwo ? 45 : 25,
                                                height: starTwo ? 45 : 25)
                                            .position(x: progressViewWidth * 0.6, y: 7)
                                      
                                        
                                        Image(systemName: "star.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(starThree ? Color.yellow : Color.gray)
                                            .frame(
                                                width: starThree ? 45 : 25,
                                                height: starThree ? 45 : 25)
                                            .position(x: progressViewWidth * 1.0, y: 7)
                                       
                                    }
                                }
                                .frame(height: 20)
                                .padding(.horizontal)
                            }
                            .frame(height: 40)
                        }
                        .padding()
                            .frame(width: 350, height: 100)
                            .foregroundStyle(Color.black)
                            .background(Color.white)
                            .clipShape(.rect(cornerRadius: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 10)
                            )
                            .shadow(radius: 10.0, x: 20, y: 10)
                            .fontDesign(.monospaced)
                            .padding(.top)
                    
                    
                    //Fetch game question and show it.
                    if let question = firebaseViewModel.currentQuestion {
                        Text(question.question)
                            .customQuestionText()
                            .font(.system(size: fontSize(for: question.question)))
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .frame(width: 350, height: 300)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
                                )
                            
                            //Show answerOptions as buttons
                            VStack(spacing: 25) {
                                
                                HStack(spacing: 25) {
                                    Spacer()
                                    optionButton(text: firebaseViewModel.optionA)
                                    optionButton(text: firebaseViewModel.optionB)
                                    Spacer()
                                }
                                HStack(spacing: 25) {
                                    Spacer()
                                    optionButton(text: firebaseViewModel.optionC)
                                    optionButton(text: firebaseViewModel.optionD)
                                    Spacer()
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                        //Active timer show ticking down in MM:SS format.
                        HStack {
                            Spacer()
                            Text(String(format: "%02d:%02d", Int(ceil(timeRemaining)) / 60, Int(ceil(timeRemaining)) % 60))
                                .padding(.horizontal)
                                .padding(.top)
                        }
                        
                        //Progressbar works together with the timer to show remaining time.
                        ProgressView(value: max(0, timeRemaining), total: time)
                            .progressViewStyle(LinearProgressViewStyle())
                            .tint(.black)
                            .padding(.horizontal)
                            .padding(.bottom, 50)
                        
                    }
                    
                    //Navigate to GameOverView after game over.
                    NavigationLink(destination: GameOverView(score: score, showGameView: $showGameView, category: $category, time: $time, noOfQuestions: $noOfQuestions, maxPoints: $maxPoints, starOne: $starOne, starTwo: $starTwo, starThree: $starThree), isActive: $isGameOver) {
                        EmptyView()
                    }
                   
                }
            }
            //Fetch first question, answerOptions and start timer.
            .onAppear {
                firebaseViewModel.fetchQuestionAndAnswer(category: category)
                startTimer()
                
               
            }
        }
    }
    
    
    /**
     * Show answerOptions
     * Check if answer is correct
     * Adapt text size depending on how many characters each string has.
    
     */
    func optionButton(text: String) -> some View {
        Button(action: {
            checkAnswer(text)
        }) {
            Text(text)
        }
        .customAnswerOptions()
        .font(.system(size: text.count < 2 ? 70 : 10))
    }

    /**
     * Adapts the text size depending on how many characters each string has.
     */
    func fontSize(for text: String) -> CGFloat {
        if text.count < 3 {
            return 90
        } else if text.count < 8 {
            return 50
        } else {
            return 20
        }
    }
    
    /**
     * Check if answer is correct or not
     * If correct = score + 10 points.
     * Run checkStars()
     * After question is answered, either a new question is fetched or GameOverView is shown.
     * New timer starts again if a new question is fetched.
     */
    
    func checkAnswer(_ selected: String) {
        timer?.invalidate()
        
        if selected == firebaseViewModel.currentQuestion?.answer {
           
            if time == 5.0 {
                score += 30
            } else if time == 7.0 {
                score += 20
            } else {
                score += 10
            }
        }
        
        checkStars()
        
        questionCount += 1
        
        if questionCount < noOfQuestions {
            firebaseViewModel.fetchQuestionAndAnswer(category: category)
            startTimer()
        } else {
            isGameOver = true
        }
    }
    
    
    /**
     * Timer starts.
     * If a timer is already running, stops it and then starts a new one.
     * If timer runs out of time, checks if a new question is being fetched or if it is GameOver.
     * Updates every 0.1 seconds. 
     */
    
    func startTimer() {
        timer?.invalidate()
        timeRemaining = time
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { tim in
            if timeRemaining <= 0 {
                tim.invalidate()
                self.timer = nil
                self.questionCount += 1
                
                if self.questionCount < self.noOfQuestions {
                    firebaseViewModel.fetchQuestionAndAnswer(category: category)
                    startTimer()
                } else {
                    isGameOver = true
                }
            } else {
                self.timeRemaining -= 0.1
            }
        }
    }
    
    /**
     * If you get a score of 1/5, 3/5 or 5/5, you get a new star that is shown on the progressview. 
     */
    func checkStars() {
        
        if score == (maxPoints * noOfQuestions) / 5 {
            starOne = true
        } else if score == ((maxPoints * noOfQuestions) / 5) * 3 {
            starTwo = true
        } else if score == (maxPoints * noOfQuestions) {
            starThree = true
        }
    }
}


