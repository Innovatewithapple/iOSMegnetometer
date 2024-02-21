# iOSMegnetometer

iOSMegneometer is a Swift package that provides access to magnetometer data for iOS apps.

## Features

- **Magnetometer Strength**: Get the strength of the magnetic field in microtesla (µT).
- **XYZ Coordinates**: Retrieve the XYZ coordinates representing the magnetic field.
- **Vertical and Horizontal Angles**: Obtain vertical and horizontal angles related to the magnetic field.
- **Available Sensors List**: Access a list of available sensors on the device.
- **Compass Value**: Retrieve the compass value indicating the direction of magnetic north.

## Installation

To integrate MagnetometerData into your Xcode project using Swift Package Manager, follow these steps:

1. In Xcode, select your project.
2. Go to the "Swift Packages" tab.
3. Click the "+" button and select "Add Package Dependency".
4. Enter the following URL: [https://github.com/Innovatewithapple/iOSMegnetometer.git](https://github.com/Innovatewithapple/iOSMegnetometer.git)
5. Follow the prompts to complete the installation process.

## Usage

After adding the package, import MagnetometerData into your Swift file:

```swift
import iOSMagnetometer
```

Create an instance of the `Magnetometer` class:

```swift
var magnet = Magnetometer.shared
```

Set the delegate protocol `MagnetometerLocationDelegate`:

```swift
magnet.locationDelegate = self
```

Implement the delegate methods to receive magnetometer data and handle errors:

```swift
extension YourViewController: MagnetometerLocationDelegate {
    func getUpdatedData(magnet: Magnetometer) {
        // Access magnetometer data: magnet.x, magnet.y, magnet.z
    }
    
    func didFailWithError(error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
```

Start updating the location and call any public functions:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    magnet.startUpdatingLocation()
    magnet.publicFunction()
}
```

## Requirements

- iOS 11.0+
- Xcode 12.0+
- Swift 5.0+

