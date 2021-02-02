//
//  RecordEditor.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-12-21.
//

import SwiftUI

struct RecordEditor: View {

    var body: some View {
        NavigationView {
            ZStack {
                Color.blue
                    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                
                HStack {
                    VStack {
                        Row1()
                        Spacer()
                        HStack {
                            Row2Col1()
                            Row2Col2()
                        }
                        Spacer()
                        HStack {
                            Row3Col1()
                            Row3Col2()
                        }
                        Spacer()
                        HStack {
                            Row4Col1()
                            Row4Col1()
                        }
                        
                    }
                }
            }
            
        }
        
    }
}

struct Row1: View {
    var recordingPreferences = RecordingPreferencesManager()
    var body: some View {
        NavigationLink(destination: MenuPicker(selectedField: recordingPreferences.rowColPreference(rowcol: "ROW1"))) {
            Text("Watts")
                .foregroundColor(.white)
                .font(.largeTitle)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
        }
        Text("100")
            .foregroundColor(.white)
            .font(.system(size: 100))
            .frame(maxWidth: .infinity)
            .background(Color.green)
        
    }
    
}


struct Row2Col1: View {
    var recordingPreferences = RecordingPreferencesManager()
    
    var body: some View {
        
        HStack {
            VStack {
                NavigationLink(destination: MenuPicker(selectedField: recordingPreferences.rowColPreference(rowcol: "ROW2COL1"))) {
                    Text("Heart Rate")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                }
                Text("146")
                    .foregroundColor(.white)
                    .font(.system(size: 100))
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
            }
        }
    }
}


struct Row2Col2: View {
    
    var recordingPreferences = RecordingPreferencesManager()
    
    var body: some View {
        VStack {
            NavigationLink(destination: MenuPicker(selectedField: recordingPreferences.rowColPreference(rowcol: "ROW2COL2"))) {
                
                Text("Speed")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
            }
            Text("42")
                .foregroundColor(.white)
                .font(.system(size: 100))
                .frame(maxWidth: .infinity)
                .background(Color.green)
        }
    }
}

struct Row3Col1: View {
    var recordingPreferences = RecordingPreferencesManager()
    
    var body: some View {
        VStack {
            NavigationLink(destination: MenuPicker(selectedField: recordingPreferences.rowColPreference(rowcol: "ROW3COL1"))) {
                Text("Ride Time")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
            }
            Text("00:00:00")
                .foregroundColor(.white)
                .font(.system(size: 40))
                .frame(maxWidth: .infinity)
                .background(Color.green)
        }
    }
}

struct Row3Col2: View {

    var recordingPreferences = RecordingPreferencesManager()

    var body: some View {
        VStack {
            NavigationLink(destination: MenuPicker(selectedField: recordingPreferences.rowColPreference(rowcol: "ROW3COL2"))) {

                Text("Cadence")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
            }
            Text("96")
                .foregroundColor(.white)
                .font(.system(size: 40))
                .frame(maxWidth: .infinity)
                .background(Color.green)
        }
    }
}

struct Row4Col1: View {
    var recordingPreferences = RecordingPreferencesManager()
    var body: some View {
        VStack {
            NavigationLink(destination: MenuPicker(selectedField: recordingPreferences.rowColPreference(rowcol: "ROW4COL1"))) {
                
                Text("Lap #")
                    .foregroundColor(.white)
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
            }
            Text("1")
                .foregroundColor(.white)
                .font(.system(size: 80))
                .frame(maxWidth: .infinity)
                .background(Color.green)
        }
    }
}

struct Row4Col2: View {
    var recordingPreferences = RecordingPreferencesManager()
    var body: some View {
        VStack {
            NavigationLink(destination: MenuPicker(selectedField: recordingPreferences.rowColPreference(rowcol: "ROW4COL2"))) {
                
                Text("Lap AVG Watts")
                    .foregroundColor(.white)
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
            }
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
    
    @AppStorage("ROW1")     var row1 = 0
    @AppStorage("ROW2COL1") var row2col1 = 0
    @AppStorage("ROW2COL2") var row2col2 = 0
    @AppStorage("ROW3COL1") var row3col1 = 0
    @AppStorage("ROW3COL2") var row3col2 = 0
    @AppStorage("ROW4COL1") var row4col1 = 0
    @AppStorage("ROW4COL2") var row4col2 = 0
    
    var fields = ["Watts", "Heart Rate", "Speed", "Ride Time", "Cadence", "Lap #", "Lap AVG Watts"]
    
    
    @State var selectedField: Int
    
    var body: some View {
        Form {
            Section {
                Picker(selection: $selectedField, label: Text("Select Field")) {
                    ForEach(0 ..< fields.count) {
                        Text(self.fields[$0])
                        
                    }
                }
            }
        }.navigationBarTitle("Recording Fields")
        
    }
}
