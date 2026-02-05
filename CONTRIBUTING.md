# Contributing to iOS Boilerplate

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Code of Conduct

Please be respectful and constructive in all interactions. We're all here to build something great together.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/ios-boilerplate.git`
3. Create a branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Run tests: `⌘U` in Xcode
6. Commit your changes
7. Push to your fork
8. Open a pull request

## Development Setup

### Prerequisites

- Xcode 15.0+
- Swift 5.9+
- SwiftLint (optional but recommended): `brew install swiftlint`
- SwiftFormat (optional but recommended): `brew install swiftformat`

### Building

1. Open `Boilerplate.xcodeproj` in Xcode
2. Select the `Boilerplate` scheme
3. Build with `⌘B`

### Running Tests

- Press `⌘U` in Xcode to run all tests
- Or use the command line:
  ```bash
  xcodebuild test -scheme Boilerplate -destination 'platform=iOS Simulator,name=iPhone 15'
  ```

## Code Style

### SwiftLint

We use SwiftLint to enforce code style. Configuration is in `.swiftlint.yml`.

```bash
# Run SwiftLint
swiftlint lint

# Auto-fix some issues
swiftlint lint --fix
```

### SwiftFormat

We use SwiftFormat for consistent formatting. Configuration is in `.swiftformat`.

```bash
# Format all code
swiftformat .

# Check without modifying
swiftformat . --lint
```

### Style Guidelines

- Use `@Observable` for ViewModels (iOS 17+)
- Prefer `async/await` over completion handlers
- Use type-safe navigation with the Router pattern
- Follow the existing folder structure
- Add documentation comments for public APIs
- Keep functions focused and small
- Use meaningful variable and function names

## Pull Request Guidelines

### Before Submitting

1. **Run tests** - Ensure all tests pass
2. **Run SwiftLint** - Fix any linting issues
3. **Run SwiftFormat** - Format your code
4. **Update documentation** - If you changed APIs or added features
5. **Add tests** - For new features or bug fixes

### PR Title Format

Use a descriptive title that explains the change:

- `feat: Add user profile editing`
- `fix: Resolve navigation crash on iOS 17`
- `refactor: Simplify API client middleware`
- `docs: Update README with new setup steps`
- `test: Add unit tests for AuthViewModel`

### PR Description

Include:
- **What** - Brief description of changes
- **Why** - Motivation for the changes
- **How** - Technical approach (if complex)
- **Testing** - How you tested the changes
- **Screenshots** - For UI changes

### Example PR Description

```markdown
## What
Add pull-to-refresh functionality to the Example list view.

## Why
Users expect to be able to refresh content by pulling down on lists.
This improves the user experience and matches iOS conventions.

## How
- Added `.refreshable` modifier to the List
- Connected refresh action to ViewModel's `refresh()` method
- Added loading indicator during refresh

## Testing
- Tested on iOS 17 simulator
- Verified refresh triggers API call
- Confirmed loading state displays correctly

## Screenshots
[Before/After screenshots if applicable]
```

## Reporting Issues

### Bug Reports

Include:
- iOS version
- Xcode version
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots or logs (if applicable)

### Feature Requests

Include:
- Clear description of the feature
- Use case / motivation
- Proposed implementation (optional)

## Questions?

Feel free to open an issue for questions or reach out to the maintainers.

Thank you for contributing!
