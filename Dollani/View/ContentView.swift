//
//  ContentView.swift
//  uwbtestapp
//
//  Created by DJ HAYDEN on 1/14/22.
//

import SwiftUI
import EstimoteUWB

struct ContentView: View {
    let uwb = UWBManagerExample()
    
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class UWBManagerExample {
    private var uwbManager: EstimoteUWBManager?
    
    init() {
        setupUWB()
    }
    
    private func setupUWB() {
        uwbManager = EstimoteUWBManager(positioningObserver: self, discoveryObserver: self, beaconRangingObserver: self)
        uwbManager?.startScanning()
    }
}

// REQUIRED PROTOCOL
extension UWBManagerExample: UWBPositioningObserver {
    func didUpdatePosition(for device: UWBDevice) {
        print("position updated for device: \(device)")
    }
}

// OPTIONAL PROTOCOL FOR BEACON BLE RANGING
extension UWBManagerExample: BeaconRangingObserver {
    func didRange(for beacon: BLEDevice) {
        print("beacon did range: \(beacon)")
    }
}

// OPTIONAL PROTOCOL FOR DISCOVERY AND CONNECTIVITY CONTROL
extension UWBManagerExample: UWBDiscoveryObserver {
    func didDiscover(device: EstimoteUWB.UWBIdentifable, with rssi: NSNumber, from manager: EstimoteUWB.EstimoteUWBManager) {
        print("Discovered Device: \(device.publicId)  rssi: \(rssi)")
    }
    
    var shouldConnectAutomatically: Bool {
        return true // set this to false if you want to manage when and what devices to connect to for positioning updates
    }
    
 
    
    func didConnect(to device: UWBIdentifable) {
        print("Successfully Connected to: \(device.publicId)")
    }
    
    func didDisconnect(from device: UWBIdentifable, error: Error?) {
        print("Disconnected from device: \(device.publicId)- error: \(String(describing: error))")
    }
    
    func didFailToConnect(to device: UWBIdentifable, error: Error?) {
        print("Failed to conenct to: \(device.publicId) - error: \(String(describing: error))")
    }
}

