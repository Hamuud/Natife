//
//  SortingExtension.swift
//  Natify_Test
//
//  Created by Артем Лясковець on 03.09.2023.
//

import SwiftUI
import Combine
import Foundation

extension ContentView.SortingOption {
    var sortingComparator: (Post, Post) -> Bool {
        switch self {
        case .likes_count:
            return { $0.likes_count > $1.likes_count }
        case .publish_date:
            return { $0.timeshamp > $1.timeshamp }
        case .default:
            return { $0.postId < $1.postId }
        }
    }
}
