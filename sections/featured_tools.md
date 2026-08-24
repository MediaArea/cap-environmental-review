# Featured Tools: Content Authenticity and Provenance in Practice

The following free and open source tools represent a selection of the audiovisual preservation toolkit. Many of these tools have no current or only minimal or newly developed C2PA implementations but nonetheless can be implemented in a manner to support many provenance features. For each tool, this section provides an overview of its role in provenance documentation, examples of how its outputs can be used to log and verify actions, and considerations for integrating it into a content authenticity and provenance workflow.

## FFmpeg

FFmpeg is foundational to audiovisual preservation workflows. It is used for capture, format migration, rewrapping, transcoding, metadata manipulation, and many other transformation or analytical tasks with audiovisual data. It is also a key dependency in larger, open-source audiovisual projects such as DVRescue, QCTools, vrecord, and others. FFmpeg is not a provenance tool by design, but its ubiquity means that it is present or involved at nearly every significant transformation in an audiovisual digital preservation workflow, which makes its logging behavior and metadata handling critical to provenance documentation.

### FFmpeg in Digitization Workflows

Digitization tools, such as vrecord, use FFmpeg internally for video capture, controlling hardware capture cards to produce preservation-quality files. In this context FFmpeg is the encoding engine, and the parameters it is invoked with, such as encoding, sampling rate, bit depth, colorspace, and audio channel mapping, constitute the technical provenance of the resulting file. The FFmpeg command line used for capture, which is retained in vrecord's log, is a partially reproducible description of how the file was made.

### Metadata Through Transformations

FFmpeg's default metadata handling varies by container and is not always predictable. The `-map_metadata` option provides explicit control. `-map_metadata 0` copies global metadata from the first input file (input numbering starts from zero) to the output. Without this flag, a rewrap operation may silently discard embedded metadata depending on the container pairing.

```bash
# Rewrap with explicit metadata copying
ffmpeg -i input.mkv -map_metadata 0 -c copy output.mkv

# Copy metadata from one stream explicitly (e.g., audio stream 0)
ffmpeg -i input.mkv -map_metadata:s:a 0:s:a -c copy output.mkv

# Set output metadata fields explicitly
ffmpeg -i input.mkv \
 -map_metadata 0 \
 -metadata title="Authentic Movie" \
 -metadata comment="Rewrapped 2026-08-01, corrected digitization metadata" \
 -map 0 -c copy \
 output.mkv
```

Although metadata may be mapped explicitly in an ffmpeg command, a field that exists in the input container may have no equivalent in the output container, in which case FFmpeg will silently discard it. Inspecting metadata before and after any transformation, using `ffprobe` or `mediainfo` and diffing the output, is a reliable way to detect this.

```bash
ffprobe -v quiet -print_format json -show_format -show_streams input.mkv > input_metadata.json
ffmpeg -i input.mkv -map_metadata 0 -c copy output.mkv
ffprobe -v quiet -print_format json -show_format -show_streams output.mkv > output_metadata.json
diff input_metadata.json output_metadata.json
```

While ffmpeg can be used to add or modify metadata when creating a new output file, ffmpeg is not effective at editing metadata for an existing file in place. Other tools do support inline metadata edits, such as mkvpropedit or mkvnote for Matroska, BWF MetaEdit for Broadcast WAVE files, and embarc for DPX sequences.

### FFmpeg and XMP

FFmpeg displays most metadata by default; however, some metadata, such as XMP, must be specifically enabled. XMP support in FFmpeg is also format-dependent and limited. The QuickTime/MOV muxer of FFmpeg can handle XMP via the `com.apple.quicktime.XMP` metadata key; however Matroska has no standardized XMP embedding path.

To display and/or map XMP metadata from a QuickTime/MOV input, the `-export_xmp` option, or the `-export_all` option must be provided to enable XMP metadata to be parsed and displayed or mapped.

### FFREPORT

FFmpeg provides a built-in logging mechanism through the `FFREPORT` environment variable. When set, FFmpeg writes a detailed log to a timestamped file:

```bash
FFREPORT=file=ffmpeg_report_%t.log:level=32 ffmpeg -i input.mkv -map_metadata 0 -c copy output.mkv
```

The `%t` token generates a timestamp in the filename. Level 32 is informational; higher values produce more verbose output. The report includes:

- The full FFmpeg command line as invoked
- FFmpeg version, build configuration, and linked library versions
- Input file format detection and stream information
- Codec, bitrate, and container parameters for the output
- Any warnings or errors encountered during processing
- Processing duration and frame count

For provenance purposes, the FFREPORT log is a record of the initialization, processing, and outcome of the requested transformation. It documents what version of FFmpeg was used, exactly what command was run, what it found in the input, and what it produced. This log could be retained as part of the preservation package and named to associate it unambiguously with the transformation it documents; for example, by embedding the output filename in the log path via `FFREPORT=file=${OUTPUT_BASENAME}_ffmpeg_%t.log`.

### Mapping FFmpeg Logs to C2PA Actions

The FFREPORT log contains enough structured information to derive a C2PA actions assertion. An FFmpeg invocation that rewraps an MXF file to MOV corresponds to `c2pa.repackaged`. A transcode from ProRes to FFV1 corresponds to `c2pa.transcoded`. A post-processing script or wrapper tool could parse an FFREPORT log and construct a C2PA manifest from it, mapping the detected codec and container operations to the appropriate action labels and recording the FFmpeg version, command line, and timestamp as claim generator and action parameters.

The same approach applies to FFmpeg filterchains: a filterchain that applies scaling (`scale=1920:1080`) corresponds to `c2pa.resized`; one that applies a crop (`crop=1280:720:0:0`) corresponds to `c2pa.cropped`; one that applies color adjustments via `colorbalance` or `curves` corresponds to `c2pa.color_adjustments`. Filterchains are machine-readable and could be parsed systematically to construct action assertions.

### Example: Deriving a C2PA Manifest from an FFmpeg Log

The following example demonstrates how a real FFmpeg log, in this case, the creation of an access derivative from a preservation file, can be analyzed and translated into a C2PA manifest. The FFREPORT log is reproduced below in abridged form, followed by an analysis of what it tells us, and the derived C2PA expression.

#### Source: FFmpeg Log (abridged)
```
ffmpeg started on 2026-08-11 at 13:36:03
Report written to "/ffmpeg/example/EXAMPLE123/logs/ffmpeg_20260811-133603.log"
Log level: 32
Command line:
/opt/homebrew/opt/ffmpeg-full/bin/ffmpeg -y -nostdin -v info -hide_banner -stats
 -i "/ffmpeg/example/EXAMPLE123/Preservation_File.mxf"
 -movflags faststart -pix_fmt yuv420p -c:v libx264 -force_key_frames chapters -f mp4
 -crf 18 -maxrate 8760k -c:a aac -ac 2 -b:a 320k -ar 48000 -metadata "creation_time=now"
 -filter_complex "yadif;[0:a:0][0:a:1]amerge=inputs=2,aformat=channel_layouts=stereo,loudnorm=measured_I=-22.12:measured_LRA=9.00:measured_TP=-6.99:measured_thresh=-32.81:offset=-0.21:linear=true:print_format=summary"
 /ffmpeg/example/EXAMPLE123/Access_File.mp4

Input #0, mxf, from 'Preservation_File.mxf':
  Metadata:
    company_name    : Adobe Inc.
    product_name    : Adobe Media Encoder
    product_version : 26.3.2
    application_platform: Mac OS X
    modification_date: 2026-08-06T15:32:27.000000Z
  Duration: 00:25:56.66, start: 0.000000, bitrate: 52650 kb/s
  Stream #0:0: Video: mpeg2video (4:2:2), yuv422p(tv, unknown/unknown/bt709, top first),
    1920x1080 [SAR 1:1 DAR 16:9], 50000 kb/s, 29.97 fps
  Stream #0:1: Audio: pcm_s24le, 48000 Hz, mono, s32 (24 bit), 1152 kb/s
  Stream #0:2: Audio: pcm_s24le, 48000 Hz, mono, s32 (24 bit), 1152 kb/s

Stream mapping:
  Stream #0:0 (mpeg2video) > yadif:default
  Stream #0:1 (pcm_s24le) > amerge
  Stream #0:2 (pcm_s24le) > amerge
  yadif:default > Stream #0:0 (libx264)
  loudnorm:default > Stream #0:1 (aac)

[libx264 @ 0xa06c1d880] profile High, level 4.0, 4:2:0, 8-bit
  264 - core 165 r3222 b35605a - H.264/MPEG-4 AVC codec
  keyint=250 keyint_min=25 scenecut=40 rc=crf crf=18.0

Output #0, mp4, to 'Access_File.mp4':
  Stream #0:0: Video: h264 (avc1), yuv420p(tv, unknown/bt709/bt709, progressive),
    1920x1080 [SAR 1:1 DAR 16:9], 29.97 fps
  Stream #0:1: Audio: aac (LC), 48000 Hz, stereo, fltp, 320 kb/s

[Parsed_loudnorm_3 @ 0xa06c15b00]
  Input Integrated:    -22.1 LUFS
  Input True Peak:      -7.0 dBTP
  Input LRA:             9.0 LU
  Output Integrated:   -24.1 LUFS
  Output True Peak:     -6.3 dBTP
  Output LRA:            6.5 LU
  Normalization Type:   Dynamic
  Target Offset:        +0.1 LU

frame=46653 fps=118 q=-1.0 Lsize=2663516KiB time=00:25:56.58 bitrate=14017.5kbits/s speed=3.95x
[libx264 @ 0xa06c1d880] frame I:415   Avg QP:15.31  size:275118
[libx264 @ 0xa06c1d880] frame P:13178 Avg QP:18.98  size:113888
[libx264 @ 0xa06c1d880] frame B:33060 Avg QP:22.11  size: 31998
[libx264 @ 0xa06c1d880] kb/s:13736.36
[aac @ 0xa06c1df80] Qavg: 50503.590
```

