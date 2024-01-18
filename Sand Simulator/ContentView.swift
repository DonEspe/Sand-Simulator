//
//  ContentView.swift
//  Sand Simulator
//
//  Created by Don Espe on 1/17/24.
//

import SwiftUI  //FIXME: Switch to spritekit or something....

let playSize = (width: 150, height: 200)

struct ContentView: View {
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State var paused = true

    @State var map = Array(repeating: Array(repeating: Particle(type: .none), count: Int(playSize.height)), count: Int(playSize.width))
    @State var drawType: ParticleType = .sand
    //[[Particle(type: .none)]]

//    var map = Array(repeating: Array(repeating: Items(), count: mapSize), count: mapSize)
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
//                                Path(ellipseIn: CGRect(origin: CGPoint(x: CGFloat(x * 2), y: CGFloat(y * 2)), size: CGSize(width: 2, height: 2))),
//                                with: .color(particleColor(particle: map[x][y])))

                            Path(roundedRect: CGRect(origin: CGPoint(x: CGFloat(x * 2), y: CGFloat(y * 2)), size: CGSize(width: 2, height: 2)), cornerSize: CGSize(width: 0, height: 0)),
                                 with: .color(particleColor(particle: map[x][y])))
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            paused = true
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

            Picker("View Style", selection: $drawType) {
                ForEach(ParticleType.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)

            Toggle(isOn: $paused) {
                Text("Pause")
            }

            Spacer()
        }
        .onReceive(timer, perform: { _ in
            if paused {
                return
            }
            map[Int.random(in: 0..<playSize.width)][0].type = .sand
            map[Int.random(in: 0..<playSize.width)][0].type = .sand
            map[Int.random(in: 0..<playSize.width)][0].type = .water

            var tempMap = map
            for i in 0..<playSize.width {
                for j in (0..<playSize.height).reversed() {
                    map = moveParticle(particles: map, position: (x: i, y: j))
                }
            }
        })
        .onAppear {
            for _ in 0...1000 {
//                map[Int.random(in: 1..<Int(playSize.width))][ Int.random(in: 1..<Int(playSize.height))] = Particle(type:  ParticleType.allCases.randomElement() ?? .solid)
                map[Int.random(in: 0..<Int(playSize.width))][ Int.random(in: 30..<200)] = Particle(type:  ParticleType.solid)
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
            case .sand:
                if let down = calcNeighbor(position: (x: position.x, y: position.y + 1), priority: 1.0, open: [.water, .none]) {
                    neighbors.append(down)
                }
                if let downRight = calcNeighbor(position: (x: position.x - 1, y: position.y + 1), priority: 0.5, open: [.water, .none]) {
                    neighbors.append(downRight)
                }
                if let downLeft = calcNeighbor(position: (x: position.x + 1, y: position.y + 1), priority: 0.5, open: [.water, .none]){
                    neighbors.append(downLeft)
                }
                if let right = calcNeighbor(position: (x: position.x - 1, y: position.y), priority: 0.1, open: [.none]) {
                    neighbors.append(right)
                }
                if let left = calcNeighbor(position: (x: position.x + 1, y: position.y), priority: 0.1, open: [.none]){
                    neighbors.append(left)
                }

//                if position.y < playSize.height - 1 && tempMap[position.x][position.y + 1].type == .none {
//                    tempMap[position.x][position.y].type = .none
//                    tempMap[position.x][position.y + 1].type = .sand
//                    return tempMap
//                }
//                if position.y < playSize.height - 1 && tempMap[position.x][position.y + 1].type == .water {
//                    tempMap[position.x][position.y].type = .water
//                    tempMap[position.x][position.y + 1].type = .sand
//                    return tempMap
//                }
//                if position.y < playSize.height - 1 && position.x < playSize.width - 1 && tempMap[position.x + 1][position.y + 1].type == .none {
//                    tempMap[position.x][position.y].type = .none
//                    tempMap[position.x + 1][position.y + 1].type = .sand
//                    return tempMap
//                }
//                if position.y < playSize.height - 1 && position.x < playSize.width - 1 && tempMap[position.x + 1][position.y + 1].type == .water {
//                    tempMap[position.x][position.y].type = .water
//                    tempMap[position.x + 1][position.y + 1].type = .sand
//                    return tempMap
//                }
//                if position.y < playSize.height - 1 && position.x > 0 && tempMap[position.x - 1][position.y + 1].type == .none {
//                    tempMap[position.x][position.y].type = .none
//                    tempMap[position.x - 1][position.y + 1].type = .sand
//                    return tempMap
//                }
//                if position.y < playSize.height - 1 && position.x > 0 && tempMap[position.x - 1][position.y + 1].type == .water {
//                    tempMap[position.x][position.y].type = .water
//                    tempMap[position.x - 1][position.y + 1].type = .sand
//                    return tempMap
//                }
            case .solid:
                return tempMap
            case .water:

                if let down = calcNeighbor(position: (x: position.x, y: position.y + 1), priority: 1.0, open: [.none]) {
                    neighbors.append(down)
                }
                if let downRight = calcNeighbor(position: (x: position.x - 1, y: position.y + 1), priority: 0.5, open: [.none]) {
                    neighbors.append(downRight)
                }
                if let downLeft = calcNeighbor(position: (x: position.x + 1, y: position.y + 1), priority: 0.5, open: [.none]){
                    neighbors.append(downLeft)
                }
                if let right = calcNeighbor(position: (x: position.x - 1, y: position.y), priority: 0.5, open: [.none]) {
                    neighbors.append(right)
                }
                if let left = calcNeighbor(position: (x: position.x + 1, y: position.y), priority: 0.5, open: [.none]){
                    neighbors.append(left)
                }

//                if position.y < playSize.height - 1 && tempMap[position.x][position.y + 1].type == .none {
//                    tempMap[position.x][position.y].type = .none
//                    tempMap[position.x][position.y + 1].type = .water
//                    return tempMap
//                }
//
//                if position.x < playSize.width - 1 && tempMap[position.x + 1][position.y ].type == .none {
//                    tempMap[position.x][position.y].type = .none
//                    tempMap[position.x + 1][position.y ].type = .water
//                    return tempMap
//                }
//                if  position.x > 0 && tempMap[position.x - 1][position.y].type == .none {
//                    tempMap[position.x][position.y].type = .none
//                    tempMap[position.x - 1][position.y].type = .water
//                    return tempMap
//                }
            case .none:
                return tempMap
        }
        var finalChoice:Neighbor? = nil

        if let highestRank = neighbors.max(by: { $0.priority < $1.priority }) {
                        let choices = neighbors.filter {
                            $0.priority == highestRank.priority
                        }
            finalChoice = choices.randomElement()
        }
            switch particle.type
            {
                case .none, .solid:
                    break
                case .sand:
                    if finalChoice != nil {
                        if finalChoice!.priority == 1 || finalChoice!.priority > Double.random(in: 0...1) {
                            print("final Choice Priority: ", finalChoice!.priority)
                            tempMap[position.x][position.y].type = tempMap[finalChoice!.x][finalChoice!.y].type
                            tempMap[finalChoice!.x][finalChoice!.y].type = .sand
                        }
                    }
                case .water:
                    if finalChoice != nil {
                        tempMap[position.x][position.y].type = tempMap[finalChoice!.x][finalChoice!.y].type
                        tempMap[finalChoice!.x][finalChoice!.y].type = .water
                    }
            }
//        }
        return tempMap
//        return particles
    }

    func calcNeighbor(position: (x: Int, y: Int), priority: Double, open: [ParticleType] = [.none]) -> Neighbor? {
        if position.x < 0 || position.x >= playSize.width || position.y < 0 || position.y >= playSize.height {
            return nil
        }

        if !open.contains(map[position.x][position.y].type) {
            return nil
        }
//        if map[position.x][position.y].type != .none {
//            return nil
//        }

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
            case .none:
                return .clear
        }
    }
}


#Preview {
    ContentView()
}
