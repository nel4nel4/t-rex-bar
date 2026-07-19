//  T-Rex Bar — a Chrome-dino-style endless runner living in the macOS menu bar.
//  Pure black & white pixel art. The dino auto-runs across the whole strip,
//  jumps cacti, ducks pterodactyls; clouds, stars, moon and meteors drift by.
//
//  Left-click the strip: pause / resume.
//  Right-click: options menu (speed, width, Touch Bar, launch at login, quit).
//  On Touch Bar MacBooks the scene also runs full-width on the OLED strip
//  (private DFRFoundation API, same technique as Pock / MTMR).

import AppKit
import ApplicationServices
import QuartzCore
import ServiceManagement

// ======================================================================
// MARK: - Pixel art  ("X" = filled cell, top row first)
// ======================================================================

enum Art {
    static let dinoRunA: [String] = [
        "..........XXXXXXX.",
        ".........XX.XXXXXX",
        ".........XXXXXXXXX",
        ".........XXXXXXXXX",
        ".........XXXX.....",
        ".........XXXXXXX..",
        "X.......XXXXX.....",
        "XX.....XXXXXXX.X..",
        "XXX...XXXXXXXXXX..",
        ".XXXXXXXXXXXXX....",
        "..XXXXXXXXXXXX....",
        "...XXXXXXXXXX.....",
        "....XX...XX.......",
        "....XXX...........",
    ]
    static let dinoRunB: [String] = [
        "..........XXXXXXX.",
        ".........XX.XXXXXX",
        ".........XXXXXXXXX",
        ".........XXXXXXXXX",
        ".........XXXX.....",
        ".........XXXXXXX..",
        "X.......XXXXX.....",
        "XX.....XXXXXXX.X..",
        "XXX...XXXXXXXXXX..",
        ".XXXXXXXXXXXXX....",
        "..XXXXXXXXXXXX....",
        "...XXXXXXXXXX.....",
        "....XX...XX.......",
        ".........XXX......",
    ]
    static let dinoJump: [String] = [
        "..........XXXXXXX.",
        ".........XX.XXXXXX",
        ".........XXXXXXXXX",
        ".........XXXXXXXXX",
        ".........XXXX.....",
        ".........XXXXXXX..",
        "X.......XXXXX.....",
        "XX.....XXXXXXX.X..",
        "XXX...XXXXXXXXXX..",
        ".XXXXXXXXXXXXX....",
        "..XXXXXXXXXXXX....",
        "...XXXXXXXXXX.....",
        "....XX...XX.......",
        "..................",
    ]
    // Eye gap of the standing dino (col, row) — filled briefly when blinking.
    static let dinoEye = (col: 11, row: 1)

    static let dinoDuckA: [String] = [
        "..............XXXXXX..",
        ".............XX.XXXXX.",
        "XX...........XXXXXXXX.",
        "XXX....XXXXXXXXXX.....",
        ".XXXXXXXXXXXXXXXX.X...",
        "..XXXXXXXXXXXXXXXX....",
        "...XXXXXXXXXXXXX......",
        "....XX....XX..........",
        "....XXX...............",
    ]
    static let dinoDuckB: [String] = [
        "..............XXXXXX..",
        ".............XX.XXXXX.",
        "XX...........XXXXXXXX.",
        "XXX....XXXXXXXXXX.....",
        ".XXXXXXXXXXXXXXXX.X...",
        "..XXXXXXXXXXXXXXXX....",
        "...XXXXXXXXXXXXX......",
        "....XX....XX..........",
        ".........XXX..........",
    ]

    static let pteroUp: [String] = [
        "......XX........",
        "......XXX.......",
        "......XXXX......",
        "......XXXXX.....",
        "XX...XXXXXXXXXXX",
        ".XXXXXXXXXXXX...",
        "..XXXXXXXXX.....",
        "................",
        "................",
    ]
    static let pteroDown: [String] = [
        "................",
        "................",
        "................",
        "................",
        "XX...XXXXXXXXXXX",
        ".XXXXXXXXXXXX...",
        "..XXXXXXXXX.....",
        "...XXXX.........",
        "....XX..........",
    ]

    static let cactusS: [String] = [
        "..XX.X",
        "X.XX.X",
        "X.XXXX",
        "XXXX..",
        "..XX..",
        "..XX..",
    ]
    static let cactusL: [String] = [
        "...XX.X",
        "X..XX.X",
        "X..XX.X",
        "X..XXXX",
        "XX.XX..",
        ".XXXX..",
        "...XX..",
        "...XX..",
    ]

    static let cloud: [String] = [
        "....XXXX......",
        "..XXXXXXXX....",
        ".XXXXXXXXXXXX.",
    ]

    static let moon: [String] = [
        "..XXXX..",
        ".XXX....",
        "XXX.....",
        "XXX.....",
        "XXX.....",
        "XXX.....",
        ".XXX....",
        "..XXXX..",
    ]

    static let heart: [String] = [
        ".XX.XX.",
        "XXXXXXX",
        "XXXXXXX",
        ".XXXXX.",
        "..XXX..",
        "...X...",
    ]
    static let heartEmpty: [String] = [
        ".XX.XX.",
        "X..X..X",
        "X.....X",
        ".X...X.",
        "..X.X..",
        "...X...",
    ]

    // 5-row pixel font — just the glyphs the HUD needs.
    static let font: [Character: [String]] = [
        "0": ["XXX", "X.X", "X.X", "X.X", "XXX"],
        "1": [".X.", "XX.", ".X.", ".X.", "XXX"],
        "2": ["XXX", "..X", "XXX", "X..", "XXX"],
        "3": ["XXX", "..X", ".XX", "..X", "XXX"],
        "4": ["X.X", "X.X", "XXX", "..X", "..X"],
        "5": ["XXX", "X..", "XXX", "..X", "XXX"],
        "6": ["XXX", "X..", "XXX", "X.X", "XXX"],
        "7": ["XXX", "..X", ".X.", ".X.", ".X."],
        "8": ["XXX", "X.X", "XXX", "X.X", "XXX"],
        "9": ["XXX", "X.X", "XXX", "..X", "XXX"],
        "G": [".XXX", "X...", "X.XX", "X..X", ".XXX"],
        "A": [".XX.", "X..X", "XXXX", "X..X", "X..X"],
        "M": ["X...X", "XX.XX", "X.X.X", "X...X", "X...X"],
        "E": ["XXXX", "X...", "XXX.", "X...", "XXXX"],
        "O": [".XX.", "X..X", "X..X", "X..X", ".XX."],
        "V": ["X...X", "X...X", "X...X", ".X.X.", "..X.."],
        "R": ["XXX.", "X..X", "XXX.", "X.X.", "X..X"],
        "H": ["X..X", "X..X", "XXXX", "X..X", "X..X"],
        "I": ["XXX", ".X.", ".X.", ".X.", "XXX"],
    ]
}

// ======================================================================
// MARK: - Shared keyboard state (one keyboard drives every strip)
// ======================================================================

final class Input {
    var left = false
    var right = false
    var down = false
    var jumpStamp = 0      // bumped on every fresh ↑ / space press
}

// ======================================================================
// MARK: - Scene (simulation + rendering, all in black & white)
// ======================================================================

final class Scene {
    // Tunables
    var speedMul: Double = 1.0
    var paused = false

