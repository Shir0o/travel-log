# Changelog & AGENT.md Compliance Log

## [Unreleased]

### Added
- **Unit & Widget Tests**: Created comprehensive test suite in `test/all_features_test.dart` to cover all screen flows (Scrapbook, Typewriter, Evidence, Banger/Studio) and custom Brutalism widgets, achieving **97.00%** line coverage.
- **GitHub Actions CI Workflow**: Configured `.github/workflows/flutter_ci.yml` to automatically run analysis, execute tests, and enforce a minimum test coverage threshold of **90.00%** on every pull request and push to `main`.

### Fixed
- **Gradle Build Cache Compatibility**: Resolved the Gradle 9 build error caused by legacy global caching configurations in `~/.gradle/init.gradle` using a version-safe conditional.
- **Flutter TypewriterScreen Assertion Error**: Fixed a Flutter assertion error in `TypewriterScreen` (`color == null || decoration == null` inside a Container) by nesting the color property inside the BoxDecoration.
- **Tab Casing/Navigation Casing**: Fixed direct screen check in `MainShell` to be case-insensitive, resolving navigation issues from `ScrapbookScreen` dialog.

### Changed
- **Project Rebranding**: Renamed package and all references to `road_song`/`com.road_song` across Android, iOS, macOS, Windows, Linux, and Web configurations.
- **Git Remote**: Updated repository remote origin URL to `git@github.com:Shir0o/road-song.git`.

---

## Compliance Verification with `.agents/AGENTS.md`

### 1. Think Before Coding
- Researched Gradle 9 caching documentation to write a safe, backwards-compatible initialization script rather than making blind settings changes.
- Identified naming constraints (underscores vs. hyphens in Dart packages) before renaming the codebase.

### 2. Simplicity First
- Implemented minimal surgical renaming changes.
- Added direct widget test cases without creating complex scaffolding or unused mocking libraries.

### 3. Surgical Changes
- Kept original UI code intact, focusing strictly on resolving the Container decoration assertion and navigation case-sensitivity bugs.
- Cleared out the orphaned original Kotlin package folder structure (`com/vibesync/`) after relocating `MainActivity.kt`.

### 4. Goal-Driven Execution
- Maintained a clear checklist in `task.md`.
- Verified changes continuously using `flutter analyze` and `flutter test --coverage` to ensure we exceeded the 90% threshold.
