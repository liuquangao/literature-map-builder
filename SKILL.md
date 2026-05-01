---
name: literature-map-builder
description: >
  Build a structured literature-to-positioning pipeline for a new research topic
  or proposal: collect representative papers, download and validate open-access
  PDFs, create literature-map.md and a manifest; convert the collection into a
  gap map by extracting PDF text, tagging each paper by project-relevant
  dimensions such as domain, task, method, data, evaluation, and limitations,
  classifying Core/Support/Peripheral papers, writing core-paper-notes.md, and
  producing gap-summary.md; then turn the gap analysis into
  proposal-positioning.md with candidate titles, cautious problem statement,
  nearest competing work, specific aims, claim-safety table, evidence-to-claim
  map, remaining literature checks, evaluation scenarios, baselines, and
  narrative skeleton. Use when the user asks to broadly collect papers, survey a
  new research area, prepare references for a proposal, build a literature map,
  create a gap map, analyze research gaps, or position a proposal without
  prematurely deciding novelty.
---

# Literature Map Builder

Use this skill to run a three-stage literature intake pipeline for a research
project:

1. Stage 1: broad paper collection and `literature-map.md`.
2. Stage 2: structured `gap-map.csv`, `gap-map.md`, `core-paper-notes.md`, and
   `gap-summary.md`.
3. Stage 3: proposal positioning in `proposal-positioning.md`.

The goal is to turn a research area from "a pile of PDFs" into evidence-backed
proposal positioning without jumping too early to novelty claims.

## Core Rule

Do not prematurely claim a gap or innovation point during Stage 1. During Stage
2, write candidate gaps only when they are grounded in the structured table and
nearest competing papers. During Stage 3, translate gaps into cautious proposal
positioning, not final grant prose. Mark uncertain claims as hypotheses requiring
follow-up search.

## Stage 1 Workflow: Build the Literature Map

1. Read the project instructions, if present, such as `AGENTS.md`.
2. Define the scope:
   - research topic;
   - target project directory;
   - PDF output directory;
   - required subareas;
   - approximate number of papers for the first pass.
3. Build a search matrix across subareas.
   - Search beyond the user's favorite method or anchor paper.
   - Include surveys, foundational papers, recent papers, datasets, benchmarks,
     and task-specific papers when relevant.
4. Prefer open, reliable PDF sources:
   - arXiv;
   - PMLR;
   - CVF OpenAccess;
   - OpenReview-hosted PDFs;
   - official project pages with direct PDF links;
   - publisher open-access PDFs.
5. Download only legitimate open PDFs.
   - Use title-based filenames.
   - Remove Windows-invalid filename characters.
   - Keep filenames concise enough for Windows paths.
   - Validate that downloaded files start with `%PDF`.
   - Do not keep HTML pages saved as `.pdf`.
6. Create a `literature-map.md`.
   - Use the template in `references/literature-map-template.md` when helpful.
   - Organize papers by category.
   - Include local PDF paths and source URLs.
   - Keep notes short in the first pass.
7. Create a download manifest.
   - Include filename, file size, source URL, category, and download status.
8. End with:
   - PDF count;
   - created files;
   - failed or skipped downloads;
   - coverage summary;
   - recommended second-pass gap-map tasks.

## Stage 2 Workflow: Build the Gap Map

Use Stage 2 after there is a local PDF collection and a first-pass
`literature-map.md`.

1. Extract text from PDFs into a cache directory.
   - Prefer `pdftotext` when available.
   - Extract enough pages to classify the paper quickly, usually the first 6-10
     pages.
   - Keep the cache local, e.g. `paper-text-cache/`.
2. Create `gap-map.csv` with one row per paper.
   - Use the fields in `references/gap-map-template.csv` when helpful.
   - Keep values concise and sortable.
   - Use `Partial`, `Not primary`, or `Unclear` rather than overclaiming.
3. Classify each paper as:
   - `Core`: directly informs the central research positioning;
   - `Support`: useful background or supporting evidence;
   - `Peripheral`: collected for coverage but not central.
4. Create `gap-map.md`.
   - Summarize coverage and tier counts.
   - Identify a priority core set for deeper reading.
   - Summarize category-level patterns.
5. Create `core-paper-notes.md`.
   - Read the priority core set more carefully.
   - For each paper, record what it solves, the domain/task/method/data and
     evaluation setting, what it does not solve, how it threatens novelty, and
     how it can be used in a proposal.
6. Create `gap-summary.md`.
   - State evidence-backed candidate gaps.
   - For each candidate gap, include supporting evidence, nearest competing
     papers, and cautions.
   - End with follow-up searches needed before finalizing novelty.
7. Verify artifacts:
   - PDF count matches text-cache count unless failures are explained.
   - `gap-map.csv` has one row per paper.
   - Core/Support/Peripheral counts are reported.

## Stage 3 Workflow: Build Proposal Positioning

Use Stage 3 after `gap-summary.md` and `core-paper-notes.md` exist. The output is
`proposal-positioning.md`, not the full proposal.