    // Game mode: attract = the classic self-playing animation,
    // playing = the user drives with the keyboard, dead = crashed.
    enum Mode { case attract, playing, dead }
    var mode: Mode = .attract
    var input: Input?
    var seenJump = 0
    var score = 0
    var hiScore = 0
    var playStartX: Double = 0
    var lives = 3
    var invulnUntil: Double = -1   // brief mercy window after losing a heart

    // World is 23 "cells" tall; one cell = viewHeight / 23 points.
    let worldCells = 23.0
    let groundLevel = 1.3          // cells: baseline the dino stands on
    let jumpApex = 8.3             // cells
    let jumpTime = 0.55            // seconds of airtime
    var jumpV0: Double { 4 * jumpApex / jumpTime }
    var gravity: Double { 8 * jumpApex / (jumpTime * jumpTime) }

    // State
    var t: Double = 0
    var worldX: Double = 0         // total scroll distance, px
    var dinoX: Double = 24         // px from left edge of the strip
    var dinoY: Double = 0          // cells above the ground
    var vy: Double = 0
    var ducking = false
    var blinkUntil: Double = -1
    var nextBlink: Double = 2.5
    var nextSpawn: Double = 1.2
    var nextMeteor: Double = 10
    var meteorStart: Double = -1
    var meteorOrigin: (x: Double, y: Double) = (0, 0)

    enum Kind { case cactusS, cactusL, cluster, ptero }
    struct Obstacle { var x: Double; var kind: Kind }
    var obstacles: [Obstacle] = []

    struct Cloud { var x: Double; var yCells: Double; var drift: Double }
    var clouds: [Cloud] = []

    struct Star { var seed: Int }
    var stars: [Star] = (0..<16).map { Star(seed: $0 * 7919 + 13) }

    // Geometry cached from the last render
    var viewW: Double = 420
    var cell: Double = 1.0

    init() {
        for i in 0..<4 {
            clouds.append(Cloud(x: Double(i) * 130 + 40,
                                yCells: Double.random(in: 14...19),
                                drift: Double.random(in: 0.22...0.42)))
        }
    }

    private func widthCells(_ kind: Kind) -> Double {
        switch kind {
        case .cactusS: return 6
        case .cactusL: return 7
        case .cluster: return 21
        case .ptero:   return 16
        }
    }

    // ------------------------------------------------------------------
    // Simulation
    // ------------------------------------------------------------------
    func update(dt: Double) {
        guard !paused else { return }

        // Crashed: the world freezes until ↑ / space restarts the run.
        if mode == .dead {
            if let inp = input, inp.jumpStamp != seenJump {
                seenJump = inp.jumpStamp
                restart()
            }
            return
        }

        t += dt
        // While playing, the world slowly speeds up with distance (Chrome-style).
        let ramp = mode == .playing ? min((worldX - playStartX) / 40, 70) : 0
        let scroll = (65.0 + ramp) * speedMul  // world speed, px/s
        let advance = 9.0 * speedMul           // dino's drift across the strip, px/s
        worldX += scroll * dt

        if mode == .playing, let inp = input {
            // Keyboard drives the dino: → forward, ← backward.
            let run = 120.0
            if inp.right { dinoX += run * dt }
            if inp.left  { dinoX -= run * dt }
            let dinoW = (ducking ? 22.0 : 18.0) * cell
            dinoX = min(max(dinoX, 2), max(2.0, viewW - dinoW - 2))

            if inp.jumpStamp != seenJump {
                seenJump = inp.jumpStamp
                if dinoY == 0 && vy <= 0 { vy = jumpV0 }
            }
            if inp.down && dinoY > 0 { vy -= gravity * 1.5 * dt }  // fast-fall
            ducking = inp.down && dinoY == 0 && vy <= 0
            score = Int((worldX - playStartX) / 10)
        } else {
            dinoX += advance * dt
            // Ran off the right edge -> re-enter from the left.
            if dinoX > viewW + 40 {
                dinoX = -20 * cell
                obstacles.removeAll { $0.x < 150 }   // don't land on someone's spikes
            }
        }

        // Jump physics (in cells)
        if dinoY > 0 || vy > 0 {
            dinoY += vy * dt
            vy -= gravity * dt
            if dinoY <= 0 { dinoY = 0; vy = 0 }
        }

        // Obstacles march left; pterodactyls fly on top of the scroll.
        for i in obstacles.indices {
            let extra = obstacles[i].kind == .ptero ? 0.35 : 0
            obstacles[i].x -= scroll * (1 + extra) * dt
        }
        obstacles.removeAll { $0.x < -80 }

        // Spawning
        nextSpawn -= dt
        if nextSpawn <= 0 {
            let spawnX = viewW + 30
            let nearestGap = obstacles.map { spawnX - ($0.x + widthCells($0.kind) * cell) }.min() ?? .infinity
            if (mode == .playing || dinoX < viewW - 150) && nearestGap > 110 {
                let r = Double.random(in: 0..<1)
                // Clusters are wider than a jump can clear, so they only
                // appear in the self-playing animation, never in a real game.
                let kind: Kind = mode == .playing
                    ? (r < 0.40 ? .cactusS : r < 0.72 ? .cactusL : .ptero)
                    : (r < 0.32 ? .cactusS : r < 0.56 ? .cactusL : r < 0.72 ? .cluster : .ptero)
                obstacles.append(Obstacle(x: spawnX, kind: kind))
                nextSpawn = Double.random(in: 1.1...2.4) / speedMul
            } else {
                nextSpawn = 0.35
            }
        }

        if mode == .attract {
            // Autopilot: jump cacti, duck pterodactyls.
            let dinoW = 18 * cell
            let closure = scroll + advance
            var wantDuck = false
            for ob in obstacles {
                let obW = widthCells(ob.kind) * cell
                if ob.kind == .ptero {
                    if ob.x < dinoX + dinoW + 26 && ob.x + obW > dinoX - 8 { wantDuck = true }
                } else {
                    let dist = ob.x - (dinoX + dinoW)
                    if dinoY == 0 && dist > -6 && dist < closure * 0.26 { vy = jumpV0 }
                }
            }
            ducking = wantDuck && dinoY == 0 && vy <= 0
        } else if t > invulnUntil && collided() {
            hit()
        }

        // Blinking
        if t > nextBlink {
            blinkUntil = t + 0.13
            nextBlink = t + Double.random(in: 2.5...5.5)
        }

        // Clouds
        for i in clouds.indices {
            clouds[i].x -= scroll * clouds[i].drift * dt
            if clouds[i].x < -70 {
                clouds[i].x = viewW + Double.random(in: 20...140)
                clouds[i].yCells = Double.random(in: 14...19)
            }
        }

        // Meteor / shooting star
        if meteorStart < 0 {
            nextMeteor -= dt
            if nextMeteor <= 0 {
                meteorStart = t
                meteorOrigin = (Double.random(in: viewW * 0.3...viewW), Double.random(in: 26...34))
                nextMeteor = Double.random(in: 14...30)
            }
        } else if t - meteorStart > 1.1 {
            meteorStart = -1
        }
    }

    // ------------------------------------------------------------------
    // Game control
    // ------------------------------------------------------------------
    func beginPlay() {
        seenJump = input?.jumpStamp ?? 0
        hiScore = UserDefaults.standard.integer(forKey: "hiScore")
        dinoX = min(dinoX, viewW * 0.35)   // start from the left third
        restart()
    }

    func endPlay() {
        mode = .attract
        ducking = false
    }

