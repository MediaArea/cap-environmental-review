# Mechanisms Registry


| ID | Name |
|---|---|
| `flac-features` | [FLAC Specific Integrity Features](#mechanism-flac-features) |
| `bwf-features` | [BWF Specific Features (BEXT Chunk)](#mechanism-bwf-features) |
| `jpeg-features` | [JPEG Specific Features (APP Segments)](#mechanism-jpeg-features) |
| `png-features` | [PNG Specific Features (Chunks)](#mechanism-png-features) |
| `tiff-features` | [TIFF Specific Features (IFD Tags)](#mechanism-tiff-features) |
| `mp4-features` | [MP4 / ISOBMFF Specific Features (Atoms)](#mechanism-mp4-features) |
| `mkv-features` | [Matroska Specific Features (EBML Tags, CRC-32, and Attachments)](#mechanism-mkv-features) |
| `vorbis-comment` | [Vorbis Comment](#mechanism-vorbis-comment) |
| `id3-geob-c2pa` | [ID3 General Encapsulated Object (GEOB) — C2PA](#mechanism-id3-geob-c2pa) |
| `bwf-bext` | [BWF BEXT Chunk](#mechanism-bwf-bext) |
| `bwf-info` | [BWF LIST-INFO Chunk](#mechanism-bwf-info) |
| `bwf-xml` | [BWF XML Chunks (aXML / iXML)](#mechanism-bwf-xml) |
| `bwf-md5` | [BWF Audio-Data MD5 Checksum](#mechanism-bwf-md5) |
| `bwf-c2pa` | [BWF C2PA Chunk](#mechanism-bwf-c2pa) |
| `xmp-embedded` | [XMP Embedded Metadata](#mechanism-xmp-embedded) |
| `exif-embedded` | [EXIF Embedded Metadata](#mechanism-exif-embedded) |
| `iptc-photo` | [IPTC Photo Metadata](#mechanism-iptc-photo) |
| `jumbf-c2pa` | [JUMBF C2PA Manifest Store (Embedded)](#mechanism-jumbf-c2pa) |
| `sidecar-c2pa` | [C2PA Sidecar Manifest](#mechanism-sidecar-c2pa) |
| `sidecar-premis` | [PREMIS Sidecar / Embedded Event Record](#mechanism-sidecar-premis) |
| `bagit-features` | [BagIt Package Fixity](#mechanism-bagit-features) |

## FLAC Specific Integrity Features

**ID:** `flac-features`  
**Type:** format-specific  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | The STREAMINFO block is embedded at a fixed offset in the file and can be overwritten in place without re-encoding the audio stream. Its field values are derived from the audio stream at encode time; overwriting them without re-encoding produces a file whose metadata no longer accurately describes the audio frames. |
| Content-level | fixed | The MD5 signature of unencoded audio and per-frame CRC values are computed at encode time and are fixed for the lifetime of the file unless the audio stream is re-encoded. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | checksum | MD5 signature of unencoded PCM audio stored in STREAMINFO; CRC-8 per frame header and CRC-16 per frame footer. Recomputable by any conformant FLAC decoder (e.g. flac --test, ffmpeg). |
| Metadata integrity | none | No integrity mechanism covers FLAC metadata blocks (Vorbis Comment, ID3, GEOB, PICTURE). Metadata can be altered without affecting the audio-data checksums. |
| Chain of custody | none | No provenance chain or signing mechanism in the base FLAC format specification. |

**FDD References:**  
- [FDD000198](https://www.loc.gov/preservation/digital/formats/fdd/fdd000198.shtml) (full: )  

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `MD5 signature` | media-integrity | Stored in STREAMINFO block; MD5 of unencoded raw PCM audio data. |
| `CRC-8` | media-integrity | Per audio frame header; covers frame header bytes up to but not including the CRC byte itself. |
| `CRC-16` | media-integrity | Per audio frame footer; covers encoded frame data. |

FLAC encodes integrity data into the bitstream as defined in RFC 9639. The STREAMINFO metadata block stores an MD5 signature of the unencoded (raw PCM) audio data. Each audio frame header carries a CRC-8 and each frame footer carries a CRC-16 of the encoded frame. These values are computed at the time of encoding and cover audio data only and do not cover any metadata blocks.


### TCR4CAP Comments

**Awareness:** STREAMINFO MD5 and per-frame CRCs are defined in RFC 9639 and are present in all conformant FLAC files. These fields are not mapped to CAP vocabularies in any current CAP framework or policy document.

**Tamper Evidence:** Any modification to the audio bitstream would produce a different MD5 or CRC value during verification, detectable by recomputing against the stored values. Metadata blocks are not covered.

**Binding:** The MD5 is computed over the unencoded audio content at the time of encoding and stored in the same file. No mechanism links the MD5 to an external identity or signing authority.

**AI Attribution:** No fields in the FLAC format specification address AI generation, training, or processing provenance.

**Substantiation:** No fields in the FLAC format specification link to external policies, transformation histories, or rights statements.

**Interoperability:** Defined in RFC 9639 (IETF). Implemented by all conformant FLAC encoders and decoders. Verifiable by flac --test, ffmpeg, and any FLAC-capable tool.

---

## BWF Specific Features (BEXT Chunk)

**ID:** `bwf-features`  
**Type:** format-specific  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | The BEXT chunk can be written or updated without re-encoding the audio data. |
| Content-level | append | CodingHistory is conventionally appended on each processing step; other BEXT fields are overwritten on write. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | none | No included audio-data integrity mechanism in the BWF/BEXT specification itself. Audio-data MD5 is a tool-level addition (see bwf-md5 mechanism). |
| Metadata integrity | none | BEXT fields have no integrity protection; any field can be overwritten without detection. |
| Chain of custody | none | No signing or provenance chain mechanism in the BWF/BEXT specification. CodingHistory is a conventional append-only log with no enforcement. |

**FDD References:**  
- [FDD000356](https://www.loc.gov/preservation/digital/formats/fdd/fdd000356.shtml) (full: )  
- [FDD000357](https://www.loc.gov/preservation/digital/formats/fdd/fdd000357.shtml) (full: )  

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `Originator` | actor-identity | Name of the originating organization; 32 bytes. |
| `OriginatorReference` | asset-identity | Unique identifier assigned by the originator; 32 bytes. |
| `OriginationDate` | creation-datetime | Date of origination in YYYY-MM-DD format. |
| `OriginationTime` | creation-datetime | Time of origination in HH-MM-SS format. |
| `CodingHistory` | transformation-history | Free-text log of processing steps; conventionally appended on each encode or transfer. |

The Broadcast Extension (BEXT) chunk is defined in EBU Tech 3285 and carries originator identity, originator reference, origination date and time, time reference (sample offset), UMID, loudness values, and a CodingHistory field documenting the processing chain. BEXT is the primary provenance carrier in BWF files. Fields can be silently overwritten; changes are not detectable without an external fixity record or audio-data MD5 comparison.


### TCR4CAP Comments

**Awareness:** BEXT fields are defined in EBU Tech 3285 and are present in all conformant BWF files. Originator, OriginatorReference, OriginationDate/Time, and CodingHistory are recognized provenance fields in broadcast and archival audio workflows. FADGI and EBU publish guidelines for consistent field use.

**Tamper Evidence:** BEXT fields have no integrity protection. Any field can be overwritten without detection. CodingHistory is appended by convention; no mechanism enforces append-only behavior or detects deletion of history entries.

**Binding:** BEXT is embedded in the RIFF container alongside the audio data. No cryptographic mechanism links BEXT field values to the audio bitstream.

**AI Attribution:** No fields in the BEXT specification address AI generation, training, or processing provenance. CodingHistory is a free-text field that could carry AI processing notes by convention.

**Substantiation:** CodingHistory documents processing steps in a structured free-text format. UMID provides a globally unique material identifier. No mechanism links BEXT fields to external policies or trust anchors.

**Interoperability:** Defined in EBU Tech 3285. Implemented across broadcast and archival audio tools. FADGI and EBU publish open guidelines for field use.

---

## JPEG Specific Features (APP Segments)

**ID:** `jpeg-features`  
**Type:** format-specific  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | APP segments can be written or replaced without re-encoding the image data. |
| Content-level | overwrite | Individual APP segment contents are replaced on write; C2PA APP11 is append-only at the manifest store level. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | none | No image-data integrity mechanism in the base JPEG/JFIF specification. |
| Metadata integrity | none | APP segments have no integrity protection in the base specification; segments can be added, removed, or replaced without detection. |
| Chain of custody | signed | C2PA manifest store in APP11 provides cryptographic signing and hard binding to image content when implemented. |

**FDD References:**  
- [FDD000017](https://www.loc.gov/preservation/digital/formats/fdd/fdd000017.shtml) (full: )  
- [FDD000018](https://www.loc.gov/preservation/digital/formats/fdd/fdd000018.shtml) (full: )  
- [FDD000147](https://www.loc.gov/preservation/digital/formats/fdd/fdd000147.shtml) (full: )  

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `APP1 (0xFFE1) — EXIF` | technical-provenance | Carries EXIF IFD structure with capture device, settings, GPS, and datetime fields. |
| `APP1 (0xFFE1) — XMP` | provenance-chain | Carries XMP RDF/XML packet including xmpMM:History, xmpMM:DerivedFrom, and IPTC AI fields. |
| `APP13 (0xFFED) — IPTC-IIM` | actor-identity | Carries IPTC Information Interchange Model fields including creator and rights. |
| `APP11 (0xFFEB) — C2PA` | provenance-chain | Carries C2PA manifest store in JUMBF container; multiple sequential APP11 segments used for large manifests. |

JPEG defines a segmented binary structure with APP marker segments for metadata. APP1 carries EXIF and XMP; APP13 carries IPTC-IIM; APP11 carries C2PA manifest stores in a JUMBF container. These are intrinsic features of the JPEG/JFIF specification.


### TCR4CAP Comments

**Awareness:** APP segment structure is defined in ISO/IEC 10918. APP11 C2PA embedding is defined in the C2PA Technical Specification Appendix A. APP1 EXIF, XMP, and APP13 IPTC-IIM are widely implemented across image tools.

**Tamper Evidence:** APP segments can be added, removed, or replaced without detection in the base format. C2PA APP11 provides cryptographic tamper-evidence when present; any modification to the signed content invalidates the manifest signature.

**Binding:** C2PA APP11 provides hard binding: the manifest contains a hash of the image content, cryptographically linking the manifest to the specific image bitstream at signing time. EXIF and XMP are structurally embedded but not cryptographically bound.

**AI Attribution:** C2PA AI attribution assertions (c2pa.ai.generatedWith, training data references) are carried in APP11 when present. IPTC 2025.1 AI fields are carried in XMP via APP1.

**Substantiation:** C2PA manifest store in APP11 preserves transformation history with external trust anchor support. XMP xmpMM:History and IPTC fields provide additional descriptive provenance.

**Interoperability:** JPEG/JFIF is defined in ISO/IEC 10918 and widely implemented. APP11 C2PA is supported by c2patool and c2pa-rs reference implementations.

---

## PNG Specific Features (Chunks)

**ID:** `png-features`  
**Type:** format-specific  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | PNG chunks can be added, replaced, or removed without re-encoding the image data. |
| Content-level | overwrite | Metadata chunks are replaced on write; caBX C2PA chunk is append-only at the manifest store level. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | checksum | CRC-32 per chunk covers each chunk's type and data fields. Detects accidental corruption of individual chunks including image data chunks. |
| Metadata integrity | checksum | CRC-32 covers metadata chunks (tEXt, iTXt, eXIf, caBX) as well as image data chunks. Does not detect intentional replacement of a chunk with a recalculated CRC. |
| Chain of custody | signed | C2PA manifest store in caBX chunk provides cryptographic signing and hard binding to image content when implemented. |

**FDD References:**  
- [FDD000153](https://www.loc.gov/preservation/digital/formats/fdd/fdd000153.shtml) (full: )  

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `caBX chunk` | provenance-chain | Carries C2PA manifest store in JUMBF container. |
| `eXIf chunk` | technical-provenance | Carries EXIF IFD structure with capture device, settings, and datetime fields. |
| `iTXt chunk (XMP)` | provenance-chain | Carries XMP RDF/XML packet including xmpMM:History, xmpMM:DerivedFrom, and IPTC AI fields. |
| `CRC-32 (per chunk)` | media-integrity | 32-bit cyclic redundancy check covering each chunk's type and data. |

PNG defines a chunk-based binary structure. The custom caBX chunk carries C2PA manifest stores. The iTXt chunk carries XMP metadata. EXIF data is carried in an eXIf chunk. PNG includes a CRC-32 per chunk for structural integrity. These are intrinsic features of the PNG specification (ISO/IEC 15948).


### TCR4CAP Comments

**Awareness:** PNG chunk structure is defined in ISO/IEC 15948. caBX C2PA embedding is defined in the C2PA Technical Specification. Per-chunk CRC-32 is implemented by all conformant PNG encoders and decoders.

**Tamper Evidence:** Per-chunk CRC-32 detects accidental corruption of any chunk. C2PA caBX provides cryptographic tamper-evidence when present. CRC-32 does not detect intentional replacement of a chunk with a recalculated CRC.

**Binding:** C2PA caBX provides hard binding: the manifest contains a hash of the image content. Per-chunk CRC-32 binds each chunk's integrity check to its content but is not a cryptographic signature.

**AI Attribution:** C2PA AI attribution assertions are carried in caBX when present. IPTC 2025.1 AI fields are carried in XMP via iTXt.

**Substantiation:** C2PA manifest store in caBX preserves transformation history. XMP in iTXt provides additional descriptive provenance.

**Interoperability:** PNG is defined in ISO/IEC 15948 and widely implemented. caBX C2PA is supported by c2patool and c2pa-rs reference implementations.

---

## TIFF Specific Features (IFD Tags)

**ID:** `tiff-features`  
**Type:** format-specific  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | IFD tags can be written or updated without re-encoding the image data. |
| Content-level | overwrite | Tag values are replaced on write. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | none | No image-data integrity mechanism in the TIFF 6.0 specification. |
| Metadata integrity | none | IFD tags have no integrity protection; any tag can be overwritten without detection. |
| Chain of custody | none | No signing or provenance chain mechanism in the TIFF 6.0 specification. No C2PA embedding defined. |

**FDD References:**  
- [FDD000022](https://www.loc.gov/preservation/digital/formats/fdd/fdd000022.shtml) (full: )  
- [FDD000145](https://www.loc.gov/preservation/digital/formats/fdd/fdd000145.shtml) (full: )  

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `Tag 306 (DateTime)` | creation-datetime | Date and time of image creation in YYYY:MM:DD HH:MM:SS format. |
| `Tag 271 (Make) / Tag 272 (Model)` | actor-identity | Camera manufacturer and model name. |
| `Tag 700 (XMP)` | provenance-chain | XMP RDF/XML packet; carries xmpMM:History, xmpMM:DerivedFrom, IPTC AI fields, and other provenance vocabularies. |
| `Tag 33723 (IPTC-IIM)` | actor-identity | IPTC Information Interchange Model binary data block. |
| `SubIFD (EXIF)` | technical-provenance | EXIF IFD structure with capture device, settings, and GPS fields. |

TIFF uses an Image File Directory (IFD) tag structure to carry metadata. EXIF metadata is carried in a SubIFD; XMP is carried in tag 700; IPTC is carried in tag 33723. No C2PA embedding is defined in the current TIFF specification; C2PA is delivered via sidecar for TIFF assets.


### TCR4CAP Comments

**Awareness:** TIFF IFD tag structure is defined in TIFF 6.0. Tag 700 XMP and tag 33723 IPTC are widely implemented in archival imaging tools. No C2PA embedding path exists in the current specification.

**Tamper Evidence:** IFD tags have no integrity protection and can be silently overwritten or stripped without detection.

**Binding:** Metadata tags are structurally embedded in the IFD alongside the image data but there is no cryptographic binding between tag values and the image bitstream.

**AI Attribution:** IPTC 2025.1 AI fields can be carried via XMP in tag 700. No purpose-built AI attribution fields exist in the TIFF 6.0 specification.

**Substantiation:** Tag 700 XMP and tag 33723 IPTC provide descriptive provenance fields. No mechanism links IFD tags to external policies or trust anchors.

**Interoperability:** TIFF 6.0 is an open specification widely implemented across archival imaging tools and repository systems.

---

## MP4 / ISOBMFF Specific Features (Atoms)

**ID:** `mp4-features`  
**Type:** format-specific  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | Metadata atoms can be written or updated without re-encoding the media data. |
| Content-level | overwrite | Metadata atom values are replaced on write; C2PA uuid atom is append-only at the manifest store level. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | none | No media-data integrity mechanism in the ISO 14496-12 base specification. |
| Metadata integrity | none | Metadata atoms have no integrity protection in the base specification. |
| Chain of custody | signed | C2PA manifest store in uuid atom provides cryptographic signing and hard binding to media content when implemented. |

**FDD References:**  
- [FDD000155](https://www.loc.gov/preservation/digital/formats/fdd/fdd000155.shtml) (full: )  
- [FDD000525](https://www.loc.gov/preservation/digital/formats/fdd/fdd000525.shtml) (preliminary: )  

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `uuid atom (C2PA UUID)` | provenance-chain | Carries C2PA manifest store in JUMBF container; UUID value defined in C2PA Technical Specification. |
| `uuid atom (XMP UUID)` | provenance-chain | Carries XMP RDF/XML packet including xmpMM:History, xmpMM:DerivedFrom, and IPTC AI fields. |
| `udta / moov metadata atoms` | creation-datetime | Carries creation date, encoder identity, and copyright fields. |

MP4 and ISO Base Media File Format use a hierarchical atom (box) structure. C2PA manifest stores are embedded in a uuid atom with a defined C2PA UUID. Descriptive metadata is carried in udta and moov atoms. XMP can be carried in a uuid atom with the XMP UUID. Covers MP4, MOV, MJ2, 3GP, and other ISOBMFF derivatives.


### TCR4CAP Comments

**Awareness:** ISOBMFF atom structure is defined in ISO 14496-12. C2PA uuid atom embedding is defined in the C2PA Technical Specification Appendix A. uuid atom XMP embedding is defined in the XMP specification.

**Tamper Evidence:** Metadata atoms have no integrity protection in the base specification. C2PA uuid atom provides cryptographic tamper-evidence when present; modification of the media data invalidates the C2PA hard binding.

**Binding:** C2PA uuid atom provides hard binding: the manifest contains a hash of the media content. udta and moov metadata atoms are structurally embedded but not cryptographically bound.

**AI Attribution:** C2PA AI attribution assertions are carried in the uuid atom when present.

**Substantiation:** C2PA manifest store in uuid atom preserves transformation history with external trust anchor support.

**Interoperability:** ISO 14496-12 is an ISO standard. MP4 is widely implemented across broadcast, streaming, and archival video tools. C2PA uuid atom is supported by c2patool and c2pa-rs.

---

## Matroska Specific Features (EBML Tags, CRC-32, and Attachments)

**ID:** `mkv-features`  
**Type:** format-specific  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | EBML tag elements and attachment elements can be written or updated without re-encoding the media data. The Tags top-level element is structurally independent of the Cluster elements that carry media data. |
| Content-level | overwrite | Tag values are replaced on write. Updating a tag rewrites the Tags element in place or appends a new Tags element; if present, the CRC-32 of the Tags element should be recomputed on any edit. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | checksum | CRC-32 elements are defined in RFC 8794 (EBML) and applied per top-level element in Matroska. RFC 9559 §6.2 states that all Top-Level Elements (SeekHead, Info, Tracks, Chapters, Cluster, Cues, Attachments, Tags) SHOULD include a CRC-32 as their first child element. The CRC-32 covers all element data of the parent element excluding the CRC-32 element itself, using IEEE-CRC-32 (little-endian). FFmpeg writes CRC-32 in all Level 1 elements by default (write_crc32=1). This provides per-element integrity verification but does not constitute a whole-file hash or a cryptographic signature. |
| Metadata integrity | checksum | The Tags top-level element SHOULD carry its own CRC-32 child, covering the tag bytes. This allows detection of accidental corruption of the Tags element. It does not prevent intentional modification; any writer can recompute a valid CRC-32 after altering tag values. |
| Chain of custody | none | No signing or provenance chain mechanism is defined in the current Matroska specification. No C2PA embedding path is defined in RFC 9559. |

**FDD References:**  
- [FDD000342](https://www.loc.gov/preservation/digital/formats/fdd/fdd000342.shtml) (full: )  

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `TAG / SimpleTag (TagName=DATE_RECORDED)` | creation-datetime | The time that the recording began. |
| `TAG / SimpleTag (TagName=DATE_ENCODED)` | creation-datetime | The time that encoding of this item was completed. |
| `TAG / SimpleTag (TagName=DATE_TAGGED)` | creation-datetime | The time that the tags were written for this item. |
| `TAG / SimpleTag (TagName=DATE_DIGITIZED)` | creation-datetime | The time that the item was transferred to a digital medium. |
| `TAG / SimpleTag (TagName=ENCODER)` | actor-identity | The software or hardware used to encode this item. |
| `TAG / SimpleTag (TagName=ENCODER_SETTINGS)` | actor-identity | A list of the settings used for encoding this item. |
| `TAG / SimpleTag (TagName=ENCODED_BY)` | actor-identity | The person or organization that encoded the item. |
| `TAG / SimpleTag (TagName=ORIGINAL)` | provenance-chain | Nested container tag describing the original work this item is based on. Any tag may be nested under ORIGINAL to describe the source work. |
| `TAG / SimpleTag (TagName=ORIGINAL_MEDIA_TYPE)` | provenance-chain | Describes the original medium type of the source material (e.g., DVD, CD, film). |
| `TAG / SimpleTag (TagName=SAMPLE)` | provenance-chain | Nested container tag describing a sample used in the item taken from another work. |
| `TAG / SimpleTag (TagName=COPYRIGHT)` | rights | Copyright information as per the copyright holder. |
| `TAG / SimpleTag (TagName=LICENSE)` | rights | The license applied to the content (e.g., Creative Commons variants). |
| `TAG / SimpleTag (TagName=TERMS_OF_USE)` | rights | The terms of use for this item. |
| `CRC-32 (per top-level element)` | media-integrity | IEEE-CRC-32 checksum covering all element data of each top-level EBML element. Written by default by FFmpeg (write_crc32=1). Defined in RFC 8794 §11.3.1. |
| `Attachments / AttachedFile` | provenance-chain | Arbitrary file attachment; can carry sidecar metadata files including PREMIS or C2PA manifests. |

Matroska uses an EBML structure defined in RFC 9559. Metadata is carried in SimpleTag elements within a Tags master element; the tag vocabulary is defined in the IETF CELLAR working group tags draft. RFC 9559 §6.2 specifies that all top-level elements SHOULD carry a CRC-32 child element (IEEE-CRC-32, covering all sibling element data within the parent); FFmpeg implements this by default. CRC-32 provides per-element corruption detection but is not a cryptographic integrity mechanism and does not prevent intentional modification. The ORIGINAL and SAMPLE nested tag containers allow structured description of source and sample provenance. Attachments can carry arbitrary sidecar files. No C2PA embedding path is defined in the current Matroska specification.


### TCR4CAP Comments

**Awareness:** Matroska tag structure and CRC-32 behavior are defined in IETF RFC 9559 and RFC 8794. Tag elements are implemented in mkvtoolnix, FFmpeg, and VLC. No CAP-specific tag vocabulary is defined in the Matroska specification. The ORIGINAL, SAMPLE, and DATE_* tags provide a richer provenance vocabulary than most container formats but are not mapped to any current CAP framework.

**Tamper Evidence:** CRC-32 elements on each top-level EBML element detect accidental corruption of that element's data. They do not prevent intentional modification; any writer can recompute a valid CRC-32 after altering content. EBML tag elements have no cryptographic integrity protection.

**Binding:** Tag elements are structurally embedded in the EBML container. CRC-32 binds element content to its checksum at write time but there is no cryptographic binding between tag values and the media data, and no external identity is involved.

**AI Attribution:** No AI attribution fields are defined in the Matroska tag vocabulary.

**Substantiation:** The ORIGINAL, ORIGINAL_MEDIA_TYPE, SAMPLE, ENCODER, ENCODER_SETTINGS, and DATE_* tags provide a structured record of encoding history and source material. LICENSE and TERMS_OF_USE fields support rights documentation. No mechanism links these values to external policies or trust anchors.

**Interoperability:** Matroska is defined in IETF RFC 9559. Tag vocabulary is defined in the IETF CELLAR tags draft. Widely implemented in FFmpeg, VLC, and mkvtoolnix. CRC-32 verification is supported by mkvinfo and ffprobe.

---

## Vorbis Comment

**ID:** `vorbis-comment`  
**Type:** embedded-metadata  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | The Vorbis Comment block is embedded in the file and can be rewritten by tooling without re-encoding the primary content. |
| Content-level | overwrite | Fields are single-value and replaced on write. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | none | Vorbis Comment carries no media-data integrity mechanism. |
| Metadata integrity | none | No integrity protection on the Vorbis Comment block; fields can be silently overwritten without detection. |
| Chain of custody | none | No provenance chain mechanism in the Vorbis Comment specification. |

**FDD References:**  
- [FDD000198](https://www.loc.gov/preservation/digital/formats/fdd/fdd000198.shtml) (full: )  

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `ARTIST` | actor-identity | Name of the performing artist or creator. |
| `DATE` | creation-datetime | Date of recording or release. |
| `ENCODER` | actor-identity | Name and version of the encoding software. |

### Used by Formats

| ID | Name |
|---|---|
| `flac` | [FLAC (Free Lossless Audio Codec)](formats.md#flac) |

Embedded metadata blocks for human-readable key=value pairs. Fields are single-value and replaced on write. No integrity protection of the block itself. Used by FLAC, Ogg Vorbis, Ogg Opus, and Ogg FLAC.


### TCR4CAP Comments

**Awareness:** Vorbis Comment fields are widely understood in audio workflows but there is no standardized mapping to CAP vocabularies.

**Tamper Evidence:** Vorbis Comment fields have no integrity protection and can be silently overwritten or stripped without detection.

**Binding:** Fields are structurally embedded in the file but there is no cryptographic binding between comment values and the audio content.

**AI Attribution:** No defined AI attribution fields; any AI documentation must repurpose general comment fields with no standardized vocabulary.

**Substantiation:** Values are readable but there is no mechanism for linking to external policies or transformation histories.

**Interoperability:** Vorbis Comment is an open, widely implemented specification; fields are plain text and broadly readable.

---

## ID3 General Encapsulated Object (GEOB) — C2PA

**ID:** `id3-geob-c2pa`  
**Type:** embedded-c2pa  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | The GEOB frame can be written or rewritten within the host file without re-encoding the primary content. |
| Content-level | append-only | The C2PA manifest store within the GEOB payload is append-only; individual signed manifests are immutable once signed, and new manifests are appended on each edit. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | signed | C2PA hard binding links the manifest cryptographically to the audio content via a content hash at signing time. |
| Metadata integrity | signed | Each manifest is cryptographically signed; any modification to the GEOB payload invalidates the signature. |
| Chain of custody | signed | The append-only manifest store preserves the full provenance chain; each manifest references prior manifests as ingredients. |

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `GEOB frame (MIME type: application/c2pa)` | provenance-chain | ID3 GEOB frame carrying the C2PA manifest store binary payload. |
| `c2pa.claim.generator` | actor-identity | Software or hardware that generated the C2PA claim; carried within the manifest. |
| `c2pa.actions` | transformation-history | Ordered list of actions performed on the asset; carried within the manifest. |
| `c2pa.hash.data` | media-integrity | Cryptographic hash of the audio content; provides hard binding within the manifest. |
| `c2pa.ai.generatedWith` | ai-attribution | Identity of the AI model used to generate the asset; carried within the manifest. |

### Used by Formats

| ID | Name |
|---|---|
| `flac` | [FLAC (Free Lossless Audio Codec)](formats.md#flac) |

C2PA manifest store embedded via an ID3 tag using the General Encapsulated Object frame (GEOB). Each edit by a C2PA-capable tool appends a new signed manifest to the store; individual manifests are immutable once signed. The GEOB frame is not covered by FLAC's included checksums (MD5/CRC), so integrity of the manifest depends entirely on the C2PA cryptographic signing chain. Applicable to any format supporting ID3 tags (FLAC, MP3, AIFF).


### TCR4CAP Comments

**Awareness:** C2PA is a defined, published standard; the GEOB embedding path is specified in the C2PA Technical Specification, though not yet widely implemented in FLAC-specific tooling.

**Tamper Evidence:** Individual manifests are cryptographically signed and immutable; the append-only store preserves the full provenance chain. Tampering with the GEOB payload invalidates the signature.

**Binding:** C2PA hard binding links the manifest cryptographically to the audio content; the GEOB frame provides a standardized embedding location within the ID3 structure.

**AI Attribution:** C2PA supports structured AI attribution assertions (c2pa.ai.generatedWith, training data, model identity) within the manifest.

**Substantiation:** C2PA manifests can reference external trust anchors and credential issuers; transformation history is preserved in the manifest store across the asset lifecycle.

**Interoperability:** C2PA is an open, published specification; GEOB is a standard ID3 frame; implementation breadth in FLAC tooling is currently limited.

---

## BWF BEXT Chunk

**ID:** `bwf-bext`  
**Type:** embedded-metadata  
**URL:** guidelines: <https://www.digitizationguidelines.gov/guidelines/digitize-embedding.html>  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | The BEXT chunk is embedded in the WAVE file and can be rewritten by tooling without re-encoding the audio data. |
| Content-level | append | CodingHistory is conventionally appended on each processing step; other BEXT fields are overwritten on write. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | none | BEXT carries no media-data integrity mechanism. |
| Metadata integrity | none | No integrity protection on the BEXT chunk; fields can be silently overwritten without detection. |
| Chain of custody | none | CodingHistory is a conventional append-only log with no enforcement; no signing or provenance chain mechanism. |

**FDD References:**  
- [FDD000356](https://www.loc.gov/preservation/digital/formats/fdd/fdd000356.shtml) (full: )  
- [FDD000357](https://www.loc.gov/preservation/digital/formats/fdd/fdd000357.shtml) (full: )  

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `Originator` | actor-identity | Name of the originating organization; 32 bytes. |
| `OriginatorReference` | asset-identity | Unique identifier assigned by the originator; 32 bytes. |
| `OriginationDate` | creation-datetime | Date of origination in YYYY-MM-DD format. |
| `OriginationTime` | creation-datetime | Time of origination in HH-MM-SS format. |
| `UMID` | asset-identity | SMPTE Unique Material Identifier; 64 bytes. |
| `CodingHistory` | transformation-history | Free-text log of processing steps; conventionally appended on each encode or transfer. |

The Broadcast Extension chunk defined in EBU Tech 3285. Carries originator identity, originator reference, origination date and time, time reference (sample offset), UMID, loudness values, and a CodingHistory field. BEXT is the primary provenance carrier in BWF files. Fields can be silently overwritten; changes are not detectable without an external fixity record or audio-data MD5 comparison. Validated against FADGI, EBU, and Microsoft rules by BWF MetaEdit.


### TCR4CAP Comments

**Awareness:** BEXT is defined in EBU Tech 3285. Originator, OriginatorReference, OriginationDate/Time, and CodingHistory are recognized provenance fields in broadcast and archival audio workflows. FADGI and EBU publish guidelines for consistent field use.

**Tamper Evidence:** BEXT fields have no integrity protection. Any field can be overwritten without detection. CodingHistory is appended by convention; no mechanism enforces append-only behavior or detects deletion of history entries.

**Binding:** BEXT is embedded in the RIFF container alongside the audio data. No cryptographic mechanism links BEXT field values to the audio bitstream.

**AI Attribution:** No fields in the BEXT specification address AI generation, training, or processing provenance. CodingHistory is a free-text field that could carry AI processing notes by convention.

**Substantiation:** CodingHistory documents processing steps in a structured free-text format. UMID provides a globally unique material identifier. No mechanism links BEXT fields to external policies or trust anchors.

**Interoperability:** Defined in EBU Tech 3285. Implemented across broadcast and archival audio tools. FADGI and EBU publish open guidelines for field use.

---

## BWF LIST-INFO Chunk

**ID:** `bwf-info`  
**Type:** embedded-metadata  
**URL:** guidelines: <https://www.digitizationguidelines.gov/guidelines/digitize-embedding.html>  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | The LIST-INFO chunk is embedded in the WAVE file and can be rewritten by tooling without re-encoding the audio data. |
| Content-level | overwrite | INFO fields are replaced on write. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | none | LIST-INFO carries no media-data integrity mechanism. |
| Metadata integrity | none | No integrity protection; fields can be silently overwritten without detection. |
| Chain of custody | none | No provenance chain mechanism in the RIFF INFO specification. |

**FDD References:**  
- [FDD000356](https://www.loc.gov/preservation/digital/formats/fdd/fdd000356.shtml) (full: )  
- [FDD000357](https://www.loc.gov/preservation/digital/formats/fdd/fdd000357.shtml) (full: )  

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `ICRD` | creation-datetime | Date of creation. |
| `IART` | actor-identity | Name of the artist or creator. |
| `ISFT` | actor-identity | Name of the software used to create the file. |
| `ICOP` | rights | Copyright statement. |

The RIFF LIST-INFO chunk carrying standard INFO tags. A secondary metadata carrier in BWF files, complementing BEXT. Fields are plain text with no integrity protection. Less structured than BEXT; no provenance-specific fields. Validated by BWF MetaEdit against Microsoft WAVE specifications.


### TCR4CAP Comments

**Awareness:** INFO tags are widely understood as descriptive metadata but are not specifically designed for provenance; no standardized mapping to CAP vocabularies.

**Tamper Evidence:** LIST-INFO fields have no integrity protection and can be silently overwritten or stripped without detection.

**Binding:** Fields are structurally embedded in the file but there is no cryptographic binding between INFO field values and the audio content.

**AI Attribution:** No defined AI attribution fields; general comment fields could be repurposed but with no standardized vocabulary.

**Substantiation:** Plain text fields with no mechanism for linking to external policies or transformation histories.

**Interoperability:** RIFF INFO is an open, widely implemented specification; fields are plain text and broadly readable across tools.

---

## BWF XML Chunks (aXML / iXML)

**ID:** `bwf-xml`  
**Type:** embedded-metadata  
**URL:** guidelines: <https://www.digitizationguidelines.gov/guidelines/digitize-embedding.html>  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | The aXML and iXML chunks are embedded in the WAVE file and can be rewritten by tooling without re-encoding the audio data. |
| Content-level | overwrite | Each XML chunk's content is replaced on write. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | none | aXML and iXML carry no media-data integrity mechanism. |
| Metadata integrity | none | No integrity protection on either chunk; content can be silently overwritten without detection. |
| Chain of custody | none | No provenance chain mechanism in the iXML or aXML specifications. |

**FDD References:**  
- [FDD000356](https://www.loc.gov/preservation/digital/formats/fdd/fdd000356.shtml) (partial: )  
- [FDD000357](https://www.loc.gov/preservation/digital/formats/fdd/fdd000357.shtml) (partial: )  

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `aXML / EBU-ISRC` | asset-identity | EBU International Standard Recording Code and additional production metadata. |
| `iXML / RECORDER` | actor-identity | Name and model of the recording device. |
| `iXML / TRACK_LIST` | technical-provenance | List of recorded tracks with channel assignments. |

Two distinct XML-carrying chunks supported in BWF/WAVE files. The aXML chunk (EBU Tech 3285 supplement) carries additional XML data including EBU ISRC and production metadata. The iXML chunk carries production sound metadata (scene, take, track names, recorder metadata) per the iXML specification. BWF MetaEdit supports reading and writing both chunk types. Neither chunk has integrity protection of its own.


### TCR4CAP Comments

**Awareness:** iXML and aXML/EBU-ISRC are well-established in broadcast production workflows but are not yet addressed in FADGI preservation guidelines.

**Tamper Evidence:** aXML and iXML fields have no integrity protection and can be silently overwritten or stripped without detection.

**Binding:** Chunks are structurally embedded in the file but there is no cryptographic binding between chunk content and the audio bitstream.

**AI Attribution:** No defined AI attribution fields in iXML or aXML vocabularies.

**Substantiation:** iXML provides structured production context (scene, take, recorder); aXML/EBU-ISRC supports rights and identifier linkage. No mechanism for linking to external trust anchors.

**Interoperability:** iXML is an open specification; aXML/EBU-ISRC is an EBU standard. Both are broadly supported in professional audio and DAW tooling.

---

## BWF Audio-Data MD5 Checksum

**ID:** `bwf-md5`  
**Type:** integrity  
**URL:** guidelines: <https://www.digitizationguidelines.gov/guidelines/digitize-embedding.html>  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | The MD5 value is stored within the WAVE file and can be written, updated, or verified by BWF MetaEdit without re-encoding the audio data. |
| Content-level | fixed | The MD5 is computed over the audio data chunk only and is fixed at write time; it must be recomputed if the audio data changes. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | checksum | MD5 computed over the WAVE audio data chunk payload. Detects changes to the audio bitstream. Recomputable by BWF MetaEdit and any MD5-capable tool given the raw data chunk. |
| Metadata integrity | none | The MD5 covers the audio data chunk only; metadata chunks (BEXT, INFO, XML) are not covered and can be altered without invalidating the checksum. |
| Chain of custody | none | No signing or provenance chain mechanism; the MD5 value itself is not signed and could be replaced along with modified audio data. |

**FDD References:**  
- [FDD000356](https://www.loc.gov/preservation/digital/formats/fdd/fdd000356.shtml) (partial: )  
- [FDD000357](https://www.loc.gov/preservation/digital/formats/fdd/fdd000357.shtml) (partial: )  

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `MD5 digest (audio data chunk)` | media-integrity | MD5 hash of the WAVE data chunk payload, excluding chunk ID, size declaration, and optional padding byte. |

An MD5 checksum computed over the WAVE file's audio data chunk, embedded within the file by BWF MetaEdit. Detects changes to the audio bitstream. Does not cover metadata chunks (BEXT, INFO, XML). Analogous to FLAC's defined STREAMINFO MD5, but applied at the tool level rather than defined in the format specification. MD5 is not collision-resistant for adversarial contexts.


### TCR4CAP Comments

**Awareness:** Audio-data MD5 is a well-understood fixity practice in broadcast and preservation workflows; BWF MetaEdit's implementation follows FADGI guidance.

**Tamper Evidence:** Detects accidental or unintentional changes to the audio bitstream. Does not cover metadata chunks. MD5 is not collision-resistant for adversarial tampering; the checksum value itself is not signed.

**Binding:** The MD5 is computed over and embedded alongside the specific audio data chunk, providing a direct integrity link between the checksum value and the audio content within the same file.

**AI Attribution:** No relevance to AI attribution; the checksum documents data integrity only.

**Substantiation:** Provides a verifiable, reproducible integrity record for the audio bitstream. Supported by FADGI guidance. Exportable for external audit. Limited to the data chunk.

**Interoperability:** MD5 is a universal algorithm; the checksum can be verified by any MD5 tool. The embedding convention is specific to BWF MetaEdit / FADGI practice and not universally standardized across all WAVE-capable tools.

---

## BWF C2PA Chunk

**ID:** `bwf-c2pa`  
**Type:** embedded-c2pa  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | The C2PA chunk is embedded in the WAVE/RIFF file and can be written or replaced by C2PA-capable tooling without re-encoding the audio data. |
| Content-level | append-only | The C2PA Manifest Store is cryptographically signed; individual manifests are immutable once signed. New manifests are appended; prior manifests are preserved as ingredient references. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | signed | C2PA hard binding: the active manifest contains a cryptographic hash of the audio content at signing time. Any modification to the audio data invalidates the binding. |
| Metadata integrity | signed | Each manifest is cryptographically signed using CMS/COSE. Any modification to a manifest's assertions or claim invalidates the signature. |
| Chain of custody | signed | The manifest store is append-only; prior manifests are preserved as ingredient references. The full provenance chain is verifiable against the signing certificate chain and optional timestamp authority. |

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `C2PA RIFF chunk (fourCC: C2PA)` | provenance-chain | RIFF chunk carrying the C2PA Manifest Store binary payload. |
| `c2pa.claim.generator` | actor-identity | Software or hardware that generated the C2PA claim. |
| `c2pa.actions` | transformation-history | Ordered list of actions performed on the asset. |
| `c2pa.hash.data` | media-integrity | Cryptographic hash of the audio content; provides hard binding. |
| `c2pa.ai.generatedWith` | ai-attribution | Identity of the AI model used to generate the asset. |
| `c2pa.training-mining` | ai-attribution | Assertion about whether the asset may be used for AI training or data mining. |
| `c2pa.claim.signature` | provenance-chain | CMS/COSE signature over the claim; includes signing certificate and optional timestamp. |

A RIFF chunk with four-character code C2PA carrying a C2PA Manifest Store, as defined in the C2PA Technical Specification (Appendix A). Applies to WAV, BWF, and AVI files. The manifest store contains one or more C2PA Manifests, each comprising a Claim, Claim Signature (COSE/X.509), and Assertions. The chunk is cryptographically signed; any modification to the audio data or metadata invalidates the signature. BWF MetaEdit can detect the chunk's presence but does not author or validate C2PA manifests; authoring is performed by c2patool, c2pa-rs, and compatible capture devices.


### TCR4CAP Comments

**Awareness:** C2PA Technical Specification is published by the Coalition for Content Provenance and Authenticity. The C2PA RIFF chunk is defined in the specification Appendix A. No current version of BWF MetaEdit writes this chunk.

**Tamper Evidence:** The manifest is cryptographically signed; any modification to the signed content invalidates the signature. Hard binding means any modification to the audio data is detectable.

**Binding:** Hard binding: the C2PA Manifest Store is embedded in the file and the Claim covers a hash of the audio data chunk, cryptographically linking the manifest to the specific audio bitstream at signing time.

**AI Attribution:** C2PA defines standardized assertions for AI generative and training provenance: c2pa.ai.generatedWith, c2pa.training-mining, and related fields for model identity and generation parameters.

**Substantiation:** Signed assertions are verifiable against a public certificate chain and optional timestamp authority. Manifest history preserves a chain of custody across multiple signing events.

**Interoperability:** C2PA is an open, published specification. Tooling support for WAV/BWF is nascent; c2patool and c2pa-rs support it but broadcast and preservation tools do not yet recognize the chunk.

---

## XMP Embedded Metadata

**ID:** `xmp-embedded`  
**Type:** embedded-metadata  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | XMP packets are embedded within the host file in a format-specific container (XMP chunk in WAVE, APP1 in JPEG, tag 700 in TIFF, uuid atom in MP4, iTXt in PNG, etc.) and can be rewritten by tooling without re-encoding the primary content. |
| Content-level | overwrite | The XMP packet is replaced on write. The xmpMM:History array supports internal modification history by convention but entries are advisory and not integrity-protected. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | none | XMP carries no media-data integrity mechanism. |
| Metadata integrity | none | XMP packets have no integrity protection; the packet can be silently overwritten or stripped without detection. |
| Chain of custody | none | xmpMM:History provides a conventional modification log; entries are advisory and unverified. No signing mechanism in the XMP specification. |

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `xmp:CreateDate` | creation-datetime | Date and time the resource was originally created. |
| `xmp:CreatorTool` | actor-identity | Name and version of the tool used to create or last modify the resource. |
| `xmpMM:DocumentID` | asset-identity | Persistent identifier for the document across all versions and renditions. |
| `xmpMM:InstanceID` | asset-identity | Identifier for the specific version or rendition of the document. |
| `xmpMM:DerivedFrom` | provenance-chain | Reference to the source asset from which this asset was derived; carries DocumentID and InstanceID of the source. |
| `xmpMM:History` | transformation-history | Array of ResourceEvent entries documenting modification history; each entry carries action, instanceID, when, and softwareAgent. |
| `dc:rights` | rights | Dublin Core rights statement. |
| `dc:source` | provenance-chain | Dublin Core source field; reference to a resource from which this resource is derived. |
| `Iptc4xmpExt:DigitalSourceType` | ai-attribution | IPTC controlled vocabulary term for the digital source type (e.g. trainedAlgorithmicMedia, compositeSynthetic). |

### Used by Formats

| ID | Name |
|---|---|
| `bwf` | [Broadcast WAVE Format (BWF)](formats.md#bwf) |
| `flac` | [FLAC (Free Lossless Audio Codec)](formats.md#flac) |
| `jpeg` | [JPEG](formats.md#jpeg) |
| `png` | [PNG (Portable Network Graphics)](formats.md#png) |
| `tiff` | [TIFF (Tagged Image File Format)](formats.md#tiff) |
| `mp4-isobmff` | [MP4 / ISO Base Media File Format](formats.md#mp4-isobmff) |
| `mkv` | [Matroska (MKV)](formats.md#mkv) |

XMP (Extensible Metadata Platform) is an RDF/XML metadata format defined by Adobe and standardized as ISO 16684. Embedded in host files via format-specific containers or stored as standalone .xmp sidecar files. Supports multiple namespaces including Dublin Core (dc:), XMP Basic (xmp:), XMP Media Management (xmpMM:), and IPTC (Iptc4xmpCore/Ext:). The xmpMM:History array provides a conventional provenance record of processing steps. XMP packets have no integrity protection of their own.


### TCR4CAP Comments

**Awareness:** XMP is defined in ISO 16684. Implemented across creative, archival, and repository tools. xmpMM:History and xmpMM:DerivedFrom are recognized provenance fields in digital asset management workflows.

**Tamper Evidence:** XMP packets have no integrity protection and can be silently overwritten or stripped without detection. xmpMM:History entries are advisory and unverified.

**Binding:** XMP is structurally embedded in host files but there is no cryptographic binding between XMP content and the primary media data. The packet can be removed without affecting the media bitstream.

**AI Attribution:** Iptc4xmpExt:DigitalSourceType and IPTC 2025.1 AI fields (AiPrompt, AiSystemUsed, AiSystemVersion) are carried in XMP namespaces. No purpose-built AI attribution fields exist in the core XMP specification itself.

**Substantiation:** xmpMM:History and xmpMM:DerivedFrom provide a readable provenance record. XMP sidecar files can be published independently. No mechanism for cryptographic verification of history entries.

**Interoperability:** XMP is defined in ISO 16684. Implemented across all major creative, archival, and repository tools. Embedded in a wide range of format containers.

---

## EXIF Embedded Metadata

**ID:** `exif-embedded`  
**Type:** embedded-metadata  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | EXIF IFD data can be written or replaced in host files without re-encoding primary content. |
| Content-level | overwrite | EXIF tag values are replaced on write. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | none | EXIF carries no media-data integrity mechanism. |
| Metadata integrity | none | EXIF data has no integrity protection; tags can be silently overwritten or stripped. |
| Chain of custody | none | No provenance chain mechanism in the EXIF specification. |

**FDD References:**  
- [FDD000145](https://www.loc.gov/preservation/digital/formats/fdd/fdd000145.shtml) (full: )  
- [FDD000146](https://www.loc.gov/preservation/digital/formats/fdd/fdd000146.shtml) (full: )  
- [FDD000147](https://www.loc.gov/preservation/digital/formats/fdd/fdd000147.shtml) (full: )  
- [FDD000618](https://www.loc.gov/preservation/digital/formats/fdd/fdd000618.shtml) (full: )  

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `Make (0x010F) / Model (0x0110)` | actor-identity | Camera manufacturer and model name. |
| `Software (0x0131)` | actor-identity | Name and version of software used to process the image. |
| `DateTimeOriginal (0x9003)` | creation-datetime | Date and time the original image was captured. |
| `DateTimeDigitized (0x9004)` | creation-datetime | Date and time the image was digitized. |
| `GPSLatitude / GPSLongitude (0x0002 / 0x0004)` | creation-location | GPS coordinates of capture location. |
| `ImageUniqueID (0xA420)` | asset-identity | Unique identifier assigned to the image by the camera or software. |
| `BodySerialNumber (0xA431)` | actor-identity | Serial number of the camera body. |

### Used by Formats

| ID | Name |
|---|---|
| `jpeg` | [JPEG](formats.md#jpeg) |
| `png` | [PNG (Portable Network Graphics)](formats.md#png) |
| `tiff` | [TIFF (Tagged Image File Format)](formats.md#tiff) |

EXIF (Exchangeable Image File Format) is a binary metadata standard defined by CIPA (DC-008) using an IFD tag structure. Records capture device identity, camera settings, GPS coordinates, and datetime. Embedded in JPEG APP1, TIFF SubIFD, PNG eXIf chunk, and HEIF. EXIF data has no integrity protection and can be silently overwritten or stripped.


### TCR4CAP Comments

**Awareness:** EXIF is defined by CIPA DC-008. Implemented universally across cameras, phones, and image processing tools. Capture device identity and datetime fields are widely used as provenance indicators in photojournalism and archival workflows.

**Tamper Evidence:** EXIF data has no integrity protection and can be silently overwritten or stripped without detection.

**Binding:** EXIF is structurally embedded in host files but there is no cryptographic binding between EXIF tag values and the image content.

**AI Attribution:** No AI attribution fields are defined in the EXIF specification. Software (0x0131) can record processing tool identity but has no structured AI attribution vocabulary.

**Substantiation:** Capture datetime, GPS, and device fields provide a factual provenance record. No mechanism links EXIF fields to external policies or transformation histories.

**Interoperability:** EXIF is defined by CIPA DC-008. Universally implemented across cameras, phones, and image processing tools.

---

## IPTC Photo Metadata

**ID:** `iptc-photo`  
**Type:** embedded-metadata  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | IPTC fields carried in XMP can be written or replaced in host files without re-encoding primary content. |
| Content-level | overwrite | IPTC property values are replaced on write. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | none | IPTC carries no media-data integrity mechanism. |
| Metadata integrity | none | IPTC fields carried in XMP have no integrity protection; fields can be silently overwritten or stripped. |
| Chain of custody | none | No provenance chain mechanism in the IPTC Photo Metadata specification. |

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `Iptc4xmpCore:CreatorContactInfo` | actor-identity | Contact information for the image creator. |
| `Iptc4xmpExt:DigitalSourceType` | ai-attribution | Controlled vocabulary term for the digital source type (e.g. trainedAlgorithmicMedia, compositeSynthetic). |
| `Iptc4xmpExt:AiPrompt (11.2)` | ai-attribution | Text prompt used to generate the image with an AI system; IPTC 2025.1. |
| `Iptc4xmpExt:AiSystemUsed (11.4)` | ai-attribution | Name of the AI system used to generate or process the image; IPTC 2025.1. |
| `Iptc4xmpExt:AiSystemVersion (11.5)` | ai-attribution | Version of the AI system; IPTC 2025.1. |
| `Iptc4xmpExt:DataMiningPermission (11.11)` | rights | Statement of permission for data mining or AI training use; IPTC 2025.1. |
| `Iptc4xmpExt:WebStatement` | rights | URL of a rights statement for the image. |

### Used by Formats

| ID | Name |
|---|---|
| `jpeg` | [JPEG](formats.md#jpeg) |
| `png` | [PNG (Portable Network Graphics)](formats.md#png) |
| `tiff` | [TIFF (Tagged Image File Format)](formats.md#tiff) |

The IPTC Photo Metadata Standard defines a vocabulary of fields carried in XMP namespaces (Iptc4xmpCore, Iptc4xmpExt). Version 2025.1 adds dedicated AI fields: AiPrompt (11.2), AiSystemUsed (11.4), AiSystemVersion (11.5), and DataMiningPermission (11.11). Widely used in photojournalism, stock photography, and digital asset management.


### TCR4CAP Comments

**Awareness:** IPTC Photo Metadata Standard is published by IPTC. Version 2025.1 AI fields are defined in the IPTC specification. Widely implemented in photo editing, DAM, and publishing tools.

**Tamper Evidence:** IPTC fields carried in XMP have no integrity protection and can be silently overwritten or stripped without detection.

**Binding:** IPTC fields are structurally embedded via XMP in host files but there is no cryptographic binding between field values and the image content.

**AI Attribution:** Version 2025.1 defines AiPrompt, AiSystemUsed, AiSystemVersion, and DataMiningPermission as purpose-built, standardized AI attribution fields within the IPTC vocabulary.

**Substantiation:** IPTC fields provide a structured, readable provenance record. The standard is publicly documented. No mechanism links field values to external trust anchors.

**Interoperability:** IPTC Photo Metadata Standard is an open standard. Implemented in photo editing, DAM, and publishing tools including Adobe Photoshop, Lightroom, and Capture One.

---

## JUMBF C2PA Manifest Store (Embedded)

**ID:** `jumbf-c2pa`  
**Type:** embedded-c2pa  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | embedded-writable | The JUMBF container carrying the C2PA Manifest Store is embedded in the host file via a format-specific mechanism (APP11 in JPEG, caBX in PNG, uuid atom in MP4, C2PA chunk in RIFF/WAV) and can be written or replaced by C2PA-capable tooling without re-encoding the primary content. |
| Content-level | append-only | The C2PA Manifest Store is append-only at the store level; individual signed manifests are immutable once signed. New manifests are appended on each edit; prior manifests are preserved as ingredient references. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | signed | C2PA hard binding: the active manifest contains a cryptographic hash of the asset content at signing time. Any modification to the asset content invalidates the binding. |
| Metadata integrity | signed | Each manifest is cryptographically signed using CMS/COSE. Any modification to a manifest's assertions or claim invalidates the signature. |
| Chain of custody | signed | The manifest store is append-only; prior manifests are preserved as ingredient references. The full provenance chain is verifiable against the signing certificate chain and optional timestamp authority. |

**FDD References:**  
- [FDD000653](https://www.loc.gov/preservation/digital/formats/fdd/fdd000653.shtml) (partial: )  

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `c2pa.claim.generator` | actor-identity | Software or hardware that generated the C2PA claim. |
| `c2pa.actions` | transformation-history | Ordered list of actions performed on the asset (c2pa.created, c2pa.edited, c2pa.converted, c2pa.transcoded, etc.). |
| `c2pa.ingredient` | provenance-chain | Reference to a prior asset version or source asset, including its manifest hash. |
| `c2pa.hash.data` | media-integrity | Cryptographic hash of the asset content; provides hard binding between manifest and asset. |
| `c2pa.ai.generatedWith` | ai-attribution | Identity of the AI model used to generate the asset. |
| `c2pa.training-mining` | ai-attribution | Assertion about whether the asset may be used for AI training or data mining. |
| `c2pa.claim.signature` | provenance-chain | CMS/COSE signature over the claim; includes signing certificate and optional timestamp authority token. |
| `c2pa.soft-binding` | provenance-chain | Perceptual identifier (watermark or fingerprint) used to link the manifest to the asset when hard binding is not possible or has been broken. |

### Used by Formats

| ID | Name |
|---|---|
| `bwf` | [Broadcast WAVE Format (BWF)](formats.md#bwf) |
| `jpeg` | [JPEG](formats.md#jpeg) |
| `png` | [PNG (Portable Network Graphics)](formats.md#png) |
| `tiff` | [TIFF (Tagged Image File Format)](formats.md#tiff) |
| `mp4-isobmff` | [MP4 / ISO Base Media File Format](formats.md#mp4-isobmff) |

A C2PA Manifest Store carried in a JUMBF (JPEG Universal Metadata Box Format) container, embedded in the host file via a format-specific mechanism. Consolidates the embedding paths for JPEG (APP11), PNG (caBX), MP4/ISOBMFF (uuid atom), and RIFF/WAV (C2PA chunk) under a single mechanism entry, as all use the same JUMBF container and C2PA manifest structure. Each manifest contains assertions, a claim, and a claim signature. Hard binding links the manifest cryptographically to the asset content via hash. The active manifest is the most recently added; prior manifests are preserved as ingredients.


### TCR4CAP Comments

**Awareness:** C2PA Technical Specification is published by the Coalition for Content Provenance and Authenticity. Adopted by Adobe, Microsoft, Google, camera manufacturers, and news organizations. Reference implementation available as c2pa-rs under an open-source license.

**Tamper Evidence:** Each manifest is cryptographically signed; any modification invalidates the signature. The append-only store preserves the full provenance chain. Hard binding means any modification to the asset content invalidates the active manifest.

**Binding:** Hard binding provides cryptographic linkage between manifest and asset content via content hash. Soft binding provides a defined alternative for non-embeddable assets using perceptual identifiers.

**AI Attribution:** C2PA defines purpose-built assertions for AI generative and training provenance: c2pa.ai.generatedWith, c2pa.training-mining, and related fields for model identity and generation parameters.

**Substantiation:** Manifest store preserves full transformation history. External trust anchors (credential issuers, TSA) are supported. Public verification is possible via the C2PA trust list and open verification tools.

**Interoperability:** Open published specification. Reference implementation (c2patool, c2pa-rs) available under open-source license. Adopted across image, video, and audio tools and camera manufacturers. Format-specific embedding paths are defined in the C2PA Technical Specification Appendix A.

---

## C2PA Sidecar Manifest

**ID:** `sidecar-c2pa`  
**Type:** sidecar-c2pa  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | sidecar-writable | The C2PA manifest store is stored as a standalone .c2pa file alongside the asset; it can be written or replaced independently of the asset file. |
| Content-level | append-only | The C2PA Manifest Store within the sidecar is append-only; individual signed manifests are immutable once signed. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | signed | C2PA hard binding: the active manifest contains a cryptographic hash of the asset content. Any modification to the asset content invalidates the binding. The sidecar file can be separated from the asset, breaking the association. |
| Metadata integrity | signed | Each manifest is cryptographically signed; any modification to the sidecar payload invalidates the signature. |
| Chain of custody | signed | The manifest store is append-only; prior manifests are preserved as ingredient references. Verifiable against the signing certificate chain and optional timestamp authority. Association with the asset depends on file management conventions. |

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `c2pa.claim.generator` | actor-identity | Software or hardware that generated the C2PA claim. |
| `c2pa.actions` | transformation-history | Ordered list of actions performed on the asset. |
| `c2pa.hash.data` | media-integrity | Cryptographic hash of the asset content; provides hard binding to the associated asset file. |
| `c2pa.ai.generatedWith` | ai-attribution | Identity of the AI model used to generate the asset. |
| `c2pa.training-mining` | ai-attribution | Assertion about whether the asset may be used for AI training or data mining. |
| `c2pa.claim.signature` | provenance-chain | CMS/COSE signature over the claim; includes signing certificate and optional timestamp authority token. |

### Used by Formats

| ID | Name |
|---|---|
| `bwf` | [Broadcast WAVE Format (BWF)](formats.md#bwf) |
| `flac` | [FLAC (Free Lossless Audio Codec)](formats.md#flac) |
| `jpeg` | [JPEG](formats.md#jpeg) |
| `png` | [PNG (Portable Network Graphics)](formats.md#png) |
| `tiff` | [TIFF (Tagged Image File Format)](formats.md#tiff) |
| `mp4-isobmff` | [MP4 / ISO Base Media File Format](formats.md#mp4-isobmff) |
| `mkv` | [Matroska (MKV)](formats.md#mkv) |

A C2PA Manifest Store stored as a standalone .c2pa file alongside the asset, used when embedding in the asset file is not possible or not desired (e.g. for TIFF, camera RAW formats, or read-only assets). The sidecar carries the same JUMBF-encoded manifest store as the embedded path. Hard binding via content hash links the sidecar to the specific asset bitstream, but the physical association between sidecar and asset depends on file management conventions; the sidecar can be separated from the asset without invalidating the manifest signatures.


### TCR4CAP Comments

**Awareness:** C2PA sidecar delivery is defined in the C2PA Technical Specification. Used for formats where embedding is not defined or not practical.

**Tamper Evidence:** Each manifest is cryptographically signed; modification of the sidecar payload invalidates the signature. The sidecar can be deleted or separated from the asset without detection at the file level.

**Binding:** Hard binding via content hash links the sidecar to the specific asset bitstream. Physical co-location of sidecar and asset depends on file management conventions and is not enforced by the format.

**AI Attribution:** C2PA AI attribution assertions are carried in the sidecar manifest store identically to the embedded path.

**Substantiation:** Manifest store preserves full transformation history. External trust anchors are supported. Sidecar files can be published or transferred independently of the asset.

**Interoperability:** C2PA sidecar is defined in the open C2PA Technical Specification. Supported by c2patool and c2pa-rs. Sidecar association conventions vary across repository and DAM systems.

---

## PREMIS Sidecar / Embedded Event Record

**ID:** `sidecar-premis`  
**Type:** sidecar-metadata  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | sidecar-writable | PREMIS documents are standalone XML files managed independently of the media assets they describe, or embedded within a METS wrapper. |
| Content-level | append | Preservation events are appended to the PREMIS document over the asset lifecycle; existing events are not modified by convention. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | external-only | PREMIS can record fixity values (checksums) for described objects in the objectCharacteristics/fixity element, but does not compute or verify them itself. Verification depends on external tooling. |
| Metadata integrity | none | PREMIS XML has no integrity protection; the document can be modified without detection. Integrity depends on the repository or packaging layer. |
| Chain of custody | external-only | PREMIS event records provide a structured provenance chain but entries are not cryptographically signed. Integrity of the event record depends on the repository audit log or packaging layer (e.g. BagIt fixity). |

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `object/objectIdentifier` | asset-identity | Persistent identifier for the described object. |
| `object/objectCharacteristics/fixity` | media-integrity | Fixity algorithm and digest value for the described object. |
| `object/objectCharacteristics/format` | technical-provenance | Format name, version, and registry designation (e.g. PRONOM PUID) of the described object. |
| `event/eventType` | transformation-history | Type of preservation event (e.g. ingestion, normalization, fixity check, deletion). |
| `event/eventDateTime` | transformation-history | Date and time of the preservation event. |
| `event/eventOutcomeInformation` | transformation-history | Outcome of the event (success, failure) and detail notes. |
| `agent/agentIdentifier` | actor-identity | Identifier for the agent (person, organization, or software) responsible for the event. |
| `rights/rightsStatement` | rights | Rights basis and rights granted for the described object. |

### Used by Formats

| ID | Name |
|---|---|
| `bwf` | [Broadcast WAVE Format (BWF)](formats.md#bwf) |
| `flac` | [FLAC (Free Lossless Audio Codec)](formats.md#flac) |
| `jpeg` | [JPEG](formats.md#jpeg) |
| `png` | [PNG (Portable Network Graphics)](formats.md#png) |
| `tiff` | [TIFF (Tagged Image File Format)](formats.md#tiff) |
| `mp4-isobmff` | [MP4 / ISO Base Media File Format](formats.md#mp4-isobmff) |
| `mkv` | [Matroska (MKV)](formats.md#mkv) |

PREMIS (Preservation Metadata: Implementation Strategies) is an XML schema defined by the Library of Congress for recording preservation metadata. Models Objects, Events, Agents, and Rights. PREMIS events map conceptually to C2PA actions (c2pa.created, c2pa.converted, c2pa.edited); PREMIS agent maps to C2PA softwareAgent or person assertions. Generated by preservation systems including Archivematica, DSpace, and Fedora.


### TCR4CAP Comments

**Awareness:** PREMIS Data Dictionary is published by the Library of Congress. Implemented in Archivematica, DSpace, Fedora, and other repository systems. Event types and agent types are defined vocabularies.

**Tamper Evidence:** PREMIS XML has no integrity protection. The document can be modified without detection. Tamper-evidence depends on the repository or packaging layer (e.g. BagIt fixity, audit logs).

**Binding:** PREMIS Object elements reference described files by identifier and path. Fixity values in objectCharacteristics/fixity link the PREMIS record to a specific file state, but the linkage is not cryptographically enforced within the PREMIS document itself.

**AI Attribution:** No purpose-built AI attribution fields in the PREMIS Data Dictionary. The agent/agentType vocabulary could accommodate AI agents; eventType could accommodate AI processing events by convention.

**Substantiation:** PREMIS event records provide a structured, policy-driven transformation history. The PREMIS Data Dictionary is an open standard. Event records are auditable by repository administrators.

**Interoperability:** PREMIS Data Dictionary is published by the Library of Congress as an open standard. Implemented across major digital preservation systems and repository platforms.

---

## BagIt Package Fixity

**ID:** `bagit-features`  
**Type:** package-integrity  

### Editability

| Level | Type | Notes |
|---|---|---|
| File-level | package-writable | BagIt manifests are plain text files within the bag directory structure; they can be regenerated when payload files change. |
| Content-level | fixed | Manifest entries are computed at bag creation time and are fixed for the lifetime of the bag; any change to a payload file requires regenerating the manifest. |

### Verifiability

| Dimension | Type | Notes |
|---|---|---|
| Media integrity | checksum | Manifest files (manifest-md5.txt, manifest-sha256.txt, etc.) record checksums for all payload files. Any modification to a payload file produces a checksum mismatch detectable by bag validation. |
| Metadata integrity | checksum | Tag manifests (tagmanifest-*.txt) record checksums for all tag files including bag-info.txt and fetch.txt. Modification of tag files is detectable by tag manifest validation. |
| Chain of custody | external-only | BagIt provides no signing mechanism; the integrity of the bag depends on the checksum algorithm and the security of the storage environment. Chain of custody depends on repository audit logs and transfer records. |

### Metadata Fields

| Field | CAP Concept | Description |
|---|---|---|
| `manifest-*.txt entries` | media-integrity | Checksum algorithm and digest for each payload file; one entry per file. |
| `tagmanifest-*.txt entries` | metadata-integrity | Checksum algorithm and digest for each tag file. |
| `bag-info.txt / Bagging-Date` | creation-datetime | Date the bag was created. |
| `bag-info.txt / Source-Organization` | actor-identity | Name of the organization that created the bag. |
| `bag-info.txt / External-Identifier` | asset-identity | Identifier assigned to the bag by the source organization. |
| `bag-info.txt / Payload-Oxum` | media-integrity | Octet count and stream count of the payload; used for quick validation. |
| `fetch.txt` | provenance-chain | List of URLs and expected sizes for payload files to be fetched; used for holey bags. |

BagIt (RFC 8493) is a hierarchical file packaging format for reliable digital transfer and storage. A bag contains a payload directory, manifest files recording checksums for all payload files, tag files carrying descriptive metadata, and tag manifest files recording checksums for tag files. Operates at the package level; does not interact with file-level metadata mechanisms. Supported algorithms include MD5, SHA-1, SHA-256, and SHA-512.


### TCR4CAP Comments

**Awareness:** BagIt is defined in IETF RFC 8493. Widely adopted in digital preservation, library, and archival transfer workflows. Implemented in bagit-python, Bagger, and Archivematica.

**Tamper Evidence:** Manifest checksums detect modification of any payload or tag file. No signing mechanism; the manifest files themselves could be replaced along with modified payload files without detection at the BagIt level.

**Binding:** Manifest entries bind each checksum to a specific file path within the bag. No cryptographic binding between the bag as a whole and an external identity or signing authority.

**AI Attribution:** No AI attribution fields in the BagIt specification. bag-info.txt custom fields could carry AI processing notes by convention.

**Substantiation:** Manifest files provide a verifiable, reproducible integrity record for all payload and tag files. bag-info.txt carries descriptive provenance fields. No mechanism for linking to external trust anchors.

**Interoperability:** BagIt is defined in IETF RFC 8493. Implemented across digital preservation, library, and archival transfer tools and systems.

---

