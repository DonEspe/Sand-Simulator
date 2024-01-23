//
//  Particle.swift
//  Sand Simulator
//
//  Created by Don Espe on 1/17/24.
//

import Foundation
import SwiftUI

enum ParticleType: String, CaseIterable {

    case sand = "Sand"
    case rainbowSand = "Rainbow Sand"
    case water = "Water"
    case snow = "Snow"
    case ice = "Ice"
    case fire = "Fire"
    case steam = "Steam"
    case solid = "Solid"
    case none = "Blank"
}

let nonMoving:[ParticleType] = [.none, .solid]

struct Particle: Identifiable {
    var id = UUID()
//    var position: CGPoint
    var type: ParticleType
    var moved = false
    var active = true
    var hueCount = 0.0

    func color() -> Color {

        switch type {
            case .sand:
                return .yellow
            case .rainbowSand:
                return Color(hue: hueCount, saturation: 1, brightness: 1)
            case .solid:
                return .gray
            case .water:
                return .blue
            case .snow:
                return .white
            case .steam:
                return .gray.opacity(0.4)
            case .ice:
                return .teal
            case .fire:
                return .red
            case .none:
                return .clear
        }
    }

}
