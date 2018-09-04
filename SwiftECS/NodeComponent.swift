//
//  NodeComponent.swift
//  Solar Wind iOS
//
//  Created by Neil Allain on 7/24/18.
//  Copyright © 2018 Neil Allain. All rights reserved.
//

import Foundation
import SpriteKit

public typealias KitNode = SKNode

extension KitNode: Component {
}

public protocol NodeComponents {
	associatedtype NodeListType: ComponentContainer where NodeListType.ComponentType == KitNode
	var nodes: NodeListType {get}
}

public struct EntityNode<NodeType: KitNode> {
	public let entity: Entity
	public let node: NodeType

	@discardableResult
	public func add<ComponentListType: ComponentContainer>(
		_ list: ComponentListType,
		_ component: ComponentListType.ComponentType) -> EntityNode<NodeType> {
		list.update(entity: self.entity, component: component)
		return self
	}
}

public extension EntityBuilder {
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
