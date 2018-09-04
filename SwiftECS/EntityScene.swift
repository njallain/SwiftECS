//
//  EntityScene.swift
//  Solar Wind iOS
//
//  Created by Neil Allain on 7/24/18.
//  Copyright © 2018 Neil Allain. All rights reserved.
//

import Foundation
import SpriteKit

public protocol EntityScene {
	var builder: EntityBuilder {get}
	func update(_ currentTime: TimeInterval)
}
