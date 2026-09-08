#!/usr/bin/env bash
# bin/assemble-pdf.sh: Concatenate markdown sections into a final PDF with
# embedded metadata for provenance.

set -euo pipefail

# Configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Document order
SECTIONS=(
  "sections/00-introduction.md"
  "sections/registry_introduction.md"
  "docs/markdown/tools.md"
  "docs/markdown/formats.md"
  "docs/markdown/mechanisms.md"
  "sections/featured_tools.md"
  "sections/app1_embarc_review.md"
  "sections/app2_bwfmetaedit_review.md"
)

TMP_DIR="$ROOT_DIR/docs/tmp"
OUTPUT_DIR="$ROOT_DIR/docs"
COMBINED_MD="$TMP_DIR/_combined.md"
METADATA_YAML="$TMP_DIR/_metadata.yaml"
FINAL_PDF="$OUTPUT_DIR/cap-environmental-review.pdf"

# PDF engine: "latex" (default) or "typst"
PDF_ENGINE="latex"

# Draft mode: skip post-processing
DRAFT=false

# Bibliographic metadata
DOC_TITLE="Content Authenticity and Provenance for Audiovisual Collections"
DOC_SUBTITLE="An Environmental Review"
DOC_AUTHOR="David Rice"
DOC_DATE="August 2026"
DOC_SUBJECT="Content Authenticity and Provenance (CAP) metadata for digital audiovisual collections"
DOC_KEYWORDS="C2PA, content provenance, audiovisual preservation, FADGI, TCR4CAP, digital archives, metadata, fixity"
DOC_PUBLISHER="Federal Agencies Digital Guidelines Initiative (FADGI)"
DOC_LANGUAGE="en-US"
DOC_RIGHTS="Produced for the Library of Congress. Released under the Creative Commons CC0 1.0 Universal Public Domain Dedication (https://creativecommons.org/publicdomain/zero/1.0/)."

# Parse arguments

while [[ $# -gt 0 ]]; do
  case "$1" in
    --engine)
      PDF_ENGINE="$2"; shift 2 ;;
    --draft)
      DRAFT=true; shift ;;
    --output|-o)
      FINAL_PDF="$2"; shift 2 ;;
    *)
      echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# Dependency check
check_dep() {
  if ! command -v "$1" &>/dev/null; then
    echo "ERROR: '$1' is required but not found in PATH." >&2
    exit 1
  fi
}

check_dep pandoc
check_dep sha256sum

if [[ "$DRAFT" == false ]]; then
  check_dep exiftool
  check_dep qpdf
fi

if [[ "$PDF_ENGINE" == "typst" ]]; then
  check_dep typst
elif [[ "$PDF_ENGINE" == "latex" ]]; then
  if ! command -v pdflatex &>/dev/null && ! command -v xelatex &>/dev/null; then
    echo "ERROR: No LaTeX engine found (need pdflatex or xelatex)." >&2
    echo "       Install texlive, or use --engine typst." >&2
    exit 1
  fi
fi

# Prepare workspace
mkdir -p "$TMP_DIR" "$OUTPUT_DIR"
if [[ -z "${TMPDIR:-}" ]] || [[ ! -w "${TMPDIR}" ]]; then
  TMPDIR="$ROOT_DIR/docs/tmp"
  export TMPDIR
fi

# Build timestamp
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_EPOCH=$(date -u +"%s")

# 1. Concatenate markdown sections
echo "Assembling markdown sections..."

> "$COMBINED_MD"
for section in "${SECTIONS[@]}"; do
  filepath="$ROOT_DIR/$section"
  if [[ ! -f "$filepath" ]]; then
    echo "  WARN: $section not found, skipping." >&2
    continue
  fi
  echo "  + $section"
  cat "$filepath" >> "$COMBINED_MD"
  # Ensure blank line between sections for proper markdown parsing
  echo "" >> "$COMBINED_MD"
  echo "" >> "$COMBINED_MD"
done
if [[ ! -s "$COMBINED_MD" ]]; then
  echo "ERROR: Combined markdown is empty. No sections were found." >&2
  exit 1
fi
echo "  Combined: $(wc -l < "$COMBINED_MD") lines"

# 2. Generate YAML metadata block
echo "Generating metadata..."

# Compute SHA-256 of the combined markdown source
SOURCE_SHA256=$(sha256sum "$COMBINED_MD" | awk '{print $1}')
SOURCE_BYTES=$(wc -c < "$COMBINED_MD")

# Generate a UUID for document identification
DOC_UUID=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "unknown-$(date +%s)")

# Pre-compute YAML keywords list (avoids command substitution inside heredoc)
KEYWORDS_YAML=$(echo "$DOC_KEYWORDS" | tr ',' '\n' | sed 's/^ *//' | sed 's/^/  - /')

