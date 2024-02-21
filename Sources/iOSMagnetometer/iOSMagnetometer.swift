// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import CoreMotion
import AVFoundation
import CoreLocation
import UIKit

public protocol MagnetometerLocationDelegate: AnyObject {
    func didFailWithError(error: Error)
    func getUpdatedData(magnet:Magnetometer)
}

public final class Magnetometer: NSObject, CLLocationManagerDelegate{
    // Singleton instance
    public static let shared = Magnetometer()

    public weak var locationDelegate: MagnetometerLocationDelegate?
    private let motionManager = CMMotionManager()
    private let magnetManager = CMMotionManager()
    private var player: AVAudioPlayer?
    private let locationManager = CLLocationManager()
    
    private let queue = OperationQueue()
    private let µ0 = (4*Double.pi)*1e-7
    private let thresholdDegrees: Double = 10.0 // Adjust the threshold as needed
    private var previousHeadingAngle: Double = 0.0
     
    private let currentDate = Date() // Get the current date and time
    private let calendar = Calendar.current
    
    //Getter Variables
    private var isMagnetDetect: Bool = false
    private var AllAvailableSensors: [String] = []
    private var isMagnetometerAvailable: Bool = false
    private var xValue: String = ""
    private var yValue: String = ""
    private var zValue: String = ""
    private var magneticStrengthValue: String = ""
    private var compassNorthValue: String = ""
    private var verticalAngleValue: String = ""
    private var horizontalAngleValue: String = ""
    private var addressValue: String = ""
    private var dateValue: String = ""
    private var timeValue: String = ""
    
    // Private initializer to prevent external instantiation
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // Internal function that users can call but not modify
    internal func internalFunction() {
        // Implementation
        self.MotionDetect()
        self.GetSensorsList()
    }
    
    //Internal function that detect position and MicroTesla value
    internal func MotionDetect(){
        if motionManager.isMagnetometerAvailable {
            self.setisMAgnetometerAvailable(true)
            motionManager.deviceMotionUpdateInterval = 0.6// Set your desired update interval
            motionManager.showsDeviceMovementDisplay = true
            motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical,to: queue, withHandler: {(data: CMDeviceMotion?, error: Error?) in
                if let field = data?.magneticField.field {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if let deviceMotion = data {
                            let attitude = deviceMotion.attitude
                            // Roll (horizontal angle) in degrees
                            let rollAngle = attitude.roll * 180 / .pi
                            
                            // Pitch (vertical angle) in degrees
                            let pitchAngle = attitude.pitch * 180 / .pi
                            
//                            print("Roll (Horizontal): \(rollAngle)°")
//                            print("Pitch (Vertical): \(pitchAngle)°")
                            self.setverticalAngleValue("\(round(pitchAngle))")
                            self.sethorizontalAngleValue("\(round(rollAngle))")
                        }
                        self.MagneticStrength(field: field)
                    }
                }
            })
        } else {
            // Magnetometer is not available on this device
            print("Magnetometer not available")
            self.setisMAgnetometerAvailable(false)
        }
    }
    
    //Internal function x,y,z and magnetic strength value
    internal func MagneticStrength(field: CMMagneticField) {
        let bField = sqrt((pow(field.x, 2.0)+pow(field.y, 2.0)+pow(field.z, 2.0)))
        let aM = bField*1e-6/self.µ0
        let totalValue = String(format: "%.2f", aM)
        
        DispatchQueue.main.async {
            self.setValueX(String(format: "%.2f", field.x))
            self.setValueY(String(format: "%.2f", field.y))
            self.setValueZ(String(format: "%.2f", field.z))
            self.setmagneticStrengthValue("\(totalValue)")
            print("xValue:-\(self.x) = \(self.magneticStrength) = \(self.compassValue)")
            if aM > 90 {
                // Device orientation has changed significantly, trigger feedback
                self.setisMagnetDetectDevice(true)
                self.GetDate()
            } else {
                self.setisMagnetDetectDevice(false)
            }
        }
        locationDelegate?.getUpdatedData(magnet: self)
    }
    
    func GetDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        let formattedDate = dateFormatter.string(from: currentDate)
        self.setDateValue(formattedDate)
        GetTime()
    }
    
    func GetTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let formattedTime = dateFormatter.string(from: currentDate)
        self.setTimeValue(formattedTime)
    }
    
    // Public function that users can call
    public func publicFunction() {
        // Implementation
        internalFunction()
    }
    
    // Public function to request location authorization
    public func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Internal function to start location updates
    public func startUpdatingLocation() {
        locationManager.startUpdatingHeading()
    }
    
    // Internal function to stop location updates
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingHeading()
    }
    
    // Function to handle location updates
    internal func handleUpdateHeading(newHeading: CLHeading) {
        let magneticHeading = newHeading.magneticHeading
        self.setcompassNorthValue("\(round(magneticHeading))")
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        handleUpdateHeading(newHeading: newHeading)
    }
    // CLLocationManagerDelegate method to handle authorization changes
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            // Handle case where user denies location access
            let error = NSError(domain: "com.example.MyPackage", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location access denied by user"])
            locationDelegate?.didFailWithError(error: error)
        default:
            break
        }
    }
    
    // CLLocationManagerDelegate method to handle location errors
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationDelegate?.didFailWithError(error: error)
    }
}

