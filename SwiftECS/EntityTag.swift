//
//  File.swift
//  SwiftECS
//
//  Created by Neil Allain on 9/10/18.
//  Copyright © 2018 Neil Allain. All rights reserved.
//

import Foundation

/**
 An EntityTag is a way of identifying a set of Entities.
 While a component can be used to do something similar, this is simpler way to do so
 when the component is only being used to identify entities and not to add properties
 to the entity.

 In addition, an entity may have multiple tags of the same type (while it may only have
 one component of a given type)
*/
public protocol EntityTag: Hashable {
}

public protocol EntityTagContainer: EntityContainer {
	associatedtype TagType where TagType: EntityTag
	/// Add the tag to the entity if it doesn't already exist
	func add(tag: TagType, toEntity: Entity)
	/// Remove the tag from the entity if it doesn't already exist
	func remove(tag: TagType, fromEntity: Entity)
	/// Sets the complete set of tags for the given entity
	func set<Source: Sequence>(tags: Source, forEntity: Entity) where TagType == Source.Element
	/// Finds all the entities with the given tag
	func entities(withTag: TagType) -> Set<Entity>
	/// Finds all the entities that have at least one of the given tags
	func entities<Source: Sequence>(withAnyTag: Source) -> Set<Entity> where TagType == Source.Element
	/// Finds all the tags for the given entity
	func tags(forEntity: Entity) -> Set<TagType>
}

/**
 A DenseTagContainer is optimized for the case where most entities have at least one more tags
*/
public class DenseTagContainer<TagType: EntityTag>: EntityTagContainer {

	/// Creates the container with a default capacity reserved
	public convenience init() {
		self.init(size: 256)
	}
	/// Creates the container with space allocated for size entities.
	/// Ideally this is the maximum number of entities in the game
	public init(size: Int) {
		tags.reserveCapacity(size)
	}

	public func remove(entity: Entity) {
		if tags.count < entity.id {
			tagMap.remove(tags: tags[entity.id], fromEntity: entity)
			tags[entity.id] = noTags
		}
	}
	public func removeAll() {
		tags.removeAll()
		tagMap.removeAll()
	}

	public func add(tag: TagType, toEntity entity: Entity) {
		ensureCapacity(entity: entity)
		var entityTags = tags[entity.id]
		entityTags.insert(tag)
		tags[entity.id] = entityTags
		tagMap.add(tag: tag, toEntity: entity)
	}

	public func remove(tag: TagType, fromEntity entity: Entity) {
		guard entity.id <= tags.count else {
			return
		}
		var entityTags = tags[entity.id]
		entityTags.remove(tag)
		tags[entity.id] = entityTags
		tagMap.remove(tags: [tag], fromEntity: entity)
	}

	public func set<Source>(tags entityTags: Source, forEntity entity: Entity)
		where TagType == Source.Element, Source: Sequence {
		ensureCapacity(entity: entity)
		tagMap.set(tags: entityTags, previous: tags(forEntity: entity), forEntity: entity)
		tags[entity.id] = Set(entityTags)

	}
	public func tags(forEntity entity: Entity) -> Set<TagType> {
		if entity.id <= tags.count {
			return tags[entity.id]
		}
		return noTags
	}
	public func entities(withTag tag: TagType) -> Set<Entity> {
		return tagMap.entities(withTag: tag)
	}

	public func entities<Source: Sequence>(withAnyTag tags: Source) -> Set<Entity>
		where TagType == Source.Element {
		return tagMap.entities(withAnyTag: tags)
	}

	private func ensureCapacity(entity: Entity) {
		while entity.id >= tags.count {
			tags.append(noTags)
		}
	}
	private let noTags = Set<TagType>()
	private var tags = [Set<TagType>]()
	private let tagMap = TagEntityMap<TagType>()
}

/**
 A SparseTagContainer is optimized for the case where most entities do not have an associated tag
*/
public class SparseTagContainer<TagType: EntityTag> : EntityTagContainer {
	public init() {
	}
	public func remove(entity: Entity) {
		guard let tags = entitiesToTags[entity] else { return }
		for tag in tags {
			tagMap.remove(tags: [tag], fromEntity: entity)
		}
		entitiesToTags.removeValue(forKey: entity)

	}
	public func removeAll() {
		entitiesToTags.removeAll()
		tagMap.removeAll()
	}

	public func add(tag: TagType, toEntity  entity: Entity) {
		tagMap.add(tag: tag, toEntity: entity)
		guard var entityTags = entitiesToTags[entity] else {
			entitiesToTags[entity] = Set([tag])
			return
		}
		entityTags.insert(tag)
		entitiesToTags[entity] = entityTags
	}

	public func remove(tag: TagType, fromEntity entity: Entity) {
		tagMap.remove(tags: [tag], fromEntity: entity)
		guard var entityTags = entitiesToTags[entity] else {
			return
		}
		entityTags.remove(tag)
		entitiesToTags[entity] = entityTags
	}

	public func set<Source>(tags entityTags: Source, forEntity entity: Entity)
		where TagType == Source.Element, Source: Sequence {
		tagMap.set(tags: entityTags, previous: tags(forEntity: entity), forEntity: entity)
		entitiesToTags[entity] = Set(entityTags)
		for newTag in entityTags {
			tagMap.add(tag: newTag, toEntity: entity)
		}
	}
	public func tags(forEntity entity: Entity) -> Set<TagType> {
		return entitiesToTags[entity] ?? noTags
	}

	public func entities(withTag tag: TagType) -> Set<Entity> {
		return tagMap.entities(withTag: tag)
	}

	public func entities<Source: Sequence>(withAnyTag tags: Source) -> Set<Entity>
		where TagType == Source.Element {
		return tagMap.entities(withAnyTag: tags)
	}
	private let noTags = Set<TagType>()
	private var entitiesToTags = [Entity: Set<TagType>]()
	private let tagMap = TagEntityMap<TagType>()
}

/**
 The TagEntityMap implements the common Tag -> Entities relationship that
 both container types (dense and sparse) use.
*/
private class TagEntityMap<TagType: EntityTag> {
	func add(tag: TagType, toEntity entity: Entity) {
		var entities = tagsToEntities[tag] ?? Set<Entity>()
		entities.insert(entity)
		tagsToEntities[tag] = entities
	}
	func remove<Source>(tags: Source, fromEntity entity: Entity) where Source.Element == TagType, Source: Sequence {
		for tag in tags {
			guard var tagEntities = tagsToEntities[tag] else { continue }
			tagEntities.remove(entity)
			tagsToEntities[tag] = tagEntities
		}
	}
	func removeAll() {
		tagsToEntities.removeAll()
	}
	func set<NewSource, PreviousSource>(tags: NewSource, previous: PreviousSource, forEntity entity: Entity)
		where TagType == NewSource.Element, NewSource: Sequence,
		TagType == PreviousSource.Element, PreviousSource: Sequence {
		remove(tags: previous, fromEntity: entity)
		for tag in tags {
			add(tag: tag, toEntity: entity)
		}
	}
	func entities(withTag tag: TagType) -> Set<Entity> {
		guard let entities = tagsToEntities[tag] else {
			return noEntities
		}
		return entities
	}
	func entities<Source: Sequence>(withAnyTag tags: Source) -> Set<Entity>
		where TagType == Source.Element {
		let all = tags.compactMap { tagsToEntities[$0] }
		return all.reduce(Set<Entity>()) { $0.union($1) }
	}
	private let noEntities = Set<Entity>()
	private var tagsToEntities = [TagType: Set<Entity>]()
}
