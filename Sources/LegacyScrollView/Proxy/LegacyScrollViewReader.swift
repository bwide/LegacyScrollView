//
//  File.swift
//  
//
//  Created by Bruno Wide on 03/03/22.
//

import Foundation
import SwiftUI

/// a UIScrollView Wrapper for SwiftUI
public struct LegacyScrollViewReader<Content: View>: UIViewRepresentable {

    var content: (LegacyScrollViewProxy) -> Content

    public init(@ViewBuilder content: @escaping (LegacyScrollViewProxy) -> Content) {
        self.content = content
    }

    public func makeUIView(context: Context) -> LegacyUIScrollViewReader {
        LegacyUIScrollViewReader()
    }

    public func updateUIView(_ view: LegacyUIScrollViewReader, context: Context) {
        guard let _ = view.scrollView else {
            //Warning: updateUIView called before view was added to view hierarchy
            return
        }
        let proxy = makeProxy(with: view)
        let contentView = content(proxy)

        guard let hosting = view.contentViewController as? UIHostingController<Content> else {
            view.contentViewController = UIHostingController(rootView: contentView)
            return
        }

        hosting.rootView = contentView
        view.updateView()
    }
}

struct LegacyScrollViewReader_Previews: PreviewProvider {
    static var previews: some View {
        LegacyScrollViewReader { proxy in
            LegacyScrollView(.vertical, showsIndicators: true) {
                VStack {
                    ForEach(0..<500) {
                        Text("item \($0)")
                            .legacyId($0)
                    }
                }
            }
            .onAppear {
                proxy.scrollToIdIfNeeded(300)
            }
        }
    }
}
