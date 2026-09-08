# Formats Registry


| ID | Name |
|---|---|
| `bwf` | [Broadcast WAVE Format (BWF)](#format-bwf) |
| `flac` | [FLAC (Free Lossless Audio Codec)](#format-flac) |
| `jpeg` | [JPEG](#format-jpeg) |
| `png` | [PNG (Portable Network Graphics)](#format-png) |
| `tiff` | [TIFF (Tagged Image File Format)](#format-tiff) |
| `mp4-isobmff` | [MP4 / ISO Base Media File Format](#format-mp4-isobmff) |
| `mkv` | [Matroska (MKV)](#format-mkv) |
| `c2pa-manifest` | [C2PA Manifest (Content Credentials)](#format-c2pa-manifest) |
| `xmp` | [XMP (Extensible Metadata Platform)](#format-xmp) |
| `exif` | [EXIF (Exchangeable Image File Format)](#format-exif) |
| `iptc-photo` | [IPTC Photo Metadata Standard 2025.1](#format-iptc-photo) |
| `premis` | [PREMIS (Preservation Metadata)](#format-premis) |
| `bagit` | [BagIt (RFC 8493)](#format-bagit) |
| `mets` | [METS (Metadata Encoding and Transmission Standard)](#format-mets) |

## Broadcast WAVE Format (BWF)

**ID:** `bwf`  
**Type:** audio  
**Structure:** `binary-chunk`  

| Property | Type | Notes |
|---|---|---|
| Readability | `open` | EBU Tech 3285 and FADGI specifications are publicly available; no licensing restrictions on implementation or use. |
| Verifiability | `integrity-only` | No native cryptographic signing. BEXT chunk carries CodingHistory, originator, and origination date/time as advisory provenance fields. BWF may store XMP data. C2PA stored in a custom C2PA RIFF chunk provides cryptographic signing when present. |
| Persistence | | Widely adopted archival audio format with long-term institutional support from EBU, FADGI, and national archives. |

**FDD References:**  
- [FDD000356](https://www.loc.gov/preservation/digital/formats/fdd/fdd000356.shtml) (full: Broadcast WAVE Audio File Format, Version 1)  
- [FDD000357](https://www.loc.gov/preservation/digital/formats/fdd/fdd000357.shtml) (full: Broadcast WAVE Audio File Format, Version 2)  

**URL:** guidelines: <https://www.digitizationguidelines.gov/guidelines/digitize-embedding.html>  

**C2PA Support Modes:**

- **embedded-riff-chunk:** C2PA manifest store may be embedded in a custom C2PA RIFF chunk within the BWF file; hard binding to audio content via C2PA cryptographic signing chain.
- **sidecar:** C2PA manifest store delivered as a standalone .c2pa sidecar file alongside the BWF asset; uses C2PA soft binding. Relationship must be maintained by the packaging or delivery layer.


**Mechanisms:**

| Mechanism | Type | File-level | Content-level | Metadata Integrity |
|---|---|---|---|---|
| [bext-chunk](mechanisms.md#bext-chunk) |  |  |  |  |
| [XMP Embedded Metadata](mechanisms.md#xmp-embedded) | embedded-metadata | embedded-writable | overwrite | none |
| [JUMBF C2PA Manifest Store (Embedded)](mechanisms.md#jumbf-c2pa) | embedded-c2pa | embedded-writable | append-only | signed |
| [PREMIS Sidecar / Embedded Event Record](mechanisms.md#sidecar-premis) | sidecar-metadata | sidecar-writable | append | none |
| [C2PA Sidecar Manifest](mechanisms.md#sidecar-c2pa) | sidecar-c2pa | sidecar-writable | append-only | signed |


EBU/FADGI standard audio format based on RIFF/WAVE. BEXT chunk carries CodingHistory, originator, origination date/time, and UMID. C2PA stored in a custom C2PA RIFF chunk. Widely used as the archival master or primary format for audio in broadcast, library, and archival workflows. Supported by BWF MetaEdit for metadata embedding and validation.


### TCR4CAP Comments

**Awareness:** BWF is a well-established archival audio format. BEXT chunk provenance fields are widely understood in broadcast and archival workflows. C2PA embedding path is defined but not yet widely implemented in BWF-specific tooling.

**Tamper Evidence:** BEXT chunk fields are informative and not integrity-protected. They can be silently overwritten, edited, added, or removed. C2PA RIFF chunk provides cryptographic tamper-evidence when present.

**Binding:** BEXT chunk is structurally embedded. C2PA RIFF chunk provides cryptographic hard binding to audio content when present. An md5 chunk may store the md5 hash of the audio content.

**AI Attribution:** No purpose-built AI attribution fields in the BWF/BEXT specification. AI documentation requires C2PA assertions or repurposing of CodingHistory.

**Substantiation:** BEXT CodingHistory provides a readable transformation record. C2PA manifest store could preserve a full transformation history when present.

**Interoperability:** Open specification (EBU Tech 3285, FADGI). Widely implemented across broadcast, archival, and audio tools.

---

## FLAC (Free Lossless Audio Codec)

**ID:** `flac`  
**Type:** audio  
**Structure:** `binary-block`  

| Property | Type | Notes |
|---|---|---|
| Readability | `open` | Full open specification originally published by Xiph.org and later standardized as IETF RFC 9639; no licensing restrictions on implementation or use. |
| Verifiability | `integrity-only` | Natively stores an MD5 signature of unencoded audio in the STREAMINFO block and CRC-8/CRC-16 checksums per frame (RFC 9639). Provides format-level integrity verification of audio data only; checksums do not cover metadata blocks. No signature or provenance chain in the base format. |
| Persistence | | Open, lossless, widely implemented format. Long-term institutional support via IETF standardization (RFC 9639). |

**FDD References:**  
- [FDD000657](https://www.loc.gov/preservation/digital/formats/fdd/fdd000657.shtml) (full: FLAC Family)  
- [FDD000198](https://www.loc.gov/preservation/digital/formats/fdd/fdd000198.shtml) (full: FLAC (Free Lossless Audio Codec), Version 1.1.2)  


**C2PA Support Modes:**

- **embedded-via-id3:** C2PA manifest store embedded using the ID3 General Encapsulated Object frame (GEOB); hard binding to audio content via C2PA cryptographic signing chain.
- **sidecar:** C2PA manifest store delivered as a standalone .c2pa sidecar file alongside the FLAC asset; uses C2PA soft binding. Relationship must be maintained by the packaging or delivery layer.


**Mechanisms:**

| Mechanism | Type | File-level | Content-level | Metadata Integrity |
|---|---|---|---|---|
| [Vorbis Comment](mechanisms.md#vorbis-comment) | embedded-metadata | embedded-writable | overwrite | none |
| [ID3 General Encapsulated Object (GEOB) — C2PA](mechanisms.md#id3-geob-c2pa) | embedded-c2pa | embedded-writable | append-only | signed |
| [XMP Embedded Metadata](mechanisms.md#xmp-embedded) | embedded-metadata | embedded-writable | overwrite | none |
| [PREMIS Sidecar / Embedded Event Record](mechanisms.md#sidecar-premis) | sidecar-metadata | sidecar-writable | append | none |
| [C2PA Sidecar Manifest](mechanisms.md#sidecar-c2pa) | sidecar-c2pa | sidecar-writable | append-only | signed |


A container for the FLAC lossless audio codec. C2PA embedding is supported via ID3 using the General Encapsulated Object frame (GEOB). Natively stores an MD5 signature of unencoded audio in the STREAMINFO block and CRC-8/CRC-16 checksums per frame (RFC 9639), providing format-level integrity verification of audio data. These checksums do not cover metadata blocks.


### TCR4CAP Comments

**Awareness:** C2PA-specific awareness in FLAC workflows is not yet common. The GEOB embedding path is defined but not widely recognized in tooling or policy.

**Tamper Evidence:** Native MD5 (STREAMINFO) and per-frame CRCs (RFC 9639) provide structured format-level integrity of audio data. These do not cover metadata blocks; tamper-evidence of CAP data depends on the mechanism used.

**Binding:** The format defines discrete metadata blocks and a specified C2PA embedding location (ID3 GEOB). Binding strength depends on the mechanism used.

**AI Attribution:** No purpose-built AI attribution fields in the FLAC or Vorbis Comment specification. Any AI documentation requires repurposing general fields or use of C2PA via GEOB.

**Substantiation:** FLAC metadata is open and readable. No formal mechanism for publishing transformation history or CAP policies at point of access at the format level.

**Interoperability:** Open specification (Xiph.org, RFC 9639). Widely implemented across tools and platforms. ID3 broadly supported.

---

## JPEG

**ID:** `jpeg`  
**Type:** image  
**Structure:** `binary-segment`  

| Property | Type | Notes |
|---|---|---|
| Readability | `published-standard` | ISO/IEC 10918 and ITU-T T.81; open standard with no licensing restrictions on implementation or use. |
| Verifiability | `signed` | C2PA stored in APP11 (0xFFEB) chunk provides cryptographic signing and hard binding to image content. EXIF, IPTC, and XMP metadata in APP1/APP13 are informative and not integrity-protected. JPEG Trust (ISO/IEC 21617) provides an additional trust framework. |
| Persistence | | Lossy compression limits use as an archival master or primary format; widely used for distribution and delivery. C2PA manifest survives most JPEG-preserving operations. |

**FDD References:**  
- [FDD000017](https://www.loc.gov/preservation/digital/formats/fdd/fdd000017.shtml) (full: JPEG Image Encoding Family)  
- [FDD000018](https://www.loc.gov/preservation/digital/formats/fdd/fdd000018.shtml) (full: JFIF, JPEG File Interchange Format, Version 1.02)  
- [FDD000147](https://www.loc.gov/preservation/digital/formats/fdd/fdd000147.shtml) (full: JPEG Encoded File with Exif Metadata)  
- [FDD000538](https://www.loc.gov/preservation/digital/formats/fdd/fdd000538.shtml) (preliminary: JPEG XL File Format)  
- [FDD000653](https://www.loc.gov/preservation/digital/formats/fdd/fdd000653.shtml) (partial: JPEG Universal Metadata Box Format (JUMBF))  
- [FDD000655](https://www.loc.gov/preservation/digital/formats/fdd/fdd000655.shtml) (preliminary: JPEG XT (JPEG eXTension))  

**URL:** homepage: <https://jpeg.org/>  

**C2PA Support Modes:**

- **embedded-app11:** C2PA manifest store embedded in APP11 (0xFFEB) chunk. Multiple sequential APP11 segments used for large manifests. Hard binding to image content via content hash. The C2PA Technical Specifications cite JPEG XT, ISO/IEC 18477-3 (which defines the JPEG file format) as the basis of the definition of the APP11 structure that stores the C2PA manifest store. If a manifest is embedded in the center of a JPEG-1 file in an APP11 segment, the claim creator may exclude the APP11 segment(s) from the hash calculation, as defined in C2PA specification 2.4.
- **sidecar:** C2PA manifest store delivered as a standalone .c2pa sidecar file; uses C2PA soft binding.


**Mechanisms:**

| Mechanism | Type | File-level | Content-level | Metadata Integrity |
|---|---|---|---|---|
| [EXIF Embedded Metadata](mechanisms.md#exif-embedded) | embedded-metadata | embedded-writable | overwrite | none |
| [XMP Embedded Metadata](mechanisms.md#xmp-embedded) | embedded-metadata | embedded-writable | overwrite | none |
| [IPTC Photo Metadata](mechanisms.md#iptc-photo) | embedded-metadata | embedded-writable | overwrite | none |
| [JUMBF C2PA Manifest Store (Embedded)](mechanisms.md#jumbf-c2pa) | embedded-c2pa | embedded-writable | append-only | signed |
| [PREMIS Sidecar / Embedded Event Record](mechanisms.md#sidecar-premis) | sidecar-metadata | sidecar-writable | append | none |
| [C2PA Sidecar Manifest](mechanisms.md#sidecar-c2pa) | sidecar-c2pa | sidecar-writable | append-only | signed |


JPEG (ISO/IEC 10918) is a dominant photographic image format with a segment-based structure (SOI, APPn, DQT, DHT, SOS, EOI). Supports EXIF (APP1), IPTC (APP13), and XMP (APP1) metadata. JPEG Trust (ISO/IEC 21617) provides an additional trust framework. Widely adopted by camera manufacturers (Leica M11-P, Nikon Z6 III) for C2PA signing at capture.


### TCR4CAP Comments

**Awareness:** JPEG is a widely deployed image format and has relatively extensive support with metadata processing tools. C2PA embedding in APP11 is a defined, published standard with broad industry adoption.

**Tamper Evidence:** C2PA APP11 chunk provides cryptographic tamper-evidence via signed manifests and hard binding to image content.

**Binding:** C2PA hard binding via content hash provides cryptographic linkage between manifest and image content.

**AI Attribution:** C2PA AI attribution assertions (c2pa.ai.generatedWith, c2pa.training-mining) and IPTC 2025.1 AI fields are both supported in JPEG.

**Substantiation:** C2PA manifest store preserves full transformation history. External trust anchors supported. Public verification via contentcredentials.org.

**Interoperability:** Universally implemented across cameras, phones, image editing tools, and repository systems.

---

## PNG (Portable Network Graphics)

**ID:** `png`  
**Type:** image  
**Structure:** `binary-chunk`  

| Property | Type | Notes |
|---|---|---|
| Readability | `open` | ISO/IEC 15948 and W3C PNG specification; open standard with no licensing restrictions. |
| Verifiability | `signed` | C2PA stored in custom caBX chunk provides cryptographic signing and hard binding to image content. XMP and EXIF metadata in iTXt/eXIf chunks are informative and not integrity-protected. PNG CRC checksums provide per-chunk structural integrity only. |
| Persistence | | Lossless compression; widely used as an archival and distribution format for images requiring transparency or lossless fidelity. Recommended by FADGI for Documents (Unbound): Modern Textual Records: https://www.digitizationguidelines.gov/guidelines/FADGITechnicalGuidelinesforDigitizingCulturalHeritageMaterials_ThirdEdition_05092023.pdf |

**FDD References:**  
- [FDD000153](https://www.loc.gov/preservation/digital/formats/fdd/fdd000153.shtml) (full: Portable Network Graphics)  


**C2PA Support Modes:**

- **embedded-cabx-chunk:** C2PA manifest store embedded in custom caBX chunk. Hard binding to image content via content hash.
- **sidecar:** C2PA manifest store delivered as a standalone .c2pa sidecar file; uses C2PA soft binding.


**Mechanisms:**

| Mechanism | Type | File-level | Content-level | Metadata Integrity |
|---|---|---|---|---|
| [EXIF Embedded Metadata](mechanisms.md#exif-embedded) | embedded-metadata | embedded-writable | overwrite | none |
| [XMP Embedded Metadata](mechanisms.md#xmp-embedded) | embedded-metadata | embedded-writable | overwrite | none |
| [IPTC Photo Metadata](mechanisms.md#iptc-photo) | embedded-metadata | embedded-writable | overwrite | none |
| [JUMBF C2PA Manifest Store (Embedded)](mechanisms.md#jumbf-c2pa) | embedded-c2pa | embedded-writable | append-only | signed |
| [PREMIS Sidecar / Embedded Event Record](mechanisms.md#sidecar-premis) | sidecar-metadata | sidecar-writable | append | none |
| [C2PA Sidecar Manifest](mechanisms.md#sidecar-c2pa) | sidecar-c2pa | sidecar-writable | append-only | signed |


PNG (ISO/IEC 15948) is a lossless image format with a chunk-based structure. C2PA stored in custom caBX chunk. Also supports XMP (iTXt), EXIF (eXIf), and text metadata (tEXt/zTXt) chunks. Strong archival format; widely used for images requiring transparency or lossless fidelity.


### TCR4CAP Comments

**Awareness:** PNG is a widely deployed image format. C2PA embedding in caBX chunk is a defined, published standard.

**Tamper Evidence:** C2PA caBX chunk provides cryptographic tamper-evidence via signed manifests and hard binding to image content.

**Binding:** C2PA hard binding via content hash provides cryptographic linkage between manifest and image content.

**AI Attribution:** C2PA AI attribution assertions and IPTC 2025.1 AI fields are both supported in PNG.

**Substantiation:** C2PA manifest store preserves full transformation history. External trust anchors supported.

**Interoperability:** Widely implemented across image editing tools, browsers, and repository systems.

---

## TIFF (Tagged Image File Format)

**ID:** `tiff`  
**Type:** image  
**Structure:** `binary`  

| Property | Type | Notes |
|---|---|---|
| Readability | `open` | Open standard with no licensing restrictions on implementation or use. |
| Verifiability | `signed` | C2PA manifests can be natively embedded in TIFF via a JUMBF box stored in the IFD structure, as defined in C2PA specification 2.4, providing cryptographic signing and hard binding to the content. A sidecar .c2pa file is also supported as an alternative delivery path. Native TIFF metadata (EXIF, IPTC, XMP) is informative and not integrity-protected outside of C2PA. |
| Persistence | | Widely used archival image format; long-term institutional support from libraries, archives, and digitization programs. Recommended by FADGI for Documents (Unbound): Modern Textual Records: https://www.digitizationguidelines.gov/guidelines/FADGITechnicalGuidelinesforDigitizingCulturalHeritageMaterials_ThirdEdition_05092023.pdf |

**FDD References:**  
- [FDD000022](https://www.loc.gov/preservation/digital/formats/fdd/fdd000022.shtml) (full: TIFF, Revision 6.0)  
- [FDD000145](https://www.loc.gov/preservation/digital/formats/fdd/fdd000145.shtml) (full: TIFF Uncompressed File with Exif Metadata)  


**C2PA Support Modes:**

- **embedded-jumbf-ifd:** C2PA manifest store embedded via a JUMBF box stored in the TIFF IFD structure, as defined in C2PA specification 2.4. Hard binding to image content via C2PA cryptographic signing chain. Use of a general box binding is strongly recommended per C2PA guidance.
- **sidecar:** C2PA manifest store delivered as a standalone .c2pa sidecar file alongside the TIFF asset; uses C2PA soft binding. Relationship must be maintained by the packaging or delivery layer.


**Mechanisms:**

| Mechanism | Type | File-level | Content-level | Metadata Integrity |
|---|---|---|---|---|
| [EXIF Embedded Metadata](mechanisms.md#exif-embedded) | embedded-metadata | embedded-writable | overwrite | none |
| [XMP Embedded Metadata](mechanisms.md#xmp-embedded) | embedded-metadata | embedded-writable | overwrite | none |
| [IPTC Photo Metadata](mechanisms.md#iptc-photo) | embedded-metadata | embedded-writable | overwrite | none |
| [JUMBF C2PA Manifest Store (Embedded)](mechanisms.md#jumbf-c2pa) | embedded-c2pa | embedded-writable | append-only | signed |
| [C2PA Sidecar Manifest](mechanisms.md#sidecar-c2pa) | sidecar-c2pa | sidecar-writable | append-only | signed |
| [PREMIS Sidecar / Embedded Event Record](mechanisms.md#sidecar-premis) | sidecar-metadata | sidecar-writable | append | none |


TIFF is a widely used archival image format with a tag-based IFD structure. Supports EXIF (SubIFD), IPTC (tag 33723), and XMP (tag 700) metadata. C2PA manifests can be natively embedded via a JUMBF box in the IFD structure per C2PA specification 2.4; a sidecar .c2pa file is also supported. Common digitization master or primary format in library and archival workflows.


### TCR4CAP Comments

**Awareness:** TIFF is a well-established archival format recommended by FADGI for digitization of cultural heritage materials. EXIF, IPTC, and XMP provenance fields are widely understood. C2PA embedding via JUMBF box in the IFD structure is defined in C2PA specification 2.4 but not yet widely implemented in TIFF-specific tooling.

**Tamper Evidence:** EXIF, IPTC, and XMP metadata are informative and not integrity-protected. C2PA JUMBF embedding provides cryptographic tamper-evidence via signed manifests and hard binding to image content when present.

**Binding:** C2PA hard binding via content hash provides cryptographic linkage between manifest and image content when embedded. Sidecar binding is soft and depends on file management conventions.

**AI Attribution:** C2PA AI attribution assertions (c2pa.ai.generatedWith, c2pa.training-mining) and IPTC 2025.1 AI fields (via XMP) are both supported in TIFF.

**Substantiation:** EXIF, IPTC, and XMP provide a readable provenance record. C2PA manifest store preserves full transformation history when present. PREMIS sidecar provides institutional transformation history.

**Interoperability:** Universally implemented across image editing tools, scanners, and repository systems.

---

## MP4 / ISO Base Media File Format

**ID:** `mp4-isobmff`  
**Type:** moving image  
**Structure:** `binary-atom`  

| Property | Type | Notes |
|---|---|---|
| Readability | `published-standard` | ISO/IEC 14496-12 (ISOBMFF); open standard. MP4 file format (ISO/IEC 14496-14) and related derivatives (MOV, MJ2, 3GP) are based on the same box/atom structure. |
| Verifiability | `signed` | C2PA stored in uuid atom provides cryptographic signing and hard binding to video content. XMP and other metadata atoms are informative and not integrity-protected. |
| Persistence | | Widely used video container format; long-term institutional support from ISO, MPEG, and industry. Widely used for archival and distribution of video content. |

**FDD References:**  
- [FDD000079](https://www.loc.gov/preservation/digital/formats/fdd/fdd000079.shtml) (full: ISO Base Media File Format)  
- [FDD000155](https://www.loc.gov/preservation/digital/formats/fdd/fdd000155.shtml) (full: MPEG-4 File Format, Version 2)  
- [FDD000525](https://www.loc.gov/preservation/digital/formats/fdd/fdd000525.shtml) (preliminary: High Efficiency Image File (HEIF) Format, MPEG-H Part 12)  


**C2PA Support Modes:**

- **embedded-uuid-atom:** C2PA manifest store embedded in uuid atom (UUID: d8fec3d6-1b0e-483c-9297-5844b8f49b68). Hard binding to video content via content hash. Covers MP4, MOV, MJ2, 3GP, and other ISO-BMFF derivatives.
- **sidecar:** C2PA manifest store delivered as a standalone .c2pa sidecar file; uses C2PA soft binding.


**Mechanisms:**

| Mechanism | Type | File-level | Content-level | Metadata Integrity |
|---|---|---|---|---|
| [XMP Embedded Metadata](mechanisms.md#xmp-embedded) | embedded-metadata | embedded-writable | overwrite | none |
| [JUMBF C2PA Manifest Store (Embedded)](mechanisms.md#jumbf-c2pa) | embedded-c2pa | embedded-writable | append-only | signed |
| [PREMIS Sidecar / Embedded Event Record](mechanisms.md#sidecar-premis) | sidecar-metadata | sidecar-writable | append | none |
| [C2PA Sidecar Manifest](mechanisms.md#sidecar-c2pa) | sidecar-c2pa | sidecar-writable | append-only | signed |


MP4 / ISO Base Media File Format (ISO/IEC 14496-12) is the primary video container format for C2PA implementations. C2PA stored in uuid atom. Covers MP4, MOV, MJ2, 3GP, and other ISO-BMFF derivatives. Supports XMP, IPTC, and other metadata in dedicated atoms.


### TCR4CAP Comments

**Awareness:** MP4/ISOBMFF is the widely used video container format. C2PA embedding in uuid atom is a defined, published standard with growing industry adoption.

**Tamper Evidence:** C2PA uuid atom provides cryptographic tamper-evidence via signed manifests and hard binding to video content.

**Binding:** C2PA hard binding via content hash provides cryptographic linkage between manifest and video content.

**AI Attribution:** C2PA AI attribution assertions (c2pa.ai.generatedWith, c2pa.training-mining) are fully supported in MP4/ISOBMFF.

**Substantiation:** C2PA manifest store preserves full transformation history. External trust anchors supported.

**Interoperability:** Universally implemented across video tools, cameras, and repository systems.

---

## Matroska (MKV)

**ID:** `mkv`  
**Type:** moving image  
**Structure:** `binary-ebml`  

| Property | Type | Notes |
|---|---|---|
| Readability | `open` | Matroska specification published by the Matroska.org community; IETF RFC 9559 (EBML) provides the underlying container standard. |
| Verifiability | `none` | No native cryptographic signing (though an early EBML draft included an Element signing feature which was dropped before standardization). Tag and attachment elements can store UTF-8 and binary metadata. Any Matroska Element may store a hash of the following content of the Element. This feature can verify integrity of the Element against the stored hash (if it exists), but there is no signature mechanism. No C2PA embedding path is defined in the C2PA Technical Specification as of 2026-06. |
| Persistence | | Open container format. Widely used in archival video workflows and video distribution. Long-term support from the Matroska community and IETF Cellar working group. |

**FDD References:**  
- [FDD000342](https://www.loc.gov/preservation/digital/formats/fdd/fdd000342.shtml) (full: Matroska Multimedia Container)  
- [FDD000516](https://www.loc.gov/preservation/digital/formats/fdd/fdd000516.shtml) (preliminary: Extensible Binary Meta Language)  


**C2PA Support Modes:**

- **sidecar:** C2PA manifest store delivered as a standalone .c2pa sidecar file alongside the MKV asset; uses C2PA soft binding. No native MKV embedding path is defined in the C2PA Technical Specification as of 2026-05.


**Mechanisms:**

| Mechanism | Type | File-level | Content-level | Metadata Integrity |
|---|---|---|---|---|
| [XMP Embedded Metadata](mechanisms.md#xmp-embedded) | embedded-metadata | embedded-writable | overwrite | none |
| [C2PA Sidecar Manifest](mechanisms.md#sidecar-c2pa) | sidecar-c2pa | sidecar-writable | append-only | signed |
| [PREMIS Sidecar / Embedded Event Record](mechanisms.md#sidecar-premis) | sidecar-metadata | sidecar-writable | append | none |


Matroska (MKV) is an open container format based on EBML (RFC 9559). Supports tags and attachments for metadata. No native C2PA embedding path defined as of 2026-05. Used in some archival video workflows and widely in consumer distribution.


### TCR4CAP Comments

**Awareness:** Matroska is a well-known container format. No native C2PA embedding path is defined; C2PA awareness in MKV workflows is limited.

**Tamper Evidence:** No native cryptographic signing. Tag and attachment metadata are advisory and not integrity-protected. C2PA sidecar provides tamper-evidence but can be separated from the asset.

**Binding:** No native C2PA embedding path. Sidecar binding is soft and depends on file management conventions.

**AI Attribution:** No purpose-built AI attribution fields in the Matroska specification. AI documentation requires C2PA sidecar or repurposing of tag elements.

**Substantiation:** Tag elements provide a readable metadata record. No formal mechanism for publishing transformation history at the format level.

**Interoperability:** Open specification. Widely implemented across video tools and platforms.

---

## C2PA Manifest (Content Credentials)

**ID:** `c2pa-manifest`  
**Type:** metadata  
**Structure:** `cbor-jumbf`  

| Property | Type | Notes |
|---|---|---|
| Readability | `published-standard` | C2PA Technical Specification published by the Coalition for Content Provenance and Authenticity; open specification with reference implementation (c2pa-rs) under open-source license. |
| Verifiability | `signed` | Each manifest is cryptographically signed using CMS/COSE. Hard binding links the manifest to the asset content via content hash. The manifest store is append-only; prior manifests are preserved as ingredient references. Any modification to a manifest or to the asset content invalidates the signature or binding. |
| Persistence | | Append-only manifest store preserves the full provenance chain across the asset lifecycle. Signed manifests are immutable. External trust anchors (TSA, credential issuers) provide long-term verifiability. |


**C2PA Support Modes:**

- **embedded:** Embedded in host files via format-specific JUMBF containers (APP11 in JPEG, caBX in PNG, uuid atom in MP4/ISOBMFF, C2PA RIFF chunk in WAV/BWF).
- **sidecar:** Stored as a standalone .c2pa sidecar file alongside the asset.


Core C2PA metadata format. CBOR-encoded assertions in a JUMBF container. Cryptographically signed using CMS/COSE. Embedded in media files via format-specific containers or stored as a standalone .c2pa sidecar file. Supports hard binding (content hash) and soft binding (perceptual identifier). Defines purpose-built assertions for AI generative and training provenance (c2pa.ai.generatedWith, c2pa.training-mining). The manifest store is append-only; prior manifests are preserved as ingredient references.


### TCR4CAP Comments

**Awareness:** C2PA Technical Specification is published by the Coalition for Content Provenance and Authenticity. Adopted by Adobe, Microsoft, Google, camera manufacturers, and news organizations.

**Tamper Evidence:** Each manifest is cryptographically signed; any modification invalidates the signature. Hard binding means any modification to the asset content invalidates the active manifest.

**Binding:** Hard binding provides cryptographic linkage between manifest and asset content via content hash. Soft binding provides a defined alternative for non-embeddable assets.

**AI Attribution:** C2PA defines purpose-built assertions for AI generative and training provenance: c2pa.ai.generatedWith, c2pa.training-mining, and related fields for model identity and generation parameters.

**Substantiation:** Manifest store preserves full transformation history. External trust anchors (credential issuers, TSA) are supported. Public verification is possible via the C2PA trust list.

**Interoperability:** Open published specification. Reference implementation (c2patool, c2pa-rs) available under open-source license. Adopted across image, video, and audio tools and camera manufacturers.

---

## XMP (Extensible Metadata Platform)

**ID:** `xmp`  
**Type:** metadata  
**Structure:** `xml-rdf`  

| Property | Type | Notes |
|---|---|---|
| Readability | `published-standard` | ISO 16684; open standard with no licensing restrictions on implementation or use. |
| Verifiability | `none` | XMP packets have no integrity protection; properties can be silently overwritten or the entire packet stripped without detection. xmpMM:History entries are advisory and unverified. |
| Persistence | | XMP packets can be stripped by processing tools; persistence depends on tool behavior and workflow policy. Sidecar .xmp files can be managed independently. |


**C2PA Support Modes:**

- **none:** XMP has no native C2PA support. IPTC 2025.1 AI fields carried in XMP namespaces provide structured AI attribution but without cryptographic protection.


XMP (ISO 16684) is an RDF/XML metadata format embedded in host files or stored as standalone .xmp sidecar files. Supports multiple namespaces including Dublin Core (dc:), XMP Basic (xmp:), XMP Media Management (xmpMM:), and IPTC (Iptc4xmpCore/Ext:). The xmpMM:History array provides a conventional provenance record. XMP packets have no integrity protection.


### TCR4CAP Comments

**Awareness:** XMP is defined in ISO 16684. Implemented across all major creative, archival, and repository tools. xmpMM:History and xmpMM:DerivedFrom are recognized provenance fields.

**Tamper Evidence:** XMP packets have no integrity protection. Properties can be silently overwritten or the entire packet stripped.

**Binding:** XMP is structurally embedded in host files but there is no cryptographic binding between XMP content and the primary media data.

**AI Attribution:** IPTC 2025.1 AI fields (AiPrompt, AiSystemUsed, AiSystemVersion) are carried in XMP namespaces. No purpose-built AI attribution fields are defined in the core XMP specification.

**Substantiation:** xmpMM:History and xmpMM:DerivedFrom provide a readable provenance record. XMP sidecar files can be published independently.

**Interoperability:** ISO 16684. Implemented across all major creative, archival, and repository tools.

---

## EXIF (Exchangeable Image File Format)

**ID:** `exif`  
**Type:** metadata  
**Structure:** `binary`  

| Property | Type | Notes |
|---|---|---|
| Readability | `open` | CIPA DC-008; open standard with no licensing restrictions on implementation or use. |
| Verifiability | `none` | EXIF data has no integrity protection; tags can be silently overwritten or stripped without detection. No provenance chain mechanism in the EXIF specification. |
| Persistence | | EXIF data can be stripped by processing tools; persistence depends on tool behavior and workflow policy. |


**C2PA Support Modes:**

- **none:** EXIF has no native C2PA support. EXIF capture device and datetime fields are referenced by C2PA assertions but are not themselves integrity-protected.


EXIF (CIPA DC-008) is a binary metadata standard using an IFD tag structure. Records capture device identity, camera settings, GPS coordinates, and datetime. Embedded in JPEG APP1, TIFF SubIFD, PNG eXIf chunk, and HEIF. EXIF data has no integrity protection and can be silently overwritten or stripped.


### TCR4CAP Comments

**Awareness:** EXIF is defined by CIPA DC-008. Universally implemented across cameras, phones, and image processing tools. Capture device identity and datetime fields are widely used as provenance indicators.

**Tamper Evidence:** EXIF data has no integrity protection. Tags can be silently overwritten or stripped.

**Binding:** EXIF is structurally embedded in host files but there is no cryptographic binding between EXIF tag values and the image content.

**AI Attribution:** No AI attribution fields are defined in the EXIF specification. Software (0x0131) can record processing tool identity but has no structured AI attribution vocabulary.

**Substantiation:** Capture datetime, GPS, and device fields provide a factual provenance record. No mechanism links EXIF fields to external policies or transformation histories.

**Interoperability:** CIPA DC-008. Universally implemented across cameras, phones, and image processing tools.

---

## IPTC Photo Metadata Standard 2025.1

**ID:** `iptc-photo`  
**Type:** metadata  
**Structure:** `xml-xmp`  

| Property | Type | Notes |
|---|---|---|
| Readability | `open` | IPTC Photo Metadata Standard published by IPTC; open standard with no licensing restrictions on implementation or use. |
| Verifiability | `none` | IPTC fields carried in XMP have no integrity protection; fields can be silently overwritten or stripped without detection. |
| Persistence | | IPTC fields carried in XMP can be stripped by processing tools; persistence depends on tool behavior and workflow policy. |


**C2PA Support Modes:**

- **none:** IPTC Photo Metadata has no native C2PA support. IPTC 2025.1 AI fields provide structured AI attribution in XMP namespaces but without cryptographic protection.


The IPTC Photo Metadata Standard defines a vocabulary of fields carried in XMP namespaces (Iptc4xmpCore, Iptc4xmpExt). Version 2025.1 adds dedicated AI fields: AiPrompt (11.2), AiSystemUsed (11.4), AiSystemVersion (11.5), and DataMiningPermission (11.11). Widely used in photojournalism, stock photography, and digital asset management.


### TCR4CAP Comments

**Awareness:** IPTC Photo Metadata Standard is published by IPTC. Version 2025.1 AI fields are defined in the specification. Widely implemented in photo editing, DAM, and publishing tools.

**Tamper Evidence:** IPTC fields carried in XMP have no integrity protection. Fields can be silently overwritten or stripped.

**Binding:** IPTC fields are structurally embedded via XMP in host files but there is no cryptographic binding between field values and the image content.

**AI Attribution:** Version 2025.1 defines AiPrompt, AiSystemUsed, AiSystemVersion, and DataMiningPermission as purpose-built, standardized AI attribution fields within the IPTC vocabulary.

**Substantiation:** IPTC fields provide a structured, readable provenance record. The standard is publicly documented.

**Interoperability:** Implemented in photo editing, DAM, and publishing tools including Adobe Photoshop, Lightroom, and Capture One.

---

## PREMIS (Preservation Metadata)

**ID:** `premis`  
**Type:** metadata  
**Structure:** `xml`  

| Property | Type | Notes |
|---|---|---|
| Readability | `open` | PREMIS Data Dictionary published by the Library of Congress; open standard with no licensing restrictions on implementation or use. |
| Verifiability | `integrity-only` | PREMIS XML has no native integrity protection; tamper-evidence depends on the repository or packaging layer (e.g. BagIt fixity, audit logs). Fixity values in objectCharacteristics/fixity link the PREMIS record to a specific file state. |
| Persistence | | PREMIS is designed for long-term institutional preservation. Widely implemented in repository systems with long-term support from the Library of Congress. |


**C2PA Support Modes:**

- **none:** PREMIS has no native C2PA support. PREMIS events map conceptually to C2PA actions (c2pa.created, c2pa.converted, c2pa.edited); PREMIS agent maps to C2PA softwareAgent or person assertions.


PREMIS (Library of Congress) is an XML schema for recording preservation metadata. Models Objects, Events, Agents, and Rights. PREMIS events map to C2PA actions; PREMIS agent maps to C2PA softwareAgent or person assertions. Generated by preservation systems including Archivematica, DSpace, and Fedora. PREMIS XML has no native integrity protection; tamper-evidence depends on the repository or packaging layer.


### TCR4CAP Comments

**Awareness:** PREMIS Data Dictionary is published by the Library of Congress. Implemented in Archivematica, DSpace, Fedora, and other repository systems.

**Tamper Evidence:** PREMIS XML has no integrity protection. Tamper-evidence depends on the repository or packaging layer.

**Binding:** Fixity values in objectCharacteristics/fixity link the PREMIS record to a specific file state. Binding is not cryptographically enforced within the PREMIS document itself.

**AI Attribution:** No purpose-built AI attribution fields in the PREMIS Data Dictionary. Agent/agentType and eventType vocabularies could accommodate AI agents and events by convention.

**Substantiation:** PREMIS event records provide a structured, policy-driven transformation history. The PREMIS Data Dictionary is an open standard. Event records are auditable by repository administrators.

**Interoperability:** Published by the Library of Congress as an open standard. Implemented across major digital preservation systems and repository platforms.

---

## BagIt (RFC 8493)

**ID:** `bagit`  
**Type:** metadata  
**Structure:** `text-manifest`  

| Property | Type | Notes |
|---|---|---|
| Readability | `open` | IETF RFC 8493; open standard with no licensing restrictions on implementation or use. |
| Verifiability | `integrity-only` | Manifest files (manifest-*.txt) record checksums for all payload files; tag manifests (tagmanifest-*.txt) record checksums for all tag files. Any modification to a payload or tag file produces a checksum mismatch detectable by bag validation. No signing mechanism; the manifest files themselves could be replaced along with modified payload files without detection at the BagIt level. |
| Persistence | | BagIt is widely adopted in digital preservation, library, and archival transfer workflows. Long-term support from the Library of Congress and IETF standardization. |


**C2PA Support Modes:**

- **none:** BagIt has no native C2PA support. C2PA sidecar files can be included as payload files within a bag; bag-info.txt custom fields could carry AI processing notes by convention.


BagIt (IETF RFC 8493) is a hierarchical file packaging format for reliable digital transfer and storage. A bag contains a payload directory, manifest files recording checksums for all payload files, tag files carrying descriptive metadata, and tag manifest files recording checksums for tag files. Operates at the package level; does not interact with file-level metadata mechanisms. Supported algorithms include MD5, SHA-1, SHA-256, and SHA-512.


### TCR4CAP Comments

**Awareness:** BagIt is defined in IETF RFC 8493. Widely adopted in digital preservation, library, and archival transfer workflows.

**Tamper Evidence:** Manifest checksums detect modification of any payload or tag file. No signing mechanism at the BagIt level.

**Binding:** Manifest entries bind each checksum to a specific file path within the bag. No cryptographic binding between the bag as a whole and an external identity or signing authority.

**AI Attribution:** No AI attribution fields in the BagIt specification. bag-info.txt custom fields could carry AI processing notes by convention.

**Substantiation:** Manifest files provide a verifiable, reproducible integrity record for all payload and tag files. bag-info.txt carries descriptive provenance fields.

**Interoperability:** IETF RFC 8493. Implemented across digital preservation, library, and archival transfer tools and systems.

---

## METS (Metadata Encoding and Transmission Standard)

**ID:** `mets`  
**Type:** metadata  
**Structure:** `xml`  

| Property | Type | Notes |
|---|---|---|
| Readability | `open` | METS schema published by the Library of Congress; open standard with no licensing restrictions on implementation or use. |
| Verifiability | `integrity-only` | METS XML has no native integrity protection; tamper-evidence depends on the repository or packaging layer. METS can carry fixity values for described files in the fileSec/fileGrp/file/FLocat elements. |
| Persistence | | METS is designed for long-term institutional preservation. Widely implemented in repository systems with long-term support from the Library of Congress. |


**C2PA Support Modes:**

- **none:** METS has no native C2PA support. METS can reference C2PA sidecar files as file objects within the fileSec; PREMIS events carried in the amdSec can document C2PA-related processing actions.


METS (Library of Congress) is an XML standard for encoding descriptive, administrative, and structural metadata for digital objects. Sections include dmdSec (descriptive), amdSec (administrative, including PREMIS), fileSec (file inventory), and structMap (structural). Used by Archivematica, DSpace, and many repository systems. METS XML has no native integrity protection; tamper-evidence depends on the repository or packaging layer.


### TCR4CAP Comments

**Awareness:** METS schema is published by the Library of Congress. Implemented in Archivematica, DSpace, and other repository systems.

**Tamper Evidence:** METS XML has no integrity protection. Tamper-evidence depends on the repository or packaging layer.

**Binding:** METS fileSec references described files by path and can carry fixity values. Binding is not cryptographically enforced within the METS document itself.

**AI Attribution:** No purpose-built AI attribution fields in the METS schema. PREMIS events in the amdSec could document AI processing actions by convention.

**Substantiation:** METS provides a structured, comprehensive metadata record for digital objects. Widely supported by repository systems.

**Interoperability:** Published by the Library of Congress as an open standard. Implemented across major digital preservation systems and repository platforms.

---

