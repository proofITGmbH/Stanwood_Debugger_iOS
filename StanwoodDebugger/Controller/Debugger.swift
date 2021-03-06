//
//  Debugger.swift
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

protocol Debugging: class {
    var isEnabled: Bool { get set }
    var isDisplayed: Bool { get set }
}

/// StanwoodDebugger acts as the framework controller, delegating logs
public class StanwoodDebugger: Debugging {
    
    /// Debugger tintColor
    public var tintColor: UIColor {
        get { return Style.tintColor }
        set { Style.tintColor = newValue; configureStyle() }
    }
    
    struct Style {
        private init () {}
        static var tintColor: UIColor = UIColor(r: 210, g: 78, b: 79)
        static let defaultColor: UIColor = UIColor(r: 51, g: 51, b: 51)
    }
    
    /// Enable Debugger View
    public var isEnabled: Bool = false {
        didSet {
            configureDebuggerView()
        }
    }
    
    var isDisplayed: Bool = false
    
    fileprivate var debuggerViewController: DebuggerViewController?
    private let window: DebuggerWindow
    private let coordinator: DebuggerCoordinator
    private let actions: DebuggerActions
    private let appData: DebuggerData
    private let paramaters: DebuggerParamaters
    
    public init() {
        window = DebuggerWindow(frame: UIScreen.main.bounds)
        
        appData = DebuggerData()
        paramaters = DebuggerParamaters(appData: appData)
        actions = DebuggerActions(appData: appData)
        
        coordinator = DebuggerCoordinator(window: window, actionable: actions, paramaterable: paramaters)
        actions.coordinator = coordinator
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        configureStyle()
    }
    
    @objc func applicationDidEnterBackground() {
        appData.save()
    }
    
    private func configureStyle() {
        window.tintColor = Style.tintColor
    }
    
    private func configureDebuggerView() {
        
        switch isEnabled {
        case true:
            if debuggerViewController == nil {
                debuggerViewController = DebuggerWireframe.makeViewController()
                DebuggerWireframe.prepare(debuggerViewController, with: actions, paramaters, self)
            }
            window.rootViewController = debuggerViewController
            window.makeKeyAndVisible()
            window.delegate = self
        case false:
            window.rootViewController = nil
            window.resignKey()
            window.removeFromSuperview()
       }
    }
}

extension StanwoodDebugger: DebuggerWindowDelegate {
    
    func isPoint(inside point: CGPoint) -> Bool {
        return debuggerViewController?.shouldHandle(point) ?? false
    }
}
