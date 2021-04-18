//
//  RideDetailView.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-11-30.
//

import SwiftUI
import SwiftUICharts

let coreData = CoreDataServices.sharedCoreDataService

var points = [DataPoint]()
var legendDict:[Int:Legend] = [:]
let activeRecovery = Legend(color: .blue, label: "Active Recovery", order: 1)
let endurance = Legend(color: .purple, label: "Endurance", order: 2)
let tempo = Legend(color: .green, label: "Tempo", order: 3)
let sweetSpot = Legend(color: .yellow, label: "Sweet Spot", order: 4)
let threshold = Legend(color: .pink, label: "Threshold", order: 5)
let vo2max = Legend(color: .gray, label: "VO2Max", order: 6)
let anaerobic =  Legend(color: .orange, label: "Anaerobic", order: 7)
let neuro =  Legend(color: .red, label: "Neuromuscular", order: 8)

var maxWatts = 0
var totalRideTime = 0.0
var smoothRideTime = 0.0

struct RideDetailsView: View {
    
    var rideMetric: CompletedRide
    var rideData = [PeripheralData]()
    
    init(rideMetric: CompletedRide) {
        self.rideMetric = rideMetric
        rideData = coreData.retrieveRide(rideID: rideMetric.ride_id!)!
    }
    
    
    var body: some View {
        
        ScrollView(.vertical) {
            VStack() {
                Text(formatDate(rawDate: rideMetric.ride_date!))
                
                Spacer()
                Image(uiImage: UIImage(data: rideMetric.map_image!)!)
                    .resizable()
                    .scaledToFit()
                    .layoutPriority(-1)
                    .cornerRadius(16)
                    

                Spacer()
                HStack(alignment: .lastTextBaseline) {
                    MetricsView(rideMetric: rideMetric)
                    Spacer()
                }
                RideBarChart(ride: rideData)
                .frame(width: 340, height: 380)
                .scaledToFill()
                .padding()
                
                Text(String(format: "Samples smoothed to %.0f seconds", smoothRideTime))
                    .font(.footnote)
                    
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
        VStack() {
            Text("Ride Time:").fixedSize().font(.system(size:10))
            Text(formatTime(timeInterval: rideMetric.ride_time)).fixedSize()
        }
        Spacer()
        VStack() {
            Text("Avg Watts:").fixedSize().font(.system(size:10))
            Text(String(rideMetric.average_watts)).fixedSize()
        }
        Spacer()
        VStack() {
            Text("Distance:").fixedSize().font(.system(size:10))
            Text(String(rideMetric.distance)).fixedSize()
        }
        Spacer()
        VStack() {
            Text("Calories:").fixedSize().font(.system(size:10))
            Text(String(rideMetric.calories)).fixedSize()
        }
        
        
    }
}

struct RideBarChart: View {
    
    
    @AppStorage("FTP") var FTP: String = "230"
    
    var ride: [PeripheralData]
    
    let defaults = UserDefaults.standard
    
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

        loadPoints(rides: ride, legendDict: legendDict, FTP: Double(FTP)!)
   
    }
    
    
    var body: some View {

        //let thresholdLimit = maxWatts / Int(FTP)!
        let thresholdLimit = Double(maxWatts) / Double(FTP)!
        let limitBar = (Double(maxWatts) / thresholdLimit) * 1.95
        let limit = DataPoint(value: Double(limitBar), label: LocalizedStringKey("FTP:  \(FTP)" ), legend: threshold)
        if points.count != 0 {
            BarChartView(dataPoints: points, limit: limit )
        }
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


func loadPoints(rides: [PeripheralData], legendDict: [Int : Legend], FTP: Double) -> [DataPoint] {
    
    var count = 1
    var totalWatts = 0
    let smoother = rides.count / 25
    let timeSmoother = rides.count / 3
    var timeLabel = ""
    let firstTimestamp = (rides.first?.timeStamp)!
    var totalCount = 0
    points.removeAll()
    
    maxWatts = 0
    totalRideTime = 0.0
    smoothRideTime = 0.0
    
    
    maxWatts = 0

    for ride in rides {
        
        totalCount += 1
        if timeSmoother == totalCount {
            let timeSplit = ride.timeStamp.timeIntervalSince(firstTimestamp)
            timeLabel = formatTime(timeInterval: timeSplit)
            totalCount = 0
        }

        if count == smoother {
 
            let watts = totalWatts / count

            if maxWatts < watts {
                maxWatts = watts
            }
            
            points.append(DataPoint(value: Double(watts), label: LocalizedStringKey(timeLabel), legend: legend(watts: watts, FTP: FTP, legendDict: legendDict)))
            count = 0
            totalWatts = 0
            timeLabel = ""
        }
        count += 1
        totalWatts = totalWatts + ride.power
        
    }
    
    totalRideTime = rides.last!.timeStamp.timeIntervalSince(firstTimestamp)
    smoothRideTime = (totalRideTime / Double(smoother))
    
    if(maxWatts != 0) {
        return points
    } else {
        points.removeAll()
        return points
    }
}
