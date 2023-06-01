//
//  TemplateTests.swift
//  
//
//  Created by 林彦君 on 1/6/23.
//

import XCTest
@testable import PluginPackageCreator

final class TemplateTests: XCTestCase {
    func testShouldIncludeAllOfSadCase() {
        let shouldInclude = ShouldInclude(allOf: ["a": true])
        let result = shouldInclude.shouldInclude(values: .init(["a": false]))
        XCTAssertFalse(result)
    }
    
    func testShouldIncludeAllOfSadCase2() {
        let shouldInclude = ShouldInclude(allOf: ["a": true])
        let result = shouldInclude.shouldInclude(values: .init([:]))
        XCTAssertFalse(result)
    }
    
    func testShouldIncludeAllOfSadCase3() {
        let shouldInclude = ShouldInclude(allOf: ["a": true, "b": false])
        let result = shouldInclude.shouldInclude(values: .init(["b": false]))
        XCTAssertFalse(result)
    }
    
    
    func testShouldIncludeAllOfHappyCase() {
        let shouldInclude = ShouldInclude(allOf: ["a": true])
        let result = shouldInclude.shouldInclude(values: .init(["a": true]))
        XCTAssertTrue(result)
    }
    
    
    func testShouldIncludeAllOfHappyCase2() {
        let shouldInclude = ShouldInclude(allOf: [:])
        let result = shouldInclude.shouldInclude(values: .init([:]))
        XCTAssertTrue(result)
    }
    
    func testShouldIncludeAllOfHappyCase3() {
        let shouldInclude = ShouldInclude(allOf: ["a": true])
        let result = shouldInclude.shouldInclude(values: .init(["a": true, "b": false]))
        XCTAssertTrue(result)
    }
    
    func testShouldIncludeAllOfHappyCase4() {
        let shouldInclude = ShouldInclude(allOf: [:])
        let result = shouldInclude.shouldInclude(values: .init(["b": true]))
        XCTAssertTrue(result)
    }
    
    

    
}
