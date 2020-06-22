# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [4.0.2] - 2018-12-04
### Added
- Ability to enable/disable registration with env var.

### Changed
- Update to taiga back 4.0.2.

## [4.0.1] - 2018-11-28
### Changed
- Update to taiga back 4.0.1 and front 4.0.0.

## [3.4.1] - 2018-08-30
### Changed
- Update to taiga 3.4.1 (front).

## [3.4.0] - 2018-08-23
### Added
- Slack integration from @anddann.

### Changed
- Update to taiga 3.4 (back and front).
- Keep SSL management from proxy with TAIGA_SSL_BY_REVERSE_PROXY.
- Improve database check script with a loop and timeout from @benyanke and @anddann.
- Upgrade base image to python 3.6
- All environment vars moved in conf.env

## [3.3.16] - 2018-08-11
### Added
- Update to taiga 3.3.16 (back).
- This CHANGELOG file and CONTRIBUTING.
- Setup HEALTHCHECK on image.
- Add themes in taiga options.

### Changed
- Move base image from python:3.5-jessie to slim-stretch.
- Nginx configurations now use snippets.
- Enable Gravatar by default.

### Fixed
- Fix docker-compose with string values as boolean.
- Allow to change hostname after container initialization.
- Allow to use ssl with events.

## [3.3.13] - 2018-07-23
### Added
- New alpine branch to provide a lighter image.
- Exclude useless files from iage with dockerignore from @jsykes.

### Changed
- Update to taiga 3.3.13 (back and front).
- Lock python to version 3.5 and postgres to version 10.4 from @jsykes.

### Fixed
- Fix external reverse proxy with https @anddann.

## [3.3.8] - 2018-06-14
### Changed
- Update to taiga 3.3.8 (back and front).
- Use default nginx package instead of external one.

## [3.3.6] - 2018-05-29
### Changed
- Update to taiga 3.3.6 (back and front).
- Now, try to migrate on each startup in case of update.
- Restore port to 8000 instead of 8001.

## [3.3.2] - 2018-05-28
### Changed
- Update to taiga 3.3.2 (back and front).
- Use gunicorn to start Django instead of using test server from @anddann.

### Fixed
- Fix some language settings from @anddann.

## 3.3.1 - 2017-09-14
### Changed
- Update to taiga 3.3.1 (back and front).

[Unreleased]: https://github.com/ajira86/docker-taiga/compare/4.0.2...HEAD
[4.0.1]: https://github.com/ajira86/docker-taiga/compare/4.0.1...4.0.2
[4.0.1]: https://github.com/ajira86/docker-taiga/compare/3.4.0...4.0.1
[3.4.0]: https://github.com/ajira86/docker-taiga/compare/3.3.16...3.4.0
[3.3.16]: https://github.com/ajira86/docker-taiga/compare/3.3.13...3.3.16
[3.3.13]: https://github.com/ajira86/docker-taiga/compare/3.3.8...3.3.13
[3.3.8]: https://github.com/ajira86/docker-taiga/compare/3.3.6...3.3.8
[3.3.6]: https://github.com/ajira86/docker-taiga/compare/3.3.2...3.3.6
[3.3.2]: https://github.com/ajira86/docker-taiga/compare/3.3.1...3.3.2
