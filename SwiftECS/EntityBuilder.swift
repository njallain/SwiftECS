//
//  EntityBuilder.swift
//  Solar Wind iOS
//
//  Created by Neil Allain on 7/24/18.
//  Copyright © 2018 Neil Allain. All rights reserved.
//

import Foundation

/**
 Builds and destroys new entities, allocating the correct entity id for each
*/
class EntityBuilder {
	private var _nextId = 0
	private var _freeIds = [Int]()
	private var _containers = [EntityContainer]()

	/**
	 Builds an entity with the next available id
	*/
	func build() -> Entity {
		if let freeId = _freeIds.last {
			_freeIds.removeLast()
			return Entity(id: freeId)
		}
		defer { _nextId += 1 }
		return Entity(id: _nextId)
	}

	/**
	 Destroys an entity, returning it's id to the pool and notifies any
	 registered entity container that it's been destroyed.
	*/
	func destroy(entity: Entity) {
		for list in _containers {
			list.remove(entity: entity)
		}
		_freeIds.append(entity.id)
	}

	/**
	 Destroys all entities
	*/
	func destroyAll() {
		_nextId = 0
		_freeIds = []
		for list in _containers {
			list.removeAll()
		}
	}

	/**
	 Registers a container with the builder that will be notified when an entity is destroyed.
	 This allows the container to clean up any resources associated with the entity
	*/
	func register(container: EntityContainer) {
		_containers.append(container)
	}
	/**
	 Registers multiple containers with the builder.
	*/
	func register(containers: [EntityContainer]) {
		_containers += containers
	}

	/**
	 Unregisters all entitiy containers
	*/
	func unregisterAll() {
		_containers.removeAll()
	}
}

extension Entity {
	/**
	 A helper function to easily add new components to an entity.
	 Returns the entity again so multiple components can be added in a single statement
	*/
	@discardableResult
	func add<ComponentListType: ComponentContainer>(
		_ list: ComponentListType,
		_ component: ComponentListType.ComponentType) -> Entity {
		list.update(entity: self, component: component)
		return self
	}
}

/**
 Protocol for anything that needs to be notified when an entity is destroyed
*/
protocol EntityContainer {
	func remove(entity: Entity)
	func removeAll()
	func register(with builder: EntityBuilder) -> Self
}

/**
 Helper for chaining creation of an entity container with registering it.
*/
extension EntityContainer {
	@discardableResult
	func register(with builder: EntityBuilder) -> Self {
		builder.register(container: self)
		return self
	}
}
