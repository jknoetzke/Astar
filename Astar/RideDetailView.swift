//
//  RideDetailView.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-11-30.
//

import SwiftUI

struct RideDetailView: View {
    
    let ride: RideMetric
    
    var body: some View {
        VStack {
            Image(uiImage: ride.mapImage!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(16)
                .padding()
        
        BarCharTest()
            .frame(width: 340, height: 260)
        }
        HorizontalBarChart()
        LineChart()
            .frame(width: 340, height: 260)
    }
}



struct RideDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RideDetailView(ride: RideMetric(rideID: UUID(), avgWatts: 234, calories: 456, distance: 120, rideTime: 40004040, rideDate: Date(), elevation: 54, mapImage: #imageLiteral(resourceName: "map")))
    }
}
