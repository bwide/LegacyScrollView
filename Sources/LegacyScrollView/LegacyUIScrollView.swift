//
//  LegacyUIScrollView.swift
//  
//
//  Created by Bruno Wide on 17/02/22.
//

import Foundation
import UIKit
import SwiftUI

public class LegacyUIScrollView: UIScrollView {

    let axis: Axis

    init(axis: Axis) {
        self.axis = axis
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    var onGestureShouldBegin: ((_ gestureRecognizer: UIPanGestureRecognizer, _ scrollView: UIScrollView) -> Bool)?

    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return super.gestureRecognizerShouldBegin(gestureRecognizer)}
        
        return onGestureShouldBegin?(panGesture, self) ?? super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    // MARK: - SwiftUI updates

    var contentViewController: UIViewController! {
        didSet { attach() }
    }

    var contentView: UIView { contentViewController.view }

    private func attach() {
        guard
            let contentViewController = contentViewController,
                contentViewController.parent == nil
        else {
            return
        }

        addSubview(contentView)
        contentView.sizeToFit()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(contentConstraints)
    }

    private lazy var contentConstraints: [NSLayoutConstraint] = {
        let sizeConstraint = axis == .vertical
            ? contentView.widthAnchor.constraint(equalTo: widthAnchor)
            : contentView.heightAnchor.constraint(equalTo: heightAnchor)

        return [
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            sizeConstraint
        ]
    }()

    func updateView() {
        contentView.removeFromSuperview()
        addSubview(contentView)
        contentSize = contentView.sizeThatFits(.greatest)
    }
}

private extension CGSize {
    static var greatest = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
}
