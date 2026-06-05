import Foundation
import SwiftData

@Observable
@MainActor
final class HistoryViewModel {
    var searchText = ""

    func filteredRecords(_ records: [ValuationRecord]) -> [ValuationRecord] {
        if searchText.isEmpty {
            return records.sorted { $0.createdAt > $1.createdAt }
        }
        let query = searchText.lowercased()
        return records
            .filter {
                $0.ticker.lowercased().contains(query) ||
                $0.companyName.lowercased().contains(query)
            }
            .sorted { $0.createdAt > $1.createdAt }
    }
}