#### What the Log Tells Us

Reading this log gives us context about the process to generate the access video file:

- **Input:** An MXF file containing MPEG-2 video at 1920×1080, 29.97fps, interlaced (top field first), 10-bit YUV 4:2:2 (yuv422p), 50 Mb/s, with two mono PCM audio tracks at 48kHz, 24-bit. Duration 25:56.66. The file was created by Adobe Media Encoder 26.3.2 on Mac OS X on 2026-08-06.
- **Video processing:** The `yadif` filter was applied to deinterlace the interlaced source to progressive. The pixel format was converted from yuv422p (10-bit 4:2:2) to yuv420p (8-bit 4:2:0) via the `-pix_fmt yuv420p` flag. The video was encoded to H264 (via libx264 encoder set to 'High profile' and level 4.0) at a constant rate factor (CRF) of 18 with a max bitrate of 8760 kb/s. Keyframes were forced at chapter boundaries (`-force_key_frames chapters`).
- **Audio processing:** Two mono PCM audio tracks (streams 0:1 and 0:2) were merged into a single stereo track via `amerge`, then loudness-normalized via `loudnorm` with measured input values producing a dynamic normalization of the audio output. The audio was encoded to AAC LC at 320 kb/s, 48kHz, stereo.
- **Container:** The output was muxed into MP4 with the `faststart` muxer option (which places the moov atom at the beginning of the output file for optimized streaming).
- **Processing context:** FFmpeg 8.0 (libavcodec 62.28.102, libavformat 62.12.102), running on Apple Silicon (ARMv8 NEON DotProd), x264 core 165. Processing took 6 minutes 34 seconds for 25 minutes 57 seconds of content (3.95× real-time). Total output size: 2,663,516 KiB (~2.5 GB).

#### Derived C2PA Manifest

The following is a simplified JSON representation of the C2PA manifest that could be derived from this log. In an actual implementation, this would be encoded as CBOR within a JUMBF manifest store and signed with the institution's signing credential. MP4 is a C2PA-supported format, so the manifest could be embedded in the output file. The input MXF is referenced as an ingredient.

```json
{
  "claim_generator": "FFmpeg/8.0 (libavcodec 62.28.102)",
  "claim_generator_info": [
    {
      "name": "FFmpeg",
      "version": "8.0",
      "schema_version": "2.4"
    }
  ],
  "ingredients": [
    {
      "title": "Preservation_File.mxf",
      "document": {
        "format": "application/mxf",
        "creation_date": "2026-08-06T15:32:27Z"
      },
      "meta": {
        "company_name": "Adobe Inc.",
        "product_name": "Adobe Media Encoder",
        "product_version": "26.3.2",
        "application_platform": "Mac OS X"
      }
    }
  ],
  "assertions": [
    {
      "label": "c2pa.actions",
      "data": {
        "actions": [
          {
            "action": "c2pa.transcoded",
            "when": "2026-08-11T13:36:03",
            "ingredientIds": [0],
            "description": "MXF preservation master transcoded to H.264/MP4 access derivative.",
            "parameters": {
              "input_container": "MXF",
              "input_video_codec": "MPEG-2 Video, 4:2:2 Profile, yuv422p, 10-bit",
              "input_audio_codec": "PCM s24le, 48kHz, 2x mono",
              "input_resolution": "1920x1080",
              "input_frame_rate": "29.97 fps",
              "input_interlaced": true,
              "input_field_order": "top first",
              "input_bitrate": "52650 kb/s",
              "input_duration": "00:25:56.66",
              "output_container": "MP4 (faststart)",
              "output_video_codec": "H.264, High profile, level 4.0, 8-bit, yuv420p",
              "output_audio_codec": "AAC LC, 48kHz, stereo, 320 kb/s",
              "output_resolution": "1920x1080",
              "output_frame_rate": "29.97 fps",
              "output_interlaced": false,
              "output_bitrate": "14017.5 kb/s",
              "output_duration": "00:25:56.58",
              "output_size": "2663516 KiB",
              "processing_time": "00:06:34.41",
              "processing_speed": "3.95x real-time",
              "ffmpeg_version": "8.0",
              "libavcodec_version": "62. 28.102",
              "libavformat_version": "62. 12.102",
              "x264_core": "165 r3222 b35605a",
              "platform": "Apple Silicon (ARMv8 NEON DotProd)",
              "command_line": "ffmpeg -y -nostdin -v info -hide_banner -stats -i [input.mxf] -movflags faststart -pix_fmt yuv420p -c:v libx264 -force_key_frames chapters -f mp4 -crf 18 -maxrate 8760k -c:a aac -ac 2 -b:a 320k -ar 48000 -filter_complex 'yadif;[0:a:0][0:a:1]amerge=inputs=2,aformat=channel_layouts=stereo,\ loudnorm=measured_I=-22.12:measured_LRA=9.00:measured_TP=-6.99:measured_thresh=-32.81:offset=-0.21:\
              linear=true:print_format=summary' [Access_file.mp4]"
            }
          },
          {
            "action": "c2pa.filtered",
            "when": "2026-08-11T13:36:03",
            "ingredientIds": [0],
            "description": "Deinterlace applied via yadif filter.",
            "parameters": {
              "filter": "yadif",
              "mode": "default",
              "input_scan_type": "interlaced (top field first)",
              "output_scan_type": "progressive"
            }
          },
          {
            "action": "c2pa.color_adjustments",
            "when": "2026-08-11T13:36:03",
            "ingredientIds": [0],
            "description": "Pixel format converted from 10-bit yuv422p (4:2:2) to 8-bit yuv420p (4:2:0). Chroma subsampling reduced from 4:2:2 to 4:2:0 and bit depth reduced from 10 to 8.",
            "parameters": {
              "conversion": "pixel_format",
              "input_pixel_format": "yuv422p (10-bit, 4:2:2)",
              "output_pixel_format": "yuv420p (8-bit, 4:2:0)",
              "bit_depth_change": "10 to 8",
              "chroma_subsampling_change": "4:2:2 to 4:2:0"
            }
          },
          {
            "action": "c2pa.filtered",
            "when": "2026-08-11T13:36:03",
            "ingredientIds": [0],
            "description": "Audio channels merged and loudness-normalized.",
            "parameters": {
              "filters": [
                {
                  "filter": "amerge",
                  "inputs": 2,
                  "description": "Two mono PCM tracks merged to stereo"
                },
                {
                  "filter": "aformat",
                  "args": "channel_layouts=stereo"
                },
                {
                  "filter": "loudnorm",
                  "normalization_type": "Dynamic",
                  "measured_I": "-22.12 LUFS",
                  "measured_LRA": "9.00 LU",
                  "measured_TP": "-6.99 dBTP",
                  "measured_thresh": "-32.81 LUFS",
                  "offset": "-0.21 LU",
                  "linear": true,
                  "output_I": "-24.1 LUFS",
                  "output_TP": "-6.3 dBTP",
                  "output_LRA": "6.5 LU"
                }
              ]
            }
          }
        ]
      }
    },
    {
      "label": "c2pa.hash.data",
      "data": {
        "alg": "sha256",
        "hash": "a1b2c3d4e5f6...[SHA-256 of output MP4, excluding embedded manifest region]"
      }
    }
  ]
}
```

#### Notes on the Derivation

In this example many arguments to the ffmpeg transcoding command play a role in provenance documentation. The derivative uses a lossy encoding and the audio is intentionally manipulated to adjust the volume. Though in an informally structured way, the FFmpeg log contextualizes these changes.

**Action selection and ingredient requirements.** For the `c2pa.transcoded` action the input MXF file is declared as an ingredient. This is a digital-to-digital transformation with an existing source file, so the ingredient chain is straightforward. The `c2pa.transcoded` action documents the container and codec conversion (MXF/MPEG-2 to MP4/H.264). Additional actions capture the specific transformations applied within the transcoding.

**Filterchain decomposition.** The log's `filter_complex` string,  `yadif;[0:a:0][0:a:1]amerge=inputs=2,aformat=channel_layouts=stereo,loudnorm=...`, contains two filterchains: one for video and one for audio. Each filter that modifies content can be mapped to a C2PA action. The `yadif` deinterlace filter maps to `c2pa.filtered` (content modification with no standard C2PA action for deinterlacing specifically). The pixel format conversion from 10-bit 4:2:2 to 8-bit 4:2:0 is a quality reduction to chroma subsampling and bit depth that maps to `c2pa.color_adjustments`. The audio filterchain (`amerge`, `aformat`, and `loudnorm`) is grouped under a single `c2pa.filtered` action with the individual filters nested as parameters. This preserves the ordering and relationship of the filterchain as a single audio processing pipeline.

