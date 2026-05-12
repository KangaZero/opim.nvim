import Foundation
import GRDB

import neomouseUtils

func seedSession(session: Session) {
    do {
        try dbQueue.write { db in
            var newSession = Session(name: "Seed Session", createdAt: Date(), updatedAt: Date())
            try newSession.insert(db)
        }
    } catch {
        debug("Seed Session error: ", error)
    }
}

func seedMark(numberOfMarks: Int = 5) {
    let markCharacters: [String] = "0123456789abcdefghijklmnopqrstuvwxyz".map {
        String($0)
    }
    guard numberOfMarks > 0, numberOfMarks <= markCharacters.count else {
        debug(
            "Invalid numberOfMarks \(numberOfMarks): must be in 1...\(markCharacters.count)")
        return
    }

    guard let currentScreen = getCurrentScreenSize() else {
        debug("Could not get current screen size in seedMark")
        return
    }
    do {
        try dbQueue.write { db in
            for i in 0..<numberOfMarks {
                let x = Double.random(in: 0...currentScreen.width)
                let y = Double.random(in: 0...currentScreen.height)
                var newMark = Mark(
                    mark: markCharacters[i],
                    startCGXPoint: x,
                    startCGYPoint: y,
                    endCGXPoint: x,
                    endCGYPoint: y,
                    createdAt: Date(),
                    sessionId: 1)
                try newMark.insert(db)
            }
        }
    } catch {
        debug("Seed Mark error: ", error)
    }

}
