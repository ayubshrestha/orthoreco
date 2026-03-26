//
//  ToastView.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 19/03/2026.
//

import SwiftUI

struct ToastView: View {
    let message: String
    let backgorundColor: Color
    
    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(backgorundColor)
            .cornerRadius(12)
            .shadow(radius: 4)
            .padding(.top,8)
    }
}
