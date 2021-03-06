//
//  DebuggerData.swift
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
import StanwoodCore

struct AddedItem {
    let type: DebuggerFilterView.DebuggerFilter
    let count: Int
}

class DebuggerData {
    
    var analyticsItems: AnalyticItems
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
    
    init() {
        if let items = try? Stanwood.Storage.retrieve(AnalyticItems.fileName, of: .json, from: .documents, as: AnalyticItems.self) {
            analyticsItems = items ?? AnalyticItems(items: [])
        } else {
            analyticsItems = AnalyticItems(items: [])
        }
        
        NotificationCenter.default.addObservers(self, observers:
            Stanwood.Observer(selector: #selector(didReceiveAnalyticsItem(_:)), name: .DebuggerDidReceiveAnalyticsItem),
                                                Stanwood.Observer(selector: #selector(didReceiveLogItem(_:)), name: .DeuggerDidReceiveLogItem),
                                                Stanwood.Observer(selector: #selector(save), name: UIApplication.willTerminateNotification),
                                                Stanwood.Observer(selector: #selector(didReceiveErrorItem(_:)), name: .DeuggerDidReceiveErrorItem),
                                                Stanwood.Observer(selector: #selector(didReceiveUITestingItem(_:)), name: .DeuggerDidReceiveUITestingItem),
                                                Stanwood.Observer(selector: #selector(didReceiveNetworkingItem(_:)), name: .DeuggerDidReceiveNetworkingItem)
        )
    }
    
    func removeAll() {
        /// Remove all stored items
        analyticsItems.removeAll()
    }
    
    func refresh(withDelay delay: DispatchTimeInterval = .milliseconds(500)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let addedIems: [AddedItem] = [AddedItem(type: .analytics, count: self.analyticsItems.numberOfItems)]
            NotificationCenter.default.post(name: NSNotification.Name.DeuggerDidAddDebuggerItem, object: addedIems)
        }
    }
    
    @objc func didReceiveAnalyticsItem(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo,
            let data = try? JSONSerialization.data(withJSONObject: userInfo, options: []),
            let item = try? decoder.decode(AnalyticsItem.self, from: data)  else { return }
        
        
        analyticsItems.append(item)
        
        analyticsItems.items.sort(by: { ($0.createdAt ?? Date()) < ($1.createdAt ?? Date()) })
        
        let addedIems: [AddedItem] = [AddedItem(type: .analytics, count: analyticsItems.numberOfItems)]
        
        NotificationCenter.default.post(name: NSNotification.Name.DebuggerDidAppendAnalyticsItem, object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.DeuggerDidAddDebuggerItem, object: addedIems)
    }
    
    @objc func didReceiveErrorItem(_ notification: Notification) {
        // SFW-52: Phase 3
    }
    
    @objc func didReceiveNetworkingItem(_ notification: Notification) {
        // SFW-54: Phase 5
    }
    
    @objc func didReceiveLogItem(_ notification: Notification) {
        // SFW-55: Phase 6
    }
    
    @objc func didReceiveUITestingItem(_ notification: Notification) {
        // SFW-53: Phase 4
    }
    
    @objc func save() {
        if DebuggerSettings.shouldStoreAnalyticsData {
            try? Stanwood.Storage.store(analyticsItems, to: .documents, as: .json, withName: AnalyticItems.fileName)
        }
        
        refresh()
    }
}
