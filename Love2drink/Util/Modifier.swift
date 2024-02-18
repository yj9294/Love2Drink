//
//  Modifier.swift
//  Love2drink
//
//  Created by Super on 2024/2/6.
//

import Foundation
import SwiftUI

struct BackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(Image("bg").resizable().ignoresSafeArea())
    }
}

extension View {
    var background: some View {
        self.modifier(BackgroundModifier())
    }
}
