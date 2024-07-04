//
//  File.swift
//  
//
//  Created by Bruno Wide on 26/02/22.
//

import Foundation
import SwiftUI

public struct LegacyScrollViewProxy {

    internal var getScrollView: () -> UIScrollView?
    internal var getRectOfContent: (_ id: Int) -> CGRect?
    internal var performScrollToPoint: (_ point: CGPoint, _ animated: Bool) -> Void
    internal var performScrollToId: (_ id: Int, _ anchor: UnitPoint, _ animated: Bool) -> Void
    internal var performScrollToIdIfNeeded: (_ id: Int, _ anchor: UnitPoint) -> Void

    /// Returns the UIScrollView
    public var scrollView: UIScrollView? { getScrollView() }
    /// returns the content's CGRect
    public func rectOfContent<ID: Hashable>(id: ID) -> CGRect? { getRectOfContent(id.hashValue) }
    /// performs a scroll to a specific `CGPoint`
    public func scrollTo(point: UnitPoint, animated: Bool = true) { performScrollToPoint(CGPoint(x: point.x, y: point.y), animated) }
    /// performs a scroll to an item with set `legacyID`
    public func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint = .top, animated: Bool = true) { performScrollToId(id.hashValue, anchor, animated) }
    /// performs a scroll to an item with set `legacyID` if the item is out of the visible rect
    public func scrollToIdIfNeeded<ID: Hashable>(_ id: ID, anchor: UnitPoint = .top) { performScrollToIdIfNeeded(id.hashValue, anchor) }
}

extension LegacyScrollViewReader {
    func makeProxy(with view: LegacyUIScrollViewReader) -> LegacyScrollViewProxy {
        LegacyScrollViewProxy {
            view.scrollView
        } getRectOfContent: { id in
            getRectOfContent(with: id, in: view)
        } performScrollToPoint: { point, animated in
            performScrollTo(point: point, animated: animated, in: view)
        } performScrollToId: { id, anchor, animated in
            performScrollTo(id, anchor: anchor, animated: animated, in: view)
        } performScrollToIdIfNeeded: { id, anchor in
            performScrollToIdIfNeeded(id, anchor: anchor, in: view)
        }
    }

    private func getRectOfContent(with id: Int, in view: LegacyUIScrollViewReader) -> CGRect? {
        guard
            let foundView = view.scrollView?.allSubviews.first(where: { $0.tag == id })?.superview
        else { return nil }

        return foundView.frame
    }

    private func performScrollTo(point: CGPoint, animated: Bool, in view: LegacyUIScrollViewReader) {
        view.scrollView?.setContentOffset(point, animated: animated)
    }

    public func performScrollTo(_ id: Int, anchor: UnitPoint = .top, animated: Bool, in view: LegacyUIScrollViewReader) {
        guard let contentFrame = getRectOfContent(with: id, in: view) else { return }

        view.scrollView?.setContentOffset(contentFrame.origin, animated: animated)
    }

    public func performScrollToIdIfNeeded(_ id: Int, anchor: UnitPoint = .top, in view: LegacyUIScrollViewReader) {
        guard
            let contentFrame = getRectOfContent(with: id, in: view),
            !(view.scrollView?.visibleRect ?? CGRect.null).contains(contentFrame)
        else { return }

        view.scrollView?.setContentOffset(contentFrame.origin, animated: true)
    }
}

extension UIView {
    var allSubviews: [UIView] {
        var ans: [UIView] = []

        for view in subviews {
            ans.append(view)
            ans += view.allSubviews
        }

        return ans
    }
}

public extension UIScrollView {
    var visibleRect: CGRect {
        CGRect(origin: contentOffset, size: visibleSize)
    }
}