**loudnorm measurements as provenance data.** The loudnorm filter's measured input and output values are preservation-relevant. They document the loudness characteristics of the source and the normalization applied and clarify that the preservation file and access file shall sound different. Recording these transformational details in the manifest could make them part of the cryptographically signed provenance record.

**Command line as provenance.** The full FFmpeg command line is recorded in the action parameters. This command describes the full process (in this case, of generating an access media file) and is machine-readable and reproducible with the transformational aspects of the process (such as loudness adjustments and deinterlacement) clarified.

**What the manifest does not capture.** The ffmpeg log records the embedded metadata of the MXF input, including the fact that it created by Adobe Media Encoder 26.3.2 on 2026-08-06, but the manifest only references this as ingredient metadata and does not establish a cryptographic chain to the input file unless the input file itself also carries a C2PA manifest. If the MXF preservation master had been signed with a C2PA manifest at the time of its creation (e.g., by the digitization tool or by a post-capture signing step), the ingredient entry would include that prior manifest, and the chain would be cryptographically verifiable back to the digitization event. Without a prior manifest, the ingredient is declared with its metadata but the chain is not cryptographically linked. The manifest documents what FFmpeg did and what it received, but not what happened to the input before FFmpeg received it.

### FFmpeg Forks with C2PA Features

While as of this writing no C2PA specific features are supported in FFmpeg, there are several works in progress worth acknowledging that seek to extend FFmpeg to add C2PA relevant features. Here's an example of one experimental fork on GitHub that adds C2PA capabilities to FFmpeg directly and may be worth following:

- **eqtylab/c2pa_ffmpeg** This is a mirror of the FFmpeg source tree with a `c2pa` branch that integrates C2PA signing into the encoding pipeline. A companion library, `eqtylab/c2pa_libffmpeg_eqty`, wraps the C2PA Rust SDK for use with this fork. It requires three parameters: `-c2pa_key` (certificate private key), `-c2pa_cert` (certificate), and `-c2pa_manifest` (a JSON manifest file defining the actions and assertions). It currently supports monolithic MP4 signing and signing of DASH segments. The work is experimental, not merged into FFmpeg's official codebase, and requires building from source against the C2PA Rust library; however, it demonstrates that in-process C2PA signing during FFmpeg encoding is architecturally feasible.

The fork is not production-ready or maintained at the level of mainline FFmpeg but is a proof-of-concept implementation, useful as reference material for understanding how C2PA signing can integrate with an encoding pipeline, and as a basis for any future effort to propose C2PA support for upstream FFmpeg. The existence of such forks also illustrates that C2PA adoption in the audiovisual workflows and ecosystems is still in early developmental stages and the community has interest in integrating it into core workflow tools.

### Logging as Provenance

The FFREPORT log can serve as a meaningful provenance record for any FFmpeg transformation. This record can be modeled as a PREMIS event, an activity of type "migration," "normalization," or "metadata modification", with the log file referenced as an event detail and input/output fixity values recorded as object characteristics. FFmpeg does not generate PREMIS events natively, but all the information needed to populate one is available in its outputs.

### FFmpeg and TCR4CAP Criteria

The FADGI Audio-Visual Working Group's TCR4CAP (Tiered Community Recommendations for Content Authenticity and Provenance) effort, initiated in early 2026, is developing tiered community recommendations for CAP practices in digital audiovisual collections. Inspired by the NDSA Levels of Digital Preservation, the framework defines levels of practice ranging from basic integrity checks to more advanced implementations such as embedded provenance metadata or trust-center integrations. A draft for public comment is expected in summer 2026.

For FFmpeg, the following subsections map these emerging criteria to FFmpeg capabilities, illustrating how an institution can use FFmpeg to satisfy CAP requirements at multiple tiers of practice.

#### Basic Integrity Checks (Fixity)

**TCR4CAP context:** The lowest tier of practice is verifying that file contents have not changed. This encompasses whole-file checksums, per-frame or intra-file fixity, and periodic re-verification.

**FFmpeg examples:**

- **Whole-file checksums (external to FFmpeg):** While FFmpeg itself does not compute whole-file checksums, it is standard practice to pair FFmpeg processing with system-level checksum generation. A potential workflow could run `md5sum` or `shasum -a 256` on the input before processing and on the output after, recording both values alongside the FFREPORT log.

- **Per-frame fixity via `framemd5` muxer:** FFmpeg's `framemd5` (or `framehash`) muxer generates per-frame checksums for video and per-chunk checksums for audio, producing a text file that lists the MD5 (or other algorithm) hash of each frame's raw pixel data:

```bash
# produce a framemd5 report for the decoded streams of the input file
ffmpeg -i input.mkv -f framemd5 output.framemd5

# produce a framemd5 report for the encoded streams of the input file
ffmpeg -i input.mkv -f framemd5 -c copy output.framemd5
```

FFmpeg's framemd5 muxers can document the hashes of audiovisual streams as decoded by FFmpeg, or hash the encoded data as stored without decoding. These two procedures have different implications: generating framemd5s from decoded data documents the fixity of how a particular version of FFmpeg decoded particular encodings. The second example skips the decoding step by using the stream copy feature via -c copy; here, the framemd5s document the encoded data as stored.

As FFmpeg can provide intra-file fixity at the frame level, this provides a significantly stronger integrity guarantee and potential for resolution than a whole-file checksum, since it can identify exactly which frames have been altered if corruption occurs. See the upcoming vrecord section for an example that demonstrates generating `framemd5` concurrently during capture, binding the fixity record to the moment of creation. 

#### Processing Documentation (Provenance of Transformations)

**TCR4CAP context:** Beyond verifying that a file is unchanged, principles of CAP require documenting what was done to the file to detail its full the transformational history. This includes recording the tools used, the parameters applied, the time of processing, and the relationship between input and output.

**FFREPORT structured logging:** FFmpeg's `-report` flag generates a structured log file containing the FFmpeg version, build configuration, command line, input and output stream mappings, codec parameters, filterchain details, and processing statistics:

```bash
ffmpeg -report -i input.mxf -c:v libx264 -crf 18 output.mp4
```

The resulting FFREPORT file is a complete processing record. As the worked example in this section demonstrates, every field needed to construct a C2PA `c2pa.transcoded` action (input codec, output codec, filters, encoding parameters, duration, frame count, bitrate, etc) is present in the log. The TCR4CAP framework's processing documentation tier can be satisfied by retaining these logs, whether or not they are subsequently encoded as C2PA manifests.

**Metadata embedding during processing:** FFmpeg can embed descriptive and technical metadata in the output container during transcoding, creating an in-file record of the processing event:

```bash
ffmpeg -i input.mxf \
  -metadata "creation_time=2026-08-11T13:36:03Z" \
  -metadata "comment=Transcoded from MXF/MPEG-2 to MP4/H.264 for access. Source: TAPE_ID_1234 preservation master." \
  -c:v libx264 -crf 18 output.mp4
```

While container metadata fields are limited and not cryptographically protected, they provide a human-readable provenance record embedded in the file itself, which serves as a baseline level of documentation.

**`ffprobe` technical characterization:** FFmpeg's tool `ffprobe` can generate structured output (JSON, XML, CSV) documenting the complete technical properties of a file before and after processing:

```bash
ffprobe -v quiet -print_format json -show_format -show_streams input.mxf > input_probe.json
ffprobe -v quiet -print_format json -show_format -show_streams output.mp4 > output_probe.json
```

Paired `ffprobe` reports serve as before-and-after snapshots that document the transformation. These can be retained as PREMIS event documentation, stored as sidecar log files, or fed into a C2PA manifest generator as structured parameters.

#### Embedded Provenance Metadata (C2PA Manifests)

**TCR4CAP context:** There is the potential for "embedded provenance metadata" as a more advanced level C2PA manifests as cryptographically signed provenance records embedded in or attached to the file. Unlike basic integrity checks or processing logs, C2PA manifests are tamper-evident, structured according to a formal specification, and designed to chain across multiple processing steps.

**FFmpeg examples:**

- **FFmpeg as a source of C2PA assertion data:** (At the moment) FFmpeg does not generate C2PA manifests, but its logs and outputs can be primary data sources from which manifests can be constructed. The example earlier in this section demonstrated this derivation: the FFREPORT log provides the `c2pa.transcoded` action parameters, the `ffprobe` output provides the ingredient document metadata, and the output file's hash provides the `c2pa.hash.data` assertion. A post-processing script (using the c2pa Rust SDK or `c2patool`) could read the FFmpeg log, construct the manifest JSON, sign it, and embeds it in the output file.

- **Embedding manifests in C2PA-supported output formats:** FFmpeg can write to formats that C2PA supports for embedding, including MP4 and WAV. When FFmpeg produces an MP4 access derivative, a subsequent C2PA signing step could embed the manifest directly in the file's `moov` atom without re-encoding. The C2PA signing could be a separate operation that modifies the container structure without modifying the audio or video streams.

- **Sidecar manifests for unsupported formats:** When FFmpeg writes to formats that C2PA does not currently support for embedding (e.g., Matroska/MKV, DPX), the manifest could be managed as a sidecar file. FFmpeg's `-f ffmetadata` muxer can export container metadata to a sidecar text file and could serve as the basis for a sidecar provenance record alongside a separately generated `.c2pa` manifest.

