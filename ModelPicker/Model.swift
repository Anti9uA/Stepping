//
//  Model.swift
//  ModelPicker
//
//  Created by Michael David on 2021-07-14.
//

import UIKit
import RealityKit
import Combine
import RealityUI

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    // var modelEntity: ClickyEntity?

    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        self.image = UIImage(named: modelName)!
        
        let filename = modelName + ".usdz"
        
//        self.cancellable = ModelEntity.loadModelAsync(named: filename)
//            .sink(receiveCompletion: { loadCompletion in
//                // Handle error
//                print("DEBUG - unable to load model entity for modelName: \(self.modelName)")
//            }, receiveValue: { modelEntity in
//                // Get model entity
//                let clickyThing = ClickyEntity(model: modelEntity.model!) { (clickedObj, atPosition) in
//                    // In this example we're just assigning the colour of the clickable
//                    // entity model to a green SimpleMaterial.
//                    (clickedObj as? HasModel)?.model?.materials = [
//                        SimpleMaterial(color: .green, isMetallic: false)
//                    ]
//                }
//                self.modelEntity = clickyThing
//                // self.modelEntity = modelEntity
//                print("DEBUG - successfully loaded model eneity for modelName: \(self.modelName)")
//            })
        
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: { loadCompletion in
                // Handle error
                print("DEBUG - unable to load model entity for modelName: \(self.modelName)")
            }, receiveValue: { modelEntity in
                // Get model entity
                self.modelEntity = modelEntity

                print("DEBUG - successfully loaded model eneity for modelName: \(self.modelName)")
            })
        
//        self.cancellable = ModelEntity.loadAsync(named: filename)
//            .sink(receiveCompletion: { status in
//                print(status)
//            }) { entity in
//                let parentEntity = ModelEntity()
//                parentEntity.addChild(entity)
//
//                let entityBounds = entity.visualBounds(relativeTo: parentEntity)
//                parentEntity.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: entityBounds.extents).offsetBy(translation: entityBounds.center)])
//
//                self.modelEntity = parentEntity
//
//            }
    }
}

/// Example class that uses the HasClick protocol
class ClickyEntity: Entity, HasClick, HasModel {
  // Required property from HasClick
  var tapAction: ((HasClick, SIMD3<Float>?) -> Void)?

    init(model: ModelComponent, tapAction: @escaping ((HasClick, SIMD3<Float>?) -> Void)) {
    self.tapAction = tapAction
    super.init()
    self.model = model
    self.generateCollisionShapes(recursive: false)
  }

  required convenience init() {
     self.init()
  }
}
