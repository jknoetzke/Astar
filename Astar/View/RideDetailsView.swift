//
//  RideDetailView.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-11-30.
//

import SwiftUI
import SwiftUICharts

let coreData = CoreDataServices.sharedCoreDataService


var legendDict:[Int:Legend] = [:]
var legendDictElevation:[Int:Legend] = [:]


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
                Spacer()
                RideBarChart(ride: rideData)
                .scaledToFit()

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
                    Text("Elevation:").fixedSize().font(.system(size:10))
                    Text(String(lap.elevation)).fixedSize()
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
            Text("Elevation:").fixedSize().font(.system(size:10))
            Text(String(rideMetric.elevation)).fixedSize()
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
    var points = [DataPoint]()
    
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
        
        points = loadPoints(rides: ride, legendDict: legendDict, FTP: Double(FTP)!)
   
    }
    
    
    var body: some View {

        let limitBar = 180.0
        let limit = DataPoint(value: limitBar, label: LocalizedStringKey("FTP:  \(FTP)" ), legend: threshold)
        let elevationPoints = loadElevationPoints(rides: ride)
        if points.count != 0 {
            BarChartView(dataPoints: points, limit: limit )
        }
        if elevationPoints.count != 0 {
            LineChartView(dataPoints: points)
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
    var points = [DataPoint]()
    
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

func loadElevationPoints(rides: [PeripheralData]) -> [DataPoint] {
    
    var count = 1
    let smoother = rides.count / 25
    var points = [DataPoint]()
    var totalElevation = 0.0
    
    let extraHigh = Legend(color: .yellow, label: "Build Fitness", order: 4)
    let high = Legend(color: .green, label: "Fat Burning", order: 3)
    let medium = Legend(color: .blue, label: "Warm Up", order: 2)
    let low = Legend(color: .gray, label: "Low", order: 1)
    
    for ride in rides {
   
        totalElevation += ride.elevation
        count += 1
        if count == smoother {
            
          //  points.append(DataPoint(value: totalElevation / Double(count)))
            count = 0
            
        }
    
    }
    
    
    return points
}


struct ElevationChart: View {
    

    var ride: [PeripheralData]

    

    var points: [DataPoint]
    
    init(ride: [PeripheralData]) {

        self.ride = ride
        points = loadElevationPoints(rides: ride)
        
        /*
        points = [
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
            .init(value: 150, label: "13", legend: buildFitness)
        ]
       */
    }
    
    
    var body: some View {
    


        LineChartView(dataPoints: points)
    
    }

}