#### Format Validation and Conformance

**TCR4CAP context:** Authenticity depends not only on documenting what was done but on verifying that the result conforms to expected specifications. A file that claims to be a preservation copy but does not conform to the relevant format standard adds a level complication and reliability issues.

**FFmpeg examples:**

- **FFmpeg as a conformance engine:** FFmpeg's decoder libraries are the reference implementation for many codecs. If FFmpeg can decode a file without errors, then in some cases the file's bitstream may be conformant to the codec specification. A simple decode test serves as a baseline conformance check:

```bash
ffmpeg -v error -i input.ffv1.mkv -f null -
```

  The `-v error` flag suppresses all output except errors. A silent run indicates the file decodes without error. Any error messages may indicate bitstream non-conformance or corruption, a potential authenticity issue that could be documented.

- **QCTools XML generation:** FFmpeg's metadata and filtering capabilities play a foundational role in QCTools, which generates detailed quality control reports including per-frame statistics (PSNR, spatial information, temporal information, loudness, etc.). These reports serve as a technical characterization of the file's content at a specific point in time, providing a baseline against which future authenticity checks can be compared. If a file's QCTools statistics change between captures, the content may be considered to have been modified.

#### Chain-of-Custody Documentation

**TCR4CAP context:** The highest tier described in the FADGI project page is the integration of trust-centers where provenance claims are not just embedded in files but are verifiable against external registries or trust services. This requires that each processing step in an asset's lifecycle produces a provenance record that references the prior step, creating a chain.

**FFmpeg examples:**

- **Ingredient declaration for chain construction:** When FFmpeg processes a file that already carries a C2PA manifest (e.g., a preservation copy that was signed at capture time), the post-processing C2PA signing step could declare the input as an ingredient with its prior manifest. This creates the cryptographic chain where the new manifest references the old manifest, which references the one before it, leading back to the point of origin.

- **FFREPORT as a PREMIS event record in a chain:** Even without C2PA, an institution can build a chain-of-custody record by retaining FFREPORT logs for every FFmpeg operation and by documenting them informally or via structuring them, for instance as PREMIS event records. Each log could record the input file's checksum (if captured as a pre-processing step), the output file's checksum, the processing tool and version, the command line, and the timestamp. A PREMIS event record could reference the prior event for the same object, creating a documentary chain that mirrors what C2PA does cryptographically. TCR4CAP's tiered approach would recognize this as a mid-level practice, between simpler practices such as storage of a single checksum and more complex practices such as management of a signed manifest chain.

- **`-metadata` chaining for documentary provenance:** For workflows where C2PA is not yet implemented, FFmpeg's metadata embedding can create a lightweight provenance chain by carrying forward source identifiers and adding processing annotations at each step:

```bash
ffmpeg -i input.mp4 \
  -metadata "comment=Generation 2: transcoded from My_Example_Movie preservation copy. Prior comment: $PRIOR_COMMENT" \
  -c:v libx264 -crf 23 output_access.mp4
```

  This is not cryptographically protected and can be manipulated or forged, but it provides a documentary chain that is readable by many media players or tools. In the context of the TCR4CAP's tiered framework this informal practice is better than no documentation, but not sufficient for authenticity guarantees in adversarial contexts.

## BWF MetaEdit

BWF MetaEdit is a free and open source tool developed by the Library of Congress and FADGI (Federal Agencies Digital Guidelines Initiative) for embedding, validating, and exporting metadata in Broadcast WAVE Format audio files. It provides a metadata editor for embedded metadata features of Broadcast WAVE files, including the EBU BEXT chunk (EBU-TECH 3285) and LIST-INFO chunk specifications. BWF MetaEdit is designed closely to implement FADGI's guidelines for embedded metadata in BWF files. For audio digitization workflows, BWF MetaEdit helps ensure that the embedded metadata in a WAV file correctly documents the provenance of the recording.

### Provenance-Relevant BEXT Fields

- **Originator:** The entity responsible for archiving the digital item.
- **OriginatorReference:** A unique identifier for the audio file.
- **OriginationDate / OriginationTime:** Date and time of the digitization event.
- **CodingHistory:** A structured field documenting the signal chain and processing history per EBU R98-1999. Each pass through the signal chain adds a row.
- **UMID:** A globally unique identifier per SMPTE ST 330.

The CodingHistory documents the transformational history of the audio recording, including its digital and analog sources, the signal chain used for digitization, and the parameters of the resulting digital file. For example:
```
A=ANALOG,M=stereo,T=VendorTapeDecoder; SN:12345; FADGI digitization project
A=PCM,F=96000,W=24,M=stereo,T=AES/EBU interface
```

In this CodingHistory example, the first row documents the analog source; the second row documents the digital capture. If a subsequent transformation changes the file's encoding, such as a sample rate conversion, a new row would be added documenting the change.

### The MD5 Chunk: Audio-Data Fixity

BWF MetaEdit supports the generation of an audio-data-only MD5 checksum, stored in a non-standardized chunk within the WAV file identified by the chunk ID `<MD5 >`. The checksum covers only the audio bitstream, which is the entire `<data>` chunk excluding the chunk identifier, size declaration, and any optional padding byte. This is a critical distinction from a whole-file checksum as subsequent metadata edits to the file would invalidate a whole-file checksum but should not invalidate the stored checksum of the audio chunk.

BWF MetaEdit exposes this feature through two operations:

- **Evaluate MD5 for audio data:** computes a checksum of the audio data and displays it in the `MD5Evaluated` column without storing it in the file. When an existing `<MD5>` chunk is present, BWF MetaEdit displays the stored value in the `MD5Stored` column on file open, and evaluation produces a comparison in the `MD5Evaluated` column, allowing immediate verification of audio data integrity.
- **Embed MD5 for audio data:** computes the checksum and stores it directly in the file in an `<MD5>` chunk. The declared size of this chunk is always 16 bytes (the size of an MD5 digest).

The audio-data MD5 is directly analogous to the image-data hashing strategy described in the embARC appendix for DPX files: it binds the preserved content (the audio bitstream) while allowing metadata to be freely edited without invalidating the fixity record. In a C2PA context, this same hash could serve as the basis for a `c2pa.hash.data` assertion with byte-range exclusions for the metadata chunks, or it could be referenced as supporting evidence in a `c2pa.actions` assertion confirming that only metadata was modified.

The FADGI guidelines describe the `<MD5>` chunk as "non-standardized" and "ad hoc". While not part of the EBU BWF specification, it has become a de facto convention in audio preservation workflows and is widely supported by BWF MetaEdit across its CLI and GUI versions for Windows, macOS, and Linux.

### Relationship to C2PA

WAV is a C2PA-supported format. BWF MetaEdit currently does not generate or read C2PA manifests, but it can document the digitization event in BEXT before a post-processing C2PA signing step embeds or attaches a manifest. The two operations, BEXT population and C2PA signing, could be complementary and sequenced items in a workflow.

For more information about the potential intersection of C2PA and BWF MetaEdit, please see the appendices of this report.

### Example: A BWF MetaEdit Digitization Workflow with CAP Metadata

The following workflow describes how an institution could use BWF MetaEdit to embed provenance metadata and audio-data fixity in a batch of WAV files from an audio digitization project, and how those outputs relate to a subsequent C2PA signing step. BWF MetaEdit is available as both a GUI and a CLI tool; the CLI is used here because it is scriptable and suitable for batch processing.

#### Scenario

An institution has digitized a collection of 1/4 inch open-reel audio tapes. The capture produced a set of WAV files at 96kHz, 24-bit, stereo. The files are stored in a project directory:
```
/audio_project/
  Tape_001.wav
  Tape_002.wav
  Tape_003.wav
  ...
  Tape_050.wav
```

The technician needs to embed BEXT metadata documenting the digitization event, embed audio-data MD5 checksums, and prepare the files for a C2PA signing step that will generate signed manifests.

#### Step 1: Export Current Metadata (Baseline)

Before making any changes, export the current state of all files as a baseline record:

```bash
bwfmetaedit --out-XML=/audio_project/metadata/before.xml /audio_project/*.wav
```

This produces an XML file containing the current BEXT, LIST-INFO, and technical metadata for every file in the directory. If the files were created by the capture software with minimal metadata, most BEXT fields will be empty. This baseline serves the same purpose as the `ffprobe` snapshot described in the FFmpeg section as it documents the state before modification so that changes can be diffed and verified.

#### Step 2: Prepare a Core Document with Provenance Metadata

BWF MetaEdit supports importing metadata from a Core document (a CSV or XML file with one record per audio file). This is the recommended approach for batch embedding because it allows metadata to be prepared and reviewed before being committed to the files.

Create a CSV file (`/audio_project/metadata/provenance.csv`) with the following structure:

