import Foundation
import SwiftData

@Observable
@MainActor
final class HomeViewModel {
    func recentRecords(_ records: [ValuationRecord], limit: Int = 5) -> [ValuationRecord] {
        records
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(limit)
            .map { $0 }
    }
}
