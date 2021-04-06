//
//  ContentView.swift
//  ActivityFeed
//
//  Created by Justin Knoetzke on 2020-11-23.
//

import SwiftUI

import CoreData


struct ActivityView: View {

    let persistenceController = PersistenceController.shared

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CompletedRide.ride_date, ascending: false)],
        animation: .default)
    private var completedRide: FetchedResults<CompletedRide>
    
    var body: some View {
        
        NavigationView {
            
            List(completedRide, id: \.ride_date) { ride in
                ZStack {
                    NavigationLink(
                        destination: RideDetailsView(rideMetric: ride)) {
                        EmptyView()
                    }.buttonStyle(PlainButtonStyle())
                    VStack(alignment: .center) {
                        DateView(ride: ride)
                        Spacer()
                       ImageView(ride: ride)
                       HStack(alignment: .lastTextBaseline) {
                           RideTimeView(ride: ride)
                        //   Divider()
                           DistanceView(ride: ride)
                         //  Divider()
                           WattsView(ride:ride)
                         //  Divider()
                           ElevationView(ride: ride)
                          // Divider()
                           CaloriesView(ride: ride)
                           //Spacer()
                       }
                    }
                }
                .navigationTitle("Rides")
                
            }
        }
    }
    
    struct ImageView: View {
        let ride: CompletedRide
        var body: some View {
            let mapImage = ride.map_image
            Image(uiImage: UIImage(data:mapImage!)!)
                .resizable()
                .frame(width: 340, height: 300)
                .cornerRadius(16)
                .padding()
        }
    }
    
        
    struct RideTimeView: View {
        let ride: CompletedRide
        
        var body: some View {
            VStack() {
                Text("Ride Time").fixedSize().font(.system(size:10))
                Text(formatTime(timeInterval: ride.ride_time)).fixedSize()
            }
        }
    }
    
    struct DateView: View {
        let ride: CompletedRide
        
        var body: some View {
            VStack() {
                Text("Date").fixedSize().font(.system(size:15))
                Text(formatDate(rawDate: ride.ride_date ?? Date())).fixedSize()
            }
        }
    }
    
    struct DistanceView: View {
        let ride: CompletedRide
        
        var body: some View {
            VStack() {
                Text("Distance").fixedSize().font(.system(size:10))
                Text(String(ride.distance)+"km").fixedSize()
               

            }
        }
    }
    
    struct WattsView: View {
        let ride: CompletedRide
        
        var body: some View {
            VStack() {
                Text("Avg Watts").fixedSize().font(.system(size:10))
                Text(String(ride.average_watts)).fixedSize()
            }
        }
    }
    
    
    struct ElevationView: View {
        let ride: CompletedRide
        
        var body: some View {
            HStack(alignment: .lastTextBaseline) {
                VStack() {
                    Text("Elevation").fixedSize().font(.system(size:10))
                    Text(String(ride.elevation)).fixedSize()
                }
            }
        }
    }
    
    struct CaloriesView: View {
        let ride: CompletedRide
        
        var body: some View {
            HStack(alignment: .lastTextBaseline) {
                VStack() {
                    Text("Calories").fixedSize().font(.system(size:10))
                    Text(String(ride.calories)).fixedSize()
                }
            }
        }
    }
    
    
    struct MetricsView: View {
        let ride: CompletedRide
        
        var body: some View {
            let hours = Int(ride.ride_time) / 3600
            let minutes = Int(ride.ride_time) / 60 % 60
            let seconds = Int(ride.ride_time) % 60
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
