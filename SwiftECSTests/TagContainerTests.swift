//
//  TagContainerTests.swift
//  SwiftECSTests
//
//  Created by Neil Allain on 9/10/18.
//  Copyright © 2018 Neil Allain. All rights reserved.
//

import XCTest
import SwiftECS

enum SweetTag: EntityTag, CaseIterable {
	case foo
	case bar
	case baz
}
class TagContainerTests: XCTestCase {
	private var builder: EntityBuilder! = nil
	private var sparse: SparseTagContainer<SweetTag>! = nil
	private var dense: DenseTagContainer<SweetTag>! = nil
	override func setUp() {
		super.setUp()
		builder = EntityBuilder()
		sparse = SparseTagContainer<SweetTag>()
		dense = DenseTagContainer<SweetTag>()
	}

	func testAddRemove() {
		addRemoveTest(sparse)
		addRemoveTest(dense)
	}

	func testSet() {
		setTest(sparse)
		setTest(dense)
	}

	func testEntitiesWithTag() {
		entitiesWithTagTest(sparse)
		entitiesWithTagTest(dense)
	}

	private func addRemoveTest<ContainerType: EntityTagContainer>(_ container: ContainerType)
		where ContainerType.TagType == SweetTag {
		let entity1 = builder.build()
		let entity2 = builder.build()
		container.add(tag: .foo, toEntity: entity1)
		container.add(tag: .bar, toEntity: entity1)
		container.add(tag: .foo, toEntity: entity2)
		verify(container, entity1, [.foo, .bar])
		verify(container, entity2, [.foo])

		container.remove(tag: .foo, fromEntity: entity1)
		verify(container, entity1, [.bar])
	}

	private func setTest<ContainerType: EntityTagContainer>(_ container: ContainerType)
		where ContainerType.TagType == SweetTag {
		let entity1 = builder.build()
		let entity2 = builder.build()
		container.set(tags: [.foo, .bar], forEntity: entity1)
		container.set(tags: [.foo], forEntity: entity2)
		verify(container, entity1, [.foo, .bar])
		verify(container, entity2, [.foo])

		container.set(tags: [.baz], forEntity: entity1)
		verify(container, entity1, [.baz])
	}

	private func entitiesWithTagTest<ContainerType: EntityTagContainer>(_ container: ContainerType)
		where ContainerType.TagType == SweetTag {
		let entity1 = builder.build()
		let entity2 = builder.build()
		container.set(tags: [.foo, .bar], forEntity: entity1)
		container.set(tags: [.foo], forEntity: entity2)
		verify(container, entity1, [.foo, .bar])
		verify(container, entity2, [.foo])
	}

	private func verify<Container, Source>(_ container: Container, _ entity: Entity, _ tags: Source)
		where Source.Element == SweetTag, Source: Sequence,
		Container: EntityTagContainer, Container.TagType == SweetTag {
		let noTags = SweetTag.allCases.filter { !tags.contains($0) }
		let hasTags = container.tags(forEntity: entity)
		assertTrue(hasTags == Set(tags))
		for tag in tags {
			assertTrue(container.entities(withTag: tag).contains(entity))
		}
		for tag in noTags {
			assertFalse(container.entities(withTag: tag).contains(entity))
		}
		assertFalse(container.entities(withAnyTag: noTags).contains(entity))
		assertTrue(container.entities(withAnyTag: SweetTag.allCases).contains(entity))
	}
}
