import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ValuationRecord.createdAt, order: .reverse) private var allRecords: [ValuationRecord]
    @State private var viewModel = HomeViewModel()

    private var recentRecords: [ValuationRecord] {
        let ownerID = authViewModel.currentUser?.userIdentifier ?? ""
        let owned = allRecords.filter { $0.ownerID == ownerID }
        return viewModel.recentRecords(owned)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Quick start
                    NavigationLink {
                        DCFInputView()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Start New Valuation")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    // Recent
                    if !recentRecords.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Valuations")
                                .font(.headline)

                            ForEach(recentRecords) { record in
                                NavigationLink {
                                    let input = PersistenceService(modelContext: modelContext).toDCFInput(from: record)
                                    let output = DCFCalculator().calculate(input: input)
                                    if let result = output.result {
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
                                    RecentValuationCard(record: record)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
        .environment(AuthViewModel())
}
