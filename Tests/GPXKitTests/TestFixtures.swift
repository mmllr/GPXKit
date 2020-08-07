import Foundation
@testable import GPXKit

let testXMLWithoutTime = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
            <metadata>
            </metadata>
            <trk>
                <name>Haus- und Seenrunde Ausdauer</name>
                <type>1</type>
                <trkseg>
                    <trkpt lat="51.2760600" lon="12.3769500">
                        <ele>114.2</ele>
                    </trkpt>
                    <trkpt lat="51.2760420" lon="12.3769760">
                        <ele>114.0</ele>
                    </trkpt>
                </trkseg>
            </trk>
        </gpx>
        """

let testXMLWithoutExtensions = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
            <metadata>
             <time>2020-03-18T12:39:47Z</time>
            </metadata>
            <trk>
                <name>Haus- und Seenrunde Ausdauer</name>
                <type>1</type>
                <trkseg>
                    <trkpt lat="51.2760600" lon="12.3769500">
                        <ele>114.2</ele>
                        <time>2020-03-18T12:39:47Z</time>
                    </trkpt>
                    <trkpt lat="51.2760420" lon="12.3769760">
                        <ele>114.0</ele>
                        <time>2020-03-18T12:39:48Z</time>
                    </trkpt>
                </trkseg>
            </trk>
        </gpx>
        """

let testXMLData = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
            <metadata>
             <time>2020-03-18T12:39:47Z</time>
            </metadata>
            <trk>
                <name>Haus- und Seenrunde Ausdauer</name>
                <type>1</type>
                <trkseg>
                    <trkpt lat="51.2760600" lon="12.3769500">
                        <ele>114.2</ele>
                        <time>2020-03-18T12:39:47Z</time>
                        <extensions>
                            <power>42</power>
                            <gpxtpx:TrackPointExtension>
                                <gpxtpx:atemp>21</gpxtpx:atemp>
                                <gpxtpx:hr>97</gpxtpx:hr>
                                <gpxtpx:cad>40</gpxtpx:cad>
                            </gpxtpx:TrackPointExtension>
                        </extensions>
                    </trkpt>
                    <trkpt lat="51.2760420" lon="12.3769760">
                        <ele>114.0</ele>
                        <time>2020-03-18T12:39:48Z</time>
                        <extensions>
                            <power>272</power>
                            <gpxtpx:TrackPointExtension>
                                <gpxtpx:atemp>20</gpxtpx:atemp>
                                <gpxtpx:hr>97</gpxtpx:hr>
                                <gpxtpx:cad>40</gpxtpx:cad>
                            </gpxtpx:TrackPointExtension>
                        </extensions>
                    </trkpt>
                </trkseg>
            </trk>
        </gpx>
        """

let testTrack = GPXTrack(date: expectedDate(for: "2020-03-18T12:39:47Z"),
                         title: "Haus- und Seenrunde Ausdauer",
                         trackPoints: [
                            TrackPoint(coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 114.2),
                                       date: expectedDate(for: "2020-03-18T12:39:47Z")),
                            TrackPoint(coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 114.0),
                                       date: expectedDate(for: "2020-03-18T12:39:48Z"))
                         ])

let testTrackWithoutTime = GPXTrack(date: nil,
                                    title: "Test track without time",
                                    trackPoints: [
                                        TrackPoint(coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 114.2),
                                                   date: nil),
                                        TrackPoint(coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 114.0),
                                                   date: nil)
                                    ])
