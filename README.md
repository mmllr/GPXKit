# GPXKit

A library for parsing gpx files.

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
}
```
See tests for usage examples.
