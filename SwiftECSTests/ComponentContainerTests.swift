//
//  ComponentListTests.swift
//  Solar Wind Tests
//
//  Created by Neil Allain on 7/26/18.
//  Copyright © 2018 Neil Allain. All rights reserved.
//

import XCTest
@testable import SwiftECS

class ComponentContainerTests: XCTestCase {
	private var builder: EntityBuilder! = nil
	var named = DenseComponentContainer<Named>()
	var tagged = DenseComponentContainer<Tagged>()
	override func setUp() {
		super.setUp()
		builder = EntityBuilder()
		named = DenseComponentContainer<Named>().register(with: builder)
		tagged = DenseComponentContainer<Tagged>().register(with: builder)
	}

	func testForEach() {
		let namedEntity = builder.build().add(named, Named(name: "1"))
		let notNamedEntity = builder.build()
		var entities = Set<Entity>()
		var components = [Named]()
		named.forEach {
			entities.insert($0)
			components.append($1)
		}
		assertTrue(entities.contains(namedEntity))
		assertFalse(entities.contains(notNamedEntity))
		assertTrue(components.count == 1)
		assertTrue(components.first?.name == "1")
	}

	func testForEachMultiple() {
		let namedAndTaggedEntity = builder.build().add(named, Named(name: "1")).add(tagged, Tagged(tag: "a"))
		let namedEntity = builder.build().add(named, Named(name: "2"))
		let taggedEntity = builder.build().add(tagged, Tagged(tag: "b"))
		let noneEntity = builder.build()
		var entities = Set<Entity>()
		var names = [Named]()
		var tags = [Tagged]()
		named.forEach(with: tagged) { entity, name, tag in
			entities.insert(entity)
			names.append(name)
			tags.append(tag)
		}
		assertEqual(1, entities.count)
		assertTrue(entities.contains(namedAndTaggedEntity))
	  assertFalse(entities.contains(namedEntity))
		assertFalse(entities.contains(taggedEntity))
		assertFalse(entities.contains(noneEntity))
		assertEqual(1, names.count)
		assertTrue(names.contains { $0.name == "1" })
		assertEqual(1, tags.count)
		assertTrue(tags.contains { $0.tag == "a" })
	}
}
