# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DCF Valuation App — a professional DCF (Discounted Cash Flow) valuation tool for iOS. Targets individual investors in US, HK, and A-share markets. Users input financial parameters and get intrinsic value per share in seconds.

## Git Workflow

- **Commit and push to GitHub regularly** — after every meaningful change, commit with a clean message and push to `origin/main` so we never lose work in progress.
- Commit messages should be concise, imperative mood, and describe the "why" not just the "what".
- Always push after committing: `git push origin main`.
- Never leave uncommitted changes sitting in the working tree when moving on to a new task.

## Tech Stack

- **Platform**: iOS 18+ (Deployment Target), built with Xcode 26, iOS 26 SDK
- **Language**: Swift 6 with strict concurrency
- **UI Framework**: SwiftUI (no UIKit)
- **Architecture**: MVVM with @Observable (Swift Observation framework)
- **Persistence**: SwiftData with CloudKit sync
- **Auth**: Sign in with Apple (AuthenticationServices + Keychain)
- **No third-party dependencies** — Apple native frameworks only

## Build & Run

This project has no `.xcodeproj` — it's a pure Swift source structure. To build:

1. Open Xcode 26 → File → New → Project → iOS App
2. Set target to iOS 18.0+
3. Drag the `DCFValuation/` folder into the project
4. Enable Capabilities: Sign in with Apple, iCloud (CloudKit), Background Modes (remote notifications)
5. Set CloudKit container to `iCloud.<bundle-id>`
6. Build with Cmd+B, run with Cmd+R

No CLI build commands, no SPM, no CocoaPods.

## Architecture

### MVVM Data Flow

```
View → ViewModel (@Observable @MainActor) → Service (Sendable struct) → Model
```

- Views use `@Environment` for shared state (AuthViewModel, SettingsService)
- ViewModels are `@Observable @MainActor` classes
- Services are stateless `Sendable` structs (except SettingsService which holds UserDefaults cache)
- Models are plain `Sendable` structs (DCFInput, DCFResult) or SwiftData `@Model` classes (ValuationRecord)

### Key Architectural Decisions

- **AuthViewModel** is the root state machine: `AuthState` enum (.unknown → .notLoggedIn → .loggedIn) drives ContentView to show LoginView or TabView
- **DCFInputViewModel** holds all calculator form state and triggers computation via DCFCalculator
- **ResultViewModel** receives a DCFResult and handles display formatting + save-to-history
- **PersistenceService** wraps SwiftData ModelContext; all writes include `ownerID` from Apple Sign In for data isolation
- **DCFCalculator** is a pure function: `DCFInput → Result<DCFResult, [ValidationError]>`, no side effects
- **SettingsService** provides default parameters (currency, WACC, forecast years) that auto-fill the calculator form

### CloudKit Sync

SwiftData's `ModelContainer` is configured with `cloudKitDatabase: .automatic`. History records sync across devices automatically. Each record has an `ownerID` field tying it to the signed-in Apple ID.

## Code Patterns

### Number Input Binding Pattern

DCFInputView converts `Double` ↔ `String` for text fields using inline `Binding(get:set:)`. Empty string maps to 0.

### Validation → Calculate → Navigate Flow

1. User taps "Calculate"
2. `DCFInputViewModel.calculate()` runs ValidationService first
3. On failure: updates `validationErrors`, errorAlert modifier shows alert
4. On success: sets `result`, triggers `navigationDestination` to ResultView

### Localization

Currently hardcoded English strings (localization deferred to v2). All user-facing text is inline in SwiftUI views — no string tables.

## Concurrency Model

Swift 6 strict concurrency is enforced:
- All ViewModels: `@Observable @MainActor`
- All model structs: `Sendable`
- ValuationRecord: `@Model @MainActor` with `nonisolated init`
- Services (DCFCalculator, ValidationService, AuthService): `Sendable` structs
- KeychainHelper: nonisolated enum with static methods
