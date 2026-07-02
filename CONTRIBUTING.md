# Contributing to Travel Log

Thank you for your interest in contributing to Travel Log! This document outlines guidelines and procedures for contributing to our open-source project.

By participating, you agree to uphold our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## Getting Started

### Prerequisites

To build and run Travel Log, you will need:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- [Dart SDK](https://dart.dev/get-started) (included with Flutter)
- A configured simulator, emulator, or physical device (iOS, Android, macOS, Web, Windows, or Linux)

### Setup & Installation

1. **Fork** and **Clone** the repository:
   ```bash
   git clone git@github.com:YOUR_USERNAME/travel-log.git
   cd travel-log
   ```
2. **Fetch Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Verify Installation**:
   Ensure everything is set up correctly by running:
   ```bash
   flutter doctor
   ```

---

## Development Guidelines

### Code Style & Formatting

We follow the standard [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and enforce it through static analysis.

- **Formatting**: Always format your code before submitting a pull request:
  ```bash
  dart format .
  ```
- **Static Analysis**: Verify there are no lints or analysis warnings:
  ```bash
  flutter analyze
  ```
  Our configuration is defined in [analysis_options.yaml](analysis_options.yaml).

### Neo-Brutalist Design Aesthetics

Travel Log has a strong, vibrant, high-contrast Neo-Brutalist design language. If you are adding or modifying UI components, please adhere to these aesthetics:

- **Colors**: Use the color tokens in `BrutalTheme` (`lib/theme.dart`), such as:
  - `BrutalTheme.primary` (Neon Pink)
  - `BrutalTheme.yellow` (Brand Yellow)
  - `BrutalTheme.cyan` (Brand Cyan)
  - `BrutalTheme.inkBlack` (Thick black borders and text)
  - `BrutalTheme.backgroundLight` (Off-white textured background)
- **UI Components**: Instead of standard Material or Cupertino components, reuse or extend the custom widgets in `lib/widgets/brutal_widgets.dart`:
  - `BrutalCard`: Flat card with a solid black border and hard offset shadows. Supports rotating and overlay tape.
  - `BrutalButton`: High-contrast button with click/press animation.
  - `DymoLabel`: Label styled like a classic raised-letter label maker strip.
  - `TapeOverlay` & `GrainOverlay`: Layout details to give a messy, textured, physical scrapbook feel.

---

## Testing & Coverage

We are committed to codebase stability. Every contribution must include tests.

- **Running Tests**: Run the test suite using:
  ```bash
  flutter test
  ```
- **Checking Coverage**:
  Our CI/CD workflow requires that pull requests maintain a test coverage threshold of **at least 90%**.
  To run tests and generate a coverage report locally:
  ```bash
  flutter test --coverage
  ```
  You can inspect the coverage file generated at `coverage/lcov.info`.

---

## Contribution Workflow

### 1. Reporting Issues
- Use the **Bug Report** template to report bugs or problems.
- Use the **Feature Request** template to propose new features or UI additions.
- Make sure to check the existing issues to avoid creating duplicates.

### 2. Creating a Pull Request
1. Create a descriptive branch off of `main`:
   ```bash
   git checkout -b feature/your-awesome-feature
   # or
   git checkout -b fix/issue-name
   ```
2. Commit your changes with clear, descriptive commit messages.
3. Keep changes focused and surgical (avoid refactoring unrelated code).
4. Run tests and static analysis to make sure they pass locally.
5. Push your branch and open a Pull Request against our `main` branch.
6. Fill out the Pull Request template completely.
