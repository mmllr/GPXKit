//
// GPXKit - MIT License - Copyright © 2024 Markus Müller. All rights reserved.
//

import Foundation
@testable import GPXKit
#if canImport(FoundationXML)
import FoundationXML
#endif

extension Coordinate {
    static let kreisel = Coordinate(latitude: 51.3322855, longitude: 12.3620086)
    static let dehner = Coordinate(latitude: 51.271591, longitude: 12.3736913)
    static let leipzig = Coordinate(latitude: 51.323331, longitude: 12.368279)
    static let postPlatz = Coordinate(latitude: 51.0507224, longitude: 13.7315993)
}

extension TestGPXPoint {
    static let kreisel = TestGPXPoint(latitude: 51.3322855, longitude: 12.3620086)
    static let dehner = TestGPXPoint(latitude: 51.271591, longitude: 12.3736913)
    static let leipzig = TestGPXPoint(latitude: 51.323331, longitude: 12.368279)
    static let postPlatz = TestGPXPoint(latitude: 51.0507224, longitude: 13.7315993)
}

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
                <time>2020-07-03T13:20:50.000Z</time>
            </trkpt>
            <trkpt lat="51.2760420" lon="12.3769760">
                <ele>114.0</ele>
                <time>2020-03-18T12:45:48Z</time>
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
        <desc>Track description</desc>
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
                        <gpxtpx:speed>1.23456</gpxtpx:speed>
                    </gpxtpx:TrackPointExtension>
                </extensions>
            </trkpt>
            <trkpt lat="51.2760420" lon="12.3769760">
                <ele>114.0</ele>
                <time>2020-03-18T12:39:48Z</time>
                <extensions>
                    <power>272</power>
                    <gpxtpx:TrackPointExtension>
                        <gpxtpx:atemp>20.5</gpxtpx:atemp>
                        <gpxtpx:hr>87</gpxtpx:hr>
                        <gpxtpx:cad>45</gpxtpx:cad>
                        <gpxtpx:speed>0.12345</gpxtpx:speed>
                    </gpxtpx:TrackPointExtension>
                </extensions>
            </trkpt>
        </trkseg>
    </trk>
</gpx>
"""

let namespacedTestXMLData = """
<?xml version="1.0" encoding="UTF-8"?>
<gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:ns3="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
    <metadata>
     <time>2020-03-18T12:39:47Z</time>
    </metadata>
    <trk>
        <name>Haus- und Seenrunde Ausdauer</name>
        <desc>Track description</desc>
        <type>1</type>
        <trkseg>
            <trkpt lat="51.2760600" lon="12.3769500">
                <ele>114.2</ele>
                <time>2020-03-18T12:39:47Z</time>
                <extensions>
                    <power>166</power>
                    <ns3:TrackPointExtension>
                        <ns3:atemp>22</ns3:atemp>
                        <ns3:hr>90</ns3:hr>
                        <ns3:cad>99</ns3:cad>
                        <ns3:speed>1.23456</ns3:speed>
                    </ns3:TrackPointExtension>
                </extensions>
            </trkpt>
            <trkpt lat="51.2760420" lon="12.3769760">
                <ele>114.0</ele>
                <time>2020-03-18T12:39:48Z</time>
                <extensions>
                    <power>230</power>
                    <ns3:TrackPointExtension>
                        <ns3:atemp>21</ns3:atemp>
                        <ns3:hr>92</ns3:hr>
                        <ns3:cad>101</ns3:cad>
                        <ns3:speed>0.123456</ns3:speed>
                    </ns3:TrackPointExtension>
                </extensions>
            </trkpt>
        </trkseg>
    </trk>
