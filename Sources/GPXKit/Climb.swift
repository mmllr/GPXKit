import Foundation

/// Describes a climb section within a track.
public struct Climb: Hashable, Sendable {
    /// The distance in meters from the climbs start to the `GPXTrack`s origin.
    public var start: Double
    /// The distance of the end climb in meters from the `GPXTrack`s origin.
    public var end: Double
    /// The elevation in meters of the climbs bottom.
    public var bottom: Double
    /// The elevation in meters of the climbs top.
    public var top: Double
    /// The total elevation gain in meters of the climb. It may be higher than `top` - `bottom` when a climb has flat or descending sections.
    public var totalElevation: Double
    /// The average grade (elevation over distance) of the climb in percent in the range {0,1}.
    public var grade: Double
    /// The maximum grade (elevation over distance) of the climb in percent in the range {0,1}. If the climb was constructed from multiple adjacent climbs it has their maximum grade, otherwise `maxGrade` is equal to `grade`.
    public var maxGrade: Double
    /// The FIETS score of the climb
    ///
    /// One way to determine the difficulty of a climb is to use the FIETS formula to calculate a numeric value for the climb. This formula was developed by the Dutch cycling magazine Fiets. The formula is shown below:
    ///
    /// ```
    /// FIETS Score = (H * H / D * 10) + (T - 1000) / 1000
    /// ```
    /// Where:

    /// * **H** is the height of the climb (meters),
    /// * **D** is the climb length or distance (meters)
    /// * **T** is the altitude at the top (meters).

    /// The second term in the formula is only added when it is positive, that is, for climbs whose top is above 1000m.
    /// **NOTE** In GPXKit, the "(T - 1000)/1000" term of the FIETS formula is not added to the climb segments, so climbs can be joined together.
    public var score: Double

    /// Initializes a `Climb`.
    /// - Parameters:
    ///   - start: The distance in meters from the `GPXTrack`s start.
    ///   - end: The distance in meters from the `GOXTracks`s end.
    ///   - bottom: The elevation in meters at the start of the climb.
    ///   - top: The elevation in meters at the top of the climb.
    ///   - totalElevation: The total elevation in meters of the climb (top - bottom in most cases).
    ///   - grade: The grade (elevation over distance) of the climb in percent in the range {0,1}.
    ///   - maxGrade: The maximum grade (elevation over distance) of the climb in percent in the range {0,1}.
    ///   - score: The FIETS Score of the climb.
    public init(start: Double, end: Double, bottom: Double, top: Double, totalElevation: Double, grade: Double, maxGrade: Double, score: Double) {
        self.start = start
        self.end = end
        self.bottom = bottom
        self.top = top
        self.totalElevation = totalElevation
        self.grade = grade
        self.maxGrade = maxGrade
        self.score = score
    }

    /// Initializes a `Climb`.
    /// - Parameters:
    ///   - start: The distance in meters from the `GPXTrack`s start.
    ///   - end: The distance in meters from the `GOXTracks`s end.
    ///   - bottom: The elevation in meters at the start of the climb.
    ///   - top: The elevation in meters at the top of the climb.
    public init(start: Double, end: Double, bottom: Double, top: Double) {
        let distance = end - start
        let elevation = top - bottom
        self.start = start
        self.end = end
        self.bottom = bottom
        self.top = top
        self.totalElevation = elevation
        self.grade = elevation / distance
        self.maxGrade = elevation / distance
        self.score = (elevation * elevation) / (distance * 10) + max(0, (top - 1000.0) / 1000.0)
    }

}

public extension Climb {
    /// The length in meters of the climb.
    var distance: Double {
        end - start
    }
}
