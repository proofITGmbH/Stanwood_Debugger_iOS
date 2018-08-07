//
//  DebuggerViewController.swift
//  StanwoodDebugger
//
//  Created by Tal Zion on 10/04/2018.
//

import Foundation

protocol DebuggerViewable: class {
    var debuggerScallableView: DebuggerScallableView? { get set }
}

class DebuggerViewController: UIViewController, DebuggerViewable {
    
    private var debuggerButton: DebuggerUIButton!
    var debuggerScallableView: DebuggerScallableView?
    
    var presenter: DebuggerPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debuggerButton = DebuggerUIButton(debuggerable: presenter.debuggerable)
        debuggerButton.addTarget(self, action: #selector(didTapDebuggerButton(target:)), for: .touchUpInside)
        view.addSubview(debuggerButton)
    }

    @objc func didTapDebuggerButton(target: DebuggerUIButton) {
        presenter.debuggerable.isDisplayed = true
        if debuggerScallableView == nil {
            debuggerScallableView = DebuggerScallableView.loadFromNib(withFrame: .zero, bundle: Bundle.debuggerBundle(from: type(of: self)))
            debuggerScallableView?.button = debuggerButton
            debuggerScallableView?.delegate = self
            view.addSubview(debuggerScallableView!)
        }
        
        presenter.refresh()
        
        presenter.presentScaled(debuggerScallableView!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.debuggerable.isDisplayed = false
        debuggerButton.preparePulse()
        debuggerButton.isPulseEnabled = true
    }
    
    func shouldHandle(_ point: CGPoint) -> Bool {
        if presenter.debuggerable.isDisplayed {
            
            if let view = debuggerScallableView, !view.frame.contains(point), isViewLoaded, view.window != nil {
                debuggerScallableView?.dismiss()
                presenter.debuggerable.isDisplayed = false
            }
            
            return true
        }
        return debuggerButton.frame.contains(point)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // TODO
    }
}

extension DebuggerViewController: DebuggerScallableViewDelegate {
    
    func scallableViewIsExpanding(completion: @escaping Completion) {
        presenter.presentDetailView(with: debuggerScallableView?.currentFilter ?? .analytics, completion: completion)
    }
    
    func scallableViewDidDismiss() {
        presenter.debuggerable.isDisplayed = false
    }
}
