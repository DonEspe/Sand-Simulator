//
//  ContentView.swift
//  Sand Simulator
//
//  Created by Don Espe on 1/17/24.
//

import SwiftUI

let playSize = (width: 150, height: 180)

struct ContentView: View {
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State var paused = true
    @State var showActive = false

    @State var map = Array(repeating: Array(repeating: Particle(type: .none), count: Int(playSize.height)), count: Int(playSize.width))
    @State var drawType: ParticleType = .sand
    @State var drawSize = 5.0

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
                                with: (.color(map[x][y].color())))

                            if showActive {
                                context.fill(
                                    Path(roundedRect: CGRect(origin: CGPoint(x: CGFloat(x * 2), y: CGFloat(y * 2)), size: CGSize(width: 2, height: 2)), cornerSize: CGSize(width: 0, height: 0)),
                                    with: (map[x][y].active ? .color(.green.opacity(0.25)) : .color(.clear)))
                            }
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let radius = Int(drawSize)
                            let useLocation = (x: Int(value.location.x / 2), y: Int(value.location.y / 2))
                            if useLocation.y < playSize.height - 1 && useLocation.x < playSize.width - 1 && useLocation.x > 0 && useLocation.y > 0 {
                                for i in (useLocation.x - radius - 2)...(useLocation.x + radius + 2) {
                                    for j in (useLocation.y - radius - 2)...(useLocation.y + radius + 2) {
                                        if ((i - useLocation.x) * (i - useLocation.x)) + ((j - useLocation.y) * (j - useLocation.y)) < radius * 2 {
                                            if i > 0 && i < playSize.width && j > 0 && j < playSize.height {
                                                map[i][j].type = drawType
                                                map[i][j].active = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .onEnded { _ in
                        }
                )

            }
            .frame(width: CGFloat(playSize.width * 2), height: CGFloat(playSize.height * 2))
            .padding()
            .scaledToFill()

            Picker("Particle type", selection: $drawType) {
                ForEach(ParticleType.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Text("Draw size (\(Int(drawSize))): ")
                Slider(value: $drawSize, in: 1...50)
            }

            Toggle(isOn: $paused) {
                Text("Pause")
            }
            Toggle(isOn: $showActive) {
                Text("Show active")
            }

            Button(action: {
                map = Array(repeating: Array(repeating: Particle(type: .none, active: true), count: Int(playSize.height)), count: Int(playSize.width))
            }) {
                Text("Reset")
            }

            Spacer()
        }
        .onReceive(timer, perform: { _ in
            if paused {
                return
            }
            let randomLoc = Int.random(in: 0..<playSize.width)
            map[randomLoc][0].type = drawType
            map[randomLoc][0].active = true
            
            for i in 0..<playSize.width {
                for j in (0..<playSize.height).reversed() {
                    if map[i][j].active {
                        map = moveParticle(particles: map, position: (x: i, y: j))
                    }
                }
            }
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

        if !particle.active {
            return particles
        }

        var tempMap = particles

        if particle.type == .none || particle.type == .solid || !particle.active {
            tempMap[position.x][position.y].active = false
            return tempMap
        }

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
                let lateralPriority = 0.92
                let vertPriority = 0.95
                if let down = calcNeighbor(position: (x: position.x, y: position.y + 1), priority: 1.0, open: [.none, .fire, .snow]) {
                    neighbors.append(down)
                }
                if let downRight = calcNeighbor(position: (x: position.x - 1, y: position.y + 1), priority: vertPriority, open: [.none, .fire, .snow]) {
                    neighbors.append(downRight)
                    if let downRight2 = calcNeighbor(position: (x: position.x - 2, y: position.y + 2), priority: vertPriority, open: [.none]) {
                        neighbors.append(downRight2)
                    }
                }
                if let downLeft = calcNeighbor(position: (x: position.x + 1, y: position.y + 1), priority: vertPriority, open: [.none, .fire, .snow]) {
                    neighbors.append(downLeft)
                    if let downLeft2 = calcNeighbor(position: (x: position.x + 2, y: position.y + 2), priority: vertPriority, open: [.none]) {
                        neighbors.append(downLeft2)
                    }
                }
                if let right = calcNeighbor(position: (x: position.x - 1, y: position.y), priority: lateralPriority, open: [.none, .fire]) {
                    neighbors.append(right)
                }
                if let right2 = calcNeighbor(position: (x: position.x - 2, y: position.y), priority: lateralPriority + 0.02, open: [.none]) {
                    neighbors.append(right2)
                }
                if let right3 = calcNeighbor(position: (x: position.x - 3, y: position.y), priority: lateralPriority + 0.03, open: [.none]) {
                    neighbors.append(right3)
                }
                if let right4 = calcNeighbor(position: (x: position.x - 4, y: position.y), priority: lateralPriority + 0.03, open: [.none]) {
                    neighbors.append(right4)
                }

                if let left = calcNeighbor(position: (x: position.x + 1, y: position.y), priority: lateralPriority, open: [.none, .fire]) {
                    neighbors.append(left)
                }
                if let left2 = calcNeighbor(position: (x: position.x + 2, y: position.y), priority: lateralPriority + 0.02, open: [.none]) {
                    neighbors.append(left2)
                }
                if let left3 = calcNeighbor(position: (x: position.x + 3, y: position.y), priority: lateralPriority + 0.03, open: [.none]) {
                    neighbors.append(left3)
                }
                if let left4 = calcNeighbor(position: (x: position.x + 4, y: position.y), priority: lateralPriority + 0.03, open: [.none]) {
                    neighbors.append(left4)
                }
            case .steam:
                if let up = calcNeighbor(position: (x: position.x, y: position.y - 1), priority: 1.0, open: [.none, .fire, .water, .snow, .ice]) {
                    neighbors.append(up)
                }
                if let upRight = calcNeighbor(position: (x: position.x - 1, y: position.y - 1), priority: 0.75, open: [.none, .fire, .water, .snow, .ice]) {
                    neighbors.append(upRight)
                }
                if let upLeft = calcNeighbor(position: (x: position.x + 1, y: position.y - 1), priority: 0.75, open: [.none, .fire, .water, .snow, .ice]){
                    neighbors.append(upLeft)
                }
        }

        if !neighbors.isEmpty {
            for i in (position.x - 3)...(position.x + 3) {
                for j in (position.y - 3)...(position.y + 3) {
                    if i >= 0 && i < (playSize.width) && j >= 0 && j < (playSize.height) {
                        tempMap[i][j].active = true
                    }
                }
            }
        } else {
            tempMap[position.x][position.y].active = false
            return tempMap
        }


        if tempMap[position.x][position.y].type == .solid || tempMap[position.x][position.y].type == .none || !tempMap[position.x][position.y].active {
            return tempMap
        }

        var finalChoice:Neighbor? = nil

        if let highestRank = neighbors.max(by: { $0.priority < $1.priority }) {
                        let choices = neighbors.filter {
                            $0.priority == highestRank.priority
                        }
            finalChoice = choices.randomElement()
        }

        guard finalChoice != nil else { return tempMap }
        let finalType = tempMap[finalChoice!.x][finalChoice!.y].type
        let currentChoice = tempMap[position.x][position.y]
        tempMap[position.x][position.y].active = true
        switch particle.type
        {
            case .none, .solid:
                break

            case .sand:
                if (finalChoice!.priority == 1 || finalChoice!.priority > Double.random(in: 0...1)) {
                    if !currentChoice.moved || (finalType != .water && finalType != .steam ) {
                        tempMap[finalChoice!.x][finalChoice!.y].moved = true
                        tempMap[position.x][position.y].type = finalType
                        tempMap[finalChoice!.x][finalChoice!.y].type = .sand
                    }  else {
                        tempMap[position.x][position.y].moved = false
                    }
                }

            case .steam:
                if position.y <= 2 {
                    tempMap[position.x][position.y].type = .none
                } else if !currentChoice.moved {
                    tempMap[position.x][position.y].type = finalType
                    tempMap[position.x][position.y].moved = false
                    tempMap[finalChoice!.x][finalChoice!.y].type = .steam
                    tempMap[finalChoice!.x][finalChoice!.y].moved = true
                } else {
                    tempMap[position.x][position.y].moved = false
                }

            case .snow:
                if finalType == .water || finalType == .sand {
                    tempMap[position.x][position.y].type = .water
                } else {
                    tempMap[position.x][position.y].type = .none
                    tempMap[finalChoice!.x][finalChoice!.y].type = .snow
                }

            case .water:
                if finalType == .ice  {
                    tempMap[position.x][position.y].type = .ice
                } else if finalType == .fire {
                    tempMap[position.x][position.y].type = .none
                    tempMap[finalChoice!.x][finalChoice!.y].type = .steam
                } else if finalType == .snow {
                    tempMap[finalChoice!.x][finalChoice!.y].type = .water
                } else {
                    tempMap[position.x][position.y].type = finalType
                    tempMap[finalChoice!.x][finalChoice!.y].type = .water
                }

            case .ice:
                if finalType == .sand {
                    tempMap[position.x][position.y].type = .water
                } else if finalType == .water {
                    tempMap[position.x][position.y].type = .ice
                    tempMap[finalChoice!.x][finalChoice!.y].type = .ice
                } else {
                    tempMap[position.x][position.y].type = .none
                    tempMap[finalChoice!.x][finalChoice!.y].type = .ice
                }

            case .fire:
                if finalType == .water {
                    tempMap[position.x][position.y].type = .steam
                    tempMap[finalChoice!.x][finalChoice!.y].type = .steam
                } else if finalType == .snow || finalType == .ice {
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

        return Neighbor(x: position.x, y: position.y, priority: priority)
    }
}

#Preview {
    ContentView()
}
