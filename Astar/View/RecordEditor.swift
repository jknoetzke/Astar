//
//  RecordEditor.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-12-21.
//

import SwiftUI

struct RecordEditor: View {
    
    var body: some View {
        
            ZStack {
                Color.blue
                    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                
                HStack {
                    VStack {
                        
                        Watts()
                        Spacer()
                        HStack {
                            HeartRate()
                            Speed()
                        }
                        Spacer()
                        HStack {
                            RideTime()
                            Cadence()
                        }
                        Spacer()
                        HStack {
                            Lap()
                            LapAvgWatts()
                        }
                        
                        
                        Spacer()
                        HStack {
                            Button(action: {
                                print("Play Pressed")
                            }, label: {
                                ZStack {
                                    Image(systemName: "play")
                                        .resizable()
                                        .frame(width: 120, height: 80)
                                        .font(.largeTitle)
                                        .foregroundColor(.black)
                                    Text("Start")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                    
                                }
                            })
                            Button(action: {
                                print("Lap Pressed")
                            }, label: {
                                ZStack {
                                    Image(systemName: "repeat")
                                        .resizable()
                                        .frame(width: 120, height: 80)
                                        .font(.largeTitle)
                                        .foregroundColor(.black)
                                    Text("Lap")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                }
                            })
                            
                        }
                        
                    }
                }
            }
        }
    }





struct Watts: View {
    
    var body: some View {
        NavigationView {
            NavigationLink(destination: MenuPicker()) {
                    Text("Watts")
                }
     //           .navigationBarTitle("Navigation")
        
        
        //Text("Watts")
        //    .foregroundColor(.white)
        //    .font(.title)
        //    .frame(maxWidth: .infinity)
        //    .background(Color.blue)
        
        Text("100")
            .foregroundColor(.white)
            .font(.system(size: 150))
            .frame(maxWidth: .infinity)
            .background(Color.green)
        
    }
    }
    
}


struct HeartRate: View {
    var body: some View {
        
        HStack {
            VStack {
                Text("Heart Rate")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                
                Text("146")
                    .foregroundColor(.white)
                    .font(.system(size: 100))
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
            }
        }
    }
}


struct Speed: View {
    var body: some View {
        VStack {
            Text("Speed")
                .foregroundColor(.white)
                .font(.largeTitle)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
            
            Text("42")
                .foregroundColor(.white)
                .font(.system(size: 100))
                .frame(maxWidth: .infinity)
                .background(Color.green)
        }
    }
}

struct RideTime: View {
    var body: some View {
        VStack {
            Text("Ride Time")
                .foregroundColor(.white)
                .font(.largeTitle)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
            Text("00:00:00")
                .foregroundColor(.white)
                .font(.system(size: 40))
                .frame(maxWidth: .infinity)
                .background(Color.green)
        }
    }
}

struct Cadence: View {
    var body: some View {
        VStack {
            Text("Cadence")
                .foregroundColor(.white)
                .font(.largeTitle)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
            
            Text("96")
                .foregroundColor(.white)
                .font(.system(size: 40))
                .frame(maxWidth: .infinity)
                .background(Color.green)
        }
    }
}

struct Lap: View {
    var body: some View {
        VStack {
            Text("Lap #")
                .foregroundColor(.white)
                .font(.title)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
            
            Text("1")
                .foregroundColor(.white)
                .font(.system(size: 80))
                .frame(maxWidth: .infinity)
                .background(Color.green)
        }
    }
}
struct LapAvgWatts: View {
    var body: some View {
        VStack {
            Text("Lap AVG Watts")
                .foregroundColor(.white)
                .font(.title)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
            
            Text("224")
                .foregroundColor(.white)
                .font(.system(size: 80))
                .frame(maxWidth: .infinity)
                .background(Color.green)
        }
    }
}

struct RecordEditor_Previews: PreviewProvider {
    static var previews: some View {
        RecordEditor()
    }
}

struct MenuPicker: View {
    var strengths = ["Mild", "Medium", "Mature"]

    @State private var selectedStrength = 0

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: $selectedStrength, label: Text("S∫trength")) {
                        ForEach(0 ..< strengths.count) {
                            Text(self.strengths[$0])

                        }
                    }
                }
            }.navigationBarTitle("Select your cheese")

        }
    }
}
