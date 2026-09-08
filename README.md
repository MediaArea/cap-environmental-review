# Content Authenticity and Provenance for Audiovisual Collections: An Environmental Review

This repository contains the registries, documentation sources, and build tooling for the FADGI-sponsored environmental review of Content Authenticity and Provenance (CAP) for digital audiovisual collections, prepared for the Library of Congress by David Rice (August 2026).

The underlying review data is maintained as XML registries and built into HTML tables and a full PDF report via the scripts in `bin/`.

## Report

The full report is available in two expressions.

Here is a full PDF of the entire review: [docs/cap-environmental-review.pdf](docs/cap-environmental-review.pdf)

Or see the links below to navigate an HTML-rendetion of the review.
### Sections

| Section | Source | HTML |
|---|---|---|
| 1. Introduction | [sections/00-introduction.md](sections/00-introduction.md) | [docs/html/00-introduction.html](docs/html/00-introduction.html) |
| 2. Registry Reference | [sections/registry_introduction.md](sections/registry_introduction.md) | [docs/html/registry_introduction.html](docs/html/registry_introduction.html) |
| 3. Tools Registry | [docs/markdown/tools.md](docs/markdown/tools.md) | [docs/tools.html](docs/tools.html) |
| 4. Formats Registry | [docs/markdown/formats.md](docs/markdown/formats.md) | [docs/formats.html](docs/formats.html) |
| 5. Mechanisms Registry | [docs/markdown/mechanisms.md](docs/markdown/mechanisms.md) | [docs/mechanisms.html](docs/mechanisms.html) |
| 6. Featured Tools | [sections/featured_tools.md](sections/featured_tools.md) | [docs/html/featured_tools.html](docs/html/featured_tools.html) |
| 7. Appendix: embARC Review | [sections/app1_embarc_review.md](sections/app1_embarc_review.md) | [docs/html/app1_embarc_review.html](docs/html/app1_embarc_review.html) |
| 8. Appendix: BWF MetaEdit Review | [sections/app2_bwfmetaedit_review.md](sections/app2_bwfmetaedit_review.md) | [docs/html/app2_bwfmetaedit_review.html](docs/html/app2_bwfmetaedit_review.html) |

### Registry tables

Browsable, sortable HTML tables generated directly from the registries:

- [Tools registry](docs/tools.html)
- [Formats registry](docs/formats.html)
- [Mechanisms registry](docs/mechanisms.html)

## Repository structure

```
registries/       Source data for each registry (XML)
  tools.xml         Open source tools assessed for CAP capabilities
  formats.xml       Audiovisual and CAP-metadata formats
  mechanisms.xml    Provenance mechanisms and specifications
sections/         Narrative sections of the report (Markdown)
bin/              Build scripts
  build-docs.sh       Convert XML registries to HTML tables and Markdown sections
  assemble-pdf.sh     Concatenate sections into the final PDF with embedded
                      XMP provenance metadata and linearization
  exiftool_config     User-defined XMP-pdfx tags for provenance embedding
docs/             Build outputs
  *.html             Interactive HTML registry tables
  markdown/*.md      Markdown registry sections (PDF assembly input)
  cap-environmental-review.pdf
  cap-environmental-review.manifest.json
```

Updates should be made once in the XML and propagated to each output by the build scripts. Direct updates directly on any PDF or HTML file in this repository is not intended.

## Building

Requirements: bash, [xmlstarlet](http://xmlstar.sourceforge.net/),
[pandoc](https://pandoc.org/) with a LaTeX engine (xelatex or lualatex),
[exiftool](https://exiftool.org/), and [qpdf](https://qpdf.sourceforge.io/).

To regenerate the HTML tables and Markdown sections from the registries:

```
bin/build-docs.sh
```

To assemble the full report, run `build-docs.sh` first, then:

```
bin/assemble-pdf.sh
```

`assemble-pdf.sh` concatenates the narrative sections with the generated registry sections into a single PDF. The build is inspired by the methodology used in the IETF Cellar Working Group for standards documents for Matroska and FFV1 with normative data kept in a structured source form and rendered into presentation formats.

## TCR4CAP

The registries evaluate each entry against criteria aligned with FADGI's [Tiered Community Recommendations for Content Authenticity and Provenance](https://www.digitizationguidelines.gov/guidelines/tcr4cap/FADGI-TCR4CAP-v01-PublicCommentDraft.pdf) (TCR4CAP).

## License

Released under the [Creative Commons CC0 1.0 Universal Public Domain Dedication](https://creativecommons.org/publicdomain/zero/1.0/).
