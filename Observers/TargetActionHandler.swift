//
//  TargetActionHandler.swift
//  RHAntXiongBing
//
//  Created by Sean on 2019/3/20.
//  Copyright © 2019年 Sean. All rights reserved.
//
import UIKit

@objc class TargetActionHandler : NSObject {
    private let action: () -> Void
    fileprivate var removeAction: (() -> Void)?
    
    fileprivate init(_ action: @escaping () -> Void) { self.action = action }
    
    @objc fileprivate func invoke() { action() }
    func remove() { removeAction?() }
}

extension UIGestureRecognizer {
    @discardableResult
    @objc func addHandler(_ handler: @escaping () -> Void) -> TargetActionHandler {
        let target = TargetActionHandler(handler)
        target.removeAction = { [weak self, unowned target] in self?.removeTarget(target, action: nil) }
        addTarget(target, action: #selector(TargetActionHandler.invoke))
        setAssociatedValue(target, forKey: unsafeBitCast(target, to: UnsafeRawPointer.self)) // Retain for lifetime of receiver
        return target
    }
    
    @objc convenience init(handler: @escaping () -> Void) {
        self.init()
        addHandler(handler)
    }
}

extension UIControl {
    @discardableResult
    @objc func addHandler(for events: UIControl.Event, handler: @escaping () -> Void) -> TargetActionHandler {
        let target = TargetActionHandler(handler)
        target.removeAction = { [weak self, unowned target] in self?.removeTarget(target, action: nil, for: .allEvents) }
        addTarget(target, action: #selector(TargetActionHandler.invoke), for: events)
        setAssociatedValue(target, forKey: unsafeBitCast(target, to: UnsafeRawPointer.self)) // Retain for lifetime of receiver
        return target
    }
}

extension UIButton {
    @discardableResult
    @objc func addTapHandler(_ handler: @escaping () -> Void) -> TargetActionHandler {
        return addHandler(for: .touchUpInside, handler: handler)
    }
}

extension UIBarButtonItem {
    @objc convenience init(title: String, style: UIBarButtonItem.Style, handler: @escaping () -> Void) {
        let target = TargetActionHandler(handler)
        self.init(title: title, style: style, target: target, action: #selector(TargetActionHandler.invoke))
        setAssociatedValue(target, forKey: unsafeBitCast(target, to: UnsafeRawPointer.self)) // Retain for lifetime of receiver
    }
}

extension Selector {
    /// Selectors can be used as unique `void *` keys, this gets that key.
    var key: UnsafeRawPointer { return unsafeBitCast(self, to: UnsafeRawPointer.self) }
}

extension NSObject {
    func getAssociatedValue(for key: UnsafeRawPointer) -> Any? {
        return objc_getAssociatedObject(self, key)
    }
    
    func setAssociatedValue(_ value: Any?, forKey key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
