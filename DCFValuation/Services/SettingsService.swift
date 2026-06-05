import Foundation

@Observable
@MainActor
final class SettingsService {
    private let defaults = UserDefaults.standard
    private let settingsKey = "app_settings"

    var settings: AppSettings {
        didSet {
            save()
        }
    }

    init() {
        if let data = defaults.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = AppSettings()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: settingsKey)
        }
    }
}
