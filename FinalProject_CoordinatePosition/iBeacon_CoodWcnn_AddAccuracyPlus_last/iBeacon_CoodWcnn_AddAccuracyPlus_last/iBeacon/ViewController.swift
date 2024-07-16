///有ibeacons時y軸很準，只要走到中間一側沒有ibeacon後就會y軸不準 x沒什麼大問題 y軸最後面可以到3.8多

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var monitorResultTextView: UITextView!
    @IBOutlet weak var rangingResultTextView: UITextView!
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    let uuid = "A3E1C063-9235-4B25-AA84-D249950AADC4"
    let identifier = "esd region"
    
    let beaconCoordinates = [
        1: (x: 0.0, y: 0.0),
        2: (x: 2.6, y: 2.67),
        3: (x: 5.71, y: 2.67),
        4: (x: 9.7, y: 2.67),
        5: (x: 13.5, y: 2.67),
        6: (x: 15.1, y: 0.0),
        7: (x: 17.5, y: 0.0),
        8: (x: 16.9, y: 3.9)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            if CLLocationManager.authorizationStatus() != .authorizedAlways {
                locationManager.requestAlwaysAuthorization()
            }
        }
        
        let region = CLBeaconRegion(uuid: UUID(uuidString: uuid)!, identifier: identifier)
        locationManager.delegate = self
        region.notifyEntryStateOnDisplay = true
        region.notifyOnEntry = true
        region.notifyOnExit = true
        locationManager.startMonitoring(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        monitorResultTextView.text = "Started monitoring \(region.identifier)\n" + monitorResultTextView.text
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        monitorResultTextView.text = "Entered \(region.identifier)\n" + monitorResultTextView.text
        manager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: UUID(uuidString: uuid)!))
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        monitorResultTextView.text = "Exited \(region.identifier)\n" + monitorResultTextView.text
        manager.stopRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: UUID(uuidString: uuid)!))
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            monitorResultTextView.text = "Inside \(region.identifier)\n" + monitorResultTextView.text
            manager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: UUID(uuidString: uuid)!))
        case .outside:
            monitorResultTextView.text = "Outside \(region.identifier)\n" + monitorResultTextView.text
            manager.stopRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: UUID(uuidString: uuid)!))
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        // 過濾出 major 為 2 的 beacons 並且 RSSI 不為 0（表示有訊號）
        let filteredBeacons = beacons.filter { $0.major.intValue == 2 && $0.rssi != 0 }
        guard filteredBeacons.count >= 1 else {
            rangingResultTextView.text = "No major 2 beacons detected\n" + rangingResultTextView.text
            return
        }
        
        // 計算每個 iBeacon 的距離
        var beaconDistances = [(beaconId: Int, distance: Double)]()
        for beacon in filteredBeacons {
            let beaconId = beacon.minor.intValue
            let distance = calculateAccuracy(txPower: -59, rssi: beacon.rssi)
            beaconDistances.append((beaconId: beaconId, distance: distance))
        }
        
        // 按距離排序，選擇最近的K個
        let k = min(4, beaconDistances.count) // 這裡選擇最近的4個，如果少於4個就選全部
        let nearestBeacons = beaconDistances.sorted(by: { $0.distance < $1.distance }).prefix(k)
        
        // 計算權重並估計位置
        var weightedX = 0.0
        var weightedY = 0.0
        var totalWeight = 0.0
        
        for beacon in nearestBeacons {
            let weight = 1.0 / (beacon.distance * beacon.distance) // 使用平方反比作為權重
            if let beaconCoord = beaconCoordinates[beacon.beaconId] {
                weightedX += beaconCoord.x * weight
                weightedY += beaconCoord.y * weight
                totalWeight += weight
            }
        }

        let estimatedX = weightedX / totalWeight
        let estimatedY = weightedY / totalWeight
        
        // 直接打印座標
        rangingResultTextView.text = "Estimated coordinates: (\(estimatedX), \(estimatedY))\n" + rangingResultTextView.text
        print("Estimated coordinates: (\(estimatedX), \(estimatedY))")
    }
    
    func calculateAccuracy(txPower: Int, rssi: Int) -> Double {
        if rssi == 0 {
            return -1.0 // if we cannot determine accuracy, return -1.
        }
        
        let ratio = Double(rssi) / Double(txPower)
        if ratio < 1.0 {
            return pow(ratio, 10)
        } else {
            return (0.89976 * pow(ratio, 7.7095)) + 0.111
        }
    }
}