    private func restart() {
        obstacles.removeAll()
        dinoY = 0
        vy = 0
        ducking = false
        playStartX = worldX
        score = 0
        lives = 3
        invulnUntil = -1
        nextSpawn = 1.2
        mode = .playing
    }

    // Lost a heart — game over only when they're all gone.
    private func hit() {
        lives -= 1
        if lives <= 0 {
            die()
        } else {
            invulnUntil = t + 1.5
        }
    }

    private func die() {
        mode = .dead
        ducking = false
        hiScore = max(UserDefaults.standard.integer(forKey: "hiScore"), score)
        UserDefaults.standard.set(hiScore, forKey: "hiScore")
    }

    // Forgiving hitboxes, all in strip pixels.
    private func collided() -> Bool {
        let groundTop = groundLevel * cell
        let dBox: NSRect
        if ducking {
            dBox = NSRect(x: dinoX + 4 * cell, y: groundTop,
                          width: 15 * cell, height: 7 * cell)
        } else {
            dBox = NSRect(x: dinoX + 5 * cell, y: groundTop + dinoY * cell,
                          width: 11 * cell, height: 12 * cell)
        }
        for ob in obstacles {
            let boxes: [NSRect]
            switch ob.kind {
            // Heights are shorter than the art on purpose: the jump arc only
            // spends so long near its apex, so tall boxes would make cacti
            // unclearable at low world speeds.
            case .cactusS:
                boxes = [NSRect(x: ob.x + 1.5 * cell, y: groundTop,
                                width: 3 * cell, height: 4 * cell)]
            case .cactusL:
                boxes = [NSRect(x: ob.x + 1.5 * cell, y: groundTop,
                                width: 4 * cell, height: 5 * cell)]
            case .cluster:
                // One tight box per cactus — the gaps between them are safe.
                boxes = [
                    NSRect(x: ob.x + 1.5 * cell, y: groundTop,
                           width: 3 * cell, height: 4 * cell),
                    NSRect(x: ob.x + 8.5 * cell, y: groundTop,
                           width: 4 * cell, height: 5 * cell),
                    NSRect(x: ob.x + 16.5 * cell, y: groundTop,
                           width: 3 * cell, height: 4 * cell),
                ]
            case .ptero:
                // Body only — the wing tips don't kill.
                boxes = [NSRect(x: ob.x + 2 * cell, y: 12.5 * cell,
                                width: 12 * cell, height: 3 * cell)]
            }
            if boxes.contains(where: { dBox.intersects($0) }) { return true }
        }
        return false
    }

    // ------------------------------------------------------------------
    // Rendering
    // ------------------------------------------------------------------
    func render(in bounds: NSRect, dark: Bool) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        ctx.setShouldAntialias(false)

        viewW = Double(bounds.width)
        cell = Double(bounds.height) / worldCells
        let fg: NSColor = dark ? .white : .black
        let groundTop = groundLevel * cell

        // --- Night sky (only on a dark / OLED menu bar) ---
        if dark {
            for star in stars {
                let h1 = hashN(star.seed), h2 = hashN(star.seed &+ 101), h3 = hashN(star.seed &+ 202)
                var sx = (Double(h1 % 1600) - worldX * 0.12).truncatingRemainder(dividingBy: viewW)
                if sx < 0 { sx += viewW }
                let sy = (12 + Double(h2 % 9)) * cell
                let tw = 0.18 + 0.42 * abs(sin(t * (0.5 + Double(h3 % 10) * 0.12) + Double(h3 % 7)))
                fg.withAlphaComponent(tw).setFill()
                let s = max(1, cell * 0.55)
                NSRect(x: sx, y: sy, width: s, height: s).fill()
            }
            var mx = viewW - 30 - (worldX * 0.04).truncatingRemainder(dividingBy: viewW + 90)
            if mx < -60 { mx += viewW + 90 }
            draw(Art.moon, x: mx, bottom: 13.5 * cell, color: fg.withAlphaComponent(0.85))
            if meteorStart >= 0 {
                let p = t - meteorStart
                let hx = meteorOrigin.x - 300 * p
                let hy = meteorOrigin.y - 9 * p * cell
                for k in 0..<4 {
                    let a = 0.9 - Double(k) * 0.22
                    fg.withAlphaComponent(a).setFill()
                    NSRect(x: hx + Double(k) * 4, y: hy + Double(k) * 0.11 * 4 * cell,
                           width: k == 0 ? 2 : 2, height: max(1, cell * 0.5)).fill()
                }
            }
        }

        // --- Clouds ---
        for cl in clouds {
            draw(Art.cloud, x: cl.x, bottom: cl.yCells * cell, color: fg.withAlphaComponent(0.32))
        }

        // --- Ground: dashed line + pebbles, scrolling ---
        let seg = 14.0
        let lineH = max(1.0, cell * 0.45)
        let phase = worldX.truncatingRemainder(dividingBy: seg)
        var i = -1
        while true {
            let sx = Double(i) * seg - phase
            if sx > viewW { break }
            let n = Int(((worldX + sx) / seg).rounded())
            let h = hashN(n)
            let gap = (h % 9 == 0) ? 4.0 : 0.0
            fg.withAlphaComponent(0.9).setFill()
            NSRect(x: sx, y: groundTop - lineH, width: seg - gap, height: lineH).fill()
            if h % 3 == 0 {
                let px = sx + Double(h % 11)
                fg.withAlphaComponent(0.7).setFill()
                NSRect(x: px, y: max(0, groundTop - lineH - cell * 0.9),
                       width: max(1, cell * 0.6), height: max(1, cell * 0.45)).fill()
            }
            i += 1
        }

        // --- Obstacles ---
        for ob in obstacles {
            switch ob.kind {
            case .cactusS:
                draw(Art.cactusS, x: ob.x, bottom: groundTop, color: fg)
            case .cactusL:
                draw(Art.cactusL, x: ob.x, bottom: groundTop, color: fg)
            case .cluster:
                draw(Art.cactusS, x: ob.x, bottom: groundTop, color: fg)
                draw(Art.cactusL, x: ob.x + 7 * cell, bottom: groundTop, color: fg)
                draw(Art.cactusS, x: ob.x + 15 * cell, bottom: groundTop, color: fg)
            case .ptero:
                let frame = Int(t * 6) % 2 == 0 ? Art.pteroUp : Art.pteroDown
                draw(frame, x: ob.x, bottom: 10.5 * cell, color: fg)
            }
        }

        // --- Dino --- (flashes while the post-hit mercy window runs)
        let bottom = groundTop + dinoY * cell
        if mode == .playing && t < invulnUntil && Int(t * 8) % 2 == 1 {
            // skip this frame — blink
        } else if ducking {
            let frame = Int(worldX / 8) % 2 == 0 ? Art.dinoDuckA : Art.dinoDuckB
            draw(frame, x: dinoX, bottom: groundTop, color: fg)
        } else if dinoY > 0 {
            draw(Art.dinoJump, x: dinoX, bottom: bottom, color: fg)
        } else {
            let frame = Int(worldX / 8) % 2 == 0 ? Art.dinoRunA : Art.dinoRunB
            draw(frame, x: dinoX, bottom: bottom, color: fg)
            if t < blinkUntil {
                let h = Art.dinoRunA.count
                fg.setFill()
                NSRect(x: dinoX + Double(Art.dinoEye.col) * cell,
                       y: bottom + Double(h - 1 - Art.dinoEye.row) * cell,
                       width: cell, height: cell).fill()
            }
        }

