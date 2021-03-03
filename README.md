# GPXKit
A library for parsing and exporting gpx files with no dependencies besides Foundation.

## Features
- [x] Parsing gpx files into a track struct
- [x] Exporting a track to a gpx xml
- [x] Support for iOS, macOS & watchOS
- [x] Optionally removes date and time from exported gpx for keeping privacy
- [x] Combine support
- [x] Heightmap, geobounds, distance and elevation information for an imported track
- [x] Test coverage

## Installation
To use the `GPXKit` library in a SwiftPM project, add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/mmllr/GPXKit", from: "1.2.6"),
```

## Usage examples
### Importing a track

```swift
import GPXKit

let parser = GPXFileParser(xmlString: xml)
    switch parser.parse() {
    case .success(let track):
        doSomethingWith(track)
    case .failure(let error):
        parseError = error
    }
...
func doSomethingWith(_ track: GPXTrack) {
    let formatter = MeasurementFormatter()
    formatter.unitStyle = .short
    formatter.unitOptions = .naturalScale
    formatter.numberFormatter.maximumFractionDigits = 1
    let trackGraph = track.graph
    print("Track length: \(formatter.string(from: Measurement<UnitLength>(value: trackGraph.distance, unit: .meters)))")
    print("Track elevation: \(formatter.string(from: Measurement<UnitLength>(value: trackGraph.elevationGain, unit: .meters)))")
    
    for point in track.trackPoints {
        print("Lat: \(point.coordinate.latitude), lon: \(point.coordinate.longitude)")
    }
}
```
### Exporting a track
```swift
import GPXKit
let track: GPXTrack = ...
let exporter = GPXExporter(track: track, shouldExportDate: false)
print(exporter.xmlString)
```
### Combine integration
```swift
import Combine
import GPXKit

let url = /// url with gpx
GPXFileParser.load(from: url)
   .publisher
   .map { track in
      // do something with parsed track 
   }
```
See tests for more usage examples.

## Documentation
Project documentation is available at [GitHub Pages](https://mmllr.github.io/GPXKit/)

Run the following commands from the projects root to generate the documentation:
```
[sudo] gem install jazzy
jazzy
```
Browse the documention under the doc folder.

## Contributing
Contributions to this project will be more than welcomed. Feel free to add a pull request or open an issue.
If you require a feature that has yet to be available, do open an issue, describing why and what the feature could bring and how it would help you!
