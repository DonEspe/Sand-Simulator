//
//  Neighbor.swift
//  Sand Simulator
//
//  Created by Don Espe on 1/18/24.
//
import Foundation

struct Neighbor: Identifiable {
    var id = UUID()
    var x: Int
    var y: Int
    var priority: Double
//    var type: ParticleType
}

