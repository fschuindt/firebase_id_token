# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.4.0] - 2020-05-02

### Fixed
- Rake development dependency vulnerability [CVE-2020-8130](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-8130).

### Changed
- Using Bundler 1.17.2.

### Added
- Ability to raise errors when verifying tokens.
- `FirebaseIdToken::Certificates.find!` method.
- `FirebaseIdToken::Signatures.verify!` method.
- `FirebaseIdToken::Exceptions::CertificateNotFound` exception.
- `:raise_error` option to `FirebaseIdToken::Signature.verify`.
- `CHANGELOG.md` file.

## [2.3.2] - 2020-02-15

### Fixed
- Certificate fixture not accessible when packing Gem into Rails application.

### Changed
- Bumped Bundler version to 1.14.

## [2.3.1] - 2019-08-13

### Fixed
- Certificate fixture reading issue.

### Added
- Test mode.
- Test mode documentation.

## [2.3.0] - 2018-06-18

### Changed
- Started to use [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
- Runtime dependencies versions upgraded.
- Use Redis `>= 3.3.3`.

## [2.2.0] - 2018-05-21
*Nothing tracked, release skipped.*

## [2.1.0] - 2018-04-09

### Fixed
- `FirebaseIdToken::Signature.verify` now returns `nil` for newly issued tokens.

## [2.0.0] - 2017-12-09

### Fixed
- Typo on Rake task `force_request` name.

## [1.3.0] - 2017-09-15

### Changed
- Renamed `Certificates.request_anyway` to `Certificates.request!` (`Certificates.request_anyway` was kept for backwards compatibility.

### Fixed
- Documentaiton typos.
- Initializer typos.

## [1.2.2] - 2017-04-29

### Changed
- Recommended people to use cron tasks instead of background jobs.
- Set certificates TTL based on cache-control's max-age.
- Documentation now warns about request during application start in Rails.

### Fixed
- Documentation typos.

## [1.2.1] - 2017-04-27

### Changed
- Small improvements on documentation.

## [1.2.0] - 2017-04-26

### Changed
- The Gem was marked as "ready to use".

## [1.1.0] - 2017-04-26
*Nothing tracked.*

## [1.0.0] - 2017-04-26
*Version removed.*

## [0.1.0] - 2017-04-23
*Version removed.*

[2.4.0]: https://github.com/fschuindt/firebase_id_token/compare/2.3.2...2.4.0
[2.3.2]: https://github.com/fschuindt/firebase_id_token/compare/2.3.1...2.3.2
[2.3.1]: https://github.com/fschuindt/firebase_id_token/compare/2.3.0...2.3.1
[2.3.0]: https://github.com/fschuindt/firebase_id_token/compare/2.0.0...2.3.0
[2.1.0]: https://github.com/fschuindt/firebase_id_token/compare/2.0.0...2.1.0
[2.0.0]: https://github.com/fschuindt/firebase_id_token/compare/1.3.0...2.0.0
[1.3.0]: https://github.com/fschuindt/firebase_id_token/compare/1.2.2...1.3.0
[1.2.2]: https://github.com/fschuindt/firebase_id_token/compare/1.2.1...1.2.2
[1.2.1]: https://github.com/fschuindt/firebase_id_token/compare/1.2.0...1.2.1