        // --- HUD: hearts left, score right, GAME OVER when crashed ---
        var hudLeft = 4.0
        if mode != .attract {
            let px = max(1.0, cell * 1.15)

            // Three hearts at the very left of the bar.
            let step = 8 * px
            let hb = (worldCells - 8.2) * cell
            if dark {
                NSColor.black.setFill()
                NSRect(x: 2, y: hb - 2, width: 6 + 3 * step, height: 6 * px + 4).fill()
            }
            for i in 0..<3 {
                let full = i < lives
                drawSprite(full ? Art.heart : Art.heartEmpty,
                           x: 5 + Double(i) * step, bottom: hb, px: px,
                           color: full ? fg : fg.withAlphaComponent(0.35))
            }
            hudLeft = 8 + 3 * step

            let hud = String(format: "HI %05d  %05d", hiScore, score)
            let w = textWidth(hud, px: px)
            let x = viewW - w - 8
            let bottom = (worldCells - 7.2) * cell
            if dark {   // keep the moon / stars from bleeding into the digits
                NSColor.black.setFill()
                NSRect(x: x - 3, y: bottom - 2, width: w + 6, height: 5 * px + 4).fill()
            }
            drawText(hud, x: x, bottom: bottom, px: px,
                     color: fg.withAlphaComponent(0.9))
        }
        if mode == .dead {
            let px = max(1.0, cell * 1.7)
            let msg = "GAME OVER"
            let w = textWidth(msg, px: px)
            let x = (viewW - w) / 2
            if dark {
                NSColor.black.setFill()
                NSRect(x: x - 4, y: 10 * cell - 2, width: w + 8, height: 5 * px + 4).fill()
            }
            drawText(msg, x: x, bottom: 10 * cell, px: px, color: fg)
        }

        // --- Pause badge --- (sits right of the hearts during a game)
        if paused {
            fg.withAlphaComponent(0.75).setFill()
            let bh = 6 * cell
            NSRect(x: hudLeft, y: Double(bounds.height) - bh - 2, width: 2, height: bh).fill()
            NSRect(x: hudLeft + 4, y: Double(bounds.height) - bh - 2, width: 2, height: bh).fill()
        }
    }

    private func draw(_ rows: [String], x: Double, bottom: Double, color: NSColor) {
        color.setFill()
        let h = rows.count
        for (r, rowStr) in rows.enumerated() {
            let y = bottom + Double(h - 1 - r) * cell
            var c = 0
            for ch in rowStr {
                if ch == "X" {
                    NSRect(x: x + Double(c) * cell, y: y, width: cell, height: cell).fill()
                }
                c += 1
            }
        }
    }

    // Like draw(), but at an arbitrary pixel size instead of the world cell.
    private func drawSprite(_ rows: [String], x: Double, bottom: Double, px: Double, color: NSColor) {
        color.setFill()
        for (r, rowStr) in rows.enumerated() {
            let y = bottom + Double(rows.count - 1 - r) * px
            var c = 0
            for ch in rowStr {
                if ch == "X" {
                    NSRect(x: x + Double(c) * px, y: y,
                           width: px.rounded(.up), height: px.rounded(.up)).fill()
                }
                c += 1
            }
        }
    }

    private func textWidth(_ text: String, px: Double) -> Double {
        var w = 0.0
        for ch in text {
            if ch == " " { w += 3 * px; continue }
            w += (Double(Art.font[ch]?[0].count ?? 3) + 1) * px
        }
        return max(0, w - px)
    }

    private func drawText(_ text: String, x: Double, bottom: Double, px: Double, color: NSColor) {
        color.setFill()
        var cx = x
        for ch in text {
            if ch == " " { cx += 3 * px; continue }
            guard let rows = Art.font[ch] else { cx += 4 * px; continue }
            for (r, rowStr) in rows.enumerated() {
                let y = bottom + Double(rows.count - 1 - r) * px
                var c = 0
                for cch in rowStr {
                    if cch == "X" {
                        NSRect(x: cx + Double(c) * px, y: y,
                               width: px.rounded(.up), height: px.rounded(.up)).fill()
                    }
                    c += 1
                }
            }
            cx += (Double(rows[0].count) + 1) * px
        }
    }

    private func hashN(_ n: Int) -> Int {
        var x = UInt64(bitPattern: Int64(n)) &* 0x9E3779B97F4A7C15
        x ^= x >> 29
        x = x &* 0xBF58476D1CE4E5B9
        x ^= x >> 32
        return Int(x & 0x7FFFFFFF)
    }
}

// ======================================================================
// MARK: - Touch Bar plumbing (private DFRFoundation API, as used by Pock/MTMR)
// ======================================================================

enum TouchBarSupport {
    private static let dfr: UnsafeMutableRawPointer? =
        dlopen("/System/Library/PrivateFrameworks/DFRFoundation.framework/DFRFoundation", RTLD_LAZY)

    private static let setPresenceFn: (@convention(c) (NSString, Bool) -> Void)? = {
        guard let h = dfr, let s = dlsym(h, "DFRElementSetControlStripPresenceForIdentifier") else { return nil }
        return unsafeBitCast(s, to: (@convention(c) (NSString, Bool) -> Void).self)
    }()

    private static let closeBoxFn: (@convention(c) (Bool) -> Void)? = {
        guard let h = dfr, let s = dlsym(h, "DFRSystemModalShowsCloseBoxWhenFrontMost") else { return nil }
        return unsafeBitCast(s, to: (@convention(c) (Bool) -> Void).self)
    }()

    private static let msgSendPtr: UnsafeMutableRawPointer? = dlsym(dlopen(nil, RTLD_LAZY), "objc_msgSend")

    private static func classResponds(_ cls: AnyClass, _ sel: Selector) -> Bool {
        guard let meta = object_getClass(cls) else { return false }
        return class_respondsToSelector(meta, sel)
    }

    // Invokes a (private) ObjC class method taking 1–2 object arguments.
    private static func callClass(_ cls: AnyClass, _ selName: String, _ a: AnyObject?, _ b: AnyObject? = nil) {
        let sel = Selector((selName))
        guard let ptr = msgSendPtr, classResponds(cls, sel) else { return }
        if b != nil {
            typealias Fn = @convention(c) (AnyObject, Selector, AnyObject?, AnyObject?) -> Void
            unsafeBitCast(ptr, to: Fn.self)(cls, sel, a, b)
        } else {
            typealias Fn = @convention(c) (AnyObject, Selector, AnyObject?) -> Void
            unsafeBitCast(ptr, to: Fn.self)(cls, sel, a)
        }
    }

    static var available: Bool {
        setPresenceFn != nil &&
        classResponds(NSTouchBar.self, Selector(("presentSystemModalTouchBar:systemTrayItemIdentifier:")))
    }

    static func setControlStripPresence(_ identifier: String, _ visible: Bool) {
        setPresenceFn?(identifier as NSString, visible)
    }
    static func showCloseBox(_ show: Bool) { closeBoxFn?(show) }

