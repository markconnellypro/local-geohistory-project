# Changelog

## [Unreleased]

### Added

- Bandwidth and Data Extraction section to Disclaimers.
- Changelog.
- Zenodo metadata file.

### Changed

- Host machine port set by .env instead of hardcoded in docker-compose.yaml.

### Removed

- Detail in Research Log under Government Detail.

## [1.0.1] - 2023-04-07

### Added

- Additional TSV import at initial data load to support production redirects for Event Detail.
- Database column comment for Source Detail to reflect masking of status field in Open Data.
- Folder named outpostgis to facilitate PostGIS exports.
- Windows-related and other editorial revisions to README and Dockerfiles.
- Zenodo DOI badge to README.

### Changed

- Database functions for Adjudication Detail to recognize ? in Location instead of prior abbreviation (ver).
- Reduce Child entries in Related for state and country Government Detail.
- Support application individualization through the .env file instead of hard-coded contacts and links.

### Fixed

- Database function permissions (security definer and readonly role grant) for Adjudication Detail.
- Database slug definition for Law Detail to substitute hyphens for forward slashes.
- Define database auto-incrementing sequences automatically after initial data load.
- Use text datatype instead of domain for regnal years in calendar extension (extension version 1.5 -> 1.6).

## [1.0.0] - 2023-04-02

### Added

- Public release of the Local Geohistory Project: Application repository.

[Unreleased]: https://github.com/markconnellypro/local-geohistory-project/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/markconnellypro/local-geohistory-project/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/markconnellypro/local-geohistory-project/releases/tag/v1.0.0