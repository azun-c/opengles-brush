//
//  FreeDrawViewRenderer.swift
//  opengles-brush
//
//  Created by azun on 2/4/24.
//

import Foundation
import MetalKit

enum BlendingMode {
    case none
    case max
    case add
}

@objc class FreeDrawViewRenderer: NSObject {
    weak var targetView: FreeDrawView?
    
    lazy var metalView: MTKView = {
        let view = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        view.clearColor = defaultOffscreenColor
        view.backgroundColor = .clear
        view.autoResizeDrawable = true
        view.delegate = self
        return view
    }()
    
    func clearMetalDrawings() {
        guard let currentDrawable = metalView.currentDrawable,
              let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        clear(texture: finishedTexture, with: defaultWhiteClearColor, by: commandBuffer)
        clear(texture: curveTexture, with: defaultOffscreenColor, by: commandBuffer)
        clear(texture: liveActionTexture, with: defaultOffscreenColor, by: commandBuffer)
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
    private lazy var metalDevice = MTLCreateSystemDefaultDevice()!
    private lazy var defaultOffscreenColor = MTLClearColorMake(0.0, 0.0, 0.0, 0.0)
    private lazy var defaultWhiteClearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)
    private lazy var viewportSize = SIMD2<Float>.zero
    private lazy var commandQueue = metalDevice.makeCommandQueue()!
    private lazy var defaultLibrary = metalDevice.makeDefaultLibrary()!
    
    private lazy var penTextures = [String: MTLTexture]()
    private lazy var quadVertexBuffer = createQuadVertexBuffer()
    
    // Texture to render new pen textures to
    private lazy var curveTexture = createOffscreenTexture()
    // Texture to render drawn objects - for storing purpose of onscreen texture
    private lazy var finishedTexture = createOffscreenTexture()
    // Texture to render new drawing objects - intermediate texture for displaying while actively drawing
    // when user touches and drags finger
    private lazy var liveActionTexture = createOffscreenTexture()
    
    // Render pass descriptor to draw penTexture to the texture
    private lazy var curveTextureRenderPass = createRenderPass(of: curveTexture,
                                                               loadAction: .load,
                                                               clearColor: defaultOffscreenColor,
                                                               storeAction: .store)
    // Render pass descriptor to draw offscreen texture to the finished texture
    private lazy var offscreenToFinishedRenderPass = createRenderPass(of: finishedTexture,
                                                                      loadAction: .load,
                                                                      clearColor: defaultOffscreenColor,
                                                                      storeAction: .store)
    // Render pass descriptor to draw new drawings to the liveActionTexture
    private lazy var liveActionRenderPass = createRenderPass(of: liveActionTexture,
                                                             loadAction: .load,
                                                             clearColor: defaultOffscreenColor,
                                                             storeAction: .store)
    
    // A pipeline object to render to the offscreen texture.
    private lazy var curveRenderPipeline = createPipeline(of: .normalProgram, mode: .max)
    // A pipeline object to render to the finished texture.
    private lazy var curveToFinishedRenderPipeline = createPipeline(of: .whiteAsAlphaProgram, mode: .add)
    // A pipeline object to copy finished texture to onscreen.
    private lazy var finishedToOnscreenRenderPipeline = createPipeline(of: .normalProgram, mode: .none)
    // A pipeline object to render new drawings texture (offscreen texture) to intermediate layer
    // when a finger taps and moves along
    private lazy var liveActionPipeline = createPipeline(of: .whiteAsAlphaProgram, mode: .add)
    // A pipeline object to render new drawings texture (offscreen texture) to intermediate layer
    // responsible for background rendering (finished texture)
    private lazy var liveActionBackgroundPipeline = createPipeline(of: .normalProgram, mode: .none)
    
    // Pen Texture to sample from.
    private var penTexture: MTLTexture? {
        loadPenTexture()
    }
}

//MARK: - MTKViewDelegate
extension FreeDrawViewRenderer: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Save the size of the drawable to pass to the vertex shader.
        viewportSize.x = size.width.asFloat
        viewportSize.y = size.height.asFloat
    }
    
    public func draw(in view: MTKView) {
        guard let currentDrawable = view.currentDrawable,
              let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        // render pen textures to offscreen texture
        renderOffscreen(with: commandBuffer)
        
        switch touchState {
        case .ended:
            // store
            renderOffscreenToFinished(with: commandBuffer)
            touchState = .none
            clear(texture: curveTexture, with: defaultOffscreenColor, by: commandBuffer)
            clear(texture: liveActionTexture, with: defaultOffscreenColor, by: commandBuffer)
            renderFinishedToOnscreen(with: commandBuffer, in: view)
        case .began, .moved:
            // live action
            renderFinishedToLiveAction(with: commandBuffer)
            renderOffscreenToLiveAction(with: commandBuffer)
            renderLiveActionToOnscreen(with: commandBuffer, in: view)
        default:
            // just render finished drawings
            renderFinishedToOnscreen(with: commandBuffer, in: view)
        }
        
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
}

