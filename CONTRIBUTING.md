# Contributing to MaidMatch

First off, thank you for considering contributing to MaidMatch! It's people like you that make MaidMatch such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues list as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps which reproduce the problem**
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed after following the steps**
- **Explain which behavior you expected to see instead and why**
- **Include screenshots and animated GIFs** if possible
- **Include your Flutter version, Dart version, and OS**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a step-by-step description of the suggested enhancement**
- **Provide specific examples to demonstrate the steps**
- **Describe the current behavior** and **explain which behavior you expected to see instead**
- **Explain why this enhancement would be useful**

### Pull Requests

- Fill in the required template
- Do not include issue numbers in the PR title
- Follow the Dart/Flutter style guide
- Include screenshots and animated GIFs in your pull request whenever possible
- Document new code based on the Documentation Styleguide
- End all files with a newline
- Avoid platform-dependent code

## Development Process

1. **Fork the repo** and create your branch from `main`
2. **Make your changes** following our coding standards
3. **Test your changes** thoroughly
4. **Update documentation** if needed
5. **Commit your changes** using clear commit messages
6. **Push to your fork** and submit a pull request

## Coding Standards

### Dart/Flutter Guidelines

- Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` to check for issues
- Format code with `dart format .`
- Write meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

Examples:

```
Add Firebase Authentication
Fix OTP verification bug
Update README with setup instructions
```

### Branch Naming

- Feature branches: `feature/your-feature-name`
- Bug fixes: `fix/bug-description`
- Documentation: `docs/description`
- Refactoring: `refactor/description`

## Project Structure

```
lib/
├── data/         # Data models and dummy data
├── models/       # Data classes
├── screens/      # UI screens
├── services/     # Business logic and API services
├── widgets/      # Reusable widgets
└── main.dart     # Entry point
```

## Testing

- Write tests for new features
- Ensure all tests pass before submitting PR
- Test on both Android and iOS if possible
- Test with different screen sizes

Run tests:

```bash
flutter test
```

## Firebase Setup for Contributors

1. Create your own Firebase project
2. Enable Phone Authentication
3. Download your own `google-services.json`
4. Add SHA keys from your debug keystore
5. Never commit Firebase configuration files

## Style Guide

### Widgets

- Use `const` constructors where possible
- Extract complex widgets into separate files
- Use meaningful widget names
- Keep widget build methods clean

### State Management

- Use StatefulWidget for local state
- Consider Provider/Riverpod for complex state
- Keep business logic in service classes

### Async Code

- Use async/await for asynchronous operations
- Handle errors with try-catch
- Show loading indicators during async operations
- Provide user feedback for all actions

## Documentation

- Update README.md for user-facing changes
- Update technical documentation for code changes
- Add inline comments for complex logic
- Include examples in documentation

## Questions?

Feel free to create an issue with the `question` label if you have any questions about contributing.

Thank you for contributing to MaidMatch! 🎉
