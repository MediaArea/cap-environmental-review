# Tools Registry


| ID | Name |
|---|---|
| `siegfried` | [Siegfried](#tool-siegfried) |
| `fido` | [FIDO](#tool-fido) |
| `mediainfo` | [MediaInfo](#tool-mediainfo) |
| `exiftool` | [ExifTool](#tool-exiftool) |
| `jhove` | [JHOVE](#tool-jhove) |
| `ffprobe` | [FFprobe](#tool-ffprobe) |
| `md5deep` | [md5deep / hashdeep](#tool-md5deep) |
| `fixity-pro` | [Fixity Pro](#tool-fixity-pro) |
| `bagit-python` | [BagIt-Python](#tool-bagit-python) |
| `bwfmetaedit` | [BWF MetaEdit](#tool-bwfmetaedit) |
| `ffmpeg` | [FFmpeg](#tool-ffmpeg) |
| `handbrake` | [HandBrake](#tool-handbrake) |
| `c2patool` | [c2patool](#tool-c2patool) |
| `c2pa-rs` | [c2pa-rs](#tool-c2pa-rs) |
| `c2pa-python` | [c2pa-python](#tool-c2pa-python) |
| `verify-contentcredentials` | [Content Credentials Verify](#tool-verify-contentcredentials) |
| `archivematica` | [Archivematica](#tool-archivematica) |
| `synthid` | [SynthID](#tool-synthid) |
| `pronom` | [PRONOM](#tool-pronom) |
| `yt-dlp` | [yt-dlp](#tool-yt-dlp) |
| `rsync` | [rsync](#tool-rsync) |

## Siegfried {#tool-siegfried}

**ID:** `siegfried`  
**Category:** Identification Tools  
**Version:** 1.11.4 (2026-01-23)  
**License:** Apache-2.0  
**Provenance Scope:** file-level  
**Provenance Durability:** n/a  
**Provenance Depth:** none  
**C2PA Support:** none  
**URL:** homepage: <https://www.itforarchivists.com/siegfried>  
**URL:** repo: <https://github.com/richardlehane/siegfried>  

Signature-based file format identification tool using PRONOM, LOC FDD, and Wikidata signatures. Outputs format identification results as JSON, CSV, or YAML. Widely used in digital preservation ingest workflows.


### TCR4CAP Comments

**Awareness:** Siegfried identifies file formats against PRONOM and FDD signatures. Siegfried has no C2PA or provenance-specific awareness beyond format identification.

**Tamper Evidence:** Siegfried performs format identification only and does not assess or verify metadata integrity or tamper-evidence.

**Binding:** No binding mechanism. Format identification is based on file signatures.

**AI Attribution:** AI attribution is out of scope.

**Substantiation:** Outputs are structured and reproducible. Format identification results are aligned with PRONOM and FDD.

**Interoperability:** Apache-2.0. Widely implemented in digipres workflows. Outputs common, open formats: JSON, CSV, YAML.

---

## FIDO {#tool-fido}

**ID:** `fido`  
**Category:** Identification Tools  
**Version:** 1.6.1 (2022-12-22)  
**License:** Apache-2.0  
**Provenance Scope:** file-level  
**Provenance Durability:** n/a  
**Provenance Depth:** none  
**C2PA Support:** none  
**URL:** <https://github.com/openpreserve/fido>  

Format Identification for Digital Objects. Python-based PRONOM signature tool from Open Preservation Foundation. Outputs PUID identifiers for identified formats.


### TCR4CAP Comments

**Awareness:** FIDO identifies file formats against PRONOM signatures. No C2PA or provenance-specific awareness beyond format identification.

**Tamper Evidence:** FIDO performs format identification only and does not assess or verify metadata integrity or tamper-evidence.

**Binding:** No binding mechanism. Format identification is based on file signatures.

**AI Attribution:** AI attribution is out of scope.

**Substantiation:** Outputs are structured and format identification results are aligned with PRONOM.

**Interoperability:** Apache-2.0. Python-based. Widely implemented in digipres workflows.

---

## MediaInfo {#tool-mediainfo}

**ID:** `mediainfo`  
**Category:** Characterization Tools  
**Version:** 26.05 (2026-05-12)  
**License:** BSD-2-Clause  
**Provenance Scope:** file-level  
**Provenance Durability:** n/a  
**Provenance Depth:** summary  
**C2PA Support:** detect-parse  
**URL:** <https://mediaarea.net/en/MediaInfo>  

Technical metadata extraction for audio and video files. As of December 2025 can detect and parse C2PA metadata in JPEG, PNG, and WAV. Outputs technical metadata as XML, JSON, HTML, or plain text. Widely used in broadcast, archives, and repository workflows.


### TCR4CAP Comments

**Awareness:** MediaInfo extracts and reports technical metadata including C2PA detection and parsing (as of December 2025). Widely used in broadcast and archive workflows.

**Tamper Evidence:** MediaInfo can detect and report C2PA manifest presence. MediaInfo does not perform cryptographic verification of C2PA signatures.

**Binding:** MediaInfo reports C2PA manifest presence and characteristics, but does not verify the cryptographic binding between manifest and asset content.

**AI Attribution:** MediaInfo can report C2PA AI attribution assertions when present and does not generate or verify them.

**Substantiation:** Outputs are structured and technical metadata reports are reproducible. Widely used as an authoritative tool in preservation workflows for identifying the technical characteristics of audiovisual files.

**Interoperability:** BSD-2-Clause. Widely implemented across broadcast, archive, and repository tools. Outputs XML, JSON, HTML, plain text.

---

## ExifTool {#tool-exiftool}

**ID:** `exiftool`  
**Category:** Characterization Tools  
**Version:** 13.59 (2026-05-27)  
**License:** GPL/Artistic  
**Provenance Scope:** file-level  
**Provenance Durability:** n/a  
**Provenance Depth:** full  
**C2PA Support:** detect-parse  
**URL:** <https://exiftool.org>  

Reads and writes metadata in image, audio, and video files. Supports EXIF, IPTC, XMP, and many other mechanisms. C2PA/JUMBF metadata can be read and structurally parsed from JPEG, PNG, TIFF, DNG, MP4, MOV, HEIF, AVIF, WAV, AVI, WebP, PDF, SVG, GIF, and ID3v2. Exiftool can parse the JUMBF hierarchy and express individual CBOR assertion fields as structured tags. C2PA JUMBF data can be deleted from writable formats. ExifTool does not write or cryptographically verify C2PA manifests.


### TCR4CAP Comments

**Awareness:** ExifTool reads and writes EXIF, IPTC, XMP, and many other mechanisms, and provides an extensive open-source structural parsing of C2PA/JUMBF content. Widely used across creative, archive, and repository workflows.

**Tamper Evidence:** ExifTool can structurally parse C2PA manifests but does not perform cryptographic verification. ExifTool can silently overwrite non-C2PA metadata without detection.

**Binding:** ExifTool parses and exposes C2PA hard-binding fields but does not verify the cryptographic binding between manifest and asset content.

**AI Attribution:** ExifTool can read and structurally parse C2PA AI attribution assertions, IPTC 2025.1 AI fields, and XMP AI attribution fields. ExifTool does not generate or verify C2PA AI attribution assertions.

**Substantiation:** Outputs are structured and metadata reports are reproducible. Widely used as an authoritative metadata extraction source.

**Interoperability:** Artistic/GPL. Widely implemented across creative, archive, and repository tools. Supports a multitude of metadata formats.

---

## JHOVE {#tool-jhove}

**ID:** `jhove`  
**Category:** Characterization Tools  
**Version:** 1.34.0 (2025-07-02)  
**License:** LGPL-2.1  
**Provenance Scope:** file-level  
**Provenance Durability:** n/a  
**Provenance Depth:** none  
**C2PA Support:** none  
**URL:** homepage: <https://jhove.openpreservation.org>  
**URL:** repo: <https://github.com/openpreserve/jhove>  

JSTOR/Harvard Object Validation Environment. Format validation and characterization for digital objects. Supports AIFF, ASCII, GIF, HTML, JPEG, JPEG 2000, PDF, TIFF, UTF-8, WAVE, and XML.


### TCR4CAP Comments

**Awareness:** JHOVE performs format validation and characterization. JHOVE has no C2PA or provenance-specific awareness beyond format validation.

**Tamper Evidence:** JHOVE performs format validation only and does not assess or verify metadata integrity or tamper-evidence.

**Binding:** No binding mechanism. Format validation is based on format structure.

**AI Attribution:** AI attribution is out of scope.

**Substantiation:** Outputs are structured and format validation results are reproducible. Widely used in digipres ingest workflows.

**Interoperability:** LGPL-2.1. Widely used in digipres ingest workflows. Outputs XML.

---

## FFprobe {#tool-ffprobe}

**ID:** `ffprobe`  
**Category:** Characterization Tools  
**Version:** 8.1.1 (2026-05-04)  
**License:** LGPL-2.1/GPL-2.0  
**Provenance Scope:** file-level  
**Provenance Durability:** n/a  
**Provenance Depth:** summary  
**C2PA Support:** none  
**URL:** <https://ffmpeg.org/ffprobe.html>  

Multimedia stream analyzer bundled with FFmpeg. Extracts technical metadata from audio/video containers and streams. Outputs JSON, XML, CSV, or plain text.


### TCR4CAP Comments

**Awareness:** FFprobe extracts technical metadata from audio, video, image, and text files. FFprobe has no C2PA or provenance-specific awareness.

**Tamper Evidence:** FFprobe reports on technical metadata and does not assess or verify metadata integrity or tamper-evidence.

**Binding:** No binding mechanism. Technical metadata reporting is based on containers and encodings.

**AI Attribution:** FFprobe can report metadata tags that may include AI attribution fields by convention. No structured AI attribution vocabulary is defined.

**Substantiation:** Outputs are structured and technical metadata reports are reproducible. Widely used in broadcast and archive workflows.

**Interoperability:** LGPL-2.1/GPL-2.0. Widely implemented across broadcast, archive, and repository tools. Outputs JSON, XML, plain text.

---

## md5deep / hashdeep {#tool-md5deep}

**ID:** `md5deep`  
**Category:** Fixity Tools  
**Version:** 4.4 (2014-01-29)  
**License:** Public Domain  
**Provenance Scope:** file-level  
**Provenance Durability:** preserves-with-action  
**Provenance Depth:** summary  
**C2PA Support:** none  
**URL:** <https://github.com/jessek/hashdeep>  

Cross-platform checksum computation and audit tool. Supports MD5, SHA-1, SHA-256, Tiger, Whirlpool. hashdeep mode supports recursive directory checksumming and audit against a known-good manifest. Also supports Digital Forensics XML for reporting on checksums and file attributes.


### TCR4CAP Comments

**Awareness:** md5deep/hashdeep computes and audits file checksums. No C2PA or provenance-specific awareness beyond fixity checking.

**Tamper Evidence:** Checksum computation and audit against a known-good manifest detects modification of any file. No signing mechanism.

**Binding:** Checksum entries bind each digest to a specific file path. No cryptographic binding between the manifest and an external identity or signing authority.

**AI Attribution:** AI attribution is out of scope.

**Substantiation:** Outputs are structured and fixity records are reproducible. Widely used in digipres transfer workflows.

**Interoperability:** Public Domain. Widely implemented across digipres, library, and archival transfer tools.

---

## Fixity Pro {#tool-fixity-pro}

**ID:** `fixity-pro`  
**Category:** Fixity Tools  
**Version:** 1.14  
**Provenance Scope:** file-level  
**Provenance Durability:** preserves-with-action  
**Provenance Depth:** summary  
**C2PA Support:** none  
**URL:** homepage: <https://fixitypro.com>  

Standalone fixity checking application. Originally created by AVPS in 2013; transferred to the Open Preservation Foundation (OPF) in September 2025. Monitors file integrity over time with scheduled checks and email reporting. Supports MD5 and SHA-256.


### TCR4CAP Comments

**Awareness:** Fixity Pro monitors file integrity over time. No C2PA or provenance-specific awareness beyond fixity checking.

**Tamper Evidence:** Scheduled fixity checks detect modification of monitored files over time. No signing mechanism.

**Binding:** Checksum entries bind each digest to a specific file path. No cryptographic binding between the manifest and an external identity or signing authority.

**AI Attribution:** AI attribution is out of scope.

**Substantiation:** Outputs are structured fixity reports with scheduled monitoring history. Supports email reporting for institutional workflows.

**Interoperability:** Maintained by OPF. Used in institutional preservation workflows.

---

## BagIt-Python {#tool-bagit-python}

**ID:** `bagit-python`  
**Category:** Fixity Tools  
**Version:** 1.9.0 (2025-06-13)  
**License:** CC0-1.0  
**Provenance Scope:** package-level  
**Provenance Durability:** preserves-with-action  
**Provenance Depth:** summary  
**C2PA Support:** none  
**URL:** <https://github.com/LibraryOfCongress/bagit-python>  

Library of Congress BagIt implementation in Python. Creates and validates BagIt packages (RFC 8493) with payload manifests. Supports MD5, SHA-1, SHA-256, SHA-512.


### TCR4CAP Comments

**Awareness:** BagIt-Python creates and validates BagIt packages. No C2PA or provenance-specific awareness beyond package fixity.

**Tamper Evidence:** Payload and tag manifest checksums detect modification of any file within the bag. No signing mechanism at the BagIt level.

**Binding:** Manifest entries bind each checksum to a specific file path within the bag. Tag manifests cover bag metadata files.

**AI Attribution:** AI attribution is out of scope.

**Substantiation:** Creates and validates structured, reproducible BagIt packages. Widely used in digipres transfer workflows.

**Interoperability:** CC0-1.0. Library of Congress reference implementation. Widely used across digipres, library, and archival transfer tools.

---

## BWF MetaEdit {#tool-bwfmetaedit}

**ID:** `bwfmetaedit`  
**Category:** Metadata Editors  
**Version:** 26.01 (2026-02-02)  
**License:** Public Domain / CC0  
**Provenance Scope:** file-level  
**Provenance Durability:** preserves-with-action  
**Provenance Depth:** summary  
**C2PA Support:** none  
**URL:** homepage: <https://mediaarea.net/BWFMetaEdit>  
**URL:** repo: <https://github.com/MediaArea/BWFMetaEdit>  

Embed, validate, and export metadata in Broadcast WAVE Format files. Supports FADGI, EBU, and BEXT chunk metadata including CodingHistory, originator, origination date/time, and UMID. GUI and CLI.


### TCR4CAP Comments

**Awareness:** BWF MetaEdit is the reference tool for BEXT chunk metadata in BWF files. Widely used in broadcast and archival audio workflows.

**Tamper Evidence:** BWF MetaEdit embeds and validates BEXT chunk metadata. BWF MetaEdit does not provide cryptographic tamper-evidence for the metadata it writes.

**Binding:** BWF MetaEdit embeds metadata directly in the BWF file structure. There is no cryptographic binding between the metadata chunks and audio content, but BWF MetaEdit can write and verify an MD5 chunk that hashes the audio content.

**AI Attribution:** BWF MetaEdit can embed CodingHistory, other BEXT fields, XMP, and other metadata that could document AI processing. No structured AI attribution vocabulary or workflow is defined.

**Substantiation:** Outputs are structured metadata in XML and CSV conforming to FADGI guidelines. Widely used as an authoritative metadata embedding tool in archival audio workflows.

**Interoperability:** Public Domain / CC0. Widely implemented across broadcast, archival, and audio tools. GUI and CLI.

---

## FFmpeg {#tool-ffmpeg}

**ID:** `ffmpeg`  
**Category:** Transcoding Tools  
**Version:** 8.1.1 (2026-05-04)  
**License:** LGPL-2.1/GPL-2.0  
**Provenance Scope:** file-level  
**Provenance Durability:** strips  
**Provenance Depth:** none  
**C2PA Support:** none-official  
**URL:** <https://ffmpeg.org>  

Open-source multimedia framework for transcoding, muxing, and processing audio and video. As of June 2026 there is no official C2PA support in the mainline codebase; however, a few ffmpeg forks (c2pa_libffmpeg_eqty) add experimental C2PA manifest embedding in MP4. FFmpeg offers substantial control over preserving metadata while transcoding.


### TCR4CAP Comments

**Awareness:** FFmpeg is a widely used open-source multimedia framework. No official C2PA support in the mainline codebase as of June 2026.

**Tamper Evidence:** FFmpeg strips most metadata by default. No cryptographic tamper-evidence for metadata it writes or preserves.

**Binding:** No cryptographic binding between metadata and media content. Metadata preservation depends on explicit command-line options.

**AI Attribution:** No structured AI attribution vocabulary. AI documentation requires explicit metadata injection via command-line options.

**Substantiation:** FFmpeg can preserve or inject metadata fields. No formal mechanism for publishing transformation history or CAP policies.

**Interoperability:** LGPL-2.1/GPL-2.0. Widely implemented across broadcast, archive, and repository tools. Supports virtually all audio/video formats.

---

## HandBrake {#tool-handbrake}

**ID:** `handbrake`  
**Category:** Transcoding Tools  
**Version:** 1.11.2 (2026-06-07)  
**License:** GPL-2.0  
**Provenance Scope:** file-level  
**Provenance Durability:** strips  
**Provenance Depth:** none  
**C2PA Support:** none  
**URL:** homepage: <https://handbrake.fr>  
**URL:** repo: <https://github.com/HandBrake/HandBrake>  

Open-source video transcoder with GUI and CLI. Removes most metadata by default during transcoding.


### TCR4CAP Comments

**Awareness:** HandBrake is a video transcoder. HandBrake has no C2PA or provenance-specific awareness.

**Tamper Evidence:** HandBrake removes most metadata by default when transcoding. No cryptographic tamper-evidence features.

**Binding:** No cryptographic binding between metadata and media content.

**AI Attribution:** AI attribution is out of scope.

**Substantiation:** No formal mechanism for publishing transformation history or CAP policies.

**Interoperability:** GPL-2.0. Widely used for video transcoding. GUI and CLI.

---

## c2patool {#tool-c2patool}

**ID:** `c2patool`  
**Category:** C2PA Tools  
**Version:** 0.26.62 (2026-06-03)  
**License:** MIT/Apache-2.0  
**Provenance Scope:** file-level  
**Provenance Durability:** preserves-with-action  
**Provenance Depth:** full  
**C2PA Support:** create-sign  
**URL:** homepage: <https://opensource.contentauthenticity.org/docs/c2patool/c2patool-index/>  
**URL:** repo: <https://github.com/contentauth/c2pa-rs>  

The official CLI tool from the Content Authenticity Initiative for reading and writing C2PA manifests. Supports JPEG, PNG, MP4, WAV, and many other formats. Reads and displays manifest content, creates and signs new manifests, verifies manifest signatures and hard binding. Built on the c2pa-rs Rust SDK. Source for c2patool was moved into the contentauth/c2pa-rs repository in December 2024.


### TCR4CAP Comments

**Awareness:** c2patool is the official CAI CLI tool in alignment with the development of the C2PA specification. Widely used as the reference implementation for C2PA manifest creation and verification.

**Tamper Evidence:** c2patool verifies C2PA manifest signatures and hard binding and detects any modification to manifest or asset content.

**Binding:** Creates and verifies C2PA hard binding (content hash) between manifest and asset content.

**AI Attribution:** Provides full support for C2PA AI attribution assertions.

**Substantiation:** c2patool creates and verifies complete C2PA manifest stores with full transformation history. Supports external trust anchors and timestamps.

**Interoperability:** MIT/Apache-2.0. Official CAI reference implementation. Supports all C2PA-defined embedding paths.

---

## c2pa-rs {#tool-c2pa-rs}

**ID:** `c2pa-rs`  
**Category:** C2PA Tools  
**Version:** 0.26.62 (2026-06-03)  
**License:** MIT/Apache-2.0  
**Provenance Scope:** file-level  
**Provenance Durability:** preserves-with-action  
**Provenance Depth:** full  
**C2PA Support:** create-sign  
**URL:** <https://github.com/contentauth/c2pa-rs>  

Official Rust SDK for the C2PA specification from the Content Authenticity Initiative. Core library underlying c2patool, c2pa-python, and many other implementations. Provides full C2PA manifest creation, signing, embedding, and verification.


### TCR4CAP Comments

**Awareness:** c2pa-rs is the official CAI Rust SDK with full C2PA specification support. c2pa-rs is the core implementation underlying the C2PA ecosystem.

**Tamper Evidence:** c2pa-rs provides full C2PA manifest signature verification and hard binding verification.

**Binding:** Creates and verifies C2PA hard binding (content hash) between manifest and asset content.

**AI Attribution:** Provides full support for C2PA AI attribution assertions.

**Substantiation:** c2pa-rs creates and verifies complete C2PA manifest stores with full transformation history. Supports external trust anchors and timestamps.

**Interoperability:** MIT/Apache-2.0. Official CAI reference library. Widely used as the foundation for C2PA implementations across languages and platforms.

---

## c2pa-python {#tool-c2pa-python}

**ID:** `c2pa-python`  
**Category:** C2PA Tools  
**Version:** 0.32.12 (2026-06-03)  
**License:** MIT/Apache-2.0  
**Provenance Scope:** file-level  
**Provenance Durability:** preserves-with-action  
**Provenance Depth:** full  
**C2PA Support:** create-sign  
**URL:** <https://github.com/contentauth/c2pa-python>  

The official Python binding for the c2pa-rs library from the Content Authenticity Initiative. Enables C2PA manifest creation, signing, embedding, and verification in Python workflows. Supports all formats and assertions supported by c2pa-rs.


### TCR4CAP Comments

**Awareness:** The official CAI Python bindings with full C2PA specification support via c2pa-rs. Enables C2PA integration in Python-based preservation and DAM workflows.

**Tamper Evidence:** Provides full C2PA manifest signature verification and hard binding verification via c2pa-rs.

**Binding:** Creates and verifies C2PA hard binding (content hash) between manifest and asset content via c2pa-rs.

**AI Attribution:** Provides full support for C2PA AI attribution assertions via c2pa-rs.

**Substantiation:** Creates and verifies complete C2PA manifest stores with full transformation history via c2pa-rs. Supports external trust anchors and timestamps.

**Interoperability:** MIT/Apache-2.0. Official CAI Python bindings. Enables C2PA integration in Python-based workflows.

---

## Content Credentials Verify {#tool-verify-contentcredentials}

**ID:** `verify-contentcredentials`  
**Category:** C2PA Tools  
**Version:** online (unknown)  
**License:** Proprietary  
**Provenance Scope:** file-level  
**Provenance Durability:** n/a  
**Provenance Depth:** full  
**C2PA Support:** verify  
**URL:** <https://contentcredentials.org/verify>  

Online C2PA manifest verification tool from the Content Authenticity Initiative. Upload a file to inspect its Content Credentials. Displays manifest assertions, signing certificate, timestamp, and hard binding status.


### TCR4CAP Comments

**Awareness:** The official CAI online verification tool. Widely used for public verification of Content Credentials.

**Tamper Evidence:** Content Credentials Verify verifies C2PA manifest signatures and reports hard binding status and detects any modification to manifest or asset content.

**Binding:** Verifies C2PA hard binding status. The online tool requires file upload.

**AI Attribution:** Displays C2PA AI attribution assertions when present.

**Substantiation:** Displays complete manifest content including assertions, signing certificate, timestamp, and provenance chain.

**Interoperability:** Proprietary, online tool. Requires file upload.

---

## Archivematica {#tool-archivematica}

**ID:** `archivematica`  
**Category:** Digital Preservation Systems  
**Version:** 1.18.0 (2025-09-26)  
**License:** AGPL-3.0  
**Provenance Scope:** package-level  
**Provenance Durability:** preserves-with-action  
**Provenance Depth:** full  
**C2PA Support:** none  
**URL:** homepage: <https://www.archivematica.org>  
**URL:** repo: <https://github.com/artefactual/archivematica>  

Open-source digital preservation system implementing the OAIS reference model. Generates PREMIS events, METS/PREMIS packages, and BagIt transfers. Integrates Siegfried, JHOVE, MediaInfo, and ExifTool for format identification and characterization. No native C2PA support as of June 2026.


### TCR4CAP Comments

**Awareness:** Archivematica implements OAIS and generates PREMIS events and METS packages. Widely used in institutional preservation workflows. No native C2PA support.

**Tamper Evidence:** Archivematica generates BagIt packages with payload manifests and PREMIS fixity events. Tamper-evidence depends on the BagIt and PREMIS layers.

**Binding:** PREMIS fixity values and BagIt manifests bind checksums to specific file states. No cryptographic binding between metadata and asset content at the C2PA level.

**AI Attribution:** No native AI attribution support. PREMIS eventDetail and eventAgent fields could document AI processing actions by convention.

**Substantiation:** Archivematica generates structured PREMIS event records and METS packages documenting the full preservation workflow. Widely supported by repository systems.

**Interoperability:** AGPL-3.0. Widely implemented in institutional preservation workflows. Integrates with DSpace, Fedora, and other repository systems.

---

## SynthID {#tool-synthid}

**ID:** `synthid`  
**Category:** Watermarking Tools  
**Version:** unknown (unknown)  
**License:** Proprietary  
**Provenance Scope:** content-level  
**Provenance Durability:** preserves  
**Provenance Depth:** summary  
**C2PA Support:** none  
**URL:** <https://deepmind.google/models/synthid/>  

SynthID is Google DeepMind's imperceptible watermarking tool for AI-generated images, audio, text, and video. Embeds watermarks directly into content pixels/samples at generation time. Detection requires access to the SynthID detection API. No C2PA support. Operates independently of the C2PA manifest store.


### TCR4CAP Comments

**Awareness:** SynthID is a published, deployed watermarking system from Google DeepMind. Widely discussed in AI provenance contexts.

**Tamper Evidence:** Imperceptible watermarks are embedded in content pixels/samples and are resistant to common image processing operations. Detection requires access to the SynthID API.

**Binding:** The watermark is embedded directly in the content signal. Binding is content-level and survives format conversion and metadata stripping.

**AI Attribution:** SynthID is purpose-built for AI-generated content attribution and embeds AI generation provenance directly in the content signal.

**Substantiation:** Watermark detection confirms AI generation provenance but does not provide a structured, auditable transformation history or external trust anchor.

**Interoperability:** Proprietary. Detection requires access to the SynthID API. No interoperability with C2PA or other open provenance standards.

---

## PRONOM {#tool-pronom}

**ID:** `pronom`  
**Category:** Metadata Standards and Registries  
**Version:** v122 (2026-01-19)  
**License:** Open Government Licence v3.0  
**Provenance Scope:** n/a  
**Provenance Durability:** n/a  
**Provenance Depth:** n/a  
**C2PA Support:** none  
**URL:** <https://www.nationalarchives.gov.uk/PRONOM/>  

National Archives UK file format registry. Provides PUID (PRONOM Unique Identifier) identifiers used by Siegfried, FIDO, DROID, and Archivematica for format identification. Maintained by The National Archives with community contributions.


### TCR4CAP Comments

**Awareness:** PRONOM is the authoritative file format registry for digital preservation. Widely used as the identification authority in institutional workflows.

**Tamper Evidence:** Tamper-evidence is out of scope.

**Binding:** Binding is out of scope.

**AI Attribution:** AI attribution is out of scope.

**Substantiation:** PRONOM provides authoritative, citable format identifiers (PUIDs) used across digipres tools and policies.

**Interoperability:** Open Government Licence. Widely implemented across digipres tools and systems. PUIDs are a de facto standard for format identification.

---

## yt-dlp {#tool-yt-dlp}

**ID:** `yt-dlp`  
**Category:** Capture and Transmission Tools  
**Version:** 2026.07.04  
**License:** Unlicense  
**Provenance Scope:** file-level  
**Provenance Durability:** strips  
**Provenance Depth:** none  
**C2PA Support:** none  
**URL:** repo: <https://github.com/yt-dlp/yt-dlp>  

yt-dlp is a command-line audio/video downloader that supports thousands of websites. It downloads media from web platforms and can embed metadata via FFmpeg post-processing. yt-dlp has no C2PA awareness and does not preserve C2PA manifests during download or re-encoding. When re-encoding is performed (e.g. format conversion or metadata embedding), embedded C2PA data generally does not survive (as per ffmpeg remuxing defaults). Direct downloads without re-encoding may preserve embedded C2PA if the source format and container are retained byte-for-byte.


### TCR4CAP Comments

**Awareness:** yt-dlp has no awareness of C2PA or Content Credentials. It downloads media files and can embed general metadata (title, uploader, upload date, description) via FFmpeg, but does not detect, parse, or preserve C2PA manifests. Source-platform metadata such as YouTube AI disclosure labels is not captured as structured CAP data.

**Tamper Evidence:** No tamper-evidence capabilities. yt-dlp does not generate or verify fixity values. Downloads are byte-for-byte when no re-encoding occurs, but re-encoding via FFmpeg strips embedded C2PA and modifies the file, breaking any existing tamper-evidence chain.

**Binding:** No binding mechanism. Metadata embedded by yt-dlp (via --embed-metadata) is written into standard metadata containers (e.g. MP4 atoms, Matroska tags) with no cryptographic binding to content. Any pre-existing C2PA hard binding is lost if re-encoding occurs.

**AI Attribution:** No AI attribution support. yt-dlp does not detect or preserve AI provenance metadata from source platforms. YouTube AI disclosure labels and C2PA AI attribution assertions are not captured.

**Substantiation:** No provenance chain preservation. yt-dlp does not record or append its own download actions to a chain of custody. The --embed-info-json option can write a sidecar JSON file with download metadata (URL, extractor, timestamp), but this is informal and not structured CAP data. The relationship between the info.json sidecar and the media file is not maintained by any binding mechanism.

**Interoperability:** Open source (Unlicense). Cross-platform. Relies on FFmpeg for post-processing, inheriting FFmpeg's format support limitations regarding C2PA preservation.

---

## rsync {#tool-rsync}

**ID:** `rsync`  
**Category:** Capture and Transmission Tools  
**Version:** 3.4.4  
**License:** GPL-3.0  
**Provenance Scope:** file-level  
**Provenance Durability:** preserves  
**Provenance Depth:** summary  
**C2PA Support:** none  
**URL:** homepage: <https://rsync.samba.org/>  
**URL:** repo: <https://github.com/RsyncProject/rsync>  

rsync is an open source file synchronization and transfer tool that copies files between systems using a delta-transfer algorithm. rsync transfers files byte-for-byte, so existing, embedded CAP metadata within file structures is preserved. However, rsync has no CAP awareness and does not verify or validate metadata after transfer. Extended attributes are preserved only with the explicit -X/--xattrs flag; the default -a archive mode does not include xattrs.


### TCR4CAP Comments

**Awareness:** rsync has no awareness of CAP metadata. It treats files as opaque byte streams. Embedded CAP data survives transfer because rsync preserves file content exactly, but rsync cannot detect, report, or validate the presence of CAP metadata. Institutions must use separate tools to verify CAP data integrity before and after transfer.

**Tamper Evidence:** rsync uses checksums internally for both its delta-transfer algorithm and its automatic post-transfer whole-file verification, but does not output or persist these checksums as a fixity record. The --checksum (-c) flag changes rsync's file comparison method from size-and-time to a 128-bit checksum, but this is for internal transfer decisions and is not reported to the user. File-level fixity must be computed separately (e.g. with bagit, md5sum, sha256sum, etc) before and after transfer to create a persistent tamper-evidence record.

**Binding:** No binding mechanism. rsync does not create or verify any binding between metadata and content. Embedded C2PA hard binding is preserved structurally (since the file is transferred byte-for-byte), but rsync cannot report whether the binding is intact. Sidecar relationships (e.g. .c2pa, .xmp, or PREMIS XML files paired with media files) are not tracked or maintained by rsync; both files must be transferred explicitly and their association managed by the institution.

**AI Attribution:** No AI attribution support. rsync does not interact with or preserve AI provenance metadata beyond preserving the file bytes that contain it.

**Substantiation:** rsync does not natively record or append transfer actions to a structured chain of custody. However, the --log-file option can log transfer actions (source, destination, filenames, timestamps, itemized changes) to a file, and --log-file-format allows customization of the log output. This log can serve as an informal provenance record documenting where files came from and when they were transferred, though it is not structured CAP data. Institutions should integrate rsync logs into formal provenance systems (e.g. PREMIS events) for transfer documentation.

**Interoperability:** Open source (GPL-3.0). Universally available on Linux, macOS, and Unix-like systems. Widely used in digital preservation workflows for file transfer and synchronization. The -aAX flag combination preserves permissions, ownership, timestamps, ACLs, and extended attributes, but awareness of these flags and their CAP implications is the institution's responsibility.

---

