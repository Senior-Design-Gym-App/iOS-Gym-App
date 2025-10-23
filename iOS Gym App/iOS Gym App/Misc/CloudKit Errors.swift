import Foundation
import CloudKit

func AllowCKError(error: CKError) -> String {
    switch error.code {
    case .internalError:
        return "A non-recoverable error occurred."
    case .partialFailure:
        return "Some of the operation failed. Please try again later."
    case .networkUnavailable:
        return "Network unavailable. Please try again later."
    case .networkFailure:
        return "Network failure. Please try again later."
    case .badContainer:
        return "Bad container. Please contact support."
    case .serviceUnavailable:
        return "Service unavailable. Please try again later."
    case .requestRateLimited:
        return "Too many requests. Please wait a moment and try again."
    case .missingEntitlement:
        return "Missing entitlement. Please try again later."
    case .notAuthenticated:
        return "Please make sure you are signed in with iCloud."
    case .permissionFailure:
        return "Missing permission. Please try again later."
    case .unknownItem:
        return "Unable to find requested item."
    case .invalidArguments:
        return "Invalid request. Please check your request."
    case .resultsTruncated:
        return "Too many results. Please try again later."
    case .serverRecordChanged:
        return "Server has a differenr record than yours. Please try again later."
    case .serverRejectedRequest:
        return "Server rejected the request. Please try again later."
    case .assetFileNotFound:
        return "Unable to find the asset. Please try again later."
    case .assetFileModified:
        return "The asset has been modified. Please try again later."
    case .incompatibleVersion:
        return "Incompadible version. Make sure you are on the latest version."
    case .constraintViolation:
        return "Constraint violation. Please contact support."
    case .operationCancelled:
        return "Request cancelled. Please try again later."
    case .changeTokenExpired:
        return "Token expired. Please try again momentarily."
    case .batchRequestFailed:
        return "Batch update failed. Please try again later."
    case .zoneBusy:
        return "Zone busy. Please try again later."
    case .badDatabase:
        return "Database error. Please contact support."
    case .quotaExceeded:
        return "Quota exceeded. Please check your iCloud storage."
    case .zoneNotFound:
        return "Zone not found. Please contact support."
    case .limitExceeded:
        return "Too many requests. Please try again later."
    case .userDeletedZone:
        return "User deleted zone. Please contact support."
    case .tooManyParticipants:
        return "Too many participants. This should not happen."
    case .alreadyShared:
        return "This is already shared with another user."
    case .referenceViolation:
        return "Failure to find a refrence. Please try again later."
    case .managedAccountRestricted:
        return "Your iCloud account is restricted. Please check your account."
    case .participantMayNeedVerification:
        return "The participant needs verification. Please try again later."
    case .serverResponseLost:
        return "Response lost. Please try again later."
    case .assetNotAvailable:
        return "The asset is not available. Please try again later."
    case .accountTemporarilyUnavailable:
        return "Your account is temporary unavailable. Please check your iCloud status."
    case .participantAlreadyInvited:
        return "The participant is already invited. Please try again later."
    @unknown default:
        return "Unknown error. Please try again later."
    }
}
