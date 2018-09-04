//
//  Component.swift
//  Solar Wind iOS
//
//  Created by Neil Allain on 7/24/18.
//  Copyright © 2018 Neil Allain. All rights reserved.
//

import Foundation

protocol Component {
}

/***
 * A component container is used to associate entities to a single component type.
 * The container can be queried for the component of any entity
 */
protocol ComponentContainer: EntityContainer {
	associatedtype ComponentType where ComponentType: Component
	/// Returns the component associated with the entity if it exists
	func get(entity: Entity) -> ComponentType?
	/// Updates or adds the component to the entity
	func update(entity: Entity, component: ComponentType)
	/// A sequence of all entities with their associated component if it has one
	var entities: AnySequence<(Entity, ComponentType)> {get}
}

/***
 * A component container that is expects to have a component associated to the majority of entities.
 */
class DenseComponentContainer<ComponentType: Component> :  ComponentContainer {

	/// Creates the container with a default capacity reserved
	convenience init() {
		self.init(size: 256)
	}
	/// Creates the container with space allocated for size entities.
	/// Ideally this is the maximum number of entities in the game
	init(size: Int) {
		slots.reserveCapacity(size)
	}

	func get(entity: Entity) -> ComponentType? {
		guard entity.id < slots.count else {
			return nil
		}
		let slot = slots[entity.id]
		switch slot {
		case .full(let component):
			return component
		case .empty:
			return nil
		}
	}
	func update(entity: Entity, component: ComponentType) {
		if entity.id < slots.count {
		} else {
			slots.reserveCapacity(entity.id * 2)
			while slots.count <= entity.id {
				slots.append(.empty)
			}
		}
		slots[entity.id] = .full(component)
	}

	var entities: AnySequence<(Entity, ComponentType)> {
		return AnySequence(slots.enumerated().filter({$0.1.isFull}).map({ return (Entity(id: $0.0), $0.1.component!) }))
	}

	func remove(entity: Entity) {
		if entity.id == slots.count-1 {
			slots.removeLast()
		} else if entity.id < slots.count {
			slots[entity.id] = .empty
		}
	}

	func removeAll() {
		for ndx in 0..<slots.count {
			slots[ndx] = .empty
		}
	}
	/// A slot is essentially a Swift Optional.
	private enum Slot {
		case empty
		case full(ComponentType)
		var isFull: Bool {
			switch self {
			case .full:
				return true
			case .empty:
				return false
			}
		}
		var component: ComponentType? {
			switch self {
			case .full(let component):
				return component
			case .empty:
				return nil
			}
		}
	}
	private var slots = [Slot]()
}

/***
 * A component container that is expects to have a component associated to a minority of entities.
 */
class SparseComponentContainer<ComponentType: Component> : ComponentContainer {
	private var components = [Entity: ComponentType]()
	init() {
	}
	func get(entity: Entity) -> ComponentType? {
		return components[entity]
	}
	func update(entity: Entity, component: ComponentType) {
		components[entity] = component
	}
	var entities: AnySequence<(Entity, ComponentType)> {
		return AnySequence(components.map({return ($0.key, $0.value)}))
	}
	func remove(entity: Entity) {
		components.removeValue(forKey: entity)
	}
	func removeAll() {
		components.removeAll()
	}
}

enum ContainerIterationAction: Equatable {
	case `continue`
	case `break`
}
extension ComponentContainer {
	func forEach(action: (Entity, ComponentType) -> Void) {
		for (entity, component) in entities {
			action(entity, component)
		}
	}

	func forEachUntil(action: (Entity, ComponentType) -> ContainerIterationAction) {
		for (entity, component) in entities {
			if action(entity, component) == .break {
				break
			}
		}
	}
	func forEach<ContainerType1: ComponentContainer>(
		with container: ContainerType1,
		action: (Entity, ComponentType, ContainerType1.ComponentType) -> Void) {
		self.forEach { entity, component in
			guard let component1 = container.get(entity: entity) else {
				return
			}
			action(entity, component, component1)
		}
	}

	func forEachUntil<ContainerType1: ComponentContainer>(
		with container: ContainerType1,
		action: (Entity, ComponentType, ContainerType1.ComponentType) -> ContainerIterationAction) {
		self.forEachUntil { entity, component in
			guard let component1 = container.get(entity: entity) else {
				return .continue
			}
			return action(entity, component, component1)
		}
	}
	func forEach<ContainerType1: ComponentContainer, ContainerType2: ComponentContainer>(
		with list1: ContainerType1,
		_ list2: ContainerType2,
		action: (Entity, ComponentType, ContainerType1.ComponentType, ContainerType2.ComponentType) -> Void) {
		self.forEach { entity, component in
			guard let (component1, component2) = entity.get(components: list1, list2) else {
				return
			}
			action(entity, component, component1, component2)
		}
	}
	func forEach<
		ContainerType1: ComponentContainer,
		ContainerType2: ComponentContainer,
		ContainerType3: ComponentContainer>(
		with list1: ContainerType1,
		_ list2: ContainerType2,
		_ list3: ContainerType3,
		action: (
			Entity,
			ComponentType,
			ContainerType1.ComponentType,
			ContainerType2.ComponentType,
			ContainerType3.ComponentType) -> Void) {
		self.forEach { entity, component in
			guard let (component1, component2, component3) = entity.get(components: list1, list2, list3) else {
				return
			}
			action(entity, component, component1, component2, component3)
		}
	}
}
