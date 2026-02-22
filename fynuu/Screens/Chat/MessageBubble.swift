//
//  MessageBubble.swift
//  fynuu
//
//  Created by Keetha Nikhil on 22/02/26.
//

import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    private var isUser: Bool { message.role == "user" }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 52) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content ?? "")
                    .font(.system(size: 15))
                    .foregroundColor(isUser ? .black : .white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isUser
                        ? LinearGradient(colors: [.green, .blue],
                                         startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color(white: 0.13), Color(white: 0.13)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )

                // Route badge for assistant only
                if !isUser, let route = message.routeUsed {
                    HStack(spacing: 4) {
                        Image(systemName: route == "cloud" ? "cloud" : "cpu")
                            .font(.system(size: 9))
                        Text(route == "cloud" ? "Groq Cloud" : "On-Device")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(route == "cloud" ? .blue : .green)
                    .padding(.horizontal, 2)
                }
            }

            if !isUser { Spacer(minLength: 52) }
        }
        .contextMenu {
            Button {
                UIPasteboard.general.string = message.content
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
        }
    }
}
