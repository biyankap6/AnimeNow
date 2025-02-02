//
//  ChipView.swift
//  Anime Now! (iOS)
//
//  Created by ErrorErrorError on 9/27/22.
//

import SwiftUI

public struct ChipView<Label: View>: View {
    let text: String
    var image: (() -> Label)?

    public init(
        text: String,
        image: (() -> Label)? = nil
    ) {
        self.text = text
        self.image = image
    }

    public var body: some View {
        HStack(
            alignment: .center,
            spacing: 4
        ) {
            image?()
            Text(text)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.25))
        .clipShape(Capsule())
    }
}

struct ChipView_Previews: PreviewProvider {
    static var previews: some View {
        ChipView(
            text: "2021",
            image: { Image(systemName: "star.fill") }
        )
        .preferredColorScheme(.dark)
    }
}

extension ChipView where Label == EmptyView {
    public init(text: String) {
        self.init(text: text, image: nil)
    }
}
