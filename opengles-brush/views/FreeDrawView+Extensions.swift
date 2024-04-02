//
//  FreeDrawView+Extensions.swift
//  opengles-brush
//
//  Created by azun on 05/03/2024.
//

extension FreeDrawView {
    @objc 
    func setupMetalView() {
        setupUI()
    }
    
    @objc
    func clearMetalDrawings() {
        renderer?.clearMetalDrawings()
    }
    
    @objc
    func wipeOutStaticVars() {
        // TODO: Need to test this out
        Self.renderers.removeValue(forKey: addressString)
    }
}

// MARK: - Private properties
private extension FreeDrawView {
    static var renderers = [String: FreeDrawViewRenderer]()
    var addressString: String {
        String(format: "%p", unsafeBitCast(self, to: Int.self))
    }
    var renderer: FreeDrawViewRenderer? {
        Self.renderers[addressString]
    }
}

// MARK: - Private functions
private extension FreeDrawView {
    func setupUI() {
        let metalRenderer = FreeDrawViewRenderer()
        Self.renderers[addressString] = metalRenderer
        guard let renderer else { return }
        renderer.targetView = self
        let metalView = renderer.metalView
        metalView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(metalView)
        NSLayoutConstraint.activate([
            metalView.leadingAnchor.constraint(equalTo: leadingAnchor),
            metalView.trailingAnchor.constraint(equalTo: trailingAnchor),
            metalView.topAnchor.constraint(equalTo: topAnchor),
            metalView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