    static func addSystemTrayItem(_ item: NSTouchBarItem) {
        callClass(NSTouchBarItem.self, "addSystemTrayItem:", item)
    }
    static func removeSystemTrayItem(_ item: NSTouchBarItem) {
        callClass(NSTouchBarItem.self, "removeSystemTrayItem:", item)
    }
    static func presentSystemModal(_ bar: NSTouchBar, systemTrayItemIdentifier id: String) {
        callClass(NSTouchBar.self, "presentSystemModalTouchBar:systemTrayItemIdentifier:",
                  bar, id as NSString)
    }
    static func dismissSystemModal(_ bar: NSTouchBar) {
        callClass(NSTouchBar.self, "dismissSystemModalTouchBar:", bar)
    }

    // The strip only renders the app/modal layer when the Touch Bar is in an
    // "App Controls" mode — in "Expanded Control Strip" or "F-keys" mode a
    // presented modal reports isVisible yet never reaches the OLED. Pock and
    // MTMR flip the same preference.
    private static let agentDomain = "com.apple.touchbar.agent" as CFString

    static var presentationMode: String {
        (CFPreferencesCopyAppValue("PresentationModeGlobal" as CFString, agentDomain) as? String)
            ?? "appWithControlStrip"
    }

    static func setPresentationMode(_ mode: String) {
        CFPreferencesSetAppValue("PresentationModeGlobal" as CFString, mode as CFString, agentDomain)
        CFPreferencesAppSynchronize(agentDomain)
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        p.arguments = ["ControlStrip"]
        try? p.run()
    }
}

// ======================================================================
// MARK: - Touch Bar view (always dark — it's an OLED strip)
// ======================================================================

final class DinoTouchBarView: NSView {
    let scene: Scene

    init(scene: Scene) {
        self.scene = scene
        super.init(frame: NSRect(x: 0, y: 0, width: 1000, height: 30))
        allowedTouchTypes = [.direct]
        // Huge intrinsic width + no compression resistance -> fill whatever
        // width the touch bar gives us.
        setContentCompressionResistancePriority(NSLayoutConstraint.Priority(1), for: .horizontal)
        setContentHuggingPriority(NSLayoutConstraint.Priority(1), for: .horizontal)
    }
    required init?(coder: NSCoder) { fatalError() }

    override var intrinsicContentSize: NSSize { NSSize(width: 1400, height: 30) }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.setFill()
        bounds.fill()
        scene.render(in: bounds, dark: true)
    }

    override func touchesBegan(with event: NSEvent) {
        scene.paused.toggle()
        needsDisplay = true
    }
}

// ======================================================================
// MARK: - Controller window (keyboard fallback — needs no permissions)
// ======================================================================

final class ControllerView: NSView {
    weak var controller: AppDelegate?
    override var acceptsFirstResponder: Bool { true }
    override func keyDown(with event: NSEvent) {
        controller?.gameKey(code: Int(event.keyCode), down: true, isRepeat: event.isARepeat)
    }
    override func keyUp(with event: NSEvent) {
        controller?.gameKey(code: Int(event.keyCode), down: false, isRepeat: false)
    }
}

