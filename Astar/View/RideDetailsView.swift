//
//  RideDetailView.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-11-30.
//

import SwiftUI
import SwiftUICharts

let coreData = CoreDataServices.sharedCoreDataService


struct RideDetailsView: View {
    
    var rideMetric: RideMetric
    var rideData = [PeripheralData]()

    
    init(rideMetric: RideMetric) {
        self.rideMetric = rideMetric
        rideData = coreData.retrieveRide(rideID: rideMetric.rideID)!

    }
    
    
    var body: some View {
        
        ScrollView(.vertical) {
            VStack(alignment: .center) {
                Text(formatDate(rawDate: rideMetric.rideDate))
                
                Spacer()
                Image(uiImage: rideMetric.mapImage!)
                    .resizable()
                    .frame(width: 340, height: 300)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(16)
                    .padding()
                Spacer()
                HStack(alignment: .lastTextBaseline) {
                    MetricsView(rideMetric: rideMetric)
                    Spacer()
                }
                RideBarChart(ride: rideData)
                     .frame(width: 340, height: 380)
                
                Spacer()
                if rideMetric.laps != nil {
                    LapView(rideMetric: rideMetric)
                }
            }
            
        }
    }
}

struct LapView: View {
    
    let rideMetric: RideMetric
    
    var body: some View {
        Text("Laps")
        Spacer()
        ForEach(rideMetric.laps!, id: \.lapNumber) { ride in
            HStack(alignment: .firstTextBaseline) {
                Spacer()
                VStack(alignment: .leading) {
                    Text("Ride Time:").fixedSize().font(.system(size:10))
                    Text(formatTime(timeInterval: ride.rideTime)).fixedSize()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Avg Watts:").fixedSize().font(.system(size:10))
                    Text(String(ride.avgWatts)).fixedSize()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Distance:").fixedSize().font(.system(size:10))
                    Text(String(ride.distance)).fixedSize()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Heart Rate:").fixedSize().font(.system(size:10))
                    Text(String(ride.heartRate)).fixedSize()
                }
                
            }
        }
    }
}

struct MetricsView: View {
    
    let rideMetric: RideMetric
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Ride Time:").fixedSize().font(.system(size:10))
            Text(formatTime(timeInterval: rideMetric.rideTime)).fixedSize()
        }
        Spacer()
        VStack(alignment: .leading) {
            Text("Avg Watts:").fixedSize().font(.system(size:10))
            Text(String(rideMetric.avgWatts)).fixedSize()
        }
        Spacer()
        VStack(alignment: .leading) {
            Text("Distance:").fixedSize().font(.system(size:10))
            Text(String(rideMetric.distance)).fixedSize()
        }
        Spacer()
        VStack(alignment: .leading) {
            Text("Calories:").fixedSize().font(.system(size:10))
            Text(String(rideMetric.calories)).fixedSize()
        }
        
        
    }
}

struct RideBarChart: View {
    
     var ride: [PeripheralData]
     let FTP = 240.0
     var points = [DataPoint]()
     var legendDict:[Int:Legend] = [:]
     let activeRecovery = Legend(color: .blue, label: "Active Recovery", order: 1)
     let endurance = Legend(color: .purple, label: "Endurance", order: 2)
     let tempo = Legend(color: .green, label: "Tempo", order: 3)
     let sweetSpot = Legend(color: .yellow, label: "Sweet Spot", order: 4)
     let threshold = Legend(color: .black, label: "Threshold", order: 5)
     let vo2max = Legend(color: .gray, label: "VO2Max", order: 6)
     let anaerobic =  Legend(color: .orange, label: "Anaerobic", order: 7)
     let neuro =  Legend(color: .red, label: "Neuromuscular", order: 8)
     