</gpx>
"""

let testTrack = GPXTrack(
    date: expectedDate(for: "2020-03-18T12:39:47Z"),
    title: "Haus- und Seenrunde Ausdauer",
    trackPoints: [
        TrackPoint(
            coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 114.2),
            date: expectedDate(for: "2020-07-03T13:20:50.000Z")
        ),
        TrackPoint(
            coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 114.0),
            date: expectedDate(for: "2020-03-18T12:45:48Z")
        )
    ], type: "running"
)

let testTrackWithoutTime = GPXTrack(
    date: nil,
    title: "Test track without time",
    description: "Description",
    trackPoints: [
        TrackPoint(
            coordinate: Coordinate(latitude: 51.2760600, longitude: 12.3769500, elevation: 114.2),
            date: nil
        ),
        TrackPoint(
            coordinate: Coordinate(latitude: 51.2760420, longitude: 12.3769760, elevation: 114.0),
            date: nil
        )
    ],
    type: "cycling"
)

let testXMLDataContainingWaypoint = """
<?xml version="1.0" encoding="UTF-8"?>
<gpx creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
    <metadata>
     <time>2020-03-18T12:39:47Z</time>
    </metadata>
    <wpt lat="51.2760600" lon="12.3769500">
        <time>2020-03-18T12:39:47Z</time>
        <name>Start</name>
        <cmt>start comment</cmt>
        <desc>This is the start</desc>
    </wpt>
    <wpt lat="51.2760420" lon="12.3769760">
        <time>2020-03-18T12:39:48Z</time>
        <name>Finish</name>
        <cmt>finish comment</cmt>
        <desc>This is the finish</desc>
    </wpt>
    <trk>
        <name>Haus- und Seenrunde Ausdauer</name>
        <desc>Track description</desc>
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
                        <gpxtpx:speed>1.2345</gpxtpx:speed>
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
                        <gpxtpx:speed>0.12345678</gpxtpx:speed>
                    </gpxtpx:TrackPointExtension>
                </extensions>
            </trkpt>
        </trkseg>
    </trk>