cat > "$METADATA_YAML" <<EOF
---
title: "${DOC_TITLE}"
subtitle: "${DOC_SUBTITLE}"
author:
  - "${DOC_AUTHOR}"
date: "${DOC_DATE}"
subject: "${DOC_SUBJECT}"
keywords:
${KEYWORDS_YAML}
description: |
  ${DOC_SUBJECT}. Prepared for the ${DOC_PUBLISHER}. This environmental review
  examines the current state of CAP-related tools, file formats, and provenance
  mechanisms for audiovisual preservation, with attention to C2PA, FADGI, and
  the forthcoming TCR4CAP framework.

_build_date: "${BUILD_DATE}"
_source_sha256: "${SOURCE_SHA256}"
_document_id: "urn:uuid:${DOC_UUID}"
_producer: "assemble-pdf.sh (pandoc + ${PDF_ENGINE})"
header-includes:
  - \usepackage[shorthands=off,english]{babel}
  - \usepackage[dvipsnames]{xcolor}
EOF

echo "  Metadata written: $(basename "$METADATA_YAML")"

# 3. Render PDF
echo "Rendering PDF via pandoc (${PDF_ENGINE})..."
PANDOC_ARGS=(--metadata-file="$METADATA_YAML" --toc --toc-depth=2 --number-sections -V geometry:margin=1in -V fontsize=11pt -V papersize:letter -V linkcolor=NavyBlue -V urlcolor=RoyalBlue)

if [[ "$PDF_ENGINE" == "typst" ]]; then
  PANDOC_ARGS+=(--pdf-engine=typst)
else
  # Use xelatex for better font handling if available, else pdflatex
  if command -v xelatex &>/dev/null; then
    PANDOC_ARGS+=(--pdf-engine=xelatex)
  else
    PANDOC_ARGS+=(--pdf-engine=pdflatex)
    # pdflatex can't use fontspec; remove font variables
    PANDOC_ARGS=("${PANDOC_ARGS[@]/-V mainfont=*/}")
    PANDOC_ARGS=("${PANDOC_ARGS[@]/-V monofont=*/}")
  fi
  PANDOC_ARGS+=(--pdf-engine-opt=--shell-escape)
fi

pandoc "$COMBINED_MD" "${PANDOC_ARGS[@]}" -o "$FINAL_PDF"
if [[ ! -f "$FINAL_PDF" ]]; then
  echo "ERROR: PDF was not generated." >&2
  exit 1
fi

PDF_SIZE=$(wc -c < "$FINAL_PDF")
echo "  PDF generated: $(basename "$FINAL_PDF") ($PDF_SIZE bytes)"

# Draft mode ends here
if [[ "$DRAFT" == true ]]; then
  echo ""
  echo "Draft PDF complete (no metadata embedding or optimization)."
  echo "  -> $FINAL_PDF"
  exit 0
fi

# 4. Embed XMP metadata with exiftool
echo "Embedding XMP metadata..."
# Core bibliographic metadata (maps to PDF Info dictionary + XMP-dc)
exiftool -overwrite_original \
  -Title="${DOC_TITLE}: ${DOC_SUBTITLE}" \
  -Author="${DOC_AUTHOR}" \
  -Subject="${DOC_SUBJECT}" \
  -Keywords="${DOC_KEYWORDS}" \
  -Creator="${DOC_AUTHOR}" \
  -Producer="assemble-pdf.sh (pandoc + ${PDF_ENGINE})" \
  -Language="${DOC_LANGUAGE}" \
  -Rights="${DOC_RIGHTS}" \
  -Publisher="${DOC_PUBLISHER}" \
  -CreateDate="${BUILD_DATE}" \
  -ModifyDate="${BUILD_DATE}" \
  "$FINAL_PDF"

# Provenance-specific XMP metadata using pdfx namespace for custom fields.
# These embed the source hash, build timestamp, and document ID directly
# into the XMP packet, making the PDF self-documenting its own provenance.
exiftool -overwrite_original \
  -XMP-pdfx:SourceHash="sha256:${SOURCE_SHA256}" \
  -XMP-pdfx:SourceBytes="${SOURCE_BYTES}" \
  -XMP-pdfx:BuildDate="${BUILD_DATE}" \
  -XMP-pdfx:BuildTool="assemble-pdf.sh" \
  -XMP-pdfx:DocumentID="urn:uuid:${DOC_UUID}" \
  -XMP-pdfx:SourceFormat="markdown" \
  -XMP-xmpMM:DocumentID="urn:uuid:${DOC_UUID}" \
  -XMP-xmpMM:InstanceID="urn:uuid:${DOC_UUID}:${BUILD_EPOCH}" \
  -XMP-dc:Format="application/pdf" \
  -XMP-dc:Identifier="urn:uuid:${DOC_UUID}" \
  "$FINAL_PDF"

