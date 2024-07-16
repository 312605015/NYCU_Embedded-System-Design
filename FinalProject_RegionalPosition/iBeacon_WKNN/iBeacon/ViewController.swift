import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var monitorResultTextView: UITextView!
    @IBOutlet weak var rangingResultTextView: UITextView!
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    let uuid = "A3E1C063-9235-4B25-AA84-D249950AADC4"
    let identifier = "esd region"
    
    let beaconCoordinates = [
        1: (x: 2.21, y: 0.0),
        2: (x: 4.3, y: 5.7),
        3: (x: 4.3, y: 7.8),
        4: (x: 2.64, y: 11.75)
    ]
    
    let areaDivisions = [
        "A": (minY: 6.5, maxY: 11.75),
        "B": (minY: 3.5, maxY: 6.5),
        "C": (minY: 0.0, maxY: 3.5)
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
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        monitorResultTextView.text = "Exited \(region.identifier)\n" + monitorResultTextView.text
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            monitorResultTextView.text = "Inside \(region.identifier)\n" + monitorResultTextView.text
            manager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: UUID(uuidString: uuid)!))
        case .outside:
            monitorResultTextView.text = "Outside \(region.identifier)\n" + monitorResultTextView.text
            manager.stopMonitoring(for: region)
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        // 過濾出 major 為 1 的 beacons 且 RSSI 不為 0（表示有信號）
        let filteredBeacons = beacons.filter { $0.major.intValue == 1 && $0.rssi != 0 }
        guard filteredBeacons.count >= 1 else {
            rangingResultTextView.text = "No major 1 beacons detected\n" + rangingResultTextView.text
            return
        }
        
        // 找出信號最強的 beacon
        guard let closestBeacon = filteredBeacons.max(by: { $0.rssi < $1.rssi }) else {
            rangingResultTextView.text = "No major 1 beacons detected\n" + rangingResultTextView.text
            return
        }
        
        // 计算每个 iBeacon 的距离
        var beaconDistances = [(beaconId: Int, distance: Double)]()
        for beacon in filteredBeacons {
            let beaconId = beacon.minor.intValue
            let distance = approximateDistance(proximity: beacon.proximity)
            beaconDistances.append((beaconId: beaconId, distance: distance))
        }
        
        // 按距离排序，选择最近的K个
        let k = min(3, beaconDistances.count) // 这里选择最近的3个，如果少于3个就选全部
        let nearestBeacons = beaconDistances.sorted(by: { $0.distance < $1.distance }).prefix(k)
        
        // 計算权重并估算位置
        var weightedX = 0.0
        var weightedY = 0.0
        var totalWeight = 0.0
        
        for beacon in nearestBeacons {
            let weight = 1.0 / beacon.distance
            if let beaconCoord = beaconCoordinates[beacon.beaconId] {
                weightedX += beaconCoord.x * weight
                weightedY += beaconCoord.y * weight
                totalWeight += weight
            }
        }

        let estimatedX = weightedX / totalWeight
        let estimatedY = weightedY / totalWeight
        
        // 根据估算的Y坐标确定区域
        let area = determineArea(yPosition: estimatedY)
        
        //用最強訊號
        let beaconId = closestBeacon.minor.intValue
        let distance = approximateDistance(proximity: closestBeacon.proximity)
        let beaconPosition = beaconCoordinates[beaconId]!
        //let estimatedY = beaconPosition.y - distance
        //let area = determineArea(yPosition: estimatedY)
        
        // 確定用戶所在的區域，如果無法確定，則使用信號最強的 beacon 來推測可能的區域
        if area == "Unknown" {
            let fallbackArea = determineFallbackArea(by: filteredBeacons)
            rangingResultTextView.text = "Fallback area: \(fallbackArea)\n" + rangingResultTextView.text
        } else {
            rangingResultTextView.text = "You are in area \(area)\n" + rangingResultTextView.text
        }
        
        // 显示预测的坐标
                rangingResultTextView.text = "Estimated coordinates: (\(estimatedX), \(estimatedY))\n" + rangingResultTextView.text
    }
    
    func approximateDistance(proximity: CLProximity) -> Double {
        switch proximity {
        case .immediate:
            return 0.5
        case .near:
            return 2.5
        case .far:
            return 5.0
        default:
            return 10.0  // Default for unknown proximity
        }
    }
    
    
    // 確定用戶所在的區域(根據y座標）
    func determineArea(yPosition: Double) -> String {
        for (area, range) in areaDivisions {
            if range.minY <= yPosition && yPosition <= range.maxY {
                return area
            }
        }
        return "Unknown"
    }
    
    //主定位方法失敗時，透過訊號最強的信標來推測使用者所在的區域
    func determineFallbackArea(by beacons: [CLBeacon]) -> String {
        if let strongestBeacon = beacons.max(by: { $0.rssi < $1.rssi }) {
            let beaconId = strongestBeacon.minor.intValue
            switch beaconId {
            case 1:
                return "C"
            case 2:
                return "B"
            case 3, 4:
                return "A"
            default:
                return "Unknown"
            }
        }
        return "No beacons available"
    }
}
