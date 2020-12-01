//
//  ContentView.swift
//  ActivityFeed
//
//  Created by Justin Knoetzke on 2020-11-23.
//

import SwiftUI

let coreData = CoreDataServices()

struct ContentView: View {
    
    @ObservedObject var coreDataService: CoreDataServices

    var body: some View {
        
        NavigationView {
            
            List(coreDataService.rideMetrics, id: \.rideID) { ride in
                ZStack {
                    RideCell(ride: ride)
                    NavigationLink(
                        destination: RideDetailView(ride: ride)) {
                        EmptyView()
                    }.buttonStyle(PlainButtonStyle())
                    
                    
                    VStack(alignment: .center) {
                        DateView(ride: ride)
                        Spacer()
                        ImageView(ride: ride)
                        HStack(alignment: .lastTextBaseline) {
                            RideTimeView(ride: ride)
                            Spacer()
                            DistanceView(ride: ride)
                            Spacer()
                            WattsView(ride:ride)
                            Spacer()
                            ElevationView(ride: ride)
                            Spacer()
                            CaloriesView(ride: ride)
                        }
                    }
                }
                .navigationTitle("Your Rides")
                
            }
        }
    }
    struct ImageView: View {
        let ride: RideMetric
        var body: some View {
            let mapImage = ride.mapImage
            Image(uiImage: mapImage!)
                .resizable()
                .frame(width: 340, height: 300)
                .cornerRadius(16)
                .padding()
        }
    }
    
        
    struct RideTimeView: View {
        let ride: RideMetric
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Ride Time:").fixedSize().font(.system(size:10))
                Text(formatTime(timeInterval: ride.rideTime)).fixedSize()
            }
        }
    }
    
    struct DateView: View {
        let ride: RideMetric
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Date:").fixedSize().font(.system(size:10))
                Text(formatDate(rawDate: ride.rideDate)).fixedSize()
            }
        }
    }
    
    struct DistanceView: View {
        let ride: RideMetric
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Distance:").fixedSize().font(.system(size:10))
                Text(String(ride.distance / 1000)).fixedSize()
            }
        }
    }
    
    struct WattsView: View {
        let ride: RideMetric
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Avg Watts:").fixedSize().font(.system(size:10))
                Text(String(ride.avgWatts)).fixedSize()
            }
        }
    }
    
    
    struct ElevationView: View {
        let ride: RideMetric
        
        var body: some View {
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading) {
                    Text("Elevation:").fixedSize().font(.system(size:10))
                    Text(String(ride.elevation)).fixedSize()
                }
            }
        }
    }
    
    struct CaloriesView: View {
        let ride: RideMetric
        
        var body: some View {
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading) {
                    Text("Calories:").fixedSize().font(.system(size:10))
                    Text(String(ride.calories)).fixedSize()
                }
            }
        }
    }
    
    
    struct MetricsView: View {
        let ride: RideMetric
        
        var body: some View {
            let hours = Int(ride.rideTime) / 3600
            let minutes = Int(ride.rideTime) / 60 % 60
            let seconds = Int(ride.rideTime) % 60
            let rideTime = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
            Text(rideTime)
            Spacer()
            Text(String(ride.distance / 1000))
            Spacer()
            Text(String(ride.elevation))
            Spacer()
            Text(String(ride.calories))
        }
    }
}

func formatDate(rawDate: Date) -> String {
    
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    formatter.timeStyle = .none
    let date = formatter.string(from: rawDate)
    
    return date
}

func formatTime(timeInterval: Double) -> String {
    let hours = Int(timeInterval) / 3600
    let minutes = Int(timeInterval) / 60 % 60
    let seconds = Int(timeInterval) % 60
    let time = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    
    return time
    
}

struct RideCell: View {
    let ride: RideMetric
    
    var body: some View {
        Text("Hello!")
    }
}


/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(rides: CoreDataServices())
    }
}
 */
