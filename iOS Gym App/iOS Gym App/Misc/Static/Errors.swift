import Foundation

enum SharePlanError: Error, LocalizedError {
    
    case encodePlanFailed
    case noFileURL
    case decodeError
    
    var errorDescription: String? {
        switch self {
        case .encodePlanFailed:
            return "Critical Error: Data encoding failed. Please try again later."
        case .noFileURL:
            return "Critical Error: Unable to locate file URL. This plan will not be able to be loaded."
        case .decodeError:
            return "Critical Error: Data decoding failed. This plan will not be able to be loaded."
        }
    }
    
}
