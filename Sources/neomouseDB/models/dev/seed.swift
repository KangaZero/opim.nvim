import AppKit
import Foundation
import GRDB

import neomouseUtils

/// Dev seed bundle. Inserts a few sessions on top of the default one, scatters
/// random marks across the current screen, and stuffs registers with sample
/// pasteboard items. Safe to re-run — Mark.set / Register.set both upsert.
public func seedAll(sessionCount: Int = 3, marksPerSession: Int = 5, registersPerSession: Int = 3) {
    seedSessions(count: sessionCount)
    seedMarks(numberOfMarks: marksPerSession)
    seedRegisters(count: registersPerSession)
}

public func seedSessions(count: Int = 3) {
    do {
        try dbQueue.write { db in
            for i in 1...count {
                var newSession = Session(
                    name: "Seed \(i)",
                    createdAt: Date(),
                    updatedAt: Date()
                )
                try newSession.insert(db)
            }
        }
    } catch {
        debug("seedSessions error: ", error)
    }
}

public func seedMarks(numberOfMarks: Int = 5) {
    let markCharacters: [String] = "0123456789abcdefghijklmnopqrstuvwxyz".map { String($0) }
    guard numberOfMarks > 0, numberOfMarks <= markCharacters.count else {
        debug("Invalid numberOfMarks \(numberOfMarks): must be in 1...\(markCharacters.count)")
        return
    }
    guard let currentScreen = Screen.currentSize() else {
        debug("Could not get current screen size in seedMarks")
        return
    }
    guard let session = Session.getLast(), let sessionId = session.id else {
        debug("seedMarks: no session in DB; run initializeDB first")
        return
    }
    // Mark.set wraps its own dbQueue.write — do NOT wrap this loop in another
    // write or GRDB will trip on reentrancy.
    for i in 0..<numberOfMarks {
        let startX = Double.random(in: 0...currentScreen.width)
        let startY = Double.random(in: 0...currentScreen.height)
        let endX = Double.random(in: 0...currentScreen.width)
        let endY = Double.random(in: 0...currentScreen.height)
        let isVisual = Bool.random()
        Mark.set(
            mark: markCharacters[i],
            isVisual: isVisual,
            startCGXPoint: isVisual ? startX : nil,
            startCGYPoint: isVisual ? startY : nil,
            endCGXPoint: endX,
            endCGYPoint: endY,
            sessionId: sessionId
        )
    }
}

public func seedRegisters(count: Int = 3) {
    let registerNames: [String] = "abcdefghijklmnopqrstuvwxyz".map { String($0) }
    guard count > 0, count <= registerNames.count else {
        debug("Invalid register count \(count): must be in 1...\(registerNames.count)")
        return
    }
    guard let session = Session.getLast(), let sessionId = session.id else {
        debug("seedRegisters: no session in DB; run initializeDB first")
        return
    }
    // Register.set wraps its own dbQueue.write — same reentrancy caveat as seedMarks.
    for i in 0..<count {
        let name = registerNames[i]
        let item = NSPasteboardItem()
        item.setString("Seed register \"\(name)\"", forType: .string)
        if let html = "<p>Seed register <b>\"\(name)\"</b></p>".data(using: .utf8) {
            item.setData(html, forType: .html)
        }
        Register.set(register: name, item: item, sessionId: sessionId)
    }
}
