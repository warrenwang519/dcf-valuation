import SwiftUI
import SwiftData

struct ValuationMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [ValuationSchemaV1.self, ValuationSchemaV2.self]
    }
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: ValuationSchemaV1.self,
        toVersion: ValuationSchemaV2.self
    )
}

enum ValuationSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [ValuationRecordV1.self] }
}

enum ValuationSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] { [ValuationRecord.self] }
}

@main
struct DCFValuationApp: App {
    @State private var authViewModel = AuthViewModel()
    @State private var settingsService = SettingsService()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema(versionedSchema: ValuationSchemaV2.self)
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: ValuationMigrationPlan.self,
                configurations: [modelConfiguration]
            )
        } catch {
            // Fallback: delete old store and retry (dev convenience)
            try? FileManager.default.removeItem(at: modelConfiguration.url)
            do {
                return try ModelContainer(
                    for: schema,
                    migrationPlan: ValuationMigrationPlan.self,
                    configurations: [modelConfiguration]
                )
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
                .environment(settingsService)
        }
        .modelContainer(sharedModelContainer)
    }
}
