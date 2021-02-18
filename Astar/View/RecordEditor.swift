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
    @AppStorage("ROW1") private var selectedField: Int = 0
    var body: some View {
        NavigationLink(destination: MenuPicker(selectedField: $selectedField)) {
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
    @AppStorage("ROW2COL1") private var selectedField: Int = 0
    
    var body: some View {
        
        HStack {
            VStack {
                NavigationLink(destination: MenuPicker(selectedField: $selectedField)) {
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
    
    @AppStorage("ROW2COL2") private var selectedField: Int = 0

    var body: some View {
        VStack {
            NavigationLink(destination: MenuPicker(selectedField: $selectedField)) {

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
    @AppStorage("ROW3COL1") private var selectedField: Int = 0

    var body: some View {
        VStack {
            NavigationLink(destination: MenuPicker(selectedField: $selectedField)) {
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

    @AppStorage("ROW3COL2") private var selectedField: Int = 0

    var body: some View {
        VStack {
            NavigationLink(destination: MenuPicker(selectedField: $selectedField)) {

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
    @AppStorage("ROW4COL1") private var selectedField: Int = 0

    var body: some View {
        VStack {
            NavigationLink(destination: MenuPicker(selectedField: $selectedField)) {

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
    @AppStorage("ROW4COL2") private var selectedField: Int = 0

    var body: some View {
        VStack {
            NavigationLink(destination: MenuPicker(selectedField: $selectedField)) {

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
    
    @Binding var selectedField: Int
    
    var fields = ["Watts", "Heart Rate", "Speed", "Ride Time", "Cadence", "Lap #", "Lap AVG Watts"]
  
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
