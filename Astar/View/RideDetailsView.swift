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
    
    var rideMetric: CompletedRide
    var rideData = [PeripheralData]()
    
    
    init(rideMetric: CompletedRide) {
        self.rideMetric = rideMetric
        rideData = coreData.retrieveRide(rideID: rideMetric.ride_id!)!
    }
    
    
    var body: some View {
        
        ScrollView(.vertical) {
            VStack(alignment: .center) {
                Text(formatDate(rawDate: rideMetric.ride_date!))
                
                Spacer()
                Image(uiImage: UIImage(data: rideMetric.map_image!)!)
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
                    LapView(laps: rideMetric)
                }
            }
            
        }
    }
}

struct LapView: View {
    
    let laps:CompletedRide
    
    var body: some View {
        Text("Laps")
        Spacer()
        ForEach(laps.lapsArray, id: \.lap_number) { lap in
            HStack(alignment: .firstTextBaseline) {
                Spacer()
                VStack(alignment: .leading) {
                    Text("Ride Time:").fixedSize().font(.system(size:10))
                    Text(formatTime(timeInterval: lap.lap_time)).fixedSize()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Avg Watts:").fixedSize().font(.system(size:10))
                    Text(String(lap.average_watts)).fixedSize()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Distance:").fixedSize().font(.system(size:10))
                    Text(String(lap.distance)).fixedSize()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Heart Rate:").fixedSize().font(.system(size:10))
                    Text(String(lap.average_hr)).fixedSize()
                }
                
            }
        }
    }
}
 

struct MetricsView: View {
    
    let rideMetric: CompletedRide
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Ride Time:").fixedSize().font(.system(size:10))
            Text(formatTime(timeInterval: rideMetric.ride_time)).fixedSize()
        }
        Spacer()
        VStack(alignment: .leading) {
            Text("Avg Watts:").fixedSize().font(.system(size:10))
            Text(String(rideMetric.average_watts)).fixedSize()
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
    
    
    @AppStorage("FTP") var FTP: Int = 240
    
    var ride: [PeripheralData]
    
    let defaults = UserDefaults.standard
    //let FTP:Int!
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

        //FTP = defaults.integer(forKey: "FTP")
        points = loadPoints(rides: ride, points: points, legendDict: legendDict, FTP: Double(FTP))
    }
    
    var body: some View {
        let limit = DataPoint(value: Double(FTP), label: LocalizedStringKey(String(FTP)), legend: threshold)
        BarChartView(dataPoints: points, limit: limit )
    }
    
   
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
