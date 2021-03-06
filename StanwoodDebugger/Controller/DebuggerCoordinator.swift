//
//  DebuggerCoordinator.swift
//
//  The MIT License (MIT)
//
//  Copyright (c) 2018 Stanwood GmbH (www.stanwood.io)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

class DebuggerCoordinator {
    
    private let window: UIWindow
    private let actionable: DebuggerActions
    private let paramaterable: DebuggerParamaters
    
    // need a better solution for it
    func currentViewController(base: UIViewController?) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return currentViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        
        return base
    }
    
    enum ActionSheet: String {
        case analytics, allData, settings
        
        var value: String {
            switch self {
            case .allData:
                return "all"
            case .settings, .analytics:
                return rawValue
            }
        }
        
        var title: String {
            switch self {
            case .allData, .analytics:
                return "Would you like to remove \(value) data?"
            case .settings:
                return "Reset to default settings?"
            }
        }
    }
    
    init(window: UIWindow, actionable: DebuggerActions, paramaterable: DebuggerParamaters) {
        self.window = window
        self.actionable = actionable
        self.paramaterable = paramaterable
    }
    
    func presentListView(with filter: DebuggerFilterView.DebuggerFilter, completion: @escaping Completion) {
        
        let title = "Debugger"
        
        // Detail Nav Controller
        let detailControllers = ListWireframe.makeViewController(withTitle: title)
        ListWireframe.prepare(detailControllers.viewController, with: actionable, paramaterable, filter: filter)
        
        // Settings Nav Controller
        let settingsControllers = SettingsWireframe.makeViewController(withTitle: title)
        SettingsWireframe.prepare(settingsControllers.viewController, with: actionable, paramaterable)
        
        let tabBarController = DebuggerUITabBarController()
        tabBarController.setViewControllers([
            detailControllers.navigationController,
            settingsControllers.navigationController], animated: false)
        
        window.rootViewController?.present(tabBarController, animated: false, completion: completion)
    }
    
    func shouldReset(_ type: ActionSheet, _ completion: @escaping () -> Void) {
        
        let completion: (UIAlertAction) -> Void = { _ in
            completion()
        }
        
        let items: [String: Bool] = [
            "Yes" : true,
            "No" : false
        ]
        
        presentAction(withTitle: type.title, completionItem: items, completion)
    }
    
    private func presentAction(withTitle title: String, completionItem: [String: Bool], _ actionCompletion: @escaping (UIAlertAction) -> Void) {
        
        let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        completionItem.forEach({
            let action = UIAlertAction(title: $0.key, style: $0.value ? .default : .cancel, handler: $0.value ? actionCompletion : nil)
            actionSheet.addAction(action)
        })
        
        currentViewController(base: window.rootViewController)?.present(actionSheet, animated: true, completion: nil)
    }
}
