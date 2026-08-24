# Content Authenticity and Provenance for Audiovisual Collections: An Environmental Review

## Authorship

**Author:** David Rice

**Prepared for:** Library of Congress

**Date:** August 2026

## Overview

This report provides an environmental overview of Content Authenticity and Provenance (CAP) metadata for digital audiovisual collections, covering both digitized and born-digital materials. It examines the current state of CAP-related tools, formats, and mechanisms available to the audiovisual preservation community, with particular attention to free and open source software (FOSS) and to the C2PA (Coalition for Content Provenance and Authenticity) specification as the emerging technical standard for signed provenance manifests.

The report is structured in three parts:

1. **Registries:** A systematic registry of tools, file formats, and provenance mechanisms, each summarized against a set of CAP-relevant terms. The registry provides a reference for understanding what exists in the ecosystem and how each component relates to content authenticity and provenance.

2. **Featured Tools:** A closer examination of selected FOSS tools that are central to audiovisual preservation workflows (FFmpeg, BWF MetaEdit, vrecord, MediaInfo, and embARC). For each tool, this section describes its current role in provenance documentation, worked examples showing how its outputs can be mapped to C2PA manifest structures, and considerations for integration into a CAP workflow. This section also maps tool capabilities to the emerging TCR4CAP (Tiered Community Recommendations for Content Authenticity and Provenance) criteria being developed by the FADGI Audio-Visual Working Group.

3. **Appendices:** Technical appendices detailing a proof-of-concept implementation plan for integrating C2PA manifest generation into embARC and BWF MetaEdit, the FADGI metadata auditing and correction tools for DPX, MXF, and WAV files. The appendices address the specific architectural challenges of embedding or sidecarring C2PA manifests in DPX image sequences, including hashing strategies that preserve each tool's design priority of not modifying audiovisual data.

## Background and Motivation

With the rapid proliferation of generative AI tools, reliable information about the origins of images and audio has become increasingly critical. Generative AI images, along with other forms of media manipulation, have an alarming capacity to mislead, confuse, or distort perceptions of current moments and historic realities. A blending of artificial records with authentic ones adds fear, uncertainty, and doubt, and can place persuasion and truth into a confusing conflict.

Archives generally serve as institutions of trust by storing records, sustaining them as authentically as possible against manipulation and decay, and then facilitating access accurately for future users. As a result, archivists have long considered the concepts of Content Authenticity and Provenance in the design of their workflows. These concepts can be seen clearly through the principal standards on archival workflow design such as OAIS (the Open Archival Information System reference model) and the NDSA Levels of Digital Preservation, and in metadata standards themselves such as PREMIS.

For archives, the abundance of media and information artificially produced by generative AI has accelerated the urgency of CAP and expanded the expectations placed upon it. The C2PA specification, developed by a coalition of companies including Adobe, Google, Microsoft, Sony, and others, provides a technical framework for cryptographically signed provenance manifests that can be embedded in or attached to digital files. While C2PA was designed primarily for editorial photography and journalism workflows, its architecture is general enough to apply to audiovisual preservation, and this report examines that applicability in detail.

## A Framework for Assessing CAP Maturity

