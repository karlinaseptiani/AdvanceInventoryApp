//
//  HideTabBar.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 23/12/24.
//


import SwiftUI

extension View {
    
    func showTabBar() -> some View {
//        if #available(iOS 16.0, *) {
//            return toolbar(.visible, for: .tabBar)
//        } else {
            return modifier(ShowTabBar())
//        }
    }
    
    func hideTabBar() -> some View {
//        if #available(iOS 16.0, *) {
//            return toolbar(.hidden, for: .tabBar)
//        } else {
            return modifier(HideTabBar())
//        }
    }
}

private struct HideTabBar: ViewModifier {
    
    func body(content: Content) -> some View {
        return content.padding(.zero).onAppear {
            TabBarModifier.hideTabBar()
        }
    }
}

private struct ShowTabBar: ViewModifier {
    
    func body(content: Content) -> some View {
        return content.padding(.zero).onAppear {
            TabBarModifier.showTabBar()
        }
    }
}

private struct TabBarModifier {
    
    static func showTabBar() {
        guard let keyWindow = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({ $0.windows }).first(where: { $0.isKeyWindow }) else {
                return
        }

        keyWindow.allSubviews().forEach { subView in
            if let tabBar = subView as? UITabBar {
                tabBar.isHidden = false
            }
        }
    }
    
    static func hideTabBar() {
        guard let keyWindow = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({ $0.windows }).first(where: { $0.isKeyWindow }) else {
                return
        }

        keyWindow.allSubviews().forEach { subView in
            if let tabBar = subView as? UITabBar {
                tabBar.isHidden = true
            }
        }
    }
}

private extension UIView {
    
    func allSubviews() -> [UIView] {
        var subviews = [UIView]()
        subviews.append(contentsOf: self.subviews)
        subviews.forEach { subview in
            subviews.append(contentsOf: subview.allSubviews())
        }
        return subviews
    }
}