//
//  DashboardCard.swift
//  orthoreco
//
//  Created by Ayub Shrestha on 18/03/2026.
//

import SwiftUI

struct DashboardCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content){
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12){
            Text(title)
                .font(.headline)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}


#Preview {
    DashboardCard(title: "Sample Card"){
        Text("Hello Card")
    }
    .padding()
}