To organize the environmental review, this report assesses tools, formats, and mechanisms against four qualities that together describe a spectrum of CAP maturity. These qualities are not a tiered standard (such as the case with FADGI Working Group's forthcoming TCR4CAP framework), but rather an analytical model for evaluating where the field currently stands and where further effort and collaboration could have the most impact.

### Awareness

At the most fundamental level, archives should be aware of what information is available that could support the perceived authenticity or provenance of their records. Such information may be generated through intentional practices such as registration forms, may happen to exist within a digital file, or be present in logs related to the records.

Examples include metadata embedded within a digital record that provides context to the record's creation, such as the name and version of the creation tool, the creation date, or the name of the user that created it. The purpose of such data is to give context to the creation process behind the media and provide some answers to who created it and how, and what steps or tools were involved.

There are levels within this category. At a basic level, an archive may be aware that a QuickTime file contains the name and version of the tool that created it and the date of the creation event, all self-contained within the media file. At a more significant level, the archive may have that awareness plus store a log of the tool that created the file, which can provide fuller context of the characteristics and variables of the creation event. Many of the tools reviewed in this report (vrecord, FFmpeg's FFREPORT, BWF MetaEdit's export functions, embARC's audit reports) generate this kind of contextual logging and the featured tools section of this report demonstrates how these logs can be retained as part of the preservation package.

### Structure

Moving beyond awareness, CAP information should be structured in a way that is consistently parseable, comparable across files and formats, and preservable over time. Unstructured free-text notes embedded in a file's comment field are a form of awareness but not of structure; they cannot be reliably extracted, validated, or compared.

Structured provenance takes several forms in the current ecosystem. The EBU BEXT chunk in Broadcast WAVE files places provenance information in defined fields with controlled vocabularies: Originator, OriginatorReference, OriginationDate, CodingHistory. The DPX header fields similarly encode provenance in fixed byte positions to describe the provenance of digitized moving image frames. PREMIS provides a structured XML schema for recording events, agents, and objects. The C2PA specification provides a highly formal structure: a CBOR-encoded manifest store containing assertions and signed according to a specified cryptographic chain.

The registries in this report assess whether and how each tool and format presents structured provenance information. The featured tools section of this report demonstrates how the semi-structured outputs of tools like FFmpeg (FFREPORT logs, ffprobe JSON) can be mapped into the formal structure of C2PA action assertions.

### Relational

Provenance information gains meaning when it is related across files, transformations, and time. A single file's creation metadata is useful but a chain that links a preservation copy to its access derivatives, and all of the above to the digitization event that produced them, is even more useful.

The C2PA ingredients model is designed to create relational provenance cryptographically. Each manifest can declare its input assets as ingredients, and if those inputs carry their own manifests, the chain is verifiable back to the point of origin. PREMIS events create relational provenance by linking event records to object records via identifiers. BWF MetaEdit's OriginatorReference and UMID fields create relational provenance by giving each file a persistent identifier that can be referenced from other systems.

This report examines whether and how each tool and format supports relational provenance. The worked examples in the featured tools section illustrate both the potential and the limits of the C2PA ingredients model, particularly at the analog-to-digital transition where vrecord captures videotape signals that have no prior digital manifest to reference as an ingredient.

### Verifiable

At the highest level of maturity, provenance claims should be independently verifiable. A file that asserts "this content was captured on July 8, 2026, by a particular named technician, using a DeckLink SDI 4K card" is making a claim. A file with that same assertion, cryptographically bound to a content hash that can be independently re-evaluated and compared against the signed manifest, is making a verifiable claim. Verifiability requires both fixity (the ability to detect whether content has changed) and authenticity (the ability to confirm that a provenance record was produced by a stated agent and has not been altered since).

Several tools in this report provide elements of verifiability without C2PA. BWF MetaEdit's audio-data MD5 chunk provides content fixity that is independent of metadata changes. vrecord's framemd5 output provides per-frame fixity generated at the moment of capture. embARC's guarantee of not touching image data provides a basis for asserting that content has not been modified during metadata correction. C2PA builds on these foundations by wrapping fixity assertions and action claims in a cryptographically signed manifest that is tamper-evident. Any modification to either the content or the manifest after signing would break the signature.

This report examines the current state of verifiability across the tools and formats in the audiovisual preservation ecosystem, and the appendices detail how a C2PA integration in embARC could extend verifiability to DPX sequence workflows at scale.

## C2PA and the Archival Context

The C2PA specification defines a manifest store format (based on JUMBF, the JPEG Universal Metadata Box Format), a set of standard assertion types (including actions, ingredients, and hash assertions), and a cryptographic signing model. Manifests can be embedded in supported file formats (including JPEG, PNG, ISO-BMFF/MP4, and RIFF/WAV) or carried as sidecar files for formats that do not support embedding.

For audiovisual archives, several aspects of C2PA require careful consideration:

- **Supported formats:** Many preservation-grade formats used in archives (Matroska, DPX, MXF) are not currently C2PA-supported for embedding. This report examines sidecar strategies for these formats and the specific challenges of DPX sequences, which can contain hundreds of thousands of individual files representing a single work.

- **The analog-to-digital transition:** C2PA's ingredients model was designed for digital-to-digital provenance chains. When a file is created by digitizing an analog source (videotape, film, audio tape), the ingredient has no prior digital manifest. This report considers how the ingredients model can be honestly applied at this transition, declaring the analog source with descriptive metadata but acknowledging that the cryptographic chain begins at digitization where hashing becomes feasible.

- **Scale and I/O:** Feature-length content digitized as DPX sequences can produce 100,000 or more individual frames. Hashing every file's image data for a C2PA manifest is a significant input/output operation. The appendices examine a hashing strategy that hashes only the image data region of each DPX file (excluding the mutable header), making the expensive processing cost a one-time operation per sequence rather than a recurring cost for each metadata correction.

- **Signing infrastructure:** C2PA requires certificates and private keys for signing. Archives and archival processing tools should consider establishing and managing signing credentials, a potentially significant requirement within most current preservation workflows. This report treats the signing step as a post-processing operation separate from the tools that generate provenance data (FFmpeg, BWF MetaEdit, vrecord, embARC), using the c2pa Rust SDK or c2patool; however, this report also examines scenarios where select tools could be expanded to incorporate signatures.

## Report Scope and Limitations

This report focuses on free and open source tools, as these tools are often more amenable to community-driven enhancement, skill-sharing, and sustainable scaled deployment. Commercial tools that participate in the C2PA ecosystem (Adobe Photoshop, Microsoft Designer, and others) are outside the scope of this review but are acknowledged as the primary drivers of C2PA adoption in the broader market.

The report reflects the state of the field as of mid-2026. C2PA support in free and open source audiovisual tools is in very early stages. No mainstream preservation tool currently generates or reads C2PA manifests natively, and the experimental forks that add C2PA to FFmpeg are in proof-of-concept implementations. The TCR4CAP framework, referenced throughout this report, was under development by the FADGI Audio-Visual Working Group at the time of writing. Efforts were made to keep the development of the two reports in sync. It is acknowledged that the C2PA Technical Specifications are also a work in progress with many changes ongoing. The recommendations and implementation plans in this report should be revisited as these related developments mature.

The examples in the featured tools section derive C2PA manifests from real tool logs (such as FFmpeg and vrecord logs). These manifests are offered as examples of potential but currently are not generated by any existing tool and should be treated as draft ideas for C2PA implementations. The JSON representations and logs within this report are examples and in some cases are simplified or truncated for readability.
