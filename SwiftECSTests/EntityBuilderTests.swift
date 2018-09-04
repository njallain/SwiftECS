//
//  EntityTests.swift
//  Solar Wind Tests
//
//  Created by Neil Allain on 7/22/18.
//  Copyright © 2018 Neil Allain. All rights reserved.
//

import XCTest
@testable import SwiftECS
import SpriteKit

class EntityBuilderTests: XCTestCase {

	private var builder: EntityBuilder! = nil
	override func setUp() {
		super.setUp()
		builder = EntityBuilder()
	}

	override func tearDown() {
		super.tearDown()
		builder.destroyAll()
		builder = nil
	}

	func testAllocateAndDestroy() {
		let entity = builder.build()
		assertEqual(0, entity.id)
		let entity2 = builder.build()
		assertEqual(1, entity2.id)
		assertFalse(entity == entity2)
		builder.destroy(entity: entity)
		let entity3 = builder.build()
		assertEqual(0, entity3.id)
		let entity4 = builder.build()
		assertEqual(2, entity4.id)
	}

	func testRegisteredComponentLists() {
		let components = DenseComponentContainer<Named>().register(with: builder)
		let entity = builder.build().add(components, Named(name: "a"))
		assertEqual("a", components.get(entity: entity)?.name)
		builder.destroy(entity: entity)
		assertNil(components.get(entity: entity))
	}

	func testComponentLists() {
		testComponentList(
			list: DenseComponentContainer<Named>().register(with: builder),
			componentA: Named(name: "A"),
			componentB: Named(name: "B"))
		testComponentList(
			list: SparseComponentContainer<Named>().register(with: builder),
			componentA: Named(name: "A"),
			componentB: Named(name: "B"))
	}
	func testDenseListSizing() {
		let list = DenseComponentContainer<Named>(size: 1).register(with: builder)
		let entityA = builder.build()
		let entityB = builder.build()
		list.update(entity: entityA, component: Named(name: "A"))
		assertEqual(nil, list.get(entity: entityB))
		list.remove(entity: entityB)
		list.update(entity: entityB, component: Named(name: "B"))
		assertEqual(1, entityB.id)
		assertEqual(Named(name: "B"), list.get(entity: entityB))
	}

	func testBuildNode() {
		let namedList = DenseComponentContainer<Named>(size: 10).register(with: builder)
		let list = DenseComponentContainer<SKNode>(size: 10).register(with: builder)
		let entityNode = builder.build(node: SKNode(), list: list).add(namedList, Named(name: "node"))
		assertEqual(entityNode.node, list.get(entity: entityNode.entity))
	}
	private func testComponentList<ComponentListType: ComponentContainer>(
		list: ComponentListType,
		componentA: ComponentListType.ComponentType,
		componentB: ComponentListType.ComponentType)
		where ComponentListType.ComponentType: Equatable {
			let entityA = builder.build()
			let entityB = builder.build()
			assertNil(list.get(entity: entityA))
			list.update(entity: entityA, component: componentA)
			assertEqual(componentA, list.get(entity: entityA))
			assertNil(list.get(entity: entityB))
			list.update(entity: entityA, component: componentB)
			list.update(entity: entityB, component: componentA)
			assertEqual(componentB, list.get(entity: entityA))
			XCTAssertNotEqual(componentA, list.get(entity: entityA))
			assertEqual(componentA, list.get(entity: entityB))
			list.remove(entity: entityA)
			assertNil(list.get(entity: entityA))
			assertEqual(componentA, list.get(entity: entityB))
	}

}