```csv
FileName,Originator,OriginatorReference,OriginationDate,OriginationTime,Description,CodingHistory
Tape_001.wav,US-AudioArchive,US-AudioArchive-20260822-103000-001,2026-08-22,10:30:00,Quarter-inch reel-to-reel; Music recording; side A,A=ANALOG,M=stereo,T=StuderA810; SN:12345; FADGI digitization project
Tape_002.wav,US-AudioArchive,US-AudioArchive-20260822-110000-002,2026-08-22,11:00:00,Quarter-inch reel-to-reel; Event recording; side B,A=ANALOG,M=stereo,T=StuderA810; SN:12345; FADGI digitization project
Tape_003.wav,US-AudioArchive,US-AudioArchive-20260822-133000-003,2026-08-22,13:30:00,Quarter-inch reel-to-reel; interview with audio cataloger; part 1,A=ANALOG,M=stereo,T=StuderA810; SN:12345; FADGI digitization project
...
```

Each row carries:

- **Originator:** The institution's FADGI-recommended identifier (`[Country code]-[Entity name]`)
- **OriginatorReference:** A structured unique identifier encoding country, entity, date, time, and sequence number
- **OriginationDate / OriginationTime:** The date and time of the digitization event
- **Description:** A free-text description of the source item
- **CodingHistory:** The signal chain documentation, following EBU R98-1999 conventions

#### Step 3: Embed the Metadata

Import the Core document to embed the provenance metadata in the BEXT chunks of all files:

```bash
bwfmetaedit --in-XML=/audio_project/metadata/provenance.xml /audio_project/*.wav
```

BWF MetaEdit reads the Core document, maps the field values to the appropriate BEXT and LIST-INFO elements, and writes the metadata into each file's header. The tool enforces FADGI validation rules during this process, rejecting values that do not conform to the guidelines (for example, an improperly formatted date or an Originator string that violates the recommended pattern).

#### Step 4: Embed Audio-Data MD5 Checksums

After metadata is embedded, generate and store audio-data MD5 checksums:

```bash
bwfmetaedit --EmbedMD5 /audio_project/*.wav
```

This reads the audio data chunk of each file, computes an MD5 hash of the PCM bitstream (excluding chunk headers and metadata), and stores the 16-byte digest in an `<MD5>` chunk within the file. The checksum computation requires reading the entire data chunk, so for large files or large batches this step can take significant time.

#### Step 5: Verify the Results

Export the metadata again and compare against the baseline to confirm that changes were applied correctly:

```bash
bwfmetaedit --out-XML=/audio_project/metadata/post_embed.xml /audio_project/*.wav
diff /audio_project/metadata/before.xml /audio_project/metadata/post_embed.xml
```

The diff should show only the BEXT fields that were populated and the addition of the `<MD5>` chunk. No audio data fields should have changed.

To verify audio data integrity, bwfmetaedit can evaluate the stored MD5 against a new computation:

```bash
bwfmetaedit --EvaluateMD5 /audio_project/*.wav
```

BWF MetaEdit will display the stored value (`MD5Stored`) and the freshly computed value (`MD5Evaluated`) for each file. If the two match, the audio data has not been altered since the checksum was embedded and the operation provides a stable integrity check across metadata operations.

#### Step 6: C2PA Signing (Post-Processing)

After BWF MetaEdit has embedded the BEXT provenance metadata and the audio-data MD5, a separate C2PA signing step could generate and embed a C2PA manifest in each WAV file. WAV is a C2PA-supported format, so the manifest can be embedded directly in the file rather than carried as a sidecar.

The C2PA manifest could reference the BEXT metadata as part of the digitization event documentation and include a `c2pa.hash.data` assertion binding the audio content. The audio-data MD5 already stored in the `<MD5>` chunk by BWF MetaEdit is not the same as a C2PA hash assertion as it is an MD5 stored in a non-standard chunk, whereas C2PA uses its own hash assertion format with specified algorithms and byte-range exclusions, however, the `<MD5>` chunk does serve as corroborating evidence. A validator examining the file could find both the BWF MetaEdit MD5 and the C2PA hash assertion, each independently confirming audio data integrity.

The signing step would require a separate tool (such as c2patool or the c2pa Rust SDK) and an institutional signing credential. BWF MetaEdit's role in this example would end at Step 5; it has prepared the file with embedded provenance metadata and audio-data fixity, and the C2PA signing step could build on that foundation. The two operations would be complementary and sequenced: BWF MetaEdit populates the embedded provenance record, and C2PA signing wraps it in a cryptographically signed manifest that establishes a verifiable chain of custody from this point forward.

#### What This Workflow Achieves

| Step               | Tool           | What It Documents                  |
|--------------------|----------------|------------------------------------|
| 1. Baseline export | BWF MetaEdit   | State of files before modification |
| 2. Prepare Core document | Manual / script | Provenance metadata for each file (originator, date, signal chain) |
| 3. Embed metadata  | BWF MetaEdit   | BEXT chunk populated with digitization provenance |
| 4. Embed audio MD5 | BWF MetaEdit   | Audio-data-only checksum stored in `<MD5>` chunk |
| 5. Verify          | BWF MetaEdit   | Confirm metadata applied, audio data unchanged |
| 6. C2PA signing    | c2patool / SDK | Signed manifest embedding provenance assertions and content hash |

The result is a set of WAV files that carry two layers of provenance documentation: the BEXT metadata, which is readable by any BWF-compliant tool and documents the digitization event in human-readable structured fields; and the C2PA manifest, which is cryptographically signed and machine-verifiable, establishing a tamper-evident provenance chain from the moment of signing forward. The audio-data MD5 provides an additional fixity layer that bridges the two and supports the same claim that the C2PA hash assertion will attest to: that the audio content has not been modified.

## vrecord

vrecord is an open-source video digitization and transfer tool developed within the audiovisual archiving community under the AMIA Open Source umbrella. It is designed for capturing analog and digital video signals through Blackmagic Design capture cards and producing preservation-quality digital files and built with archivists' needs in mind.

### vrecord in Digitization and Transcoding Workflows

vrecord uses FFmpeg internally for capture and encoding. Operator-configured settings for format, codec, sampling rate, audio channel mapping, and others are applied through an FFmpeg command that vrecord constructs and executes. vrecord also supports post-capture processing steps, including format conversion and quality control workflows, which involve FFmpeg transcoding and rewrapping operations. All of the FFmpeg considerations above (`-map_metadata`, `FFREPORT`, filterchain logging) apply as well to vrecord's FFmpeg invocations.

### Provenance Through Capture Logging

For each recorded file, vrecord generates a structured set of log files:

- **FFmpeg log*:* (timestamped) the full FFmpeg encoding log for the session
- **Capture options log:** the full set of vrecord settings as configured at the time of capture
- **framemd5 file:** per-frame MD5 hashes for every frame in the captured file (when enabled)
- **QCTools XML:** comprehensive quality control data (when enabled)

This set of outputs is a more complete contemporaneous provenance record than most digitization tools produce. The capture options log documents the configuration that produced the file. The FFmpeg log documents the exact version and libraries used. Together they answer who captured the, when, with what equipment, with what settings, and with what tool version.

### FrameMD5 as Intra-File Fixity

The framemd5 output provides per-frame integrity verification that does not require C2PA. Given the framemd5 file and the original video, any frame can be verified against its hash. For long-form content, multi-hour programs at 29.97fps, the framemd5 file is large but is generated during capture at marginal additional cost.

vrecord's log files should be treated as part of the preservation package and not as diagnostic output to be discarded. The capture options log in particular documents decisions that cannot be reconstructed after the fact.

### Example: Deriving a C2PA Manifest from a vrecord Capture Session

The following example demonstrates how the logs from a vrecord capture session could be translated into a C2PA manifest. Unlike the FFmpeg transcoding example above, which modeled a digital-to-digital transformation with an existing source file as ingredient, this example models the origin of a digital asset within a videotape digitization event. The C2PA ingredients model was designed for digital-to-digital provenance chains, and this example illustrates how it encounters the analog-to-digital transition.

#### Source: vrecord Capture Options Log (abridged)