//MARK: - Extend the class
extension Magnetometer {
    // Define your properties with getters only
     
     public var isMagnetDeviceDetect: Bool {
         return isMagnetDetect
     }
     
     
    public var AllSensors: [String] {
         return AllAvailableSensors
     }
     
    
    public var isMagnetomer: Bool {
        return isMagnetometerAvailable
    }
    
    
    public var x: String {
        return xValue
    }
    
    
    public var y: String {
        return yValue
    }
    
    
    public var z: String {
        return zValue
    }
    
    
    public var magneticStrength: String {
        return magneticStrengthValue
    }
    
    
    public var compassValue: String {
        return compassNorthValue
    }
    
    
    public var verticalAngle: String {
        return verticalAngleValue
    }
    
    
    public var horizontalAngle: String {
        return horizontalAngleValue
    }
     
     
    public var DateValue: String {
         return dateValue
     }
     
     
    public var TimeValue: String {
         return timeValue
     }
    
    // Define methods to set the values (optional)
     fileprivate func setisMagnetDetectDevice(_ newValue: Bool) {
         isMagnetDetect = newValue
     }
     
     fileprivate func setSensors(_ newValue: [String]) {
         AllAvailableSensors = newValue
     }
     
    fileprivate func setisMAgnetometerAvailable(_ newValue: Bool) {
        isMagnetometerAvailable = newValue
    }
    
     fileprivate func setValueX(_ newValue: String) {
        xValue = newValue
    }
    
     fileprivate func setValueY(_ newValue: String) {
        yValue = newValue
    }
    
     fileprivate func setValueZ(_ newValue: String) {
        zValue = newValue
    }
    
     fileprivate func setmagneticStrengthValue(_ newValue: String) {
        magneticStrengthValue = newValue
    }
    
     fileprivate func setcompassNorthValue(_ newValue: String) {
        compassNorthValue = newValue
    }
    
     fileprivate func setverticalAngleValue(_ newValue: String) {
        verticalAngleValue = newValue
    }
    
     fileprivate func sethorizontalAngleValue(_ newValue: String) {
        horizontalAngleValue = newValue
    }
     
     
     fileprivate func setDateValue(_ newValue: String) {
         dateValue = newValue
    }
     
     fileprivate func setTimeValue(_ newValue: String) {
         timeValue = newValue
    }
    
    internal func GetSensorsList() {
        let accelerometerAvailable = motionManager.isAccelerometerAvailable
        let gyroAvailable = motionManager.isGyroAvailable
        let Rotation = motionManager.isDeviceMotionAvailable
        let magnetometerAvailable = motionManager.isMagnetometerAvailable
        let Barometer = CMAltimeter.isRelativeAltitudeAvailable()
        
        let proximitySensorAvailable = UIDevice.current.isProximityMonitoringEnabled
        let gpsAvailable = CLLocationManager.locationServicesEnabled()
        let audioSession = AVAudioSession.sharedInstance()
        let audioInputAvailable = audioSession.isInputAvailable
        
        var appendSensors = [String]()
        
        if accelerometerAvailable {
            appendSensors.append("Accelerometer")
        }
        if gyroAvailable{
            appendSensors.append("Gyroscope")
        }
        if Rotation{
            appendSensors.append("Rotation Vector")
        }
        if magnetometerAvailable{
            appendSensors.append("Magnetometer")
        }
        if Barometer{
            appendSensors.append("Barometer")
        }
        if proximitySensorAvailable{
            appendSensors.append("Proximity")
        }
        if gpsAvailable{
            appendSensors.append("GPS(Location)")
        }
        if audioInputAvailable{
            appendSensors.append("Microphone")
        }
        if appendSensors.count>0 {
            let sortedArray = appendSensors.sorted()
            self.setSensors(sortedArray)
        }
        print("Barometer Available:\(Barometer)")
        print("Accelerometer Available: \(accelerometerAvailable)")
        print("Gyroscope Available: \(gyroAvailable)")
        print("Magnetometer Available: \(magnetometerAvailable)")
        print("Rotation Available: \(Rotation)")
        print("Proximity Sensor Available: \(proximitySensorAvailable)")
        print("GPS Available: \(gpsAvailable)")
        print("Microphone (Audio Input) Available: \(audioInputAvailable)")
    }
}

