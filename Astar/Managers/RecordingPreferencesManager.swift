//
//  RecordingPreferencesManager.swift
//  Astar
//
//  Created by Justin Knoetzke on 2021-02-02.
//

import Foundation
import SwiftUI


class RecordingPreferencesManager {

    @AppStorage("ROW1")     var row1 = 0
    @AppStorage("ROW2COL1") var row2col1 = 0
    @AppStorage("ROW2COL2") var row2col2 = 0
    @AppStorage("ROW3COL1") var row3col1 = 0
    @AppStorage("ROW3COL2") var row3col2 = 0
    @AppStorage("ROW4COL1") var row4col1 = 0
    @AppStorage("ROW4COL2") var row4col2 = 0

    func rowColPreference(rowcol: String) -> Int {
        
        if rowcol == "ROW1" {
            return row1
        } else if rowcol == "ROW2COL1" {
            return row2col1
        } else if rowcol == "ROW2COL2" {
            return row2col2
        } else if rowcol == "ROW3COL1" {
            return row3col1
        } else if rowcol == "ROW3COL2" {
            return row3col2
        } else if rowcol == "ROW4COL1" {
            return row4col1
        } else if rowcol == "ROW4COL2" {
            return row4col2
        }

        return 0
    }
    
}
