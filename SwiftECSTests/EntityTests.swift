//
//  EntityTests.swift
//  Solar Wind Tests
//
//  Created by Neil Allain on 7/26/18.
//  Copyright © 2018 Neil Allain. All rights reserved.
//

import XCTest
@testable import SwiftECS

class EntityTests: XCTestCase {

	private var builder: EntityBuilder! = nil
	var named = DenseComponentContainer<Named>()
	var tagged = DenseComponentContainer<Tagged>()
	var numbered = SparseComponentContainer<Numbered>()
	override func setUp() {
		super.setUp()
		builder = EntityBuilder()
		named = DenseComponentContainer<Named>().register(with: builder)
		tagged = DenseComponentContainer<Tagged>().register(with: builder)
		numbered = SparseComponentContainer<Numbered>().register(with: builder)
	}

	func testGet() {
		let namedEnt = builder.build().add(named, Named(name: "1"))
		let taggedEnt = builder.build().add(tagged, Tagged(tag: "a"))
		let namedAndTaggedEnt = builder.build().add(named, Named(name: "3")).add(tagged, Tagged(tag: "c"))
		let namedNumberedAndTagged = builder.build()
			.add(named, Named(name: "4"))
			.add(tagged, Tagged(tag: "d"))
			.add(numbered, Numbered(num: 5))
		assertNil(namedEnt.get(components: self.named, self.tagged))
		assertNil(taggedEnt.get(components: named, tagged))
		guard let (name3, tag3) = namedAndTaggedEnt.get(components: named, tagged) else {
			assertFail()
			return
		}
		assertEqual("3", name3.name)
		assertEqual("c", tag3.tag)
		guard let (name4, tag4, num4) =  namedNumberedAndTagged.get(components: named, tagged, numbered) else {
			assertFail()
			return
		}
		assertEqual("4", name4.name)
		assertEqual("d", tag4.tag)
		assertEqual(5, num4.num)
	}
}
