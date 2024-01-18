//
//  Particle.swift
//  Sand Simulator
//
//  Created by Don Espe on 1/17/24.
//

import Foundation

enum ParticleType: String, CaseIterable {

    case sand = "sand"
    case solid = "solid"
    case water = "water"
    case none = "blank"
}

struct Particle: Identifiable {
    var id = UUID()
//    var position: CGPoint
    var type: ParticleType
}
