//
//  Entity.swift
//  Solar Wind iOS
//
//  Created by Neil Allain on 7/22/18.
//  Copyright © 2018 Neil Allain. All rights reserved.
//

import Foundation

struct Entity: Hashable {
	// swiftlint:disable identifier_name
	let id: Int
	// swiftlint:enable identifier_name
}

extension Entity {
	func get<ComponentListType1: ComponentContainer, ComponentListType2: ComponentContainer>(
		components list1: ComponentListType1,
		_ list2: ComponentListType2) -> (ComponentListType1.ComponentType, ComponentListType2.ComponentType)? {
		guard let component1 = list1.get(entity: self) else {
			return nil
		}
		guard let component2 = list2.get(entity: self) else {
			return nil
		}
		return (component1, component2)
	}

	// swiftlint:disable large_tuple
	func get<
		ComponentListType1: ComponentContainer,
		ComponentListType2: ComponentContainer,
		ComponentListType3: ComponentContainer>(
		components list1: ComponentListType1,
		_ list2: ComponentListType2,
		_ list3: ComponentListType3)
		-> (ComponentListType1.ComponentType, ComponentListType2.ComponentType, ComponentListType3.ComponentType)? {
		guard let component1 = list1.get(entity: self),
			let component2 = list2.get(entity: self),
			let component3 = list3.get(entity: self)  else {
			return nil
		}
		return (component1, component2, component3)
	}
	// swiftlint:enable large_tuple
}
