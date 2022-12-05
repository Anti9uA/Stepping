//
//  ContentView.swift
//  ModelPicker
//
//  Created by Michael David on 2021-07-13.
//

// Import(s)
import SwiftUI
import FocusEntity
import RealityKit
import ARKit
import UIKit
import RealityUI


private var models: [Model] = {
    // Dynamically get file names
    let filemanager =  FileManager.default
    
    guard let path = Bundle.main.resourcePath, let files = try? filemanager.contentsOfDirectory(atPath: path) else {
        return []
    }
    
    var availableModels: [Model] = []
    for filename in files where filename.hasSuffix("usdz") {
        let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
        let model = Model(modelName: modelName)
        availableModels.append(model)
    }
    
    return availableModels
}()

let backupModel = models

// Main content view
struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State private var modelConfirmedForPlacement: Model?
    @State private var isShowSheet = false
    @State private var backups = backupModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedForPlacement: self.$modelConfirmedForPlacement, isShowSheet: $isShowSheet)
                .sheet(isPresented: $isShowSheet) {
                    SampleView(selectedModel: $selectedModel, backupModel: $backups)
                }
            
            
            if self.isPlacementEnabled {
                PlacementButtonsView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            } else {
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: models)
            }
        }
    }
}

// ARView container
struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement: Model?
    @Binding var isShowSheet: Bool
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = CustomARView(frame: .zero)
        
        // ---------------------------------------------------------
        RealityUI.enableGestures(.all, on: arView)
        
        //        let testAnchor = AnchorEntity(world: [0, 0, -1])
        //
        //        let clickySphere = ClickyEntity(
        //          model: ModelComponent(mesh: .generateBox(size: 0.2), materials: [SimpleMaterial(color: .red, isMetallic: false)])
        //        ) {
        //            (clickedObj, atPosition) in
        //            // In this example we're just assigning the colour of the clickable
        //            // entity model to a green SimpleMaterial.
        //            (clickedObj as? HasModel)?.model?.materials = [
        //                SimpleMaterial(color: .green, isMetallic: false)
        //            ]
        //            print("testing 1 2 3")
        //
        //
        //        }
        
        //        testAnchor.addChild(clickySphere)
        //        arView.scene.addAnchor(testAnchor)
        // ---------------------------------------------------------
        
        return arView
    }
    
    
    func updateUIView(_ uiView: ARView, context: Context) {
        let anchorEntity = AnchorEntity(plane: .any)
        if let model = self.modelConfirmedForPlacement {
            if let modelEntity = model.modelEntity {
                print("DEBUG - adding model to scene: \(model.modelName)")
                let clicky = ClickyEntity(model: modelEntity.model!) {
                    (clickedObj, atPosition) in
                    // In this example we're just assigning the colour of the clickable
                    // entity model to a green SimpleMaterial.
                    print("hello hello")
                    print(anchorEntity.position)
                    
                    self.isShowSheet.toggle()
                    
                }
                anchorEntity.addChild(clicky)
                uiView.scene.addAnchor(anchorEntity)
            }
            
            var xX: Float = -0.1
            var zZ: Float = -0.1
            
            var count = 0
            _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ t in
                
                let anchorEntity2 = AnchorEntity(plane: .any)
                let model2 = backupModel[count]
                if let modelEntity2 = model2.modelEntity {
                    print("DEBUG - adding model to scene: \(model2.modelName)")
                    let clicky2 = ClickyEntity(model: modelEntity2.model!) {
                        (clickedObj, atPosition) in
                        // In this example we're just assigning the colour of the clickable
                        // entity model to a green SimpleMaterial.
                        print("hello hello")
                        print(anchorEntity.position)
                        self.isShowSheet.toggle()
                        
                    }
                    anchorEntity2.transform.translation = [xX, 0, zZ]
                    anchorEntity2.addChild(clicky2)
                    uiView.scene.addAnchor(anchorEntity2)
                }
                xX = (xX - 0.1) * -1
                zZ -= 0.2
                count += 1
                
                if count >= backupModel.count - 1 {
                        t.invalidate()
                }
            }
            
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
            
        }

    }
    
}



// Custom ARView with FocusEntity
class CustomARView: ARView {
    let focusSquare = FESquare()
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        
        focusSquare.viewDelegate = self
        focusSquare.delegate = self
        focusSquare.setAutoUpdate(to: true) // Auto-update position in scene
        
        self.setupARView()
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupARView() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        self.session.run(config)
    }
}

extension CustomARView: FEDelegate {
    func toTrackingState() {
        print("Tracking FE")
    }
    func toInitializingState() {
        print("Tnitializing FE")
    }
}


// Picker UI
struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    
    var models: [Model]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(0 ..< self.models.count) {
                    index in
                    Button(action: {
                        print("DEBUG - selected model with name: \(self.models[index].modelName)")
                        self.selectedModel = self.models[index]
                        self.isPlacementEnabled = true
                    }) {
                        Image(uiImage: self.models[index].image)
                            .resizable()
                            .frame(height: 71)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
}

// Placement confirm/cancel UI
struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
    
    var body: some View {
        HStack {
            // Cancel button
            Button(action: {
                print("DEBUG - cancel model placement")
                self.resetParameters()
            }) {
                Image(systemName: "xmark")
                    .frame(width: 50, height: 50)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
            
            // Confirmation button
            Button(action: {
                print("DEBUG - confirm model placement")
                self.modelConfirmedForPlacement = self.selectedModel
                self.resetParameters()
            }) {
                Image(systemName: "checkmark")
                    .frame(width: 50, height: 50)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }
    
    func resetParameters() {
        self.isPlacementEnabled = false
        // self.selectedModel = nil
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