//MARK: - Private properties
private extension FreeDrawViewRenderer {
    private var drawingRect: CGRect {
        targetView?.bounds ?? .zero
    }
    private var vertices: [VertexObj] {
        (targetView?.vertices ?? []).compactMap {
            $0 as? VertexObj
        }
    }
    private var lineWidth: Float {
        targetView?.lineWidth ?? 6
    }
    
    private var drawingColor: SIMD4<Float> {
        guard let colorArray = targetView?.m_drawColor else {
            return .zero
        }
        return .init(Float(colorArray[safe: 0] as? Double ?? 0),
                     Float(colorArray[safe: 1] as? Double ?? 0),
                     Float(colorArray[safe: 2] as? Double ?? 0),
                     Float(colorArray[safe: 3] as? Double ?? 0))
    }
    
    private var touchState: TouchState {
        get {
            targetView?.touchState ?? .none
        }
        set {
            targetView?.touchState = newValue
        }
    }
}

//MARK: - Private
private extension FreeDrawViewRenderer {
    func createQuadVertexBuffer() -> MTLBuffer? {
        let quadVertices: [FreeDrawTextureVertex] =
        [
            .init(position: .init( 1.0, -1.0), texcoord: .init(1.0, 1.0)),
            .init(position: .init(-1.0, -1.0), texcoord: .init(0.0, 1.0)),
            .init(position: .init(-1.0,  1.0), texcoord: .init(0.0, 0.0)),
            
                .init(position: .init( 1.0, -1.0), texcoord: .init(1.0, 1.0)),
            .init(position: .init(-1.0,  1.0), texcoord: .init(0.0, 0.0)),
            .init(position: .init( 1.0,  1.0), texcoord: .init(1.0, 0.0))
        ]
        return metalDevice.makeBuffer(bytes: quadVertices,
                                      length: quadVertices.size(),
                                      options: .storageModeShared)
    }
    
    func buildTriangleVertices() -> [FreeDrawTextureVertex] {
        guard vertices.count > 0 else { return [] }
        
        let triangleVerticesInViewportSpace: [FreeDrawTextureVertex] = vertices.map {
            return $0.asFreeDrawVertex()
        }
        // inspired by: https://stackoverflow.com/a/66519925
        return triangleVerticesInViewportSpace.map {
            .init(position: metalCoordinate(for: $0.position),
                  texcoord: $0.texcoord)
        }
    }
    
    func metalCoordinate(for position: SIMD2<Float>) -> SIMD2<Float> {
        // Quote: To transform the position into Metal’s coordinates, the function needs the size of the viewport (in pixels) that the triangle is being drawn into ==> (position.x * scale, position.y * scale)
        // Ref: https://developer.apple.com/documentation/metal/using_a_render_pipeline_to_render_primitives
        let scale = metalView.contentScaleFactor.asFloat
        let inverseViewSize: SIMD2<Float> = .init(1.0 / viewportSize.x,
                                                  1.0 / viewportSize.y)
        let clipX = 2.0 * position.x * scale * inverseViewSize.x - 1.0
        let clipY = 2.0 * -position.y * scale * inverseViewSize.y + 1.0
        return .init(clipX, clipY)
    }
    
    func createRenderPass(of targetTexture: MTLTexture, loadAction: MTLLoadAction,
                          clearColor: MTLClearColor, storeAction: MTLStoreAction) -> MTLRenderPassDescriptor {
        let descriptor = MTLRenderPassDescriptor()
        
        descriptor.colorAttachments[0].texture = targetTexture;
        descriptor.colorAttachments[0].loadAction = loadAction
        descriptor.colorAttachments[0].clearColor = clearColor
        descriptor.colorAttachments[0].storeAction = storeAction
        return descriptor
    }
    
    func createOffscreenTexture() -> MTLTexture {
        let scaleFactor = metalView.contentScaleFactor
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.textureType = .type2D
        texDescriptor.width = (drawingRect.size.width * scaleFactor).asInt
        texDescriptor.height = (drawingRect.size.height * scaleFactor).asInt
        texDescriptor.pixelFormat = metalView.colorPixelFormat
        texDescriptor.usage = [.renderTarget, .shaderRead]
        
        return metalDevice.makeTexture(descriptor: texDescriptor)!
    }
    