// ======================================================================
// MARK: - App delegate
// ======================================================================

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSWindowDelegate {
    var timer: Timer?
    var lastTick = CACurrentMediaTime()

    // Compact dino icon in the menu bar that opens the game menu on click
    var gameMenuItem: NSStatusItem?

    // Keyboard game
    let input = Input()
    var gameOn = false
    var eventTap: CFMachPort?
    var tapSource: CFRunLoopSource?
    var panel: NSWindow?
    var upgradeTimer: Timer?

    // The one-time "how to get global keys" explainer — never show it twice.
    var axOffered: Bool {
        get { UserDefaults.standard.bool(forKey: "axOffered") }
        set { UserDefaults.standard.set(newValue, forKey: "axOffered") }
    }

    // Touch Bar (independent scene so each strip adapts to its own width)
    let tbScene = Scene()
    var tbView: DinoTouchBarView?
    var tbBar: NSTouchBar?
    var tbTray: NSCustomTouchBarItem?
    var tbPresented = false
    var touchBarOn = false
    static let trayID = NSTouchBarItem.Identifier("local.trexbar.tray")
    static let stripID = NSTouchBarItem.Identifier("local.trexbar.strip")

    static let speeds: [(String, Double)] =
        [("Chill", 0.6), ("Normal", 1.0), ("Fast", 1.6), ("Insane", 2.4)]

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Single instance: this launch takes over — ask any older instance to
        // quit (force it if needed) so re-opening the app always works.
        if let bid = Bundle.main.bundleIdentifier {
            let others = NSRunningApplication.runningApplications(withBundleIdentifier: bid)
                .filter { $0 != NSRunningApplication.current }
            if !others.isEmpty {
                others.forEach { $0.terminate() }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                    NSRunningApplication.runningApplications(withBundleIdentifier: bid)
                        .filter { $0 != NSRunningApplication.current }
                        .forEach { $0.forceTerminate() }
                    self?.finishLaunching()
                }
                return
            }
        }
        finishLaunching()
    }

    private func finishLaunching() {
        let defaults = UserDefaults.standard
        tbScene.speedMul = defaults.object(forKey: "speed") as? Double ?? 1.0
        tbScene.input = input

        // The dino icon in the menu bar — click it for the game menu.
        gameMenuItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = gameMenuItem?.button {
            button.image = Self.dinoIcon(height: 16, color: .black, template: true)
            button.toolTip = "T-Rex Bar — game menu"
        }
        let barMenu = NSMenu()
        barMenu.delegate = self
        gameMenuItem?.menu = barMenu

        let t = Timer(timeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(t, forMode: .common)
        timer = t

        touchBarOn = defaults.object(forKey: "touchBarOn") as? Bool ?? true
        if touchBarOn && TouchBarSupport.available {
            // Give the status item a beat to settle before taking the strip.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.enableTouchBar()
            }
        }
    }

    private func tick() {
        let now = CACurrentMediaTime()
        let dt = min(now - lastTick, 0.1)
        lastTick = now
        if tbPresented, let tv = tbView, !tbScene.paused {
            tbScene.update(dt: dt)
            tv.needsDisplay = true
        }
    }

    // ------------------------------------------------------------------
    // Touch Bar
    // ------------------------------------------------------------------

    static func dinoIcon(height: CGFloat = 20, color: NSColor = .white,
                         template: Bool = false) -> NSImage {
        let rows = Art.dinoRunA
        let px = height / CGFloat(rows.count)
        let size = NSSize(width: CGFloat(rows[0].count) * px, height: height)
        let img = NSImage(size: size)
        img.lockFocus()
        color.setFill()
        for (r, rowStr) in rows.enumerated() {
            var c = 0
            for ch in rowStr {
                if ch == "X" {
                    NSRect(x: CGFloat(c) * px, y: CGFloat(rows.count - 1 - r) * px,
                           width: px, height: px).fill()
                }
                c += 1
            }
        }
        img.unlockFocus()
        img.isTemplate = template
        return img
    }

    func enableTouchBar() {
        guard TouchBarSupport.available else { return }
        if tbBar == nil {
            let view = DinoTouchBarView(scene: tbScene)
            let item = NSCustomTouchBarItem(identifier: Self.stripID)
            item.view = view
            let bar = NSTouchBar()
            bar.templateItems = [item]
            bar.defaultItemIdentifiers = [Self.stripID]
            tbView = view
            tbBar = bar

            let tray = NSCustomTouchBarItem(identifier: Self.trayID)
            tray.view = NSButton(image: Self.dinoIcon(), target: self,
                                 action: #selector(presentTouchBar))
            tbTray = tray
            TouchBarSupport.addSystemTrayItem(tray)
            TouchBarSupport.setControlStripPresence(Self.trayID.rawValue, true)
            TouchBarSupport.showCloseBox(true)
        }
        let mode = TouchBarSupport.presentationMode
        if mode == "fullControlStrip" || mode == "functionKeys" {
            // Remember the user's mode; give ControlStrip a moment to restart
            // in the new mode before presenting.
            UserDefaults.standard.set(mode, forKey: "prevTouchBarMode")
            TouchBarSupport.setPresentationMode("appWithControlStrip")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.presentTouchBar()
            }
        } else {
            presentTouchBar()
        }
    }

    @objc func presentTouchBar() {
        guard let bar = tbBar else { return }
        TouchBarSupport.presentSystemModal(bar, systemTrayItemIdentifier: Self.trayID.rawValue)
        tbPresented = true
    }

    func disableTouchBar() {
        if let bar = tbBar { TouchBarSupport.dismissSystemModal(bar) }
        TouchBarSupport.setControlStripPresence(Self.trayID.rawValue, false)
        if let tray = tbTray { TouchBarSupport.removeSystemTrayItem(tray) }
        tbPresented = false
        tbBar = nil
        tbView = nil
        tbTray = nil
        if let prev = UserDefaults.standard.string(forKey: "prevTouchBarMode") {
            TouchBarSupport.setPresentationMode(prev)
            UserDefaults.standard.removeObject(forKey: "prevTouchBarMode")
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Give the user their Touch Bar mode back; keep the key so the next
        // launch knows what to restore after it re-enables the dino.
        if tbPresented, let prev = UserDefaults.standard.string(forKey: "prevTouchBarMode") {
            TouchBarSupport.setPresentationMode(prev)
        }
    }

    @objc func toggleTouchBar() {
        touchBarOn.toggle()
        UserDefaults.standard.set(touchBarOn, forKey: "touchBarOn")
        if touchBarOn {
            enableTouchBar()
        } else {
            if gameOn { stopGame() }   // nowhere left to play
            disableTouchBar()
        }
    }

    @objc func togglePause() {
        tbScene.paused.toggle()
        tbView?.needsDisplay = true
    }

    // ------------------------------------------------------------------
    // Keyboard game (global CGEvent tap — needs Accessibility permission)
    // ------------------------------------------------------------------

    @objc func toggleGame() {
        if gameOn { stopGame() } else { startGame() }
    }

    func startGame() {
        guard !gameOn else { return }
        // Best case: Accessibility is granted -> a global event tap lets the
        // arrows steer the dino no matter which app is focused.
        // Otherwise fall back to a tiny floating controller window that
        // captures the keys the normal way — works with zero permissions.
        if !(AXIsProcessTrusted() && startKeyTap()) {
            offerAccessibility()
            openControllerPanel()
            // The instant Accessibility gets granted, swap the controller
            // window for global keys — no dialog, no window.
            startUpgradeWatch()
        }
        // The game lives on the Touch Bar — make sure it's showing.
        if TouchBarSupport.available && !touchBarOn {
            touchBarOn = true
            UserDefaults.standard.set(true, forKey: "touchBarOn")
            enableTouchBar()
        }
        gameOn = true
        tbScene.paused = false
        tbScene.beginPlay()
    }

    func stopGame() {
        upgradeTimer?.invalidate()
        upgradeTimer = nil
        stopKeyTap()
        closeControllerPanel()
        input.left = false
        input.right = false
        input.down = false
        gameOn = false
        tbScene.endPlay()
    }

    // Shared by the event tap and the controller window.
    func gameKey(code: Int, down: Bool, isRepeat: Bool) {
        switch code {
        case 123: input.left = down
        case 124: input.right = down
        case 125: input.down = down
        case 126, 49:                       // ↑ or space: jump / restart after crash
            if down && !isRepeat { input.jumpStamp &+= 1 }
        case 53:                            // esc leaves the game
            if down { DispatchQueue.main.async { [weak self] in self?.stopGame() } }
        default: break
        }
    }

    private func openControllerPanel() {
        if panel == nil {
            let size = NSRect(x: 0, y: 0, width: 340, height: 46)
            let w = NSWindow(contentRect: size, styleMask: [.titled, .closable],
                             backing: .buffered, defer: false)
            w.title = "T-Rex Controller"
            w.level = .floating
            w.isReleasedWhenClosed = false
            w.isMovableByWindowBackground = true
            w.delegate = self
            let view = ControllerView(frame: size)
            view.controller = self
            let label = NSTextField(labelWithString: "← → run    ↑ jump    ↓ duck    esc quit")
            label.alignment = .center
            label.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
            label.frame = NSRect(x: 0, y: 15, width: size.width, height: 16)
            label.autoresizingMask = [.width]
            view.addSubview(label)
            w.contentView = view
            if let sf = NSScreen.main?.visibleFrame {
                w.setFrameTopLeftPoint(NSPoint(x: sf.maxX - size.width - 20, y: sf.maxY - 10))
            }
            panel = w
        }
        NSApp.activate(ignoringOtherApps: true)
        panel?.makeKeyAndOrderFront(nil)
        panel?.makeFirstResponder(panel?.contentView)
    }

    private func closeControllerPanel() {
        panel?.orderOut(nil)
    }

    private func startUpgradeWatch() {
        upgradeTimer?.invalidate()
        upgradeTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] tm in
            guard let self, self.gameOn, self.eventTap == nil else { tm.invalidate(); return }
            if AXIsProcessTrusted(), self.startKeyTap() {
                tm.invalidate()
                self.upgradeTimer = nil
                self.closeControllerPanel()
            }
        }
    }

    func windowWillClose(_ notification: Notification) {
        if (notification.object as? NSWindow) === panel && gameOn { stopGame() }
    }

    // Explain (once per launch) how to get rid of the controller window.
    private func offerAccessibility() {
        guard !axOffered else { return }
        axOffered = true
        // Registers the app in the Accessibility list & shows the system prompt.
        let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        _ = AXIsProcessTrustedWithOptions([promptKey: true] as CFDictionary)

        let a = NSAlert()
        a.messageText = "Ready to play — one optional upgrade"
        a.informativeText = """
            The game starts now in the little "T-Rex Controller" window: \
            keep it focused and use the arrow keys.

            Prefer to play with arrows working globally, whatever app is \
            focused? Allow T-Rex Bar under System Settings → Privacy & \
            Security → Accessibility — the moment you allow it, the \
            controller window disappears by itself. If T-Rex Bar is already \
            in that list but greyed-out or ignored, remove it with − and add \
            it back.

            (This message won't be shown again.)
            """
        a.addButton(withTitle: "Open System Settings")
        a.addButton(withTitle: "Play Now")
        NSApp.activate(ignoringOtherApps: true)
        if a.runModal() == .alertFirstButtonReturn {
            let url = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
            NSWorkspace.shared.open(URL(string: url)!)
        }
    }

    private static let tapCallback: CGEventTapCallBack = { _, type, event, refcon in
        guard let refcon else { return Unmanaged.passUnretained(event) }
        let me = Unmanaged<AppDelegate>.fromOpaque(refcon).takeUnretainedValue()
        return me.handleKey(type: type, event: event)
    }

    private func startKeyTap() -> Bool {
        let mask = (CGEventMask(1) << CGEventType.keyDown.rawValue) |
                   (CGEventMask(1) << CGEventType.keyUp.rawValue)
        guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                          place: .headInsertEventTap,
                                          options: .defaultTap,
                                          eventsOfInterest: mask,
                                          callback: AppDelegate.tapCallback,
                                          userInfo: Unmanaged.passUnretained(self).toOpaque())
        else { return false }
        eventTap = tap
        let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        tapSource = src
        CFRunLoopAddSource(CFRunLoopGetMain(), src, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        return true
    }

    private func stopKeyTap() {
        if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: false) }
        if let src = tapSource { CFRunLoopRemoveSource(CFRunLoopGetMain(), src, .commonModes) }
        if let tap = eventTap { CFMachPortInvalidate(tap) }
        eventTap = nil
        tapSource = nil
    }

    private func handleKey(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: true) }
            return Unmanaged.passUnretained(event)
        }
        guard gameOn, type == .keyDown || type == .keyUp else {
            return Unmanaged.passUnretained(event)
        }
        // App shortcuts (⌘/⌃/⌥ + key) pass through untouched.
        if !event.flags.intersection([.maskCommand, .maskControl, .maskAlternate]).isEmpty {
            return Unmanaged.passUnretained(event)
        }
        let isDown = type == .keyDown
        let isRepeat = event.getIntegerValueField(.keyboardEventAutorepeat) != 0
        let code = Int(event.getIntegerValueField(.keyboardEventKeycode))
        switch code {
        case 123, 124, 125, 126, 49, 53:
            gameKey(code: code, down: isDown, isRepeat: isRepeat)
            return nil   // swallowed — the game ate it
        default:
            return Unmanaged.passUnretained(event)
        }
    }

    // The dino icon's menu — rebuilt every time it opens.
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        fillMenu(menu)
    }

    private func fillMenu(_ menu: NSMenu) {
        let title = NSMenuItem(title: "T-Rex Bar", action: nil, keyEquivalent: "")
        title.isEnabled = false
        menu.addItem(title)

        let game = NSMenuItem(title: gameOn ? "Stop Keyboard Game (esc)"
                                            : "Play with Keyboard  ← → ↑ ↓",
                              action: #selector(toggleGame), keyEquivalent: "")
        game.target = self
        game.state = gameOn ? .on : .off
        menu.addItem(game)

        let pause = NSMenuItem(title: tbScene.paused ? "Resume" : "Pause",
                               action: #selector(togglePause), keyEquivalent: "")
        pause.target = self
        menu.addItem(pause)
        menu.addItem(.separator())

        let speedMenu = NSMenu()
        for (idx, s) in Self.speeds.enumerated() {
            let item = NSMenuItem(title: s.0, action: #selector(setSpeed(_:)), keyEquivalent: "")
            item.target = self
            item.tag = idx
            item.state = abs(tbScene.speedMul - s.1) < 0.01 ? .on : .off
            speedMenu.addItem(item)
        }
        let speedRoot = NSMenuItem(title: "Speed", action: nil, keyEquivalent: "")
        menu.addItem(speedRoot)
        menu.setSubmenu(speedMenu, for: speedRoot)

        if TouchBarSupport.available {
            let tb = NSMenuItem(title: "Touch Bar Dino", action: #selector(toggleTouchBar),
                                keyEquivalent: "")
            tb.target = self
            tb.state = touchBarOn ? .on : .off
            menu.addItem(tb)
        }

        menu.addItem(.separator())
        if #available(macOS 13.0, *) {
            let login = NSMenuItem(title: "Launch at Login",
                                   action: #selector(toggleLogin), keyEquivalent: "")
            login.target = self
            login.state = SMAppService.mainApp.status == .enabled ? .on : .off
            menu.addItem(login)
            menu.addItem(.separator())
        }
        let relaunch = NSMenuItem(title: "Relaunch T-Rex Bar",
                                  action: #selector(relaunchApp), keyEquivalent: "r")
        relaunch.target = self
        menu.addItem(relaunch)

        let quit = NSMenuItem(title: "Quit T-Rex Bar", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
    }

    // Fresh start: spawn a new copy of the app — its single-instance
    // takeover terminates this one, so this is a full quit + reopen.
    @objc func relaunchApp() {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        p.arguments = ["-n", Bundle.main.bundlePath]
        try? p.run()
    }

    @objc func setSpeed(_ sender: NSMenuItem) {
        tbScene.speedMul = Self.speeds[sender.tag].1
        UserDefaults.standard.set(tbScene.speedMul, forKey: "speed")
    }

    @objc func toggleLogin() {
        if #available(macOS 13.0, *) {
            let svc = SMAppService.mainApp
            if svc.status == .enabled { try? svc.unregister() } else { try? svc.register() }
        }
    }

    @objc func quit() { NSApp.terminate(nil) }
}

// ======================================================================
// MARK: - Offline preview renderer (development aid)
//   TRexBar --sprites <dir>   renders every sprite large, for inspection
//   TRexBar --preview <dir>   renders staged menu-bar strips as PNGs
// ======================================================================

func writePNG(_ image: NSImage, to path: String) {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let data = rep.representation(using: .png, properties: [:]) else { return }
    try? data.write(to: URL(fileURLWithPath: path))
}

func renderSpriteSheet(dir: String) {
    let sprites: [(String, [String])] = [
        ("dinoRunA", Art.dinoRunA), ("dinoRunB", Art.dinoRunB), ("dinoJump", Art.dinoJump),
        ("dinoDuckA", Art.dinoDuckA), ("dinoDuckB", Art.dinoDuckB),
        ("pteroUp", Art.pteroUp), ("pteroDown", Art.pteroDown),
        ("cactusS", Art.cactusS), ("cactusL", Art.cactusL),
        ("cloud", Art.cloud), ("moon", Art.moon),
    ]
    let px: CGFloat = 10
    for (name, rows) in sprites {
        let w = CGFloat(rows[0].count) * px, h = CGFloat(rows.count) * px
        let img = NSImage(size: NSSize(width: w, height: h))
        img.lockFocus()
        NSColor.black.setFill()
        NSRect(x: 0, y: 0, width: w, height: h).fill()
        NSColor.white.setFill()
        for (r, rowStr) in rows.enumerated() {
            var c = 0
            for ch in rowStr {
                if ch == "X" {
                    NSRect(x: CGFloat(c) * px, y: CGFloat(rows.count - 1 - r) * px,
                           width: px, height: px).fill()
                }
                c += 1
            }
        }
        img.unlockFocus()
        writePNG(img, to: "\(dir)/\(name).png")
    }
}

func renderScenePreviews(dir: String) {
    let stripW = 420.0, stripH = 24.0, scale = 3.0

    func snapshot(_ name: String, dark: Bool, setup: (Scene) -> Void) {
        let scene = Scene()
        scene.viewW = stripW
        setup(scene)
        let img = NSImage(size: NSSize(width: stripW * scale, height: stripH * scale))
        img.lockFocus()
        (dark ? NSColor.black : NSColor.white).setFill()
        NSRect(x: 0, y: 0, width: stripW * scale, height: stripH * scale).fill()
        let xf = NSAffineTransform()
        xf.scale(by: CGFloat(scale))
        xf.concat()
        scene.render(in: NSRect(x: 0, y: 0, width: stripW, height: stripH), dark: dark)
        img.unlockFocus()
        writePNG(img, to: "\(dir)/\(name).png")
    }

    snapshot("1-run-dark", dark: true) { s in
        s.t = 3.0; s.worldX = 40; s.dinoX = 60
        s.obstacles = [.init(x: 260, kind: .cactusS), .init(x: 360, kind: .cactusL)]
    }
    snapshot("2-jump-dark", dark: true) { s in
        s.t = 5.0; s.worldX = 128; s.dinoX = 150; s.dinoY = 7.5; s.vy = 0.1
        s.obstacles = [.init(x: 165, kind: .cactusL), .init(x: 330, kind: .cluster)]
    }
    snapshot("3-duck-dark", dark: true) { s in
        s.t = 7.0; s.worldX = 200; s.dinoX = 200; s.ducking = true
        s.obstacles = [.init(x: 205, kind: .ptero), .init(x: 380, kind: .cactusS)]
    }
    snapshot("4-run-light", dark: false) { s in
        s.t = 9.0; s.worldX = 296; s.dinoX = 300
        s.obstacles = [.init(x: 120, kind: .cluster)]
    }
    snapshot("5-game-hud-dark", dark: true) { s in
        s.t = 4.0; s.worldX = 500; s.dinoX = 120; s.dinoY = 6; s.vy = 1
        s.mode = .playing; s.score = 231; s.hiScore = 1204; s.lives = 2
        s.obstacles = [.init(x: 190, kind: .cactusS), .init(x: 330, kind: .ptero)]
    }
    snapshot("6-gameover-dark", dark: true) { s in
        s.t = 6.0; s.worldX = 700; s.dinoX = 160
        s.mode = .dead; s.score = 452; s.hiScore = 1204; s.lives = 0
        s.obstacles = [.init(x: 172, kind: .cactusL)]
    }
}

// Renders the app icon (1024x1024 "icon_512x512@2x.png"): the Touch Bar
// night scene shrunk onto a black rounded square — dino, cactus, moon,
// and the three hearts.
func renderAppIcon(dir: String) {
    let S: CGFloat = 1024
    let img = NSImage(size: NSSize(width: S, height: S))
    img.lockFocus()

    let inset: CGFloat = 100
    let plate = NSRect(x: inset, y: inset, width: S - 2 * inset, height: S - 2 * inset)
    let squircle = NSBezierPath(roundedRect: plate, xRadius: 150, yRadius: 150)
    NSColor.black.setFill()
    squircle.fill()
    NSColor(white: 1, alpha: 0.16).setStroke()
    squircle.lineWidth = 8
    squircle.stroke()

    func sprite(_ rows: [String], x: CGFloat, bottom: CGFloat, px: CGFloat, color: NSColor) {
        color.setFill()
        for (r, rowStr) in rows.enumerated() {
            let y = bottom + CGFloat(rows.count - 1 - r) * px
            var c = 0
            for ch in rowStr {
                if ch == "X" {
                    NSRect(x: x + CGFloat(c) * px, y: y, width: px, height: px).fill()
                }
                c += 1
            }
        }
    }

    // Stars
    for (sx, sy, sz, a) in [(300.0, 660.0, 14.0, 0.9), (430, 730, 10, 0.6),
                            (560, 640, 12, 0.8), (640, 780, 10, 0.5),
                            (250, 560, 10, 0.5), (780, 560, 12, 0.7)] {
        NSColor(white: 1, alpha: a).setFill()
        NSRect(x: sx, y: sy, width: sz, height: sz).fill()
    }
    // Moon (top right)
    sprite(Art.moon, x: 700, bottom: 660, px: 16, color: NSColor(white: 1, alpha: 0.9))
    // Three hearts (top left)
    for i in 0..<3 {
        sprite(Art.heart, x: 165 + CGFloat(i) * 122, bottom: 762, px: 14, color: .white)
    }
    // Ground: dashed line + pebbles
    NSColor(white: 1, alpha: 0.9).setFill()
    var gx: CGFloat = 140
    while gx < 860 {
        NSRect(x: gx, y: 268, width: 40, height: 10).fill()
        gx += 56
    }
    NSColor(white: 1, alpha: 0.6).setFill()
    for px in [220.0, 460, 700] { NSRect(x: px, y: 240, width: 14, height: 10).fill() }
    // Cactus + the dino
    sprite(Art.cactusL, x: 665, bottom: 278, px: 22, color: .white)
    sprite(Art.dinoRunA, x: 175, bottom: 280, px: 24, color: .white)

    img.unlockFocus()
    writePNG(img, to: "\(dir)/icon_512x512@2x.png")
}

// Renders a scripted ~10 s play session as GIF frames at Touch Bar size:
// jumps, a duck under a pterodactyl, and one deliberate hit so the hearts
// show. Assemble with any GIF tool at ~15 fps.
func renderGifFrames(dir: String) {
    let W = 1085.0, H = 30.0
    let scene = Scene()
    let input = Input()
    scene.input = input
    scene.viewW = W
    scene.cell = H / scene.worldCells
    scene.speedMul = 1.5
    scene.beginPlay()
    scene.hiScore = 348
    scene.dinoX = 130
    scene.obstacles = [
        .init(x: 380, kind: .cactusS),
        .init(x: 560, kind: .ptero),
        .init(x: 760, kind: .cactusL),
        .init(x: 950, kind: .cactusS),    // this one lands — a heart goes
        .init(x: 1340, kind: .cactusL),
        .init(x: 1620, kind: .cactusS),   // still approaching at the end
    ]

    var frame = 0
    var out = 0
    var hitTaken = false
    while frame < 320 {
        scene.nextSpawn = 999             // fully scripted — no random spawns
        if scene.lives < 3 { hitTaken = true }
        let suppress = !hitTaken && frame > 170   // stand still, take the hit
        var wantDuck = false
        let front = scene.dinoX + 18 * scene.cell
        // Mirror the scene's live scroll speed so jumps stay well timed
        // as the world accelerates.
        let ramp = min((scene.worldX - scene.playStartX) / 40, 70)
        let closure = (65.0 + ramp) * scene.speedMul
        for ob in scene.obstacles {
            if ob.kind == .ptero {
                if ob.x < front + 40 && ob.x + 16 * scene.cell > scene.dinoX - 6 {
                    wantDuck = true
                }
            } else {
                let dist = ob.x - front
                if scene.dinoY == 0 && dist > -6 && dist < closure * 0.26 && !suppress {
                    input.jumpStamp += 1
                }
            }
        }
        input.down = wantDuck

        if frame % 2 == 0 {               // 30 fps sim -> 15 fps GIF
            let img = NSImage(size: NSSize(width: W, height: H))
            img.lockFocus()
            NSColor.black.setFill()
            NSRect(x: 0, y: 0, width: W, height: H).fill()
            scene.render(in: NSRect(x: 0, y: 0, width: W, height: H), dark: true)
            img.unlockFocus()
            writePNG(img, to: String(format: "%@/frame_%03d.png", dir, out))
            out += 1
        }
        scene.update(dt: 1.0 / 30.0)
        frame += 1
    }
}

// ======================================================================
// MARK: - Entry point
// ======================================================================

let args = CommandLine.arguments
if args.count >= 3, args[1] == "--sprites" {
    renderSpriteSheet(dir: args[2]); exit(0)
}
if args.count >= 3, args[1] == "--preview" {
    renderScenePreviews(dir: args[2]); exit(0)
}
if args.count >= 3, args[1] == "--appicon" {
    renderAppIcon(dir: args[2]); exit(0)
}
if args.count >= 3, args[1] == "--gifframes" {
    renderGifFrames(dir: args[2]); exit(0)
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
