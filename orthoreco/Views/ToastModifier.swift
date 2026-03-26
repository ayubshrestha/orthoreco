//
//  ToastModifier.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let backgroundColor: Color
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                if isShowing {
                    ToastView(message: message, backgorundColor: backgroundColor)
                        .transition(.move(edge: .top).combined(with: .opacity))
                                                .padding(.top, 10)
                }
                Spacer()
            }
            .padding()
        }
        .animation(.easeInOut, value: isShowing)
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String, backgroundColor: Color = .green) -> some View {
        modifier(ToastModifier(isShowing: isShowing, message: message, backgroundColor: backgroundColor))
    }
}
