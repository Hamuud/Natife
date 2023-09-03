//
//  ImageExtension.swift
//  Natify_Test
//
//  Created by Артем Лясковець on 03.09.2023.
//

import SwiftUI
import Combine
import Foundation

extension Image {
    func data(url: String) -> Image {
        if let imageUrl = URL(string: url) {
            do {
                let data = try Data(contentsOf: imageUrl)
                if let uiImage = UIImage(data: data) {
                    return Image(uiImage: uiImage)
                }
            } catch {
                print("Error loading image from URL: \(error)")
            }
        }
        return self
    }
}