```ini
computer_name: Videos-Mac-mini-204.local
computer_model_id: Mac14,3
computer_memory: 16 GB
computer_cores: 8
operating_system_version: Darwin Kernel Version 23.6.0
user_name: videolabmini
vrecord version: 2026-07-07
datetime_start: 2026-07-08T16:31:32
capture_device_name: WD_BLACK SN850XE 4000GB
capture_device_location: External
FILE_PATH: /Volumes/FinalStore/Test/LC_10min_Framemd5_MP4_QCLI.mkv
video_card_name: DeckLink SDI 4K
VIDEO_INPUT_CHOICE: SDI
AUDIO_INPUT_CHOICE: SDI Embedded Audio
VIDEO_BIT_DEPTH_CHOICE: 10 bit
AUDIO_MAPPING_CHOICE: 2 Stereo Tracks (Channels 1 & 2 > 1st Track Stereo, Channels 3 & 4 > 2nd Track Stereo)
STANDARD_CHOICE: NTSC
ASPECT_RATIO_CHOICE: 4/3
CONTAINER_CHOICE: Matroska
VIDEO_CODEC_CHOICE: FFV1 version 3
AUDIO_CODEC_CHOICE: 24-bit PCM
QCTOOLSXML_CHOICE: Yes, concurrent with recording
TECHNICIAN: MM
Record command: /opt/homebrew/bin/ffmpeg-ma -nostdin -nostats -t 600 -benchmark -benchmark_all -timecode_format all -guess_layout_max 0 -loglevel info -loglevel +time -f decklink -signal_loss_action none -audio_input embedded -video_input sdi -format_code ntsc -channels 8 -audio_depth 32 -raw_format yuv422p10 -i DeckLink SDI 4K -c:v ffv1 -level 3 -g 1 -slices 24 -slicecrc 1 -c:a pcm_s24le -rf64 auto -map_metadata 0:s:v:0 -metadata:s:v:0 encoder=FFV1 version 3 -metadata creation_time=now -filter_complex [0:v:0]setparams=range=limited:color_primaries=smpte170m:color_trc=bt709:colorspace=smpte170m:field_mode=auto,setsar=10/11,readeia608=lp=1:spw=0.27,metadata=mode=print:key=lavfi.readeia608.0.cc:file=/tmp/vrecord.0bUuKZ.eia608.txt[vout];[0:a:0]asplit[orig],pan=stereo| c0=c0 | c1=c1[stereo1];[0:a:0]pan=stereo| c0=c2 | c1=c3[stereo2] -map [vout] -map [orig] -map [stereo1] -map [stereo2] -f tee [f=matroska:select=v,a\\:1,a\\:2]/Volumes/FinalStore/Test/LC_10min_Framemd5_MP4_QCLI.mkv|[f=nut:onfail=abort:select=v,a\\:1,a\\:2,a\\:0]pipe:1 -an -f framemd5 /Volumes/FinalStore/Test/LC_10min_Framemd5_MP4_QCLI.framemd5 -metadata creation_time=now -movflags write_colr+faststart -filter_complex [0:v:0]crop=w=720:h=480:x=0:y=4,setsar=10/11,bwdif,format=yuv420p[mp4_v_out];[0:a:0]pan=stereo| c0=c0 | c1=c1[stereo1];[0:a:0]pan=stereo| c0=c2 | c1=c3[stereo2] -c:v h264 -g 12 -profile:v main -level 3.1 -b:v 3500k -c:a aac -map [mp4_v_out] -map [stereo1] -map [stereo2] /Volumes/FinalStore/Test/LC_10min_Framemd5_MP4_QCLI.mp4
Playback command: /opt/homebrew/bin/ffplay-ma -v info -hide_banner -stats -autoexit -window_title mode:record - video:'sdi' audio:'embedded' - to end recording press q, esc, or close video window -i - -vf split=6[a][b][c][d][e][f];[a]copy[a1];[b]field=top,    format=yuv422p,    waveform=scale=digital:intensity=0.1:mode=column:mirror=1:c=1:f=lowpass:e=instant:graticule=green:flags=numbers+dots[b1];[c]field=bottom,    format=yuv422p,    waveform=scale=digital:intensity=0.1:mode=column:mirror=1:c=1:f=lowpass:e=instant:graticule=green:flags=numbers+dots[c1];[d]    format=yuv422p,    vectorscope=i=0.04:mode=color2:c=1:envelope=instant:graticule=green:flags=name,    scale=512:512,    drawbox=w=9:h=9:t=1:x=128-3:y=512-452-5:c=sienna@0.8,    drawbox=w=9:h=9:t=1:x=160-3:y=512-404-5:c=sienna@0.8,    drawbox=w=9:h=9:t=1:x=192-3:y=512-354-5:c=sienna@0.8,    drawbox=w=9:h=9:t=1:x=224-3:y=512-304-5:c=sienna@0.8,    drawgrid=w=32:h=32:t=1:c=white@0.1,    drawgrid=w=256:h=256:t=1:c=white@0.2[d1];[e]signalstats=out=brng:stat=brng+vrep+tout,scale=512:ih,split[e1][e2];[e2]format=yuv422p,geq=lum=60:cb=128:cr=128,scale=180:ih+512,setsar=1/1,drawtext=fontcolor=white:fontsize=22:fontfile=/System/Library/Fonts/Supplemental/Andale Mono.ttf:textfile=/tmp/vrecord.IAoIQL.drawtext.1.txt,drawtext=fontcolor=white:fontsize=17:fontfile=/System/Library/Fonts/Supplemental/Andale Mono.ttf:textfile=/tmp/vrecord.spgCTN.drawtext.2.txt:y=480,drawtext=fontcolor=white:fontsize=52:fontfile=/System/Library/Fonts/Supplemental/Andale Mono.ttf:textfile=/tmp/vrecord.8UucU5.drawtext.3.txt:y=640[e3];[f]scale=iw+512+180:82,format=yuv422p,geq=lum=60:cb=128:cr=128,drawtext=fontcolor=white:fontsize=22:fontfile=/System/Library/Fonts/Supplemental/Andale Mono.ttf:textfile=/tmp/vrecord.53Rwmg.vrecord_input.log:reload=1:y=82-th[f1];[e3][a1][b1][c1][e1][d1][f1]xstack=inputs=7:layout=0_0|w0_0|w0_h1|w0_h1+h2|w0+w1_0|w0+w1_h1|0_h0 -af pan=4c|c0=c0|c1=c1|c2=c2|c3=c3
Record exit code: 0
Playback exit code: 0
datetime_end: 2026-07-08T16:45:41
Decklink input buffer overrun: No
mediaconch_outcome: passed
```

#### Source: FFmpeg Log (abridged)

```
ffmpeg version 8.0 Copyright (c) 2000-2025 the FFmpeg developers
  built with Apple clang version 16.0.0 (clang-1600.0.26.4)
  libavutil      60.  8.100 / 60.  8.100
  libavcodec     62. 11.100 / 62. 11.100
  libavformat    62.  3.100 / 62.  3.100

Input #0, decklink, from 'DeckLink SDI 4K':
  Stream #0:0: Audio: pcm_s32le, 48000 Hz, 8 channels, s32, 12288 kb/s
  Stream #0:1: Video: v210, yuv422p10le(bottom first), 720x486, 223725 kb/s, 29.97 fps
    Metadata:
      timecode        : 10:33:58;09

Output #0, tee, to '[f=matroska]/Volumes/.../LC_10min_Framemd5_MP4_QCLI.mkv|...':
  Stream #0:0: Video: ffv1, yuv422p10le(tv, smpte170m/smpte170m/bt709, bottom coded first (swapped)),
    720x486 [SAR 10:11 DAR 400:297], 29.97 fps
  Stream #0:1: Audio: pcm_s24le, 48000 Hz, 8 channels, s32 (24 bit), 9216 kb/s
  Stream #0:2: Audio: pcm_s24le, 48000 Hz, stereo, s32 (24 bit), 2304 kb/s
  Stream #0:3: Audio: pcm_s24le, 48000 Hz, stereo, s32 (24 bit), 2304 kb/s

Output #1, framemd5, to 'LC_10min_Framemd5_MP4_QCLI.framemd5':
  Stream #1:0: Video: rawvideo, yuv422p10le, 720x486, 29.97 fps

Output #2, mp4, to 'LC_10min_Framemd5_MP4_QCLI.mp4':
  Stream #2:0: Video: h264 (avc1), yuv420p(tv, progressive), 720x480 [SAR 10:11 DAR 15:11], 3500 kb/s, 59.94 fps
  Stream #2:1: Audio: aac (LC), 48000 Hz, stereo, fltp, 128 kb/s
  Stream #2:2: Audio: aac (LC), 48000 Hz, stereo, fltp, 128 kb/s

frame=17944 fps= 21 q=-0.0 Lsize=N/A time=00:09:58.69 bitrate=N/A dup=3399 drop=0 speed=0.714x elapsed=0:13:59.03
```

#### What the Logs Tell Us

These logs together provide a wealth of details about the digitization event:

- **What was captured:** An NTSC SDI video signal at 720×486, 29.97fps interlaced (bottom field first), 10-bit YUV 4:2:2 (yuv422p10le), with 8 channels of 48kHz 32-bit embedded SDI audio. The source signal carried SMPTE timecode 10:33:58;09. The properties of the video and audio aligns with the highest quality of NTSC multimedia streams that the Blackmagic capture card can provide. Prior to the Blackmagic capture card are more details such as the details of the source video tape, its playback device, any timebase corrector involved; however, this information is not documented in the current vrecord logs which start detailing the provenance chain at the capture card.
- **What produced it:** A vrecord session (version 2026-07-07) running on a Mac mini (Mac14,3, 16GB RAM, 8 cores, Darwin 23.6.0), using a DeckLink SDI 4K capture card, writing to an external SSD.
- **What FFmpeg did (preservation copy):** Captured the DeckLink SDI stream and encoded it to FFV1 version 3 (level 3, GOP=1, 24 slices with CRC) in a Matroska container, with 24-bit PCM audio mapped into two stereo pairs. The color metadata was set explicitly: SMPTE 170M primaries, BT.709 transfer, SMPTE 170M matrix, limited range. The sample aspect ratio was set to 10:11 for 4:3 NTSC.
- **What FFmpeg did (concurrent fixity):** A `framemd5` file was generated concurrently with per-frame MD5 hashes for every frame in the captured video, providing intra-file fixity.
- **What FFmpeg did (concurrent QC):** A QCTools XML report was generated concurrently for quality control analysis.
- **What FFmpeg did (access derivative):** Simultaneously produced an H.264/MP4 access copy by cropping the video to 720×480 (removing 6 lines of vertical blanking: `crop=w=720:h=480:x=0:y=4`), deinterlacing with `bwdif`, converting to 8-bit YUV 4:2:0 (`format=yuv420p`), encoding to H.264 Main profile level 3.1 at 3500 kb/s, with AAC audio at 128 kb/s per stereo pair. The MP4 was written with `faststart` (moov atom moved to beginning for streaming) and color information embedded (`write_colr`).
- **Post-capture validation:** MediaConch validation passed (`mediaconch_outcome: passed`), confirming the resulting MKV file conforms to the expected Matroska/FFV1/LPCM specification.
- **Processing context:** FFmpeg 8.0 (libavcodec 62.11.100, libavformat 62.3.100), built statically with DeckLink support, running on Apple Silicon.

