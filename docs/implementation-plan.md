# Basair Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Build an Arabic mobile Quran exploration app connecting visual discoveries to verifiable verses, sources and private reflections.

**Architecture:** Flutter UI with local SQLite and versioned source bundles. A verified corpus powers deterministic calculations; editorial sources power reviewed topic links and journeys. Offline-first, no account required.

**Tech Stack:** Flutter/Dart, SQLite, flutter_test, integration_test. Select maintained compatible package versions during setup and record lockfile.

**Spec:** /workspace/work/basair-design.md plus the proposed experience additions below, subject to user review.

## Proposed experience additions
1. A circular surah map: each segment represents a surah, with text-list alternative. Selection filters the results instead of implying a semantic relation.
2. Build your question: choose word, matching method and scope, optionally compare a second word. Export preserves these settings.
3. Evidence drawer on every result: text version, method, source, scope and verse occurrences.
4. Topic journeys allow parallel verse reading and sourced explanation. Connection type is explicit: editorial topic membership or lexical match.
5. A personal discovery notebook links a reflection to selected verse IDs and query configuration.
6. An export studio offers a portrait story and square card, with source footnotes and preview; private notes are excluded unless explicitly selected.
7. Warm ivory, deep teal and restrained brass palette, generous Arabic typography and subtle optional motion. Visual polish must not obscure verse readability.

## Global Constraints
- Arabic RTL; Quran text from a licensed, verified Hafs Uthmani source selected before corpus integration.
- No fabricated counts, unsupported miracle claims, or unreviewed published commentary.
- Display text immutable; search normalization separate and documented.
- Every count opens its occurrences; every editorial connection names its source.
- Ten reviewed topics and three reviewed journeys define the first content release.
- No account, cloud sync, payment, social feed or generated commentary in release one.

## Review Focus
- Empty or punctuation-only queries: guidance, never a match-all result.
- Overlapping topic groups: unique verse count distinct from membership count.
- Missing analysis data: unavailable state rather than guessed roots.
- Storage or update failure: existing content retained, understandable error.
- Large text, screen reader and image export: no clipped verse text or inaccessible chart-only result.

## File structure
- app/lib/main.dart: app entry, RTL theme and routing.
- app/lib/corpus/: immutable verse models, source metadata, bundle validation and repository.
- app/lib/search/: normalization policies, lexical queries, counts and result models.
- app/lib/features/{discover,atlas,words,insights,library}/: five main destinations.
- app/lib/journeys/: reviewed journey state and questions.
- app/lib/export/: card renderer and native share/save boundary.
- app/lib/storage/: local database and recoverable persistence.
- app/assets/content/: approved source bundles and licenses.
- app/test/: domain and widget checks; app/integration_test/: offline journey/export checks.
- app/README.md: setup, test commands, source policy and implementation limitations.

### Task 1: Runnable visual shell
Interfaces: BasairApp, five navigation destinations, TopicPreview without invented counts.
- [ ] Add widget checks that navigation opens the matching screen and RTL is applied.
- [ ] Confirm checks fail because app entry is missing.
- [ ] Create Flutter app, theme, navigation, accessible placeholder states and distinctive discovery layout.
- [ ] Run flutter analyze and flutter test; expect no errors and passing navigation checks.
Deliverable: runnable mobile shell; unavailable data clearly labeled. No implication of complete content.

### Task 2: Approved corpus and deterministic word exploration
Interfaces: Verse(id, surah, ayah, displayText); CorpusMetadata(source, license, version, countingPolicy); SearchQuery(text, mode, scope); SearchResult(occurrences, metadata). SearchRepository.search(SearchQuery) returns SearchResult.
- [ ] Select and document corpus license, exact text version, basmala policy and normalization rules. Stop corpus import if permissions or integrity cannot be established.
- [ ] Add failing checks for immutable display text, empty input, diacritics, scoped matches, exact versus normalized results and unavailable root analysis. Pin expected results using manually checked source passages.
- [ ] Import corpus and metadata; implement separate normalization and indexed search. Do not offer a root mode without verified morphology.
- [ ] Implement occurrence list, surah chart with accessible alternative, query builder and evidence drawer.
- [ ] Run flutter test and flutter analyze; inspect source excerpts against the approved bundle independently.
Deliverable: real searchable text and auditable counts, not sample statistics.

### Task 3: Reviewed atlas and journeys
Interfaces: Topic(id, title, sourceRefs, verseIds, children); Journey(id, steps); each step references approved topic or verse IDs and an editorial source.
- [ ] Add failing checks that overlapping groups deduplicate verse totals, broken references reject a content bundle and unreviewed records never appear as published material.
- [ ] Implement versioned editorial schema and validation. Prepare ten topics and three journeys only with approved sources and editorial review; otherwise keep them visibly unavailable.
- [ ] Build topic maps, list alternative, verse/context panels, journey navigation and progress.
- [ ] Run domain and widget checks; verify all published references resolve.
Deliverable: reviewed thematic exploration; editorial approval remains an explicit release dependency.

### Task 4: Private notebook and export studio
Interfaces: Reflection(id, verseIds, query, body, updatedAt); LibraryRepository save/delete/list; CardExport(title, verseIds, queryMetadata, sourceRefs, optionalNote).
- [ ] Add failing checks for note persistence/deletion, read/write failure feedback, private notes excluded from exports by default, and mandatory query/source metadata in exported counts.
- [ ] Implement local SQLite library, favorites and journey progress with recoverable error states.
- [ ] Add square and portrait card previews, save/share, wrapping verse layouts and source references. No analytics or remote note transmission.
- [ ] Run unit/widget tests and native export smoke checks on supported targets; inspect rendered text at large font sizes.
Deliverable: useful saved discoveries and traceable exports.

### Task 5: Release verification and handoff
- [ ] Validate bundle integrity and retention of previous content on a failed update using a corrupted fixture.
- [ ] Exercise discovery-to-verse-to-reflection-to-export offline on Android and iOS when runners are available.
- [ ] Run flutter analyze, flutter test and supported platform build commands; record exact results and unsupported platform checks.
- [ ] Manually check RTL, large text, reduced motion, screen reader labeling and chart alternatives.
- [ ] Review source rights and scientific content signoff before declaring release readiness; document unresolved dependencies.
- [ ] Provide runnable source and installation instructions; publishing to stores is a separate action.

## Execution and environment limits
No Flutter project currently exists in /workspace. Inspect installed SDKs and applicable workspace instructions before execution. The present environment cannot write the designated /codex output directory; do not claim downloadable artifacts there. Native platform validation depends on available SDKs/runners. No repository commits, deployment or store publication are assumed authorized.

## Self-review
The five destinations, calculations, provenance, editorial review, local privacy, exports, offline behavior, accessibility and failure states each map to tasks above. No production statistics can ship before Task 2, and no reviewed-content claim can ship before Task 3 signoff. Prototype completeness and release readiness must be reported separately.
