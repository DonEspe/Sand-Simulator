//
//  ContentView.swift
//  Sand Simulator
//
//  Created by Don Espe on 1/17/24.
//

import SwiftUI

let playSize = (width: 150, height: 200)

struct ContentView: View {
    let timer = Timer.publish(every: 0.06, on: .main, in: .common).autoconnect()
    @State var paused = true

    @State var map = Array(repeating: Array(repeating: Particle(type: .none), count: Int(playSize.height)), count: Int(playSize.width))
    @State var drawType: ParticleType = .sand

    var trackReset = [(x: Int, y: Int)]()

    var body: some View {
        VStack {
            Text("Sand Simulator")
                .bold()
                .font(.title)
                .padding(.bottom)
            ZStack {
                Rectangle()
                    .stroke(lineWidth: 1)
                    .foregroundColor(.blue)

                Canvas { context, size in
                    for y in 0..<playSize.height {
                        for x in 0..<playSize.width {
                            context.fill(

                            Path(roundedRect: CGRect(origin: CGPoint(x: CGFloat(x * 2), y: CGFloat(y * 2)), size: CGSize(width: 2, height: 2)), cornerSize: CGSize(width: 0, height: 0)),
                                 with: .color(particleColor(particle: map[x][y])))
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
//                            paused = true
                            let useLocation = (x: Int(value.location.x / 2), y: Int(value.location.y / 2))
                            if useLocation.y < playSize.height - 1 && useLocation.x < playSize.width - 1 && useLocation.x > 0 && useLocation.y > 0 {
                                map[useLocation.x][useLocation.y].type = drawType
                                map[useLocation.x + 1][useLocation.y].type = drawType
                                map[useLocation.x][useLocation.y + 1].type = drawType
                                map[useLocation.x + 1][useLocation.y + 1].type = drawType
                            }
                        }
                        .onEnded { _ in
//                            paused = false
                        }
                )


            }
            .frame(width: CGFloat(playSize.width * 2), height: CGFloat(playSize.height * 2))
            .padding()

            Picker("Particle type", selection: $drawType) {
                ForEach(ParticleType.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)

            Toggle(isOn: $paused) {
                Text("Pause")
            }

            Button(action: {
                map = Array(repeating: Array(repeating: Particle(type: .none), count: Int(playSize.height)), count: Int(playSize.width))
            }) {
                Text("Reset")
            }

            Spacer()
        }
        .onReceive(timer, perform: { _ in
            if paused {
                return
            }

            map[Int.random(in: 0..<playSize.width)][0].type = drawType
//            map[Int.random(in: 0..<playSize.width)][0].type = .snow
//            map[Int.random(in: 0..<playSize.width)][0].type = .sand
//            map[Int.random(in: 0..<playSize.width)][0].type = .sand
//            map[Int.random(in: 0..<playSize.width)][0].type = .sand
//            map[Int.random(in: 0..<playSize.width)][0].type = .water

            for i in 0..<playSize.width {
                for j in (0..<playSize.height).reversed() {
                    map = moveParticle(particles: map, position: (x: i, y: j))
                }
            }

//            for i in 0..<playSize.width {
//                for j in (0..<playSize.height) {
//                    map[i][j].moved = false
//                }
//            }
        })
        .onAppear {
            for _ in 0...1000 {
//                map[Int.random(in: 1..<Int(playSize.width))][ Int.random(in: 1..<Int(playSize.height))] = Particle(type:  ParticleType.allCases.randomElement() ?? .solid)
//                map[Int.random(in: 0..<Int(playSize.width))][ Int.random(in: 30..<200)] = Particle(type:  ParticleType.solid)
            }
            paused.toggle()
        }
//        .animation(.linear, value: colony)
    }

    func moveParticle(particles: [[Particle]], position: (x: Int, y: Int)) -> [[Particle]] {
        let particle = map[position.x][position.y]
        if particle.type == .none || particle.type == .solid {
            return particles
        }
        var tempMap = particles
        var neighbors = [Neighbor]()
        switch particle.type {
            case .solid:
                return tempMap

            case .none:
                return tempMap

            case .sand:
                if let down = calcNeighbor(position: (x: position.x, y: position.y + 1), priority: 1.0, open: [.water, .none, .fire, .steam]) {
                    neighbors.append(down)
                }
                if let downRight = calcNeighbor(position: (x: position.x - 1, y: position.y + 1), priority: 0.75, open: [.water, .none, .fire, .steam]) {
                    neighbors.append(downRight)
                }
                if let downLeft = calcNeighbor(position: (x: position.x + 1, y: position.y + 1), priority: 0.75, open: [.water, .none, .steam]){
                    neighbors.append(downLeft)
                }
                if let right = calcNeighbor(position: (x: position.x - 1, y: position.y), priority: 0.1, open: [.none]) {
                    neighbors.append(right)
                }
                if let left = calcNeighbor(position: (x: position.x + 1, y: position.y), priority: 0.1, open: [.none]){
                    neighbors.append(left)
                }
                if let right = calcNeighbor(position: (x: position.x - 1, y: position.y), priority: 0.6, open: [.water]) {
                    neighbors.append(right)
                }
                if let left = calcNeighbor(position: (x: position.x + 1, y: position.y), priority: 0.6, open: [.water]){
                    neighbors.append(left)
                }


            case .fire:
                if let down = calcNeighbor(position: (x: position.x, y: position.y + 1), priority: 1.0, open: [.water, .none, .snow, .ice]) {
                    neighbors.append(down)
                }
                if let downRight = calcNeighbor(position: (x: position.x - 1, y: position.y + 1), priority: 0.75, open: [.water, .none, .snow, .ice]) {
                    neighbors.append(downRight)
                }
                if let downLeft = calcNeighbor(position: (x: position.x + 1, y: position.y + 1), priority: 0.75, open: [.water, .none, .snow, .ice]){
                    neighbors.append(downLeft)
                }
                if let right = calcNeighbor(position: (x: position.x - 1, y: position.y), priority: 0.2, open: [.water, .snow, .ice, .none]) {
                    neighbors.append(right)
                }
                if let left = calcNeighbor(position: (x: position.x + 1, y: position.y), priority: 0.2, open: [.water, .snow, .ice, .none]){
                    neighbors.append(left)
                }

            case .snow:
                if let down = calcNeighbor(position: (x: position.x, y: position.y + 1), priority: 1.0, open: [.none, .sand, .water]) {
                    neighbors.append(down)
                }
                if let downRight = calcNeighbor(position: (x: position.x - 1, y: position.y + 1), priority: 0.2, open: [.none, .sand, .water]) {
                    neighbors.append(downRight)
                }
                if let downLeft = calcNeighbor(position: (x: position.x + 1, y: position.y + 1), priority: 0.2, open: [.none, .sand, .water]) {
                    neighbors.append(downLeft)
                }

            case .ice:
                if let down = calcNeighbor(position: (x: position.x, y: position.y + 1), priority: 1.0, open: [.none, .sand, .water]) {
                    neighbors.append(down)
                }
                if let right = calcNeighbor(position: (x: position.x - 1, y: position.y), priority: 0.1, open: [.water]) {
                    neighbors.append(right)
                }
                if let left = calcNeighbor(position: (x: position.x + 1, y: position.y), priority: 0.1, open: [.water]) {
                    neighbors.append(left)
                }

            case .water:
                if let down = calcNeighbor(position: (x: position.x, y: position.y + 1), priority: 1.0, open: [.none, .fire, .steam]) {
                    neighbors.append(down)
                }
                if let downRight = calcNeighbor(position: (x: position.x - 1, y: position.y + 1), priority: 0.95, open: [.none, .fire, .steam]) {
                    neighbors.append(downRight)
                }
                if let downLeft = calcNeighbor(position: (x: position.x + 1, y: position.y + 1), priority: 0.95, open: [.none, .fire, .steam]){
                    neighbors.append(downLeft)
                }
                if let right = calcNeighbor(position: (x: position.x - 1, y: position.y), priority: 0.8, open: [.none, .fire]) {
                    neighbors.append(right)
                }
                if let left = calcNeighbor(position: (x: position.x + 1, y: position.y), priority: 0.8, open: [.none, .fire]) {
                    neighbors.append(left)
                }

            case .steam:
                if let up = calcNeighbor(position: (x: position.x, y: position.y - 1), priority: 1.0, open: [.none, .fire, .water]) {
                    neighbors.append(up)
                }
                if let upRight = calcNeighbor(position: (x: position.x - 1, y: position.y - 1), priority: 0.75, open: [.none, .fire, .water]) {
                    neighbors.append(upRight)
                }
                if let upLeft = calcNeighbor(position: (x: position.x + 1, y: position.y - 1), priority: 0.75, open: [.none, .fire, .water]){
                    neighbors.append(upLeft)
                }

        }
        var finalChoice:Neighbor? = nil

        if let highestRank = neighbors.max(by: { $0.priority < $1.priority }) {
                        let choices = neighbors.filter {
                            $0.priority == highestRank.priority
                        }
            finalChoice = choices.randomElement()
        }

        guard finalChoice != nil else { return tempMap }
        switch particle.type
        {
            case .none, .solid:
                break

            case .sand:
                if finalChoice!.priority == 1 || finalChoice!.priority > Double.random(in: 0...1) {
                    tempMap[position.x][position.y].type = tempMap[finalChoice!.x][finalChoice!.y].type
                    tempMap[finalChoice!.x][finalChoice!.y].type = .sand
                }
            case .steam:
                if position.y <= 2 {
                    tempMap[position.x][position.y].type = .none
                } else if !tempMap[position.x][position.y].moved {
                    tempMap[position.x][position.y].type = tempMap[finalChoice!.x][finalChoice!.y].type
                    tempMap[position.x][position.y].moved = false
                    tempMap[finalChoice!.x][finalChoice!.y].type = .steam
                    tempMap[finalChoice!.x][finalChoice!.y].moved = true
                } else {
                    tempMap[position.x][position.y].moved = false
                }

            case .snow:
                if tempMap[finalChoice!.x][finalChoice!.y].type == .water || tempMap[finalChoice!.x][finalChoice!.y].type == .sand {
                    tempMap[position.x][position.y].type = .water
                } else {
                    tempMap[position.x][position.y].type = .none //tempMap[finalChoice!.x][finalChoice!.y].type
                    tempMap[finalChoice!.x][finalChoice!.y].type = .snow
                }

            case .water:
                if tempMap[finalChoice!.x][finalChoice!.y].type == .ice  {
                  /*  tempMap[finalChoice!.x][finalChoice!.y].type == .snow ||*/ /*tempMap[finalChoice!.x][finalChoice!.y].type == .ice*/
                    tempMap[position.x][position.y].type = .ice
                } else if tempMap[finalChoice!.x][finalChoice!.y].type == .fire {
                    tempMap[position.x][position.y].type = .none //tempMap[finalChoice!.x][finalChoice!.y].type
                    tempMap[finalChoice!.x][finalChoice!.y].type = .steam
                } else {
                    tempMap[position.x][position.y].type = tempMap[finalChoice!.x][finalChoice!.y].type
                    tempMap[finalChoice!.x][finalChoice!.y].type = .water
                }

            case .ice:
                if tempMap[finalChoice!.x][finalChoice!.y].type == .sand {
                    tempMap[position.x][position.y].type = .water
                } else if tempMap[finalChoice!.x][finalChoice!.y].type == .water {
                    tempMap[position.x][position.y].type = .ice
                    tempMap[finalChoice!.x][finalChoice!.y].type = .ice
                } else {
                    tempMap[position.x][position.y].type = .none
                    tempMap[finalChoice!.x][finalChoice!.y].type = .ice
                }

            case .fire:
                if tempMap[finalChoice!.x][finalChoice!.y].type == .water {
                    tempMap[position.x][position.y].type = .steam
                    tempMap[finalChoice!.x][finalChoice!.y].type = .steam
                } else if tempMap[finalChoice!.x][finalChoice!.y].type == .snow || tempMap[finalChoice!.x][finalChoice!.y].type == .ice {
                    tempMap[position.x][position.y].type = .steam
                    tempMap[finalChoice!.x][finalChoice!.y].type = .steam
                } else {
                    tempMap[position.x][position.y].type = .none
                    tempMap[finalChoice!.x][finalChoice!.y].type = .fire
                }
        }
        return tempMap
    }

    mutating func trackParticle(x: Int, y: Int) {
        trackReset.append((x: x, y: y))
    }

    func calcNeighbor(position: (x: Int, y: Int), priority: Double, open: [ParticleType] = [.none]) -> Neighbor? {
        if position.x < 0 || position.x >= playSize.width || position.y < 0 || position.y >= playSize.height {
            return nil
        }

        if !open.contains(map[position.x][position.y].type) {
            return nil
        }

        return Neighbor(x: position.x, y: position.y, priority: priority)//, type: map[position.x][position.y].type)
    }

    func particleColor(particle: Particle) -> Color {
        switch particle.type {
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


#Preview {
    ContentView()
}
