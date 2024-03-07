//
//  FreeDrawView+Extensions.swift
//  opengles-brush
//
//  Created by azun on 05/03/2024.
//

import MetalKit
import GLKit
import simd

extension FreeDrawView {
    
    @objc func setupMetalView() {
        setupStaticVars()
        setupUI()
    }
}

// MARK: - MTKViewDelegate
extension FreeDrawView: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Save the size of the drawable to pass to the vertex shader.
        viewportSize.x = size.width.asFloat
        viewportSize.y = size.height.asFloat
    }
    
    public func draw(in view: MTKView) {
        guard let currentDrawable = view.currentDrawable,
                let commandBuffer = commandQueue?.makeCommandBuffer() else { return }
        
        commandBuffer.label = "Command Buffer"
        renderOffscreen(with: commandBuffer)
        renderOnscreen(with: commandBuffer, in: view)
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
}

// MARK: - Private properties
private extension FreeDrawView {
    var commandQueue: MTLCommandQueue? {
        Self._commandQueue
    }
    
    var metalDevice: MTLDevice? {
        Self._metalDevice
    }
    
    var metalView: MTKView {
        Self._metalView
    }
    
    var defaultLibrary: MTLLibrary? {
        Self._defaultLibrary
    }
    
    var viewportSize: SIMD2<Float> {
        get {
            Self._viewportSize
        }
        set {
            Self._viewportSize = newValue
        }
    }
    
    // Texture to render to
    var offscreenTexture: MTLTexture? {
        Self._offscreenTexture
    }
    
    // Pen Texture to sample from.
    var penTexture: MTLTexture? {
        loadPenTexture()
    }
    
    // Render pass descriptor to draw to the texture
    var offscreenRenderPassDescriptor: MTLRenderPassDescriptor? {
        Self._offscreenRenderPass
    }
    
    // A pipeline object to render to the offscreen texture.
    var offscreenRenderPipeline: MTLRenderPipelineState? {
        Self._offscreenRenderPipeline
    }
    
    // A pipeline object to render to onscreen.
    var onscreenRenderPipeline: MTLRenderPipelineState? {
        Self._onscreenRenderPipeline
    }
    
    var textureSamplerState: MTLSamplerState? {
        Self._textureSamplerState
    }
    
    // A buffer for the rectangle, draw offscreen to onscreen
    var quadVertexBuffer: MTLBuffer? {
        Self._quadVertexBuffer
    }
    
    var drawingColor: SIMD4<Float> {
        .init(m_drawColor[safe: 0] as? Float ?? 0,
              m_drawColor[safe: 1] as? Float ?? 0,
              m_drawColor[safe: 2] as? Float ?? 0,
              m_drawColor[safe: 3] as? Float ?? 0)
    }
    
    var defaultOffscreenColor: MTLClearColor {
        MTLClearColorMake(0.0, 0.0, 0.0, 0.0)
    }
    
    var maxSampleCount: Int {
        4
    }
}

// MARK: - Private functions
private extension FreeDrawView {
    static var _metalDevice: MTLDevice?
    static var _metalView: MTKView!
    static var _commandQueue: MTLCommandQueue?
    static var _defaultLibrary: MTLLibrary?
    static var _viewportSize: SIMD2<Float> = .zero
    
    static var _offscreenTexture: MTLTexture?
    static var _offscreenRenderPass: MTLRenderPassDescriptor?
    static var _offscreenRenderPipeline: MTLRenderPipelineState?
    
    static var _onscreenRenderPipeline: MTLRenderPipelineState?
    static var _quadVertexBuffer: MTLBuffer?
    
    static var _textureSamplerState: MTLSamplerState?
    
    static var _penTextures: [String: MTLTexture]?
    
    func setupStaticVars() {
        Self._metalDevice = MTLCreateSystemDefaultDevice()
        guard let metalDevice else { return }
        Self._metalView = MTKView(frame: .zero, device: metalDevice)
        Self._commandQueue = metalDevice.makeCommandQueue()
        Self._defaultLibrary = metalDevice.makeDefaultLibrary()
        
        Self._penTextures = [String: MTLTexture]()
        
        Self._offscreenTexture = createOffscreenTexture()
        Self._offscreenRenderPass = createOffscreenRenderPass()
        Self._offscreenRenderPipeline = createOffscreenPipelineState()
        
        Self._onscreenRenderPipeline = createOnscreenPipelineState()
        Self._quadVertexBuffer = createOnscreenVertexBuffer()
        Self._textureSamplerState = createSamplerState()
    }
    
