# Changelog

All notable changes to this project will be documented in this file.

## 1.0.0

### Added
- Initial beta release of Telegram Login Flutter package
- Support for basic Telegram OAuth flow
- Pre-built `TelegramLoginButton` widget
- Core `TelegramAuth` service class

## [1.0.1] - 2025-05-15

### Fixed
- Improved Telegram app deep-linking to open **Service Notifications**  for login confirmations.
- Fallback to main Telegram app (`tg://`) if service chat fails.
- Final fallback to `https://telegram.org` if the app is not installed.
- Removed dependency on `botId` to avoid "no account" errors.

### Changed
- Improved error handling for URL launching.
