import XCTest
import SwiftTreeSitter
import TreeSitterZenc

final class TreeSitterZencTests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_zenc())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading Zen-C grammar")
    }
}
