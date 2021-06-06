//
//  ContentView.swift
//  TestAR
//
//  Created by Jordan Yee on 6/5/21.
//

import SwiftUI
import RealityKit
import ARKit
import Swift

var arView: ARView!
var sunglasses: Experience.FilterOne!
var rimL: Entity!
var rimR: Entity!
var stickL: Entity!
var stickR: Entity!
var middle: Entity!
var rimLModel: ModelEntity!
var rimRModel: ModelEntity!
var middleModel: ModelEntity!

struct ContentView : View {
    @State var filterNumber: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(filterNumber: $filterNumber).edgesIgnoringSafeArea(.all)
            
            HStack {
                Spacer()
                
                Button(action: {
                    self.filterNumber = 0
                }) {
                    Text("Sunglasses")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                }
                
                Spacer()
                
                Button(action: {
                    self.filterNumber = 1
                }) {
                    Text("Hello World")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
        }
    }
}


struct ARViewContainer: UIViewRepresentable {
    
    @Binding var filterNumber: Int
    
    func makeUIView(context: Context) -> ARView {
        
        arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        return arView
    }
    
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
        sunglasses = nil
        arView.scene.anchors.removeAll()
        
        let config = ARFaceTrackingConfiguration()
        
        uiView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        switch (filterNumber) {
        case 0:
            let faceAnchor = try! Experience.loadFilterOne()
            uiView.scene.anchors.append(faceAnchor)
            sunglasses = faceAnchor
            rimL = sunglasses.findEntity(named: "rimL")
            rimR = sunglasses.findEntity(named: "rimR")
            stickL = sunglasses.findEntity(named: "stickL")
            stickR = sunglasses.findEntity(named: "stickR")
            middle = sunglasses.findEntity(named: "middle")
            
            rimLModel = rimL.children.first as? ModelEntity
            rimRModel = rimR.children.first as? ModelEntity
            middleModel = middle.children.first as? ModelEntity

            break
        case 1:
            let faceAnchor = try! Experience.loadFilterTwo()
            uiView.scene.anchors.append(faceAnchor)
            break
        default:
            break
        }
    }
    
    func makeCoordinator() -> ARDelegateHandler {
        ARDelegateHandler(self)
    }
    
    class ARDelegateHandler: NSObject, ARSessionDelegate {
        
        var arContainer: ARViewContainer
        
        init(_ control: ARViewContainer) {
            arContainer = control
            super.init()
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            
            guard sunglasses != nil else {return}
            
            var faceAnchor: ARFaceAnchor?
        
            
            for anchor in anchors {
                if let a = anchor as? ARFaceAnchor {
                    faceAnchor = a
                }
            }
            
            guard let blendShapes = faceAnchor?.blendShapes,
            let jawVal = blendShapes[.jawOpen]?.floatValue,
            let smileLVal = blendShapes[.mouthSmileLeft]?.floatValue,
            let smileRVal = blendShapes[.mouthSmileRight]?.floatValue else {return}
            

            rimL.scale.z = jawVal * 2 + 1.0
            rimR.scale.z = jawVal * 2 + 1.0
            
            rimLModel.model?.materials = [SimpleMaterial.init(color: .init(red: CGFloat(min(smileLVal, smileRVal)) + 0.24, green: 0.0, blue: 0.0, alpha: 1), isMetallic: true)]
            rimRModel.model?.materials = [SimpleMaterial.init(color: .init(red: CGFloat(min(smileLVal, smileRVal)) + 0.25, green: 0.0, blue: 0.0, alpha: 1), isMetallic: true)]
            middleModel.model?.materials = [SimpleMaterial.init(color: .init(red: CGFloat(min(smileLVal, smileRVal)) + 0.25, green: 0.0, blue: 0.0, alpha: 1), isMetallic: true)]

        }
    }
    
}
