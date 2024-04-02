//
//  UIImage+Extensions.swift
//  opengles-brush
//
//  Created by azun on 2/4/24.
//

import Foundation

extension UIImage {
    static func roundedImage(with cornerRadius: CGFloat = 32, fillColor: UIColor = .white) -> UIImage? {
        let rect = CGRect(origin: .zero, size: CGSize(width: cornerRadius, height: cornerRadius))
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        fillColor.setFill()
        UIBezierPath(ovalIn: rect).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let _ = image?.cgImage
        return image
    }
}
