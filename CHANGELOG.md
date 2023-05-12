# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Nothing.

## [3.0.0] - 2023-04-11

### Added
- CI testing using GitHub Actions.
- Explains on `README.md` about the behavior of `verify` on expired tokens. [Details here](https://github.com/fschuindt/firebase_id_token/issues/29).
- Warns about the poorly synchronized clocks issue with the token's `iat`. [Details here](https://github.com/fschuindt/firebase_id_token/issues/21#issuecomment-623133926).
- Gives better examples when testing. [Details here](https://github.com/fschuindt/firebase_id_token/pull/38).
- Created a `.ruby-version` file.
- Added ActiveSupport as dependency for `Time.current`.
- SimpleCov JSON formatter and `json` as dependency.

### Changed
- It won't default to `Redis.new` anymore. You must now provide Redis details during configuration. [Details here](https://github.com/fschuindt/firebase_id_token/issues/30).
- Upgraded Redis to 5.0.6.
- Upgraded Redis Namespace to 1.10.
- Upgraded HTTParty to 0.21.0.
- Upgraded JWT to 2.7.
- Upgraded [Dev] Ruby to 3.2.2.
- Upgraded [Dev] Bundler to 2.4.13.
- Upgraded [Dev] Rake to 13.0.6.
- Upgraded [Dev] RSpec to 3.12.
- Upgraded [Dev] Redcarpet to 3.6.
- Upgraded [Dev] Simplecov to 0.22.0.
- Upgraded [Dev] Pry to 0.14.2.

### Fixed
- Code Climate test coverage report.

### Removed
- Travis CI badge.

## [2.5.2] - 2023-04-09

### Fixed
- [CWE-472](https://github.com/fschuindt/firebase_id_token/pull/41).

## [2.5.1] - 2022-08-15

### Fixed
- "[New caching doesn't honor request! calls](https://github.com/fschuindt/firebase_id_token/issues/35)", by reverting "[Caching certificates on memory.](https://github.com/fschuindt/firebase_id_token/pull/33)", PR #33.

## [2.5.0] - 2022-04-13

### Fixed
- Local Code Execution through Argument Injection via dash leading git url parameter in Gemfile [CVE-2021-43809](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-43809).
- Dependency Confusion in Bundler [CVE-2020-36327](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-36327).
- Insecure path handling in Bundler [CVE-2019-3881](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-3881).

### Changed
- Using Bundler 2.3.11.
- Using `Time.current` instead of `Time.now` to work with timezones [PR 34](https://github.com/fschuindt/firebase_id_token/pull/34).
- Caching certificates on memory using `Thread` to avoid unnecessary calls into Redis [PR 33](https://github.com/fschuindt/firebase_id_token/pull/33).

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

[3.0.0]: https://github.com/fschuindt/firebase_id_token/compare/2.5.2...3.0.0
[2.5.2]: https://github.com/fschuindt/firebase_id_token/compare/2.5.1...2.5.2
[2.5.1]: https://github.com/fschuindt/firebase_id_token/compare/2.5.0...2.5.1
[2.5.0]: https://github.com/fschuindt/firebase_id_token/compare/2.4.0...2.5.0
[2.4.0]: https://github.com/fschuindt/firebase_id_token/compare/2.3.2...2.4.0
[2.3.2]: https://github.com/fschuindt/firebase_id_token/compare/2.3.1...2.3.2
[2.3.1]: https://github.com/fschuindt/firebase_id_token/compare/2.3.0...2.3.1
[2.3.0]: https://github.com/fschuindt/firebase_id_token/compare/2.0.0...2.3.0
[2.1.0]: https://github.com/fschuindt/firebase_id_token/compare/2.0.0...2.1.0
[2.0.0]: https://github.com/fschuindt/firebase_id_token/compare/1.3.0...2.0.0
[1.3.0]: https://github.com/fschuindt/firebase_id_token/compare/1.2.2...1.3.0
[1.2.2]: https://github.com/fschuindt/firebase_id_token/compare/1.2.1...1.2.2
[1.2.1]: https://github.com/fschuindt/firebase_id_token/compare/1.2.0...1.2.1
