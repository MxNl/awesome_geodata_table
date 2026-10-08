# Awesome Geodata Table <img src="man/figures/awesome_geodata_table_logo.png" align="right" height="139"/>

[![build](https://github.com/MxNl/awesome_geodata_table/actions/workflows/build.yaml/badge.svg)](https://github.com/MxNl/awesome_geodata_table/actions/workflows/build.yaml)
[![License: CC BY 4.0](https://img.shields.io/badge/license-CC%20BY%204.0-blue.svg)](https://creativecommons.org/licenses/by/4.0/)

A searchable, filterable collection of **metadata on geodatasets** for groundwater and
environmental modelling: climate forcings, hydrogeology, geology, soils, topography,
land cover and more. Each row is one parameter (variable) of a dataset, with its
spatial and temporal resolution, coverage, access, license and links.

**→ [Open the table](https://mxnl.github.io/awesome_geodata_table/)**

The table only collects metadata and links to the data providers; it does not host data.

## Using the table

- **Search** matches every word you type against parameter, dataset, tags, domain and publisher.
- **Filters** combine with AND; several values within one filter combine with OR.
  Clearing a filter or pressing **Reset** always brings back every row.
- **Spatial / temporal res. at least** keeps parameters whose *finest* available
  resolution is at least as fine as the selected value. Unknown values are never removed.
- **Covers period** keeps parameters whose temporal coverage *overlaps* the selected years.
- **▸** opens all metadata of a row. **Group by dataset** gives a dataset overview.
- **Copy link** shares the current search; **Download CSV** exports the filtered rows.

## Contributing a dataset

- Open a [*Suggest a dataset* issue](https://github.com/MxNl/awesome_geodata_table/issues/new?template=new-dataset.yml), or
- edit the CSV files in [`metadata/`](metadata) and open a pull request. The CI validates every change.

### Data model

| File | One row per | Notes |
|---|---|---|
| [`metadata/datasets.csv`](metadata/datasets.csv) | dataset | id, name, domain, resolution, coverage, access, license, links … |
| [`metadata/parameters.csv`](metadata/parameters.csv) | parameter | `dataset_id`, `parameter`, `unit` + optional overrides |
| [`metadata/schema.yaml`](metadata/schema.yaml) | – | field types, required fields and allowed vocabularies |

- Any column of `datasets.csv` may also appear in `parameters.csv`. A filled value
  overrides the dataset value for that parameter, `none` means "not applicable", and an empty cell inherits.
  `tags` in `parameters.csv` are added to the dataset tags.
- Spatial resolution is given in **metres** (`res_spatial_finest_m`, `res_spatial_coarsest_m`).
  Keep the original notation (e.g. `0.25°`, `1:250,000`) in `res_spatial_note`.
- Temporal resolution uses the classes `hourly` (≤ 1 h), `daily`, `weekly`, `monthly`, `yearly`,
  `decadal`, `multi-decadal` and `static`.
- Coverage is given in years; `coverage_end` may be `present`.
- Tags are lower case and separated by `;`.

## Building locally

Requirements: R ≥ 4.1 with the packages listed in `DESCRIPTION`, and [Quarto](https://quarto.org).

```sh
Rscript tests/testthat.R   # validate metadata + unit tests
quarto render              # writes the site to _site/
```

Browser tests (optional, need Node.js):

```sh
cd tests/e2e && npm ci && npx playwright install chromium
python3 -m http.server 8765 --directory ../../_site &
node e2e.js http://localhost:8765/
```

### Project structure

```
metadata/        datasets.csv, parameters.csv, schema.yaml   ← the content
R/               read_metadata(), validate_metadata(), agt_table(), agt_filters()
assets/          agt.js (filter panel), agt.css (styles), logo
index.qmd        the page
tests/           testthat unit tests, tests/e2e browser tests
data-raw/        one-off migration of the legacy Google Sheet export
```

All filtering runs client-side in [reactable](https://glin.github.io/reactable/), so the
site is static and hosted on GitHub Pages.

## Authors

Anne-Karin Cooke, Sandra Willkommen, Mariana Gomez-Ospina, Maximilian Nölscher – and contributors.

## License

The metadata and code are licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
The licenses of the linked datasets are listed per dataset in the table.
