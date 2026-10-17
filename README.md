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

- **Quick start** chips (*Recharge modelling*, *Aquifer properties*, *Climate forcing*, *ML predictors*,
  *Groundwater monitoring*, *Crop types*, *Germany*) apply a ready-made search; click again to clear it.
- **Search** matches every word you type against parameter, dataset, variable, tags, domain and publisher.
  English and German give **the same results**: a bilingual dictionary maps both to one concept
  (*Niederschlag* = *precipitation*, *Grundwasserstände* = *groundwater levels*, *DWD* = *Deutscher Wetterdienst*).
  Case, umlauts (*Dürre* = *Duerre*) and inflections are ignored; words outside the dictionary match literally.
- **Publisher** shows the institution behind each dataset; the Publisher filter lists all datasets of one institution.
- **Variable** puts comparable parameters of different datasets side by side, e.g. every precipitation product.
- **Filters** combine with AND; several values within one filter combine with OR.
  Clearing a filter or pressing **Reset** always brings back every row.
- **Spatial / temporal res. at least** keeps parameters whose *finest* available
  resolution is at least as fine as the selected value. Unknown values are never removed.
- **Covers period** keeps parameters whose temporal coverage *overlaps* the selected years.
- **Study area**: type a latitude/longitude or click **Map** and pick a point. Only datasets whose extent
  covers the point remain.
- **License** filters by licence class: *open* (any use incl. commercial, with attribution), *non-commercial*,
  *custom terms* or *unknown*.
- **▸** opens all metadata of a row, a map of the dataset's extent and, where available,
  a copy-ready R / Python access snippet. **Group by dataset** gives a dataset overview.
- **Shortlist**: tick rows to collect them across searches (kept in your browser). The shortlist bar
  downloads them as CSV, copies BibTeX citations (fetched from the DOIs) or shows only the shortlist.
- **Copy link** shares the current search; **Download CSV** exports the filtered rows.

## Contributing a dataset

- Open a [*Suggest a dataset* issue](https://github.com/MxNl/awesome_geodata_table/issues/new?template=new-dataset.yml), or
- edit the CSV files in [`metadata/`](metadata) and open a pull request. The CI validates every change.

### Data model

| File | One row per | Notes |
|---|---|---|
| [`metadata/datasets.csv`](metadata/datasets.csv) | dataset | id, name, domain, resolution, coverage, access, license, links … |
| [`metadata/parameters.csv`](metadata/parameters.csv) | parameter | `dataset_id`, `parameter`, `unit`, `variable` + optional overrides |
| [`metadata/schema.yaml`](metadata/schema.yaml) | – | field types, vocabularies (incl. standard variables), regions, quick-start presets |
| [`metadata/dictionary.yaml`](metadata/dictionary.yaml) | search concept | English and German terms that return the same search results |
| [`metadata/snippets/`](metadata/snippets) | dataset | optional `<id>.R` / `<id>.py` access examples shown in the row details |

- Any column of `datasets.csv` may also appear in `parameters.csv`. A filled value
  overrides the dataset value for that parameter, `none` means "not applicable", and an empty cell inherits.
  `tags` in `parameters.csv` are added to the dataset tags.
- Spatial resolution is given in **metres** (`res_spatial_finest_m`, `res_spatial_coarsest_m`).
  Keep the original notation (e.g. `0.25°`, `1:250,000`) in `res_spatial_note`.
- Temporal resolution uses the classes `hourly` (≤ 1 h), `daily`, `weekly`, `monthly`, `yearly`,
  `decadal`, `multi-decadal` and `static`.
- Coverage is given in years; `coverage_end` may be `present`.
- Tags are lower case and separated by `;`.
- `variable` assigns each parameter to a standard variable from the schema, so it can be compared across datasets.
- `license_class` is `open`, `non-commercial`, `custom terms` or `unknown`.
- `publisher` is the institution that maintains the data (not the journal of the paper);
  `publisher_short` (e.g. *JRC*, *DWD*) is shown in the Publisher column.
- New words in names or tags? Add English and German terms to `dictionary.yaml` so both languages find them.
- The study-area filter uses `bbox_west/south/east/north` (degrees). Leave them empty when the extent equals the
  region in `coverage_spatial` (boxes in `schema.yaml` → `regions`).
- Set `last_verified` (YYYY-MM-DD) whenever you check an entry against the provider's page.
- Snippets must run without changes apart from credentials; please keep them short and use a small example area.

### Link check

A weekly workflow extracts every download, documentation and DOI link
([`tests/extract_links.py`](tests/extract_links.py)), checks them with
[lychee](https://github.com/lycheeverse/lychee) and keeps one issue labelled *broken links* up to date;
the issue is closed automatically when all links work again. Publishers that block automated
requests (HTTP 403) count as working; hosts that cannot be checked at all are excluded in [`lychee.toml`](lychee.toml).

For a closer look, `node tests/e2e/linkcheck.js` opens every link in a real browser and also reports
"soft 404s" – pages that load but say *not found* or redirect to a home or news page.

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
metadata/        datasets.csv, parameters.csv, schema.yaml, snippets/   ← the content
R/               read_metadata(), validate_metadata(), agt_table(), agt_filters()
assets/          agt.js (filter panel), agt.css (styles), logo
index.qmd        the page
tests/           testthat unit tests, tests/e2e browser tests
data-raw/        one-off scripts: legacy migration, variable assignment
```

All filtering runs client-side in [reactable](https://glin.github.io/reactable/), so the
site is static and hosted on GitHub Pages.

## Authors

Anne-Karin Cooke, Sandra Willkommen, Mariana Gomez-Ospina, Maximilian Nölscher – and contributors.

## License

The metadata and code are licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
The licenses of the linked datasets are listed per dataset in the table.