1. Read:
   - project instructions such as `AGENTS.md`;
   - `gap-summary.md`;
   - `core-paper-notes.md`;
   - `gap-map.md`;
   - any previous application/template structure if available.
2. Write a cautious working problem statement.
   - Ground it in the strongest evidence-backed gap.
   - Avoid universal claims such as "no one has done X."
3. Generate 3-5 candidate proposal titles.
   - Include conservative and ambitious variants.
   - Choose one recommended working title.
4. State the chosen main positioning.
   - Make clear what the project is and what it is not.
5. Write a nearest-competing-work paragraph.
   - Name the closest papers or systems.
   - Explain how the proposed direction differs.
6. Write a one-sentence pitch.
7. Draft 2-4 specific aims.
   - Each aim should have expected outputs.
   - Keep aims feasible for the user's project, timeline, hardware, and budget.
8. Create a claim-safety table.
   - Include safe wording and wording to avoid.
9. Create an evidence-to-claim map.
   - Map each proposal claim to supporting papers and remaining checks.
10. List remaining literature checks before finalizing novelty.
11. Add evaluation scenarios and candidate baselines.
12. End with a narrative skeleton and the recommended next artifact, usually a
    proposal outline.

## Search Coverage Heuristics

For each subarea, try to include:

- one or two foundational papers;
- one survey or benchmark if available;
- two to five recent papers;
- at least one method paper and one dataset/evaluation paper when possible.

For domain-specific proposals, adapt the tagging dimensions to the project. Do
not assume any one domain, platform, or method is central unless the user's
project instructions say so. Common dimensions include:

- problem setting or deployment context;
- inputs, modalities, or data sources;
- platform, system, population, or environment;
- task, objective, or decision being supported;
- method family or training paradigm;
- outputs or prediction targets;
- safety, robustness, fairness, reliability, or human-facing constraints;
- real-world, simulation, retrospective, or benchmark evaluation;
- dataset, benchmark, or measurement availability.

## Download Script

Use `scripts/download_open_pdfs.ps1` when you have a candidate CSV. The script
expects columns:

- `Title`
- `Url`
- optional `Category`

Example:

```powershell
$SkillDir = "$HOME\.codex\skills\literature-map-builder"
powershell -ExecutionPolicy Bypass -File `
  (Join-Path $SkillDir "scripts\download_open_pdfs.ps1") `
  -CsvPath ".\paper-candidates.csv" `
  -OutputDir ".\reference-papers-pdf" `
  -ManifestPath ".\reference-papers-pdf\download-manifest.csv"
```

If no CSV exists, collect candidates in memory or create a small temporary CSV,
then run the script.

## PDF Text Extraction

Use `scripts/extract_pdf_text_cache.ps1` to create a text cache from local PDFs.
The script expects an input PDF directory and output text directory.

Example:

```powershell
$SkillDir = "$HOME\.codex\skills\literature-map-builder"
powershell -ExecutionPolicy Bypass -File `
  (Join-Path $SkillDir "scripts\extract_pdf_text_cache.ps1") `
  -PdfDir ".\reference-papers-pdf" `
  -TextDir ".\paper-text-cache" `
  -FirstPage 1 `
  -LastPage 8
```

If `pdftotext` is unavailable, report the blocker and use another available PDF
text extraction tool if the environment provides one.

## Literature Map Fields

The first-pass map should include:

- paper title;
- category;
- why it is relevant;
- local PDF path;
- source URL.

The second-pass gap map should expand each paper with:

- domain or application setting;
- inputs, modalities, or data sources;
- platform, system, population, or environment;
- task or objective;
- method type;
- output, prediction target, or intervention;
- evaluation setting;
- robustness, safety, fairness, or reliability concern;
- limitation or gap;
- proposal relevance.

## Stage 2 Outputs

Create these files unless the user requests different names:

- `gap-map.csv`: one row per paper, sortable and machine-readable.
- `gap-map.md`: human-readable category and tier summary.
- `core-paper-notes.md`: focused notes on the priority core papers.
- `gap-summary.md`: evidence-backed candidate gaps and nearest competitors.

Use `references/gap-map-template.csv` and
`references/gap-summary-template.md` when helpful.

## Stage 3 Output

Create `proposal-positioning.md` unless the user requests a different name. Use
`references/proposal-positioning-template.md` when helpful.

## Output Discipline

- Be explicit about which information was verified and which remains tentative.
- Cite source URLs in the literature map.
- If a PDF fails to download, record the failure and move on to an open
  alternative when possible.
- Do not present first-pass observations as final research contributions.
- Keep project-specific categories distinct; for example, do not blur input
  modality, model type, prediction target, and evaluation task.
- Always name nearest competing papers for each candidate gap.
- In proposal positioning, distinguish candidate gaps from final novelty claims.
- Prefer "the current map suggests..." or "we hypothesize..." until targeted
  follow-up searches have ruled out close prior work.
