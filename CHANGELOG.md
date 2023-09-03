# Changelog

## [1.1.2] - 2023-09-03

### Added

- Map labels for water on MapTiler layers.

### Changed

- Layer labels for KlokanTech layers to reference MapTiler.
- Map style to declutter smaller scale maps on MapTiler layers.
- Reorganized references to libraries and styles used to create base maps.

### Fixed

- CORS issue with CSS stylesheet preventing full screen icon from appearing on map.

### Removed

- Stamen and other obsolete map layer content.

## [1.1.1] - 2023-08-26

### Fixed

- Missing Government name on Government Detail timelapse maps for some pages that group related, sequential governments.

## [1.1.0] - 2023-07-01

### Added

- Database column comment indicating partial or full omission from open data in law.lawdescriptiondone, lawgroup.eventeffectivetype, lawgroup.lawgroupcourtname, lawgroup.lawgroupgroup, lawgroup.lawgroupplanningagency, lawgroup.lawgroupprocedure, lawgroup.lawgrouprecording, lawgroup.lawgroupsecretaryofstate, lawgroup.lawgroupsectionlead, recording.recordingrepositoryitemfrom, recording.recordingrepositoryitemto, and researchlog.event.
- Database columns geohistory.lawsectionevent.lawgroup and geohistory.researchlog.event.
- Database function changes to accommodate future mutilingual support for Government Identifier Detail.
- Database tables geohistory.lawgroup and geohistory.lawgroupsection.
- Database triggers to ensure database integrity when changes made in lawgroupsection, lawsectionevent.
- Database trigger when source inserted.
- Group to Law table under Event Detail and Event Links under Law Detail.
- Support for alternate government name information in Event Detail, and links to pages from Government Detail.
- Various accommodations for use in development version.

### Changed

- Codeigniter from 4.3.1 to 4.3.6.
- Database constraint on geohistory.metesdescription to ensure metesdescriptionacres cannot be negative.
- Database extract pg_dump and OS versions.
- Database functions to remove placeholder affected government part references when other materialized views refreshed.
- Database table geohistory.government to remove governmentclass and governmentcurrenthomerule fields and substitute with governmentcurrentform field.
- Delimiter in How Effective Date Determined in Event Detail.
- Esri Leaflet from 2.5.3 (manually modified) to 3.0.10 (forked with modifications).
- Maplibre GL JS from 1.15.3 to 3.0.0.
- Maplibre GL Leaflet from 0.0.18 to 0.0.19.
- Parcel map style in New Jersey.
- Statistics for mapped governments to omit Independent School Districts.
- Stylistic and minor changes to changelog and README.

### Fixed

- HTML validation issues in several views.
- Leaflet attribution for maps.
- Linting errors in changelog and README.
- Obsolete state GIS links.
- Parameter order for map tile display to put optional parameter last.

### Removed

- Survey Township page.
- Various database functions only used in development version.

## [1.0.2] - 2023-04-10

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

[1.1.2]: https://github.com/markconnellypro/local-geohistory-project/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/markconnellypro/local-geohistory-project/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/markconnellypro/local-geohistory-project/compare/v1.0.2...v1.1.0
[1.0.2]: https://github.com/markconnellypro/local-geohistory-project/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/markconnellypro/local-geohistory-project/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/markconnellypro/local-geohistory-project/releases/tag/v1.0.0
