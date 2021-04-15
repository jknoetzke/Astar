//
//  RecordEditor.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-12-21.
//

import SwiftUI


var fields = ["Watts", "Heart Rate", "Speed", "Ride Time", "Cadence", "Lap #", "Lap AVG Watts", "Distance", "Lap Speed", "L/R Balance"]
var metrics = ["220", "146", "35", "1:24:43", "112", "2", "243", "25", "34", "52/48"]

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
                            Row4Col2()
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
            Text(fields[selectedField])
                .foregroundColor(.white)
                .font(.largeTitle)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
        }
        Text(metrics[selectedField])
            .foregroundColor(.white)
            .font(.system(size: 100))
            .frame(maxWidth: .infinity)
            .background(Color.green)
    }
}


struct Row2Col1: View {
    @AppStorage("ROW2COL1") private var selectedField: Int = 1

    var body: some View {
        
        HStack {
            VStack {
                NavigationLink(destination: MenuPicker(selectedField: $selectedField)) {
                    Text(fields[selectedField])
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                }
                Text(metrics[selectedField])
                    .foregroundColor(.white)
                    .font(.system(size: 100))
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
            }
        }
    }
}


struct Row2Col2: View {
    
    @AppStorage("ROW2COL2") private var selectedField: Int = 2
 
    var body: some View {
        VStack {
            NavigationLink(destination: MenuPicker(selectedField: $selectedField)) {
                Text(fields[selectedField])
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
            }
            Text(metrics[selectedField])
                .foregroundColor(.white)
                .font(.system(size: 100))
                .frame(maxWidth: .infinity)
                .background(Color.green)
        }
    }
}

struct Row3Col1: View {
    @AppStorage("ROW3COL1") private var selectedField: Int = 3
 
    var body: some View {
        VStack {
            NavigationLink(destination: MenuPicker(selectedField: $selectedField)) {
                Text(fields[selectedField])
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
            }
            Text(metrics[selectedField])
                .foregroundColor(.white)
                .font(.system(size: 40))
                .frame(maxWidth: .infinity)
                .background(Color.green)
        }
    }
}

struct Row3Col2: View {

    @AppStorage("ROW3COL2") private var selectedField: Int = 4
 
    
    var body: some View {
        VStack {
            NavigationLink(destination: MenuPicker(selectedField: $selectedField)) {
                Text(fields[selectedField])
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
            }
            Text(metrics[selectedField])
                .foregroundColor(.white)
                .font(.system(size: 40))
                .frame(maxWidth: .infinity)
                .background(Color.green)
        }
    }
}

struct Row4Col1: View {
    @AppStorage("ROW4COL1") private var selectedField: Int = 5

    var body: some View {
        VStack {
            NavigationLink(destination: MenuPicker(selectedField: $selectedField)) {
                Text(fields[selectedField])
                    .foregroundColor(.white)
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
            }
            Text(metrics[selectedField])
                .foregroundColor(.white)
                .font(.system(size: 80))
                .frame(maxWidth: .infinity)
                .background(Color.green)
        }
    }
}

struct Row4Col2: View {
    @AppStorage("ROW4COL2") private var selectedField: Int = 6

    var body: some View {
        VStack {
            NavigationLink(destination: MenuPicker(selectedField: $selectedField)) {
                Text(fields[selectedField])
                    .foregroundColor(.white)
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
            }
            Text(metrics[selectedField])
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
    
    var body: some View {
        Form {
            Section {
                Picker(selection: $selectedField, label: Text("Select Field")) {
                    ForEach(0 ..< fields.count) {
                        Text(fields[$0])
                    }
                }
            }

        }.navigationBarTitle("Recording Fields")
    }
}
