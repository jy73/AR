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
var glasses:Experience.Glasses!
var filterVal = 0
var rimL: Entity!
var rimR: Entity!
var stickL: Entity!
var stickR: Entity!
var middle: Entity!
var rimLModel: ModelEntity!
var rimRModel: ModelEntity!
var middleModel: ModelEntity!

var glassesObj: Entity!

struct ContentView : View {
    @State var filterNumber: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(filterNumber: $filterNumber).edgesIgnoringSafeArea(.all)
            
            HStack {
                Spacer()
                
                Button(action: {
                    self.filterNumber = 0
                    filterVal = 0
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
                    filterVal = 1
                }) {
                    Text("Hello World")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                }
                
                Spacer()
                
                Button(action: {
                    self.filterNumber = 2
                    filterVal = 2
                }) {
                    Text("Glasses")
                        .padding()
                        .background(Color.gray)
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
        glasses = nil
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
        case 2:
            let faceAnchor = try! Experience.loadGlasses()
            uiView.scene.anchors.append(faceAnchor)
            glasses = faceAnchor
            glassesObj = glasses.findEntity(named: "glassesObj")
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
            
            if filterVal == 0 {
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
            } else if filterVal == 2 {
                guard glasses != nil else {return}
                
                var faceAnchor: ARFaceAnchor?
                
                for anchor in anchors {
                    if let a = anchor as? ARFaceAnchor {
                        faceAnchor = a
                    }
                }
                
                guard let blendShapes = faceAnchor?.blendShapes,
                      let leftBrow = blendShapes[.browOuterUpLeft]?.floatValue,
                      let rightBrow = blendShapes[.browOuterUpRight]?.floatValue else {return}
                
//                let radians = (jawVal * 45.0 * Float.pi / 180.0) + 0
//                glassesObj.setOrientation(simd_quatf(angle: -0.785398, axis: SIMD3<Float>(0,1,0)), relativeTo: nil)
                let position = min(leftBrow, rightBrow) * -0.1 + 0.0144
                glassesObj.position.z = position
//                let y = 6.0 * jawVal + 1.44
//                glassesObj.setPosition(SIMD3<Float>(0, 0, -4.56), relativeTo: nil)
//                glassesObj.transform.translation = SIMD3<Float>(0, 0, -4.56)
//                glasses.glassesObj?.orientation = simd_quatf(
//                    angle: convToRad(-100 + (60)),
//                    axis: [1, 0, 0])


            }
            
            func convToRad(_ value: Float) -> Float {
                  return value * .pi / 180
                }
            


        }
    }
    
}