echo "  XMP metadata embedded."

# 5. Optimize/linearize with qpdf
echo "Optimizing PDF..."
TEMP_OPT="${FINAL_PDF%.pdf}_opt.pdf"
qpdf --linearize --object-streams=generate "$FINAL_PDF" "$TEMP_OPT"
mv "$TEMP_OPT" "$FINAL_PDF"
echo "  Linearized."

# 6. Compute final fixity and write provenance manifest
FINAL_SHA256=$(sha256sum "$FINAL_PDF" | awk '{print $1}')
FINAL_SIZE=$(wc -c < "$FINAL_PDF")
FINAL_PAGES=$(exiftool -s3 -PageCount "$FINAL_PDF" 2>/dev/null || echo "unknown")

# Pre-compute keywords JSON array (avoids quoting issues in heredoc)
KEYWORDS_JSON=$(echo "$DOC_KEYWORDS" | tr ',' '\n' | sed 's/^ *//;s/ *$//' | sed 's/.*/"&"/' | paste -sd ',' -)

# Pre-compute sections JSON array
SECTIONS_JSON=""
for s in "${SECTIONS[@]}"; do
  if [[ -n "$SECTIONS_JSON" ]]; then
    SECTIONS_JSON+=","
  fi
  SECTIONS_JSON+="\"$s\""
done

# Write a provenance manifest sidecar
MANIFEST="${FINAL_PDF%.pdf}.manifest.json"
cat > "$MANIFEST" <<EOF
{
  "document": {
    "title": "${DOC_TITLE}: ${DOC_SUBTITLE}",
    "author": "${DOC_AUTHOR}",
    "date": "${DOC_DATE}",
    "publisher": "${DOC_PUBLISHER}",
    "language": "${DOC_LANGUAGE}",
    "rights": "${DOC_RIGHTS}"
  },
  "file": {
    "name": "$(basename "$FINAL_PDF")",
    "format": "application/pdf",
    "bytes": ${FINAL_SIZE},
    "sha256": "${FINAL_SHA256}",
    "pages": ${FINAL_PAGES:-0}
  },
  "provenance": {
    "document_id": "urn:uuid:${DOC_UUID}",
    "build_date": "${BUILD_DATE}",
    "build_tool": "assemble-pdf.sh (pandoc + ${PDF_ENGINE})",
    "source": {
      "format": "markdown",
      "sections": [
        ${SECTIONS_JSON}
      ],
      "combined_sha256": "${SOURCE_SHA256}",
      "combined_bytes": ${SOURCE_BYTES}
    },
    "embedded_xmp": {
      "dc:title": "${DOC_TITLE}: ${DOC_SUBTITLE}",
      "dc:creator": ["${DOC_AUTHOR}"],
      "dc:subject": [${KEYWORDS_JSON}],
      "dc:format": "application/pdf",
      "dc:identifier": "urn:uuid:${DOC_UUID}",
      "xmpMM:documentID": "urn:uuid:${DOC_UUID}",
      "xmpMM:instanceID": "urn:uuid:${DOC_UUID}:${BUILD_EPOCH}",
      "pdfx:sourceHash": "sha256:${SOURCE_SHA256}",
      "pdfx:buildDate": "${BUILD_DATE}",
      "pdfx:buildTool": "assemble-pdf.sh"
    }
  }
}
EOF

# Summary

echo ""
echo "============================================================"
echo " PDF Assembly Complete"
echo "============================================================"
echo ""
echo " Output:"
printf "   %-20s %s\n" "PDF:" "$FINAL_PDF"
printf "   %-20s %s\n" "Size:" "${FINAL_SIZE} bytes"
printf "   %-20s %s\n" "Pages:" "${FINAL_PAGES}"
printf "   %-20s %s\n" "SHA-256:" "${FINAL_SHA256}"
printf "   %-20s %s\n" "Manifest:" "$MANIFEST"
echo ""
echo " Embedded metadata:"
printf "   %-20s %s\n" "Title:" "${DOC_TITLE}: ${DOC_SUBTITLE}"
printf "   %-20s %s\n" "Author:" "${DOC_AUTHOR}"
printf "   %-20s %s\n" "Date:" "${DOC_DATE}"
printf "   %-20s %s\n" "Document ID:" "urn:uuid:${DOC_UUID}"
printf "   %-20s %s\n" "Build date:" "${BUILD_DATE}"
printf "   %-20s %s\n" "Source SHA-256:" "${SOURCE_SHA256}"
echo ""
echo " To verify embedded metadata:"
echo "   exiftool -a -G1 '$FINAL_PDF'"
echo ""
echo " To verify PDF fixity:"
echo "   sha256sum '$FINAL_PDF'"
echo ""
