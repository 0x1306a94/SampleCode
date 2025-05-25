import SwiftUI

struct ContentView: View {
    let items = [
        ("IMG_1902", "Next Level - Single"),
        ("IMG_1902", "Supernova - Single"),
        ("IMG_1902", "Drama - The 4th Mini Album"),
        ("IMG_1902", "Whiplash - The 5th Mini Album - EP"),
        ("IMG_1902", "Good Day 2025 (Telepathy By the Moonlight Window) - Single")
    ]

    var body: some View {
        VStack(alignment: .center) {
            GeometryReader { geometry in
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack {
                        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                            ItemView(
                                index: index,
                                coverName: item.0,
                                title: item.1,
                                parentGeometry: geometry
                            )
                            .frame(height: geometry.size.width)
                            .offset(y: -geometry.size.width * 0.5)
                            .offset(y: CGFloat(index) * 80)
                            .compositingGroup()
                        }
                    }
                }
            }
            .frame(width: 323)
        }
        .padding(20)
    }
}

struct ItemView: View {
    let index: Int
    let coverName: String
    let title: String
    let parentGeometry: GeometryProxy

    var body: some View {
        GeometryReader { geometry in

            let itemWidth = geometry.size.width
            let itemHeight = geometry.size.height
            let titleHeight = 16.0
            let coverHeight = (itemHeight - titleHeight) * 0.5

            let offset = geometry.frame(in: .global).midY - parentGeometry.size.height / 2
            let isAboveCenter = offset < 0
            let titleOffset = (itemHeight - titleHeight) * 0.5

            let coverOffset = ((itemHeight - coverHeight) * 0.5 + coverHeight * 0.5 + titleHeight * 0.5)

            let progress = min(max(offset / (parentGeometry.size.height / 2), -1), 1)

//            let degrees = 30.0 * (1 - abs(progress))

            let degrees = 40.0

            let _ = print(index, isAboveCenter)

            /*
             * 从Lookin中分析来看，大致实现如下
             * 1. title 始终和cell中心对齐
             * 2. cell 在 ScollView 中心以上时 cover 顶部对齐到 title 底部。
             * 2.1 cover 以顶部往前倒  title 以底部往后倒
             * 3. cell 在 ScollView 中心以下时 cover 底部对齐到 title 顶部。
             * 3.1 cover 以底部往后倒  title 以顶部往前倒
             *
             */

            ZStack(alignment: .top) {
                // cover
                Color.clear
                    .overlay(alignment: .top, content: {
                        ZStack(alignment: .topLeading) {
                            Color.red

                            Image(coverName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: itemWidth, height: itemHeight)
                                .rotationEffect(.degrees(90))
                        }
                    })
                    .frame(width: itemWidth, height: coverHeight)
                    .frame(maxHeight: coverHeight)
                    .rotation3DEffect(
                        .degrees(-degrees),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .top
                    )
                    .offset(y: coverOffset)

                // title
                Color.purple
                    .overlay(alignment: .center, content: {
                        Text(title)
                            .font(.caption)
                            .foregroundColor(.white)
                            .frame(maxWidth: itemWidth * 0.8)
                    })
                    .frame(width: itemWidth, height: titleHeight)
                    .frame(maxHeight: titleHeight)
                    .rotation3DEffect(
                        .degrees(degrees),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .bottom
                    )
                    .offset(y: titleOffset)
            }
            .frame(width: itemWidth, height: itemHeight)
        }
    }
}

#Preview {
    ContentView()
}
