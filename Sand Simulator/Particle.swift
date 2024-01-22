//
//  Particle.swift
//  Sand Simulator
//
//  Created by Don Espe on 1/17/24.
//

import Foundation
import SwiftUI

enum ParticleType: String, CaseIterable {

    case sand = "sand"
    case solid = "solid"
    case water = "water"
    case snow = "snow"
    case ice = "ice"
    case fire = "fire"
    case steam = "steam"
    case none = "blank"
}

let nonMoving:[ParticleType] = [.none, .solid]

struct Particle: Identifiable {
    var id = UUID()
//    var position: CGPoint
    var type: ParticleType
    var moved = false
    var active = true

    func color() -> Color {

        switch type {
            case .sand:
                return .yellow
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