#### Derived C2PA Manifest

The following is a simplified JSON representation of the C2PA manifest. In an actual implementation, this would be encoded as CBOR within a JUMBF manifest store and signed with the institution's signing credential. The manifest covers the collection of outputs produced by the capture session, the preservation MKV, the access MP4, the framemd5 fixity file, and the QCTools XML report, with each file individually hashed. MKV is not currently a C2PA-supported format for embedding, so the manifest would be a sidecar file.

```json
{
  "claim_generator": "vrecord/2026-07-07 (ffmpeg-ma/8.0)",
  "claim_generator_info": [
    {
      "name": "vrecord",
      "version": "2026-07-07",
      "schema_version": "2.4"
    }
  ],
  "ingredients": [
    {
      "title": "Analog video source (NTSC SDI signal)",
      "document": {
        "format": "video/sdi",
        "description": "Analog videotape playback via SDI connection to DeckLink SDI 4K capture card"
      },
      "meta": {
        "digitalSourceType": "http://cv.iptc.org/newscodes/digitalsourcetype/analogOriginal",
        "signalStandard": "NTSC",
        "timecodeIn": "10:33:58;09"
      }
    }
  ],
  "assertions": [
    {
      "label": "c2pa.actions",
      "data": {
        "actions": [
          {
            "action": "c2pa.created",
            "when": "2026-07-08T16:31:32",
            "ingredientIds": [0],
            "description": "Video digitization capture from analog source via DeckLink SDI 4K. NTSC SDI input, 720x486, 29.97fps interlaced, 10-bit YUV 4:2:2, 8-channel 48kHz embedded audio.",
            "parameters": {
              "source_signal": "NTSC SDI",
              "capture_card": "DeckLink SDI 4K",
              "video_format": "720x486, 29.97fps, interlaced (bottom field first), yuv422p10le",
              "audio_format": "pcm_s32le, 48000 Hz, 8 channels",
              "timecode_in": "10:33:58;09",
              "technician": "MM",
              "capture_device": "WD_BLACK SN850XE 4000GB (External)",
              "capture_host": "Mac mini Mac14,3, 16GB, 8 cores, Darwin 23.6.0",
              "vrecord_version": "2026-07-07",
              "ffmpeg_version": "8.0, libavcodec 62.11.100",
              "ffmpeg_build": "Apple clang 16.0.0, static, DeckLink enabled"
            }
          },
          {
            "action": "c2pa.transcoded",
            "when": "2026-07-08T16:31:32",
            "ingredientIds": [0],
            "description": "DeckLink SDI v210 stream encoded to FFV1 version 3 in Matroska container (preservation master). Audio encoded to 24-bit PCM. Framemd5 and QCTools XML generated concurrently.",
            "parameters": {
              "input_codec": "v210 (raw 10-bit YUV 4:2:2 from DeckLink SDI)",
              "output_video_codec": "FFV1 version 3, level 3, GOP=1, 24 slices, CRC enabled",
              "output_audio_codec": "pcm_s24le, 48kHz",
              "output_container": "Matroska",
              "color_metadata": "primaries=smpte170m, transfer=bt709, matrix=smpte170m, range=limited",
              "sar": "10:11 (NTSC 4:3)",
              "audio_streams": "4 streams: 1x 8-channel original, 2x stereo (ch1+2, ch3+4)",
              "concurrent_fixity": "framemd5 (per-frame MD5)",
              "concurrent_qc": "QCTools XML",
              "closed_captions": "EIA-608 extracted via readeia608 filter"
            }
          },
          {
            "action": "c2pa.transcoded",
            "when": "2026-07-08T16:31:32",
            "ingredientIds": [0],
            "description": "Access derivative: DeckLink SDI stream cropped, deinterlaced, and converted to H.264/MP4.",
            "parameters": {
              "filters": [
                {
                  "filter": "crop",
                  "args": "w=720:h=480:x=0:y=4",
                  "c2pa_action": "c2pa.cropped",
                  "description": "Vertical blanking lines removed (6 lines from top: 486 to 480)"
                },
                {
                  "filter": "bwdif",
                  "description": "Bob-Wavering deinterlace (interlaced to progressive)"
                },
                {
                  "filter": "format",
                  "args": "yuv420p",
                  "description": "Pixel format conversion: 10-bit yuv422p10le to 8-bit yuv420p"
                }
              ],
              "output_video_codec": "H.264, Main profile, level 3.1, 3500 kb/s",
              "output_audio_codec": "AAC LC, 48kHz, 128 kb/s per stereo pair",
              "output_container": "MP4 (faststart, write_colr)",
              "output_frame_rate": "59.94 fps (doubled from 29.97 by deinterlace)"
            }
          }
        ]
      }
    },
    {
      "label": "stds.device_capture",
      "data": {
        "capture_device": "Blackmagic DeckLink SDI 4K",
        "input": "SDI",
        "signal_standard": "NTSC",
        "video": {
          "width": 720,
          "height": 486,
          "frame_rate": "29.97",
          "interlaced": true,
          "field_order": "bottom first",
          "pixel_format": "yuv422p10le",
          "bit_depth": 10
        },
        "audio": {
          "sample_rate": 48000,
          "channels": 8,
          "bit_depth": 32,
          "source": "SDI Embedded"
        },
        "timecode": "10:33:58;09"
      }
    },
    {
      "label": "fadgi.capture_event",
      "data": {
        "technician": "MM",
        "vrecord_version": "2026-07-07",
        "ffmpeg_version": "8.0",
        "capture_start": "2026-07-08T16:31:32",
        "capture_end": "2026-07-08T16:45:41",
        "duration_captured": "00:09:58.69",
        "frames_captured": 17944,
        "frames_duplicated": 3399,
        "frames_dropped": 0,
        "processing_time": "00:13:59.03",
        "processing_speed": "0.714x real-time",
        "post_capture_validation": {
          "tool": "MediaConch",
          "outcome": "passed"
        },
        "concurrent_outputs": [
          "framemd5 (per-frame MD5 fixity)",
          "QCTools XML (quality control)",
          "EIA-608 closed captions (extracted to file)"
        ]
      }
    },
    {
      "label": "c2pa.hash.collection.data",
      "data": {
        "alg": "sha256",
        "uris": [
          {
            "uri": "LC_10min_Framemd5_MP4_QCLI.mkv",
            "hash": "a1b2c3d4e5f6...[SHA-256 of preservation master]"
          },
          {
            "uri": "LC_10min_Framemd5_MP4_QCLI.mp4",
            "hash": "f7e8d9c0b1a2...[SHA-256 of access derivative]"
          },
          {
            "uri": "LC_10min_Framemd5_MP4_QCLI.framemd5",
            "hash": "1a2b3c4d5e6f...[SHA-256 of framemd5 fixity file]"
          },
          {
            "uri": "LC_10min_Framemd5_MP4_QCLI.qctools.xml",
            "hash": "aabbccdd1122...[SHA-256 of QCTools report]"
          }
        ]
      }
    }
  ]
}
```

#### Notes on the Derivation

For a walk-through of the potential for C2PA to record a vrecord digitization event, here is an overview of what is documented:

**`c2pa.created` as the first action.** The CAI SDK documentation states that "every manifest has to start with either an `c2pa.opened` or `c2pa.created` action, which has to be the first action in the manifest," and that "each of these actions need to have an associated ingredient." For a digitization capture from a potentially analog source, `c2pa.created` is the most fitting action with a digital asset being created with an analog source signal as its ingredient.

**The analog source as ingredient.** Here the C2PA ingredients model becomes an awkward fit. The specification's ingredients model appears to be designed for digital-to-digital provenance chains, where an ingredient is a prior digital asset that may itself carry a C2PA manifest. An analog videotape signal has no prior manifest and analog material is generally incompatible with the forms of integrity management that can be applied to digital materials (such as cryptographic signatures, content hashing, and other forms of hard binding). The ingredient can be declared with its metadata (such as signal standard and timecode with the digital source type set to `analogOriginal` per the IPTC NewsCodes vocabulary), but the `ingredientIds` array references an ingredient that carries no cryptographic manifest, only descriptive metadata. This is a genuine representation of the provenance chain: vrecord can document what it received and what it did, but it cannot cryptographically prove what happened to the analog source before it reached the SDI input. Within the context of a potential integration of vrecord and C2PA the provenance chain would begin at the capture card.

**Two `c2pa.transcoded` actions.** vrecord often generates multiple outputs from a single input, such as simultaneously creating a preservation master (FFV1/Matroska) and the access derivative (H.264/MP4). Each is a distinct transcode with different codecs, containers, processing, and intents. Rather than blending them into one action, in this example they are modeled as two separate `c2pa.transcoded` actions, both pointing to the same ingredient (the analog source) but with the details of each transcoding given its full distinction; i.e. the preservation-grade encoding using lossless FFV1 and full resolution whereas the access file encoding uses lossy H264, frame cropping, and downsampling.

