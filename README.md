# literature-map-builder

A Codex skill for turning a research area into a structured literature map,
gap map, and proposal-positioning artifact.

The skill supports a three-stage workflow:

1. Collect representative papers and build `literature-map.md`.
2. Extract PDF text and build `gap-map.csv`, `gap-map.md`,
   `core-paper-notes.md`, and `gap-summary.md`.
3. Convert the gap analysis into `proposal-positioning.md`.

## Install

Clone this repository into your Codex skills directory:

```powershell
git clone https://github.com/liuquangao/literature-map-builder.git `
  "$HOME\.codex\skills\literature-map-builder"
```

The installed directory should contain:

```text
literature-map-builder/
  SKILL.md
  agents/
  references/
  scripts/
```

## Included Tools

- `scripts/download_open_pdfs.ps1`: downloads open-access PDFs from a candidate
  CSV and writes a manifest.
- `scripts/extract_pdf_text_cache.ps1`: extracts first-pass text from PDFs into
  a local text cache.
- `references/`: templates for literature maps, gap maps, gap summaries, and
  proposal positioning.

## Notes

This skill is designed for proposal preparation, literature surveys, and
research positioning. It emphasizes cautious claims: candidate gaps should be
grounded in the collected papers and nearest competing work before being turned
into proposal language.
