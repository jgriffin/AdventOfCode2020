//
//  Day22Tests.swift
//
//
//  Created by Griff on 12/27/20.
//

import ParserCombinator
import XCTest

final class Day22Tests: XCTestCase {
    let input = resourceURL(filename: "Day22Input.txt")!.readContents()!

    let example = """
    Player 1:
    9
    2
    6
    3
    1

    Player 2:
    5
    8
    4
    7
    10
    """
}

extension Day22Tests {
    func testParseExample() {
        let game = Self.game.match(example)
        XCTAssertNotNil(game)
    }

    func testParseInput() {
        let game = Self.game.match(input)!
        XCTAssertEqual(game.player1.cards.last, 50)
        XCTAssertEqual(game.player2.cards.last, 7)
    }

    func testPlayerUntilWinnerExample() {
        var game = Self.game.match(example)!
        let winner = game.playUntilWinner()
        XCTAssertEqual(winner, .player2)
        XCTAssertEqual(game.player1.score, 0)
        XCTAssertEqual(game.player2.score, 306)
    }

    func testPlayerUntilWinnerInput() {
        var game = Self.game.match(input)!
        let winner = game.playUntilWinner()
        XCTAssertEqual(winner, .player1)
        XCTAssertEqual(game.player1.score, 32824)
        XCTAssertEqual(game.player2.score, 0)
    }
}

extension Day22Tests {
    struct Game {
        var player1: Player
        var player2: Player

        enum Winner { case player1, player2 }
        
        mutating func playUntilWinner() -> Winner {
            while true {
                if let winner = playRound() {
                    return winner
                }
            }
        }

        mutating func playRound() -> Winner? {
            let card1 = player1.cards.removeFirst()
            let card2 = player2.cards.removeFirst()

            if card1 > card2 {
                player1.cards.append(contentsOf: [card1, card2])
            } else {
                player2.cards.append(contentsOf: [card2, card1])
            }

            if player1.cards.isEmpty {
                return .player2
            }
            if player2.cards.isEmpty {
                return .player1
            }
            return nil
        }
    }

    struct Player {
        let name: String
        var cards: [Int]

        var score: Int {
            cards.reversed()
                .enumerated()
                .reduce(0) { result, icard in
                    result + (icard.offset + 1) * icard.element
                }
        }
    }
}

extension Day22Tests {
    typealias P = Parser
    static let player = zip(P.character(if: { $0 != ":" }).oneOrMore().asString,
                            ":\n",
                            P.integer.oneOrMore(separatedBy: "\n"))
        .map { name, _, cards in Player(name: name, cards: cards) }

    static let game = player.takeCount(2, separatedBy: "\n\n")
        .ignoring(P.whitespacesAndNewlines.zeroOrMore())
        .map { players in Game(player1: players.first!, player2: players.last!) }
}
