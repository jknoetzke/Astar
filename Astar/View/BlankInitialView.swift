//
//  BlankInitialView.swift
//  Astar
//
//  Created by Justin Knoetzke on 2021-06-12.
//

import SwiftUI

struct BlankInitialView: View {
    var body: some View {
        ZStack {
        Image("Astar")
            .resizable()
            .scaledToFit()
        Spacer()
        Text("Use record tab to record your first ride")
                .fontWeight(.bold)
                .font(.callout)
                .foregroundColor(.white)
            
        }
    }
}

struct BlankInitialView_Previews: PreviewProvider {
    static var previews: some View {
        BlankInitialView()
    }
}