    func createPipeline(of type: ProgramType, mode: BlendingMode, label: String = "") -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.label = label
        switch type {
        case .whiteAsAlphaProgram:
            descriptor.vertexFunction = defaultLibrary.makeFunction(name: "whiteAsAlphaVertex")
            descriptor.fragmentFunction =  defaultLibrary.makeFunction(name: "whiteAsAlphaFragment")
        default:
            descriptor.vertexFunction = defaultLibrary.makeFunction(name: "normalVertex")
            descriptor.fragmentFunction =  defaultLibrary.makeFunction(name: "normalFragment")
        }
        
        if let renderBufferAttachment = descriptor.colorAttachments[0] {
            renderBufferAttachment.pixelFormat = .bgra8Unorm
            
            renderBufferAttachment.isBlendingEnabled = true
            switch mode {
            case .none:
                renderBufferAttachment.isBlendingEnabled = false
            case .add:
                renderBufferAttachment.alphaBlendOperation = .add
                renderBufferAttachment.rgbBlendOperation = .add
            case .max:
                renderBufferAttachment.alphaBlendOperation = .max
                renderBufferAttachment.rgbBlendOperation = .max
            }
            renderBufferAttachment.sourceAlphaBlendFactor = .sourceAlpha
            renderBufferAttachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
            renderBufferAttachment.sourceRGBBlendFactor = .sourceAlpha
            renderBufferAttachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        }
        
        return try! metalDevice.makeRenderPipelineState(descriptor: descriptor)
    }
    
    func loadTexture(from name: String) -> MTLTexture? {
        if let penTexture = penTextures[name] {
            return penTexture
        }
        let loader = MTKTextureLoader(device: metalDevice)
        guard let url = Bundle.main.url(forResource: name, withExtension: "png") else {
            return nil
        }
        let texture = try? loader.newTexture(URL: url, options: [
            MTKTextureLoader.Option.origin: MTKTextureLoader.Origin.bottomLeft,
            MTKTextureLoader.Option.SRGB: false
        ])
        penTextures[name] = texture
        return texture
    }
    
    func loadPenTexture() -> MTLTexture? {
        let name: String
        let curveWidth = lineWidth
        if curveWidth > 24.0 {
            name = "FreeDrawPenGray_32"
        } else if curveWidth > 12.0 {
            name = "FreeDrawPenGray_16"
        } else if curveWidth > 6.0 {
            name = "FreeDrawPenGray-2_32"
        } else {
            name = "FreeDrawPenGray-2_16"
        }
        
        return loadTexture(from: name)
    }
}

//MARK: Rendering
private extension FreeDrawViewRenderer {
    func renderOffscreen(with commandBuffer: MTLCommandBuffer) {
        let triangleVertices = buildTriangleVertices()
        guard !triangleVertices.isEmpty else { return }
        
        guard let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(descriptor: curveTextureRenderPass) else { return }
        renderEncoder.label = "Offscreen Render Encoder";
        renderEncoder.setRenderPipelineState(curveRenderPipeline)
        
        renderEncoder.setFragmentTexture(penTexture, index: FreeDrawTextureInputIndexColor.rawValue.asInt)
        
        let triangleVertexBuffer = metalDevice.makeBuffer(bytes: triangleVertices,
                                                          length: triangleVertices.size(),
                                                          options: .storageModeShared)
        renderEncoder.setVertexBuffer(triangleVertexBuffer, offset: 0,
                                      index: FreeDrawVertexInputIndexVertices.rawValue.asInt)
        var color = drawingColor
        renderEncoder.setVertexBytes(&color, length: MemoryLayout.size(ofValue: drawingColor),
                                     index: FreeDrawVertexInputIndexDrawColor.rawValue.asInt)
        // Draw polygon (a set of triangles) with pen texture.
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0,
                                     vertexCount: triangleVertices.count)
        