</gpx>
"""

let sampleGPX = """
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="Garmin Connect"
  xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd"
  xmlns="http://www.topografix.com/GPX/1/1"
  xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1"
  xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <metadata>
    <link href="connect.garmin.com">
      <text>Garmin Connect</text>
    </link>
    <time>2012-10-24T23:22:51.000Z</time>
  </metadata>
  <trk>
    <name>Untitled</name>
    <trkseg>
      <trkpt lon="-77.02016168273985" lat="38.92747367732227">
        <ele>25.600000381469727</ele>
        <time>2012-10-24T23:29:40.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>130</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02014584094286" lat="38.927609380334616">
        <ele>35.599998474121094</ele>
        <time>2012-10-24T23:30:00.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>134</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02007895335555" lat="38.927675262093544">
        <ele>38.0</ele>
        <time>2012-10-24T23:30:01.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>139</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0200021751225" lat="38.927735360339284">
        <ele>40.0</ele>
        <time>2012-10-24T23:30:03.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>144</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01996009796858" lat="38.927761344239116">
        <ele>40.79999923706055</ele>
        <time>2012-10-24T23:30:04.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>149</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01987116597593" lat="38.927804343402386">
        <ele>44.20000076293945</ele>
        <time>2012-10-24T23:30:06.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>161</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01976303942502" lat="38.92782395705581">
        <ele>45.20000076293945</ele>
        <time>2012-10-24T23:30:08.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>164</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01961317099631" lat="38.927846755832434">
        <ele>48.599998474121094</ele>
        <time>2012-10-24T23:30:11.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>171</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01956137083471" lat="38.9278503600508">
        <ele>49.0</ele>
        <time>2012-10-24T23:30:12.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>177</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01945785433054" lat="38.927872739732265">
        <ele>49.599998474121094</ele>
        <time>2012-10-24T23:30:14.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>181</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01935978606343" lat="38.92788724042475">
        <ele>53.79999923706055</ele>
        <time>2012-10-24T23:30:16.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>184</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01909424737096" lat="38.927910877391696">
        <ele>57.20000076293945</ele>
        <time>2012-10-24T23:30:21.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>188</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01898645609617" lat="38.92792269587517">
        <ele>56.79999923706055</ele>
        <time>2012-10-24T23:30:23.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>189</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01882753521204" lat="38.92793518491089">
        <ele>57.79999923706055</ele>
        <time>2012-10-24T23:30:26.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>191</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0187256950885" lat="38.92793895676732">
        <ele>58.599998474121094</ele>
        <time>2012-10-24T23:30:28.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>191</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01857406646013" lat="38.92795689404011">
        <ele>58.20000076293945</ele>
        <time>2012-10-24T23:30:31.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>192</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01841003261507" lat="38.92795957624912">
        <ele>58.20000076293945</ele>
        <time>2012-10-24T23:30:34.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>193</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01831196434796" lat="38.9279555529356">
        <ele>58.20000076293945</ele>
        <time>2012-10-24T23:30:36.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>194</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0181167498231" lat="38.927953876554966">
        <ele>56.79999923706055</ele>
        <time>2012-10-24T23:30:40.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>195</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01796344481409" lat="38.92792269587517">
        <ele>56.79999923706055</ele>
        <time>2012-10-24T23:30:43.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>195</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01785816811025" lat="38.92790475860238">
        <ele>57.20000076293945</ele>
        <time>2012-10-24T23:30:45.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01770058833063" lat="38.927874667569995">
        <ele>57.20000076293945</ele>
        <time>2012-10-24T23:30:48.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01749975793064" lat="38.927824879065156">
        <ele>57.20000076293945</ele>
        <time>2012-10-24T23:30:52.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>197</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01740856282413" lat="38.92779445275664">
        <ele>57.79999923706055</ele>
        <time>2012-10-24T23:30:54.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>197</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01717604883015" lat="38.92769847996533">
        <ele>59.20000076293945</ele>
        <time>2012-10-24T23:30:59.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0170960854739" lat="38.92764626070857">
        <ele>59.20000076293945</ele>
        <time>2012-10-24T23:31:01.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01688896864653" lat="38.927528662607074">
        <ele>60.599998474121094</ele>
        <time>2012-10-24T23:31:06.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01667975634336" lat="38.92741408199072">
        <ele>61.0</ele>
        <time>2012-10-24T23:31:11.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>199</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01654857955873" lat="38.92733269371092">
        <ele>61.599998474121094</ele>
        <time>2012-10-24T23:31:14.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>199</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01646216213703" lat="38.927280558273196">
        <ele>61.599998474121094</ele>
        <time>2012-10-24T23:31:16.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>200</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01628899201751" lat="38.92716589383781">
        <ele>61.599998474121094</ele>
        <time>2012-10-24T23:31:20.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>200</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01620366424322" lat="38.92711367458105">
        <ele>61.0</ele>
        <time>2012-10-24T23:31:22.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>200</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01607164926827" lat="38.92703019082546">
        <ele>61.0</ele>
        <time>2012-10-24T23:31:25.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>200</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01573377475142" lat="38.926835898309946">
        <ele>62.0</ele>
        <time>2012-10-24T23:31:33.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>201</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0155177731067" lat="38.92670505680144">
        <ele>63.0</ele>
        <time>2012-10-24T23:31:38.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>202</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0154741872102" lat="38.92667965963483">
        <ele>63.0</ele>
        <time>2012-10-24T23:31:39.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>202</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01526665128767" lat="38.92657555639744">
        <ele>64.0</ele>
        <time>2012-10-24T23:31:44.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>202</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01507185585797" lat="38.92649408429861">
        <ele>65.4000015258789</ele>
        <time>2012-10-24T23:31:48.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>203</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0148972608149" lat="38.926416048780084">
        <ele>65.80000305175781</ele>
        <time>2012-10-24T23:31:52.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>202</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0147526729852" lat="38.9263753965497">
        <ele>67.4000015258789</ele>
        <time>2012-10-24T23:31:55.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>202</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01459065079689" lat="38.92632409930229">
        <ele>69.80000305175781</ele>
        <time>2012-10-24T23:31:59.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>202</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01433315873146" lat="38.926287051290274">
        <ele>77.0</ele>
        <time>2012-10-24T23:32:05.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>202</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0141704659909" lat="38.92626433633268">
        <ele>82.80000305175781</ele>
        <time>2012-10-24T23:32:09.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>202</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01398195698857" lat="38.92624338157475">
        <ele>82.19999694824219</ele>
        <time>2012-10-24T23:32:13.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>202</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01379646547139" lat="38.9262337423861">
        <ele>82.19999694824219</ele>
        <time>2012-10-24T23:32:17.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>202</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01359488070011" lat="38.92623843625188">
        <ele>81.80000305175781</ele>
        <time>2012-10-24T23:32:21.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>203</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01340997591615" lat="38.92626844346523">
        <ele>81.80000305175781</ele>
        <time>2012-10-24T23:32:25.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>203</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01331693679094" lat="38.926288140937686">
        <ele>81.19999694824219</ele>
        <time>2012-10-24T23:32:27.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>203</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0130842551589" lat="38.92627774737775">
        <ele>80.80000305175781</ele>
        <time>2012-10-24T23:32:32.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>203</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01287286356091" lat="38.926266096532345">
        <ele>79.80000305175781</ele>
        <time>2012-10-24T23:32:36.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>203</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01276607811451" lat="38.92626425251365">
        <ele>78.4000015258789</ele>
        <time>2012-10-24T23:32:38.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>203</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0126148685813" lat="38.92626249231398">
        <ele>76.4000015258789</ele>
        <time>2012-10-24T23:32:41.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>203</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01249006204307" lat="38.92625897191465">
        <ele>75.5999984741211</ele>
        <time>2012-10-24T23:32:44.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>203</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01230624690652" lat="38.92624296247959">
        <ele>74.0</ele>
        <time>2012-10-24T23:32:48.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>203</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01226199045777" lat="38.92622619867325">
        <ele>74.0</ele>
        <time>2012-10-24T23:32:49.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>203</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01224053278565" lat="38.926080856472254">
        <ele>74.0</ele>
        <time>2012-10-24T23:32:52.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>203</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01226693578064" lat="38.925901148468256">
        <ele>74.0</ele>
        <time>2012-10-24T23:32:56.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>203</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01227179728448" lat="38.92573828808963">
        <ele>73.5999984741211</ele>
        <time>2012-10-24T23:33:00.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>202</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01227724552155" lat="38.92563938163221">
        <ele>73.0</ele>
        <time>2012-10-24T23:33:03.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>202</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01229015365243" lat="38.925464786589146">
        <ele>73.5999984741211</ele>
        <time>2012-10-24T23:33:08.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>202</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01230306178331" lat="38.92527426593006">
        <ele>73.5999984741211</ele>
        <time>2012-10-24T23:33:13.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>201</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0123072527349" lat="38.925195978954434">
        <ele>72.5999984741211</ele>
        <time>2012-10-24T23:33:15.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>201</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01229996047914" lat="38.92502188682556">
        <ele>73.0</ele>
        <time>2012-10-24T23:33:20.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>201</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0123035646975" lat="38.92488098703325">
        <ele>72.5999984741211</ele>
        <time>2012-10-24T23:33:24.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>200</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01231328770518" lat="38.92474964261055">
        <ele>72.5999984741211</ele>
        <time>2012-10-24T23:33:28.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>200</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01231303624809" lat="38.924559876322746">
        <ele>73.0</ele>
        <time>2012-10-24T23:33:33.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>200</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01229895465076" lat="38.924409840255976">
        <ele>73.0</ele>
        <time>2012-10-24T23:33:37.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>200</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01230415143073" lat="38.924231892451644">
        <ele>72.19999694824219</ele>
        <time>2012-10-24T23:33:42.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>200</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01232016086578" lat="38.92405436374247">
        <ele>72.5999984741211</ele>
        <time>2012-10-24T23:33:47.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>199</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01230415143073" lat="38.923897789791226">
        <ele>72.19999694824219</ele>
        <time>2012-10-24T23:33:52.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>199</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01228545978665" lat="38.92370265908539">
        <ele>72.5999984741211</ele>
        <time>2012-10-24T23:33:58.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>197</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01229459606111" lat="38.923558657988906">
        <ele>73.0</ele>
        <time>2012-10-24T23:34:02.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>197</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01230658218265" lat="38.923359671607614">
        <ele>73.5999984741211</ele>
        <time>2012-10-24T23:34:07.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>197</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01228395104408" lat="38.92321198247373">
        <ele>71.5999984741211</ele>
        <time>2012-10-24T23:34:11.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01229459606111" lat="38.922983994707465">
        <ele>69.19999694824219</ele>
        <time>2012-10-24T23:34:17.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01228738762438" lat="38.922844771295786">
        <ele>66.4000015258789</ele>
        <time>2012-10-24T23:34:21.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01228244230151" lat="38.92261954955757">
        <ele>62.0</ele>
        <time>2012-10-24T23:34:27.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01228328049183" lat="38.922506645321846">
        <ele>60.20000076293945</ele>
        <time>2012-10-24T23:34:30.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01227799989283" lat="38.922362979501486">
        <ele>57.79999923706055</ele>
        <time>2012-10-24T23:34:34.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0122657623142" lat="38.92222115769982">
        <ele>56.20000076293945</ele>
        <time>2012-10-24T23:34:38.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01225637458265" lat="38.9220704510808">
        <ele>53.79999923706055</ele>
        <time>2012-10-24T23:34:42.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01225796714425" lat="38.92183315940201">
        <ele>53.79999923706055</ele>
        <time>2012-10-24T23:34:48.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>197</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01224774122238" lat="38.92163903452456">
        <ele>53.79999923706055</ele>
        <time>2012-10-24T23:34:53.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>197</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01221999712288" lat="38.921515233814716">
        <ele>55.79999923706055</ele>
        <time>2012-10-24T23:34:57.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>197</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0122554525733" lat="38.92134097404778">
        <ele>54.79999923706055</ele>
        <time>2012-10-24T23:35:02.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>197</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01225738041103" lat="38.921144753694534">
        <ele>55.400001525878906</ele>
        <time>2012-10-24T23:35:08.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>197</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01226215809584" lat="38.92102338373661">
        <ele>56.79999923706055</ele>
        <time>2012-10-24T23:35:12.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0122723840177" lat="38.92085096798837">
        <ele>57.79999923706055</ele>
        <time>2012-10-24T23:35:17.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0122089330107" lat="38.920597583055496">
        <ele>61.599998474121094</ele>
        <time>2012-10-24T23:35:22.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>195</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01216978952289" lat="38.92040236853063">
        <ele>64.0</ele>
        <time>2012-10-24T23:35:26.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>195</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01215906068683" lat="38.92031284980476">
        <ele>65.80000305175781</ele>
        <time>2012-10-24T23:35:28.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>195</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0122107770294" lat="38.920206064358354">
        <ele>64.4000015258789</ele>
        <time>2012-10-24T23:35:32.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>195</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01249215751886" lat="38.92026264220476">
        <ele>56.79999923706055</ele>
        <time>2012-10-24T23:35:37.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>195</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01258645392954" lat="38.920278484001756">
        <ele>55.400001525878906</ele>
        <time>2012-10-24T23:35:39.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>194</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01288635842502" lat="38.92032223753631">
        <ele>53.79999923706055</ele>
        <time>2012-10-24T23:35:45.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>193</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01314385049045" lat="38.92034595832229">
        <ele>50.0</ele>
        <time>2012-10-24T23:35:50.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>193</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01339229010046" lat="38.92036314122379">
        <ele>44.79999923706055</ele>
        <time>2012-10-24T23:35:55.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>194</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01363989152014" lat="38.92035643570125">
        <ele>40.0</ele>
        <time>2012-10-24T23:36:00.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>195</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01386544853449" lat="38.92037169076502">
        <ele>35.20000076293945</ele>
        <time>2012-10-24T23:36:05.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01400383375585" lat="38.92036356031895">
        <ele>32.79999923706055</ele>
        <time>2012-10-24T23:36:08.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01413459144533" lat="38.92035995610058">
        <ele>30.399999618530273</ele>
        <time>2012-10-24T23:36:11.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01432075351477" lat="38.920363476499915">
        <ele>28.399999618530273</ele>
        <time>2012-10-24T23:36:15.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01445704326034" lat="38.9203433599323">
        <ele>27.0</ele>
        <time>2012-10-24T23:36:18.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01449979096651" lat="38.920343862846494">
        <ele>26.399999618530273</ele>
        <time>2012-10-24T23:36:19.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01466114260256" lat="38.92034235410392">
        <ele>27.0</ele>
        <time>2012-10-24T23:36:23.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01598179526627" lat="38.92052206210792">
        <ele>37.599998474121094</ele>
        <time>2012-10-24T23:38:09.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>146</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01598179526627" lat="38.92052206210792">
        <ele>37.599998474121094</ele>
        <time>2012-10-24T23:38:09.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>146</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01600886881351" lat="38.92051678150892">
        <ele>37.0</ele>
        <time>2012-10-24T23:38:10.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>147</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01603543944657" lat="38.92051284201443">
        <ele>36.599998474121094</ele>
        <time>2012-10-24T23:38:11.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>147</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0161356870085" lat="38.92049775458872">
        <ele>34.20000076293945</ele>
        <time>2012-10-24T23:38:15.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>152</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01615194790065" lat="38.920499347150326">
        <ele>34.20000076293945</ele>
        <time>2012-10-24T23:38:16.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>154</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01633408665657" lat="38.920493479818106">
        <ele>34.599998474121094</ele>
        <time>2012-10-24T23:38:27.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>151</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01648789457977" lat="38.92048099078238">
        <ele>36.0</ele>
        <time>2012-10-24T23:38:30.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>156</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0166211668402" lat="38.92047478817403">
        <ele>39.0</ele>
        <time>2012-10-24T23:38:33.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>162</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01676617376506" lat="38.920447546988726">
        <ele>39.0</ele>
        <time>2012-10-24T23:38:36.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>164</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0168904773891" lat="38.92043078318238">
        <ele>37.599998474121094</ele>
        <time>2012-10-24T23:38:39.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>169</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01698016375303" lat="38.920421060174704">
        <ele>37.0</ele>
        <time>2012-10-24T23:38:41.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>172</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01714377850294" lat="38.9204075653106">
        <ele>36.0</ele>
        <time>2012-10-24T23:38:45.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>177</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0173085667193" lat="38.92041904851794">
        <ele>34.20000076293945</ele>
        <time>2012-10-24T23:38:49.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>182</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01752968132496" lat="38.92041586339474">
        <ele>34.20000076293945</ele>
        <time>2012-10-24T23:38:53.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>184</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01772565022111" lat="38.920386862009764">
        <ele>35.20000076293945</ele>
        <time>2012-10-24T23:38:58.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>186</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0179124828428" lat="38.920359034091234">
        <ele>35.599998474121094</ele>
        <time>2012-10-24T23:39:03.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>188</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01812907122076" lat="38.92033095471561">
        <ele>36.599998474121094</ele>
        <time>2012-10-24T23:39:08.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>188</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0183514431119" lat="38.920300863683224">
        <ele>36.599998474121094</ele>
        <time>2012-10-24T23:39:13.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>188</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01856836676598" lat="38.92029248178005">
        <ele>37.0</ele>
        <time>2012-10-24T23:39:18.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>189</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01884387992322" lat="38.92028016038239">
        <ele>34.20000076293945</ele>
        <time>2012-10-24T23:39:24.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>190</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01909625902772" lat="38.920257948338985">
        <ele>33.599998474121094</ele>
        <time>2012-10-24T23:39:30.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>191</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01929985545576" lat="38.92024646513164">
        <ele>31.799999237060547</ele>
        <time>2012-10-24T23:39:35.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>192</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01955776661634" lat="38.92021235078573">
        <ele>33.599998474121094</ele>
        <time>2012-10-24T23:39:41.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>193</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.01977494172752" lat="38.92019617371261">
        <ele>36.0</ele>
        <time>2012-10-24T23:39:46.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>194</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02000485733151" lat="38.92018695361912">
        <ele>36.0</ele>
        <time>2012-10-24T23:39:51.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>194</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02022136189044" lat="38.920163065195084">
        <ele>34.599998474121094</ele>
        <time>2012-10-24T23:39:56.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>194</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02042487449944" lat="38.920137668028474">
        <ele>38.0</ele>
        <time>2012-10-24T23:40:01.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>194</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02062293887138" lat="38.92012685537338">
        <ele>39.400001525878906</ele>
        <time>2012-10-24T23:40:06.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>194</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0207773335278" lat="38.92012685537338">
        <ele>40.400001525878906</ele>
        <time>2012-10-24T23:40:10.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>194</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02101445756853" lat="38.920146552845836">
        <ele>42.79999923706055</ele>
        <time>2012-10-24T23:40:15.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>194</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02119827270508" lat="38.92016038298607">
        <ele>42.79999923706055</ele>
        <time>2012-10-24T23:40:19.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>195</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02131696045399" lat="38.92013439908624">
        <ele>43.20000076293945</ele>
        <time>2012-10-24T23:40:23.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>195</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0213476382196" lat="38.920117635279894">
        <ele>42.400001525878906</ele>
        <time>2012-10-24T23:40:24.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>195</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02155919745564" lat="38.92003775574267">
        <ele>42.400001525878906</ele>
        <time>2012-10-24T23:40:30.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>195</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02182884328067" lat="38.920014034956694">
        <ele>42.79999923706055</ele>
        <time>2012-10-24T23:40:35.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0219174399972" lat="38.92002157866955">
        <ele>41.400001525878906</ele>
        <time>2012-10-24T23:40:37.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02199949882925" lat="38.920043455436826">
        <ele>39.400001525878906</ele>
        <time>2012-10-24T23:40:39.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02204375527799" lat="38.92017396166921">
        <ele>40.79999923706055</ele>
        <time>2012-10-24T23:40:44.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>197</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02204928733408" lat="38.92031645402312">
        <ele>42.79999923706055</ele>
        <time>2012-10-24T23:40:48.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>197</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02205297537148" lat="38.92041829414666">
        <ele>44.20000076293945</ele>
        <time>2012-10-24T23:40:51.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02206856571138" lat="38.92059146426618">
        <ele>47.599998474121094</ele>
        <time>2012-10-24T23:40:56.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>197</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02208214439452" lat="38.9207373932004">
        <ele>51.0</ele>
        <time>2012-10-24T23:41:00.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0220794621855" lat="38.92083537764847">
        <ele>50.599998474121094</ele>
        <time>2012-10-24T23:41:05.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02207904309034" lat="38.92085717059672">
        <ele>51.0</ele>
        <time>2012-10-24T23:41:07.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02209253795445" lat="38.92088457942009">
        <ele>52.400001525878906</ele>
        <time>2012-10-24T23:41:09.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>197</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02210125513375" lat="38.920895140618086">
        <ele>53.0</ele>
        <time>2012-10-24T23:41:12.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02209765091538" lat="38.920905785635114">
        <ele>53.400001525878906</ele>
        <time>2012-10-24T23:41:13.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>194</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02209488488734" lat="38.92095607705414">
        <ele>52.400001525878906</ele>
        <time>2012-10-24T23:41:20.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>189</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02210435643792" lat="38.92098658718169">
        <ele>51.400001525878906</ele>
        <time>2012-10-24T23:41:21.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>189</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0221209526062" lat="38.921102257445455">
        <ele>46.599998474121094</ele>
        <time>2012-10-24T23:41:24.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>190</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0221386384219" lat="38.92116017639637">
        <ele>45.20000076293945</ele>
        <time>2012-10-24T23:41:26.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>190</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02216068282723" lat="38.92126126214862">
        <ele>41.400001525878906</ele>
        <time>2012-10-24T23:41:30.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>191</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02217007055879" lat="38.921307446435094">
        <ele>39.400001525878906</ele>
        <time>2012-10-24T23:41:32.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>192</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02217174693942" lat="38.92141515389085">
        <ele>37.599998474121094</ele>
        <time>2012-10-24T23:41:37.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>193</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02221374027431" lat="38.92158564180136">
        <ele>37.599998474121094</ele>
        <time>2012-10-24T23:41:43.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>195</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02224978245795" lat="38.92172587104142">
        <ele>40.400001525878906</ele>
        <time>2012-10-24T23:41:47.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02228079549968" lat="38.92189275473356">
        <ele>42.79999923706055</ele>
        <time>2012-10-24T23:41:52.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>196</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02229898422956" lat="38.922113198786974">
        <ele>43.20000076293945</ele>
        <time>2012-10-24T23:41:58.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0223336853087" lat="38.92230455763638">
        <ele>45.599998474121094</ele>
        <time>2012-10-24T23:42:03.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>198</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02235983684659" lat="38.9224174618721">
        <ele>48.20000076293945</ele>
        <time>2012-10-24T23:42:07.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>199</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02238263562322" lat="38.922575460746884">
        <ele>50.0</ele>
        <time>2012-10-24T23:42:12.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>200</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02240124344826" lat="38.922690292820334">
        <ele>50.599998474121094</ele>
        <time>2012-10-24T23:42:16.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>200</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02242705971003" lat="38.92284108325839">
        <ele>52.0</ele>
        <time>2012-10-24T23:42:21.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>200</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02245295979083" lat="38.92299338243902">
        <ele>53.400001525878906</ele>
        <time>2012-10-24T23:42:26.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>200</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0224732439965" lat="38.92314593307674">
        <ele>54.79999923706055</ele>
        <time>2012-10-24T23:42:31.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>201</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0224819611758" lat="38.923230757936835">
        <ele>55.79999923706055</ele>
        <time>2012-10-24T23:42:34.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>201</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02251255512238" lat="38.92340946011245">
        <ele>58.20000076293945</ele>
        <time>2012-10-24T23:42:40.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>201</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02252085320652" lat="38.92353979870677">
        <ele>59.20000076293945</ele>
        <time>2012-10-24T23:42:44.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>201</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02255035750568" lat="38.9236643537879">
        <ele>60.599998474121094</ele>
        <time>2012-10-24T23:42:48.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>201</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02258019708097" lat="38.923895275220275">
        <ele>60.20000076293945</ele>
        <time>2012-10-24T23:42:55.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>202</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02259595505893" lat="38.9240200817585">
        <ele>60.599998474121094</ele>
        <time>2012-10-24T23:42:59.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>203</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02263216488063" lat="38.92404958605766">
        <ele>60.599998474121094</ele>
        <time>2012-10-24T23:43:01.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>203</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0233437884599" lat="38.9241355843842">
        <ele>48.599998474121094</ele>
        <time>2012-10-24T23:43:53.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>167</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02335686422884" lat="38.92414337955415">
        <ele>48.20000076293945</ele>
        <time>2012-10-24T23:43:54.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>167</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02337748371065" lat="38.92415435984731">
        <ele>48.599998474121094</ele>
        <time>2012-10-24T23:43:55.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>166</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02344378456473" lat="38.92416425049305">
        <ele>49.0</ele>
        <time>2012-10-24T23:43:58.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>167</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02356305904686" lat="38.92415679059923">
        <ele>48.599998474121094</ele>
        <time>2012-10-24T23:43:59.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>169</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02378945425153" lat="38.92415016889572">
        <ele>48.599998474121094</ele>
        <time>2012-10-24T23:44:05.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>172</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02393596991897" lat="38.9241511747241">
        <ele>47.20000076293945</ele>
        <time>2012-10-24T23:44:09.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>177</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02412808313966" lat="38.9241252746433">
        <ele>46.20000076293945</ele>
        <time>2012-10-24T23:44:14.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>178</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02428666874766" lat="38.92410314641893">
        <ele>44.79999923706055</ele>
        <time>2012-10-24T23:44:18.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>179</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02448104508221" lat="38.92406467348337">
        <ele>43.79999923706055</ele>
        <time>2012-10-24T23:44:23.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>181</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0245560631156" lat="38.92404363490641">
        <ele>43.20000076293945</ele>
        <time>2012-10-24T23:44:25.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>181</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02482596039772" lat="38.92400298267603">
        <ele>44.79999923706055</ele>
        <time>2012-10-24T23:44:32.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>182</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02502603642642" lat="38.923988565802574">
        <ele>44.79999923706055</ele>
        <time>2012-10-24T23:44:37.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>183</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02520733699203" lat="38.923978339880705">
        <ele>45.20000076293945</ele>
        <time>2012-10-24T23:44:42.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>185</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02523876912892" lat="38.9239735621959">
        <ele>44.79999923706055</ele>
        <time>2012-10-24T23:44:43.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>185</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02534915879369" lat="38.92397255636752">
        <ele>43.20000076293945</ele>
        <time>2012-10-24T23:44:47.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>185</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02538243494928" lat="38.92397616058588">
        <ele>42.400001525878906</ele>
        <time>2012-10-24T23:44:50.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>185</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02541328035295" lat="38.92397305928171">
        <ele>46.599998474121094</ele>
        <time>2012-10-24T23:44:53.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>184</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02544135972857" lat="38.9239682815969">
        <ele>45.599998474121094</ele>
        <time>2012-10-24T23:44:54.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>183</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02550858259201" lat="38.923965683206916">
        <ele>46.599998474121094</ele>
        <time>2012-10-24T23:44:57.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>182</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02560254372656" lat="38.92400943674147">
        <ele>44.79999923706055</ele>
        <time>2012-10-24T23:45:00.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>182</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02565283514559" lat="38.924188474193215">
        <ele>44.79999923706055</ele>
        <time>2012-10-24T23:45:06.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>182</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02569868415594" lat="38.92435099929571">
        <ele>44.20000076293945</ele>
        <time>2012-10-24T23:45:11.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>182</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02571486122906" lat="38.92446834594011">
        <ele>44.79999923706055</ele>
        <time>2012-10-24T23:45:15.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>183</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02572366222739" lat="38.92463514581323">
        <ele>46.599998474121094</ele>
        <time>2012-10-24T23:45:20.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>184</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02572626061738" lat="38.92478199675679">
        <ele>48.599998474121094</ele>
        <time>2012-10-24T23:45:25.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>185</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.0257300324738" lat="38.92479809001088">
        <ele>48.599998474121094</ele>
        <time>2012-10-24T23:45:26.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>186</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lon="-77.02575484290719" lat="38.92482256516814">
        <ele>48.599998474121094</ele>
        <time>2012-10-24T23:45:28.000Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>186</gpxtpx:hr>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
    </trkseg>
  </trk>
</gpx>
"""
