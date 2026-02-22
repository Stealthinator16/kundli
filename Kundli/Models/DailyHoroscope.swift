import Foundation

struct DailyHoroscope {
    let sign: ZodiacSign
    let date: Date
    let overallRating: Int    // 1-5
    let loveRating: Int
    let careerRating: Int
    let healthRating: Int
    let prediction: String
    let luckyNumber: Int
    let luckyColor: String
}
