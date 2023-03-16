//
//  ConnectionManager.swift
//  GeoTimetracker
//
//  Created by LGH on 8/5/21.
//

import Foundation
import Reachability

class ConnectionManager {

    static let sharedInstance = ConnectionManager()
    private var reachability : Reachability!

    func observeReachability(){
        try! self.reachability = Reachability()
        NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        do {
            try self.reachability.startNotifier()
        }
        catch(let error) {
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }

    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .cellular:
            print("Network available via Cellular Data.")
            isConnectedToNetwork = true
            break
        case .wifi:
            print("Network available via WiFi.")
            isConnectedToNetwork = true
            break
        case .none:
            print("Network is not available.")
            isConnectedToNetwork = false
            break
        case .unavailable:
            print("Network is unavailable.")
            isConnectedToNetwork = false
            break
        }
    }
}
