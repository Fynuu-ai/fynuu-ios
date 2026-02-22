//
//  StreamingBubble.swift
//  fynuu
//
//  Created by Keetha Nikhil on 22/02/26.
//
import SwiftUI

struct StreamingBubble: View {
    let text: String

    var body: some View {
        HStack(alignment: .bottom) {
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(white: 0.13))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(alignment: .bottomTrailing) {
                    // Pulsing dot to show it's still generating
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                        .padding(6)
                        .opacity(0.8)
                }

            Spacer(minLength: 52)
        }
    }
}
