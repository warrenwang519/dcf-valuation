import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ValuationRecord.createdAt, order: .reverse) private var allRecords: [ValuationRecord]
    @State private var viewModel = HistoryViewModel()

    private var filteredRecords: [ValuationRecord] {
        let ownerID = authViewModel.currentUser?.userIdentifier ?? ""
        let owned = allRecords.filter { $0.ownerID == ownerID }
        return viewModel.filteredRecords(owned)
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredRecords.isEmpty {
                    ContentUnavailableView(
                        "No History",
                        systemImage: "clock",
                        description: Text("Your valuation history will appear here.")
                    )
                } else {
                    List {
                        ForEach(filteredRecords) { record in
                            NavigationLink {
                                let input = PersistenceService(modelContext: modelContext).toDCFInput(from: record)
                                let calculator = DCFCalculator()
                                if case .success(let result) = calculator.calculate(input: input) {
                                    ResultView(
                                        viewModel: ResultViewModel(
                                            result: result,
                                            isReadOnly: true,
                                            persistenceService: PersistenceService(modelContext: modelContext),
                                            ownerID: record.ownerID
                                        )
                                    )
                                }
                            } label: {
                                HistoryRowView(record: record)
                            }
                        }
                        .onDelete { indexSet in
                            let service = PersistenceService(modelContext: modelContext)
                            for index in indexSet {
                                service.delete(filteredRecords[index])
                            }
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search by ticker or company")
            .navigationTitle("History")
        }
    }
}

#Preview {
    HistoryView()
        .environment(AuthViewModel())
}