    func setupUI() {
        metalView.delegate = self
        metalView.clearColor = defaultOffscreenColor
        metalView.backgroundColor = .clear
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.autoResizeDrawable = true
        metalView.sampleCount = maxSampleCount
        addSubview(metalView)
        NSLayoutConstraint.activate([
            metalView.leadingAnchor.constraint(equalTo: leadingAnchor),
            metalView.trailingAnchor.constraint(equalTo: trailingAnchor),
            metalView.topAnchor.constraint(equalTo: topAnchor),
            metalView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func renderOffscreen(with commandBuffer: MTLCommandBuffer) {
        let triangleVertices = buildTriangleVertices()
        guard !triangleVertices.isEmpty else { return }
        
        guard let offscreenRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: offscreenRenderPassDescriptor),
              let offscreenRenderPipeline else { return }
        renderEncoder.label = "Offscreen Render Pass";
        renderEncoder.setRenderPipelineState(offscreenRenderPipeline)
        
        // Set the penTexture as the source texture.
        renderEncoder.setFragmentTexture(penTexture, index: FreeDrawTextureInputIndexColor.rawValue.asInt)
        // Set our sampler state so we can use it to sample the texture in the frag
        renderEncoder.setFragmentSamplerState(textureSamplerState,
                                              index: FreeDrawSamplerInputIndexSampler.rawValue.asInt)
        
        let triangleVertexBuffer = metalDevice?.makeBuffer(bytes: triangleVertices,
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
    
    func renderOnscreen(with commandBuffer: MTLCommandBuffer, in view: MTKView) {
        guard let onscreenRenderPassDescriptor = view.currentRenderPassDescriptor else { return }
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: onscreenRenderPassDescriptor),
              let onscreenRenderPipeline else { return }
        renderEncoder.label = "Onscreen Render Pass";
        renderEncoder.setRenderPipelineState(onscreenRenderPipeline)
        
        // Set the offscreenTexture as the source texture.
        renderEncoder.setFragmentTexture(offscreenTexture, index: FreeDrawTextureInputIndexColor.rawValue.asInt)
        // Set our sampler state so we can use it to sample the texture in the frag
        renderEncoder.setFragmentSamplerState(textureSamplerState, 
                                              index: FreeDrawSamplerInputIndexSampler.rawValue.asInt)
        
        renderEncoder.setVertexBuffer(quadVertexBuffer, offset: 0,
                                      index: FreeDrawVertexInputIndexVertices.rawValue.asInt)

        // Draw quad with rendered texture.
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)

        renderEncoder.endEncoding()
    }
    
    func buildTriangleVertices() -> [FreeDrawTextureVertex] {
        guard vertices.count > 0 else { return [] }
        
        let triangleVerticesInViewportSpace: [FreeDrawTextureVertex] = vertices.compactMap {
            return ($0 as? VertexObj)?.asFreeDrawVertex()
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
    
    func createOffscreenTexture() -> MTLTexture? {
        let scaleFactor = metalView.contentScaleFactor
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.textureType = .type2D
        texDescriptor.width = (frame.size.width * scaleFactor).asInt
        texDescriptor.height = (frame.size.height * scaleFactor).asInt
        texDescriptor.pixelFormat = .bgra8Unorm
        texDescriptor.usage = [.renderTarget, .shaderRead]

        return metalDevice?.makeTexture(descriptor: texDescriptor)
    }
    
    func createOffscreenRenderPass() -> MTLRenderPassDescriptor {
        let descriptor = MTLRenderPassDescriptor()

        descriptor.colorAttachments[0].texture = offscreenTexture;
        descriptor.colorAttachments[0].loadAction = .load;
        descriptor.colorAttachments[0].clearColor = defaultOffscreenColor
        descriptor.colorAttachments[0].storeAction = .store
        return descriptor
    }
    
    func createOffscreenPipelineState() -> MTLRenderPipelineState? {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.label = "Offscreen Render Pipeline"
        descriptor.vertexFunction = defaultLibrary?.makeFunction(name: "whiteAsAlphaVertex")
        descriptor.fragmentFunction =  defaultLibrary?.makeFunction(name: "whiteAsAlphaFragment")
        
        if let renderBufferAttachment = descriptor.colorAttachments[0] {
            renderBufferAttachment.pixelFormat = offscreenTexture?.pixelFormat ?? .bgra8Unorm
            
            renderBufferAttachment.isBlendingEnabled = true
            renderBufferAttachment.alphaBlendOperation = .max
            renderBufferAttachment.sourceAlphaBlendFactor = .sourceAlpha
            renderBufferAttachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
            renderBufferAttachment.rgbBlendOperation = .add
            renderBufferAttachment.sourceRGBBlendFactor = .sourceAlpha
            renderBufferAttachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        }
        
        descriptor.vertexBuffers[FreeDrawVertexInputIndexVertices.rawValue.asInt].mutability = .immutable
        return try? metalDevice?.makeRenderPipelineState(descriptor: descriptor)
    }
    
    func createOnscreenPipelineState() -> MTLRenderPipelineState? {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.label = "Onscreen Render Pipeline"
        descriptor.vertexFunction = defaultLibrary?.makeFunction(name: "normalVertex")
        descriptor.fragmentFunction =  defaultLibrary?.makeFunction(name: "normalFragment")
        if let renderBufferAttachment = descriptor.colorAttachments[0] {
            renderBufferAttachment.pixelFormat = metalView.colorPixelFormat
            renderBufferAttachment.isBlendingEnabled = true
            
            renderBufferAttachment.alphaBlendOperation = .add
            renderBufferAttachment.sourceAlphaBlendFactor = .sourceAlpha
            renderBufferAttachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
            renderBufferAttachment.rgbBlendOperation = .add
            renderBufferAttachment.sourceRGBBlendFactor = .sourceAlpha
            renderBufferAttachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        }
        descriptor.rasterSampleCount = maxSampleCount
        
        descriptor.vertexBuffers[FreeDrawVertexInputIndexVertices.rawValue.asInt].mutability = .immutable
        return try? metalDevice?.makeRenderPipelineState(descriptor: descriptor)
    }
    
    func createSamplerState() -> MTLSamplerState? {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .clampToEdge
        samplerDescriptor.tAddressMode = .clampToEdge
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        return metalDevice?.makeSamplerState(descriptor: samplerDescriptor)
    }
    
    func createOnscreenVertexBuffer() -> MTLBuffer? {
        let quadVertices: [FreeDrawTextureVertex] =
        [
            .init(position: .init( 1.0, -1.0), texcoord: .init(1.0, 1.0)),
            .init(position: .init(-1.0, -1.0), texcoord: .init(0.0, 1.0)),
            .init(position: .init(-1.0,  1.0), texcoord: .init(0.0, 0.0)),
            
            .init(position: .init( 1.0, -1.0), texcoord: .init(1.0, 1.0)),
            .init(position: .init(-1.0,  1.0), texcoord: .init(0.0, 0.0)),
            .init(position: .init( 1.0,  1.0), texcoord: .init(1.0, 0.0))
        ]
        return metalDevice?.makeBuffer(bytes: quadVertices,
                                       length: quadVertices.size(),
                                       options: .storageModeShared)
    }
    
    func loadTexture(from name: String) -> MTLTexture? {
        if let penTexture = Self._penTextures?[name] {
            return penTexture
        }
        guard let metalDevice else { return nil }
        let loader = MTKTextureLoader(device: metalDevice)
        guard let url = Bundle.main.url(forResource: name, withExtension: "png") else {
            return nil
        }
        let texture = try? loader.newTexture(URL: url, options: [
            MTKTextureLoader.Option.origin: MTKTextureLoader.Origin.bottomLeft,
            MTKTextureLoader.Option.SRGB: false
        ])
        Self._penTextures?[name] = texture
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
