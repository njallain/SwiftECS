//
//  NodeComponent.swift
//  Solar Wind iOS
//
//  Created by Neil Allain on 7/24/18.
//  Copyright © 2018 Neil Allain. All rights reserved.
//

import Foundation
import SpriteKit

typealias KitNode = SKNode

extension KitNode: Component {
}

protocol NodeComponents {
	associatedtype NodeListType: ComponentContainer where NodeListType.ComponentType == KitNode
	var nodes: NodeListType {get}
}

struct EntityNode<NodeType: KitNode> {
	let entity: Entity
	let node: NodeType

	@discardableResult
	func add<ComponentListType: ComponentContainer>(
		_ list: ComponentListType,
		_ component: ComponentListType.ComponentType) -> EntityNode<NodeType> {
		list.update(entity: self.entity, component: component)
		return self
	}
}

extension EntityBuilder {
	@discardableResult
	func build<NodeType: KitNode, ComponentListType: ComponentContainer>(
		node: NodeType,
		list: ComponentListType) -> EntityNode<NodeType>
		where  ComponentListType.ComponentType == KitNode {
		let nodeBuilder = EntityNode(entity: self.build(), node: node)
		list.update(entity: nodeBuilder.entity, component: nodeBuilder.node)
		return nodeBuilder
	}
}
