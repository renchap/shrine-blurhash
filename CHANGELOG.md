# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## 0.2.2 - 2024-10-25

### Fixed

- 0.2.1 was mistakenly missing the latest commit, re-releasing with it.

## 0.2.1 - 2024-10-25

### Fixed

- Fixed processing of images with not exactly 3 bands (#14 by @renchap)

## 0.2.0 - 2024-10-22

### Breaking changes

- Minimum supported Ruby version is 3.1.0

### Fixed

- Remove alpha channel from transparent images (#13 by @bb)

## 0.1.0 - 2021-03-28

### Added

- Allow passing a proc to calculate components (#9 by @NuckChorris)
- Run tests on Ruby 3.0 and 3.1 in CI

###

## 0.0.1 - 2020-05-27

### Added

- First version!
- Multiple pixel extractors support, even if only VIPS is implemented right now
- Allows to resize the image before computing blurhash (to 100 pixels by default) for a faster computation
- Supports custom blurhash components parameter