        renderEncoder.endEncoding()
    }
    
    func renderOffscreenToFinished(with commandBuffer: MTLCommandBuffer) {
        guard let renderEncoder = 
                commandBuffer.makeRenderCommandEncoder(descriptor: offscreenToFinishedRenderPass) else { return }
        renderEncoder.label = "Offscreen to Finished Encoder";
        renderEncoder.setRenderPipelineState(curveToFinishedRenderPipeline)
        
        // Set the curveTexture as the source texture.
        renderEncoder.setFragmentTexture(curveTexture, index: FreeDrawTextureInputIndexColor.rawValue.asInt)
        
        renderEncoder.setVertexBuffer(quadVertexBuffer, offset: 0,
                                      index: FreeDrawVertexInputIndexVertices.rawValue.asInt)
        var color = drawingColor
        renderEncoder.setVertexBytes(&color, length: MemoryLayout.size(ofValue: drawingColor),
                                     index: FreeDrawVertexInputIndexDrawColor.rawValue.asInt)
        
        // Draw quad with rendered texture.
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        
        renderEncoder.endEncoding()
    }
    
    // Render drawn objects (aka background) to Onscreen before drawing any new objects
    func renderFinishedToOnscreen(with commandBuffer: MTLCommandBuffer, in view: MTKView) {
        guard let onscreenRenderPassDescriptor = view.currentRenderPassDescriptor else { return }
        guard let renderEncoder = 
                commandBuffer.makeRenderCommandEncoder(descriptor: onscreenRenderPassDescriptor) else { return }
        renderEncoder.label = "Finished to Onscreen Encoder";
        renderEncoder.setRenderPipelineState(finishedToOnscreenRenderPipeline)
        
        // Set the finishedTexture as the source texture.
        renderEncoder.setFragmentTexture(finishedTexture, index: FreeDrawTextureInputIndexColor.rawValue.asInt)
        
        renderEncoder.setVertexBuffer(quadVertexBuffer, offset: 0,
                                      index: FreeDrawVertexInputIndexVertices.rawValue.asInt)
        
        var color = drawingColor
        renderEncoder.setVertexBytes(&color, length: MemoryLayout.size(ofValue: drawingColor),
                                     index: FreeDrawVertexInputIndexDrawColor.rawValue.asInt)
        
        // Draw quad with rendered texture.
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        
        renderEncoder.endEncoding()
    }
    
    func renderFinishedToLiveAction(with commandBuffer: MTLCommandBuffer) {
        guard let renderEncoder = 
                commandBuffer.makeRenderCommandEncoder(descriptor: liveActionRenderPass) else { return }
        renderEncoder.label = "Finished to LiveAction encoder";
        renderEncoder.setRenderPipelineState(liveActionBackgroundPipeline)
        
        renderEncoder.setFragmentTexture(finishedTexture, index: FreeDrawTextureInputIndexColor.rawValue.asInt)
        
        renderEncoder.setVertexBuffer(quadVertexBuffer, offset: 0,
                                      index: FreeDrawVertexInputIndexVertices.rawValue.asInt)
        var color = drawingColor
        renderEncoder.setVertexBytes(&color, length: MemoryLayout.size(ofValue: drawingColor),
                                     index: FreeDrawVertexInputIndexDrawColor.rawValue.asInt)
        
        // Draw quad with rendered texture.
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        
        renderEncoder.endEncoding()
    }
    
    func renderOffscreenToLiveAction(with commandBuffer: MTLCommandBuffer) {
        guard let renderEncoder = 
                commandBuffer.makeRenderCommandEncoder(descriptor: liveActionRenderPass) else { return }
        renderEncoder.label = "Offscreen to LiveAction encoder";
        renderEncoder.setRenderPipelineState(liveActionPipeline)
        
        renderEncoder.setFragmentTexture(curveTexture, index: FreeDrawTextureInputIndexColor.rawValue.asInt)
        
        renderEncoder.setVertexBuffer(quadVertexBuffer, offset: 0,
                                      index: FreeDrawVertexInputIndexVertices.rawValue.asInt)
        var color = drawingColor
        renderEncoder.setVertexBytes(&color, length: MemoryLayout.size(ofValue: drawingColor),
                                     index: FreeDrawVertexInputIndexDrawColor.rawValue.asInt)
        
        // Draw quad with rendered texture.
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        
        renderEncoder.endEncoding()
    }
    
    func renderLiveActionToOnscreen(with commandBuffer: MTLCommandBuffer, in view: MTKView) {
        guard let onscreenRenderPassDescriptor = view.currentRenderPassDescriptor,
                let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(descriptor: onscreenRenderPassDescriptor) else { return }
        renderEncoder.label = "LiveAction to Onscreen Render Encoder";
        renderEncoder.setRenderPipelineState(liveActionBackgroundPipeline)
        
        // Set the liveActionTexture as the source texture.
        renderEncoder.setFragmentTexture(liveActionTexture, index: FreeDrawTextureInputIndexColor.rawValue.asInt)
        
        renderEncoder.setVertexBuffer(quadVertexBuffer, offset: 0,
                                      index: FreeDrawVertexInputIndexVertices.rawValue.asInt)
        var color = drawingColor
        renderEncoder.setVertexBytes(&color, length: MemoryLayout.size(ofValue: drawingColor),
                                     index: FreeDrawVertexInputIndexDrawColor.rawValue.asInt)
        
        // Draw quad with rendered texture.
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        
        renderEncoder.endEncoding()
    }
    
    func clear(texture: MTLTexture, with clearColor: MTLClearColor, by commandBuffer: MTLCommandBuffer) {
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = texture
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].clearColor = clearColor
        descriptor.colorAttachments[0].storeAction = .store
        let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        renderCommandEncoder?.endEncoding()
    }
}
