//
//  TestExtensions.swift
//  Solar Wind Tests
//
//  Created by Neil Allain on 7/4/18.
//  Copyright © 2018 Neil Allain. All rights reserved.
//

import Foundation
import XCTest
@testable import SwiftECS

func assertEqual<T>(
	_ expression1: @autoclosure () throws -> T?,
	_ expression2: @autoclosure () throws -> T?,
	_ message: @autoclosure () -> String = "",
	file: StaticString = #file, line: UInt = #line) where T: Equatable {
	return XCTAssertEqual(expression1, expression2, message, file: file, line: line)
}

func assertAlmostEqual<T: ApproximateEquatable>(
	_ expression1: @autoclosure () throws -> T?,
	_ expression2: @autoclosure () throws -> T?,
	file: StaticString = #file, line: UInt = #line) where T: Equatable {
	// swiftlint:disable force_try
	let lhs = try! expression1()!
	let rhs = try! expression2()!
	// swiftlint:enable force_try
	if lhs ~= rhs {
	} else {
		XCTFail("expected \(lhs), but was \(rhs)", file: file, line: line)
	}
	//return XCTAssertEqual(expression1, expression2, message, file: file, line: line)
}

func assertTrue(
	_ expression: @autoclosure () throws -> Bool,
	_ message: @autoclosure () -> String = "",
	file: StaticString = #file, line: UInt = #line) {
	XCTAssertTrue(expression, message, file: file, line: line)
}

func assertFalse(
	_ expression: @autoclosure () throws -> Bool,
	_ message: @autoclosure () -> String = "",
	file: StaticString = #file, line: UInt = #line) {
	XCTAssertFalse(expression, message, file: file, line: line)
}

func assertFail(_ message: String = "", file: StaticString = #file, line: UInt = #line) {
	XCTFail(message, file: file, line: line)
}

func assertNil(
	_ expression: @autoclosure () throws -> Any?,
	_ message: @autoclosure () -> String = "",
	file: StaticString = #file, line: UInt = #line) {
	XCTAssertNil(expression, message, file: file, line: line)
}

func assertNotNil(
	_ expression: @autoclosure () throws -> Any?,
	_ message: @autoclosure () -> String = "",
	file: StaticString = #file, line: UInt = #line) {
	XCTAssertNotNil(expression, message, file: file, line: line)
}

extension XCTestCase {
	func simulate(simulateFn: (Int) -> Bool) -> Int {
		var frame = 1
		self.measure {
			while simulateFn(frame) {
				frame += 1
			}
		}
		return frame
	}
}