**Filterchain decomposition for the access derivative.** The access derivative's filterchain contains three filters, each documented as a nested parameter: `crop` (removing 6 lines of vertical blanking from 486 to 480), `bwdif` (deinterlacing from 29.97i to 59.94p), and `format=yuv420p` (converting 10-bit 4:2:2 to 8-bit 4:2:0). The `crop` filter maps to `c2pa.cropped`; the others are documented as descriptive parameters under the transcoded action.

**What the manifest does not capture.** The vrecord log records the full FFmpeg command line used for capture, including the complex filterchain syntax with `setparams`, `readeia608` (closed caption extraction), `asplit`, `pan` (channel mapping), and `setsar`. The command line is available in the vrecord log while the manifest itself records only the structured parameters. As with the FFmpeg transcoding example, the command line itself is pertinent to document, could be retained in the log file and bound to the manifest by hash, but is not necessarily duplicated in the manifest's structured fields. A validator checking the manifest would confirm the log is unchanged since signing, then consult the log for the full command line detail.

**Sidecar vs. embedded manifest.** vrecord often uses Matroska as a preservation format; however Matroska is not currently a C2PA-supported format for embedding, while the access derivative (MP4) is C2PA-supported. In this example, the manifest is modeled as a sidecar covering the collection of outputs. Alternative approaches would be to embed a manifest in the MP4 (since MP4 supports embedding) and use a sidecar for the MKV or coordinate with C2PA and the IETF on establishing C2PA support for Matroska.

## MediaInfo

MediaInfo is a widely used free and open-source tool for reading and reporting technical metadata from audiovisual files. It is not a metadata editing tool and does not participate in creating provenance records, but it is a critical instrument for verifying that provenance metadata exists, is correctly formed, and has survived transformations. Understanding what MediaInfo reports, and how it differs from the underlying format's native field structure, is important for using it effectively in provenance workflows.

### Standard MediaInfo Report

The standard MediaInfo output presents a cross-format normalized view of a file's technical metadata. It maps format-native field names and values to a common vocabulary that MediaInfo applies consistently across formats. As MediaInfo has a focus on interoperability and a cross-referenced audiovisual property vocabulary: a user can compare a DPX file and an MXF file in MediaInfo using the same field names. This normalization is useful for general analysis and assessment, but it means the reported field names are MediaInfo's own and may not correspond directly to the field names as they appear in the format specification. Values may also be interpreted, converted, or truncated to fit the common vocabulary.

The `-f` (or `--Full`) option on the command line produces a more complete output, including fields that MediaInfo populates but does not display in its default report. This surfaces additional technical and tag data that may be relevant to provenance analysis but hidden in the default view.

### MediaTrace and `--Details=1`

MediaTrace is a separate report mode that expresses the binary architecture of a file as MediaInfo interprets it, field by field, with byte offsets, lengths, and raw values, in the context of the original format specification. It is generated using `--Details=1` on the MediaInfo command line:

```bash
# Standard report with all fields
mediainfo -f myfile.dpx

# MediaTrace output (binary structure, full field context)
mediainfo --Details=1 myfile.dpx

# MediaTrace in XML (recommended for scripted processing)
mediainfo --Details=1 --Output=XML myfile.dpx
```

The distinction between the standard report and MediaTrace is significant for provenance work. The standard report tells you what MediaInfo determined the value to be, normalized for cross-format comparison. MediaTrace tells you where in the file the value lives, what its raw value is, and what the format standard says the field means. For DPX, MediaTrace reports FADGI-relevant fields such as Creator (Field 12), Project name (Field 13), Creation date/time (Field 10), Source image date/time (Field 37), and the user-defined data area in their original byte positions and encoding. This is closer to a direct read of the format specification than the standard report.

### MediaInfo Fields That Relate to CAP

MediaInfo reports several fields in its General section that have direct relevance to provenance documentation. However, it is worth noting that while MediaInfo defines these fields in its schema, implementations in the wild may use them inconsistently. A field that is defined in the format specification may be populated with values that differ from what a provenance workflow expects, or may be used for purposes other than what FADGI or the spec intends. This variability is a reason to prefer MediaTrace, which presents values in their native field context, over the standard report for provenance auditing.

Fields worth noting:

- **Encoded_Date / Tagged_Date / File_Created_Date:** MediaInfo surfaces multiple date fields, which can reflect the digitization date, the metadata tagging date, or the filesystem date depending on the format and implementation. In a format like DPX, where Field 10 (Creation date/time) and Field 37 (Source image date/time) carry distinct provenance meanings, the standard MediaInfo output may surface only one of these as `Encoded_Date` while MediaTrace shows both in their proper field context.
- **Encoded_Library / Encoded_Library_Name / Encoded_Library_Version:** Records the software used to create the file. Useful for identifying tool provenance but only as reliable as the tool that wrote it. Some encoders populate this field accurately; others use it for unrelated purposes or leave it empty.
- **OriginalSourceMedium:** Records the original source medium (film, tape, etc.). Availability and accuracy depend entirely on the originating tool and format.
- **Comment / Description:** Free-text fields that tools sometimes use to embed workflow notes, provenance information, or tool-specific data. The content is unpredictable across implementations.

For DPX specifically, MediaTrace is preferable over the standard report when the goal is auditing FADGI-compliant embedded metadata, because it surfaces the raw field values in the context of the format standard, the same context in which embARC validates them. The combination of embARC (for validation and correction) and MediaInfo MediaTrace (for inspection and documentation) provides a complete picture.

### Scripted MediaInfo Output as Provenance Documentation

MediaInfo's `--Output=XML` and `--Output=JSON` modes produce machine-readable reports that can be ingested into PREMIS object records or other preservation metadata schemas. Running MediaInfo against files at defined workflow points, such as at ingest, after any transformation, and at periodic intervals in storage, produces a chronological record of the file's reported technical state. Differences between reports at different points can surface metadata changes, format changes, or unexpected modifications. This is a low-cost, broadly applicable provenance practice.

```bash
# Capture a full MediaInfo report in XML for a DPX sequence at ingest
for f in /scans/MyFilm_Reel1/*.dpx; do
 mediainfo --Output=XML "$f" >> ingest_mediainfo_report.xml
done
```

MediaInfo has recently added features to report on the presence or selected details of embedded C2PA manifests in a variety of file formats. As C2PA adoption grows in the preservation community, support for reading C2PA manifest sidecars alongside technical metadata in a single tool would be a useful development. At present, C2PA verification requires separate tooling such as c2patool.

## embARC

embARC (Metadata Embedded for Archival Content) is a free and open source application developed by FADGI in conjunction with AVP and PortalMedia for auditing, validating, and correcting embedded metadata in DPX and MXF files. It is the primary tool for ensuring FADGI-compliant embedded provenance at the sequence scale, and under this project's statement of work it is the designated proof-of-concept implementation for CAP features.

### embARC and Provenance Documentation

embARC's core function, ensuring that DPX header fields accurately document the provenance of a scan, is itself a provenance practice. A DPX sequence in which Field 12 is correctly populated with the institution's name, Field 37 correctly records the source material date, and Field 76 correctly encodes the digitization process history is a sequence with meaningful embedded provenance. embARC makes this achievable at the scale of a full-length film scan: correcting or populating these fields across 100,000 frames in a single batch operation, rewriting only the specific header byte ranges that need to change without touching image data.

### Logging embARC Operations

embARC generates audit and correction reports documenting which fields were non-conformant, which corrections were applied, and across which files. These reports should be retained as provenance records as they document that a review process identified metadata problems and that a specific version of embARC applied specific corrections on a specific date. A recommended practice is to run an audit before any correction, export the report, perform corrections, and run a second audit to confirm results. The two reports together constitute a before-and-after record of the metadata state, equivalent to the `ffprobe` diff approach described for FFmpeg.

### embARC and Content Authenticity

Because embARC does not touch image data, it can assert that any DPX sequence it has processed retains its original pixel content. The combination of an embARC audit report, pre- and post-operation fixity of the image data portion of each file, and a C2PA sidecar manifest generated by embARC would constitute a well-documented provenance chain for a corrected DPX sequence.

### Planned C2PA Integration

As described in the companion appendix, embARC is planned to gain the ability to generate C2PA sequence-level sidecar manifests as part of its metadata operation workflow, and to display existing C2PA manifests in its audit interface. The sidecar approach uses `c2pa.hash.collection.data` with a hashing strategy that hashes only the image data region of each DPX file and excludes the header, mapping directly to embARC's core guarantee that image data is not modified. This means the expensive I/O cost of hashing the image data of every frame in a long sequence is a one-time cost per sequence, not a recurring cost for each subsequent metadata correction. The manifest's `c2pa.actions` assertion records which header fields were modified, with `image_data_modified: false` confirming that the image data hash should still match.

These additions will not change embARC's existing DPX editing behavior. The initial release of C2PA features will follow community review and testing, per the process described in Section 3.2.2. Content authenticity and provenance updates to embARC will be subject to regression testing and external user testing before release, consistent with the project's release standards for major versions, and will not inhibit existing functionality.
