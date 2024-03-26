//
//  ViewController+Extensions.swift
//  opengles-brush
//
//  Created by azun on 3/26/24.
//

extension ViewController {
    
    @objc func setupButtons() {
        setupSegmentedButtons()
        setupActionButtons()
    }
}

//MARK: Private
private extension ViewController {
    func changeModeTo(_ mode: DrawingMode) {
        freeDrawView.changeMode(to: mode)
    }
    
    func setupSegmentedButtons() {
        guard let freeDrawView else { return }
        
        let control = UISegmentedControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.insertSegment(with: UIImage(named: "brush")?.withRenderingMode(.alwaysOriginal),
                              at: DrawingMode.brush.rawValue, animated: true)
        control.insertSegment(with: UIImage(named: "highlighter")?.withRenderingMode(.alwaysOriginal),
                              at: DrawingMode.highlighter.rawValue, animated: true)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentTapped(_:)), for: .valueChanged)
        
        view.addSubview(control)
        NSLayoutConstraint.activate([
            control.bottomAnchor.constraint(equalTo: freeDrawView.topAnchor),
            control.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            control.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        changeModeTo(.brush)
    }
    
    @objc func segmentTapped(_ sender: UISegmentedControl) {
        let newMode = DrawingMode(rawValue: sender.selectedSegmentIndex) ?? .brush
        changeModeTo(newMode)
    }
    
    func setupActionButtons() {
        guard let freeDrawView else { return }
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 3
        stack.alignment = .fill
        stack.distribution = .fillEqually
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: freeDrawView.bottomAnchor, constant: 3),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.heightAnchor.constraint(equalToConstant: 50)
        ])
        
//        stack.addArrangedSubview(createStackButton(of: .background))
        stack.addArrangedSubview(createStackButton(of: .clear))
        stack.addArrangedSubview(createStackButton(of: .color))
        stack.addArrangedSubview(createStackButton(of: .width))
    }
    
    func createStackButton(of type: ActionButtonType) -> UIButton {
        let button = UIButton(type: .roundedRect)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemBackground
        config.baseForegroundColor = .systemRed
        config.cornerStyle = .capsule
        config.buttonSize = .medium
        button.configuration = config
        switch type {
        case .background:
            button.setTitle("Background", for: .normal)
        case .clear:
            button.setTitle("Clear", for: .normal)
        case .color:
            button.setTitle("Color", for: .normal)
        case .width:
            button.setTitle("Width", for: .normal)
        }
        button.addAction(UIAction { [weak self] _ in
            self?.stackButtonTappedWith(type: type)
        }, for: .touchUpInside)
        return button
    }
    
    func stackButtonTappedWith(type: ActionButtonType) {
        guard let freeDrawView else { return }
        switch type {
        case .background:
            freeDrawView.changeBg()
        case .clear:
            freeDrawView.clearDrawings()
        case .color:
            freeDrawView.changeColor()
        case .width:
            freeDrawView.changeWidth()
        }
    }
    
    enum ActionButtonType {
        case background
        case color
        case width
        case clear
    }
}