     init(ride: [PeripheralData]) {
     
     self.ride = ride
     legendDict[1] = activeRecovery
     legendDict[2] =  endurance
     legendDict[3] =  tempo
     legendDict[4] =  sweetSpot
     legendDict[5] =  threshold
     legendDict[6] =  vo2max
     legendDict[7] =  anaerobic
     legendDict[8] =  neuro
     
     points = loadPoints(rides: ride, points: points, legendDict: legendDict, FTP: FTP)
     
     
     
     }
     
     var body: some View {
     let limit = DataPoint(value: FTP, label: LocalizedStringKey(String(FTP)), legend: threshold)
     BarChartView(dataPoints: points, limit: limit )
     }
    
 /*
    var body: some View {
        let highIntensity = Legend(color: .orange, label: "High Intensity", order: 5)
        let buildFitness = Legend(color: .yellow, label: "Build Fitness", order: 4)
        let fatBurning = Legend(color: .green, label: "Fat Burning", order: 3)
        let warmUp = Legend(color: .blue, label: "Warm Up", order: 2)
        let low = Legend(color: .gray, label: "Low", order: 1)
        
        let limit = DataPoint(value: 130, label: "5", legend: fatBurning)
        
        let points: [DataPoint] = [
            .init(value: 70, label: "1", legend: low),
            .init(value: 90, label: "2", legend: warmUp),
            .init(value: 91, label: "3", legend: warmUp),
            .init(value: 92, label: "4", legend: warmUp),
            .init(value: 130, label: "5", legend: fatBurning),
            .init(value: 124, label: "6", legend: fatBurning),
            .init(value: 135, label: "7", legend: fatBurning),
            .init(value: 133, label: "8", legend: fatBurning),
            .init(value: 136, label: "9", legend: fatBurning),
            .init(value: 138, label: "10", legend: fatBurning),
            .init(value: 150, label: "11", legend: buildFitness),
            .init(value: 151, label: "12", legend: buildFitness),
            .init(value: 150, label: "13", legend: buildFitness),
            .init(value: 136, label: "14", legend: fatBurning),
            .init(value: 135, label: "15", legend: fatBurning),
            .init(value: 130, label: "16", legend: fatBurning),
            .init(value: 130, label: "17", legend: fatBurning),
            .init(value: 150, label: "18", legend: buildFitness),
            .init(value: 151, label: "19", legend: buildFitness),
            .init(value: 150, label: "20", legend: buildFitness),
            .init(value: 160, label: "21", legend: highIntensity),
            .init(value: 159, label: "22", legend: highIntensity),
            .init(value: 161, label: "23", legend: highIntensity),
            .init(value: 158, label: "24", legend: highIntensity),
        ]
        
        
        BarChartView(dataPoints: points, limit: limit)
    }
    */
    
}
func legend(watts: Int, FTP: Double, legendDict: [Int : Legend]) -> Legend {
    
    switch watts {
    
    case 0..<Int(FTP * 0.55): //Recovery
        return legendDict[1]!
    case Int(FTP * 0.55)..<Int(FTP * 0.75): //Endurance
        return legendDict[2]!
    case Int(FTP * 0.75)..<Int(FTP * 0.87): // Tempo
        return legendDict[3]!
    case Int(FTP * 0.87)..<Int(FTP * 0.94): //Sweetspot
        return legendDict[4]!
    case Int(FTP * 0.94)..<Int(FTP * 1.05): //Threshold
        return legendDict[5]!
    case Int(FTP * 1.05)..<Int(FTP * 1.20):
        return legendDict[6]!
    default:
        return legendDict[7]!
    }
    
}


func loadPoints(rides: [PeripheralData], points: [DataPoint], legendDict: [Int : Legend], FTP: Double) -> [DataPoint] {
    
    var count = 1
    
    var points = points
    
    for ride in rides {
        
        //        DataPoint(value: 200.0,      label: "Foobar",      legend: legend(watts: ride.power, FTP: FTP, legendDict: legendDict))
        points.append(DataPoint(value: Double(ride.power), label: LocalizedStringKey(String(count)), legend: legend(watts: ride.power, FTP: FTP, legendDict: legendDict)))
        count += 1
    }
    
    return points
}
