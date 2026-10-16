# Verification — Basair 0.1.0

Verified in this workspace on 2026-10-15:

- Node v24.19.0; local Chromium; Playwright 1.56.1.
- `npm run build`: full 6236-row corpus / 114 surahs, pinned SHA256; same generated HTML copied to native assets.
- `npm test`: 22 domain assertions, zero failures.
- `npm run test:build`: UI content changes invalidate worker cache; source alteration is refused; browser/native HTML equality checked.
- `npm run test:browser`: RTL/navigation, actual source search, evidence, favorite reload, escaped personal notes, journey progression, PNG download, 390px layout.
- `npm run test:boundaries`: scope/comparison drilldown, invalid range, library restore/edit/cancel, offline reload/search, long-card width/footer, corrupt-data retention.
- `node --check`: app/domain/build/server/configuration JavaScript; `bash -n app/bootstrap.sh`.
- Independently inspected screenshots for desktop/mobile and exported card.
- Independent read-only agent reviewed the project. Fixes cover comparison provenance, card accessibility/layout, snapshot uniqueness/version, cache update identity, and native stale snapshot injection.

Not verified:

- Flutter dependency resolution, `flutter analyze`, Dart unit tests, APK/IPA builds or installation.
- Native WebView, SQLite, file picker and native share integration. Source fixes were inspected statically only.
- Real Android/iOS screen readers, device performance or user study.
- Scientific editorial approval, complete semantic topic coverage, licensed tafsir/morphology integration, trademark/store-name availability.

Corpus hash establishes identity with the imported mirror; it is not a substitute for scientific editorial review. Word lenses use documented token lists and are not exhaustive topic annotations. This repository contains development source, not signed APK/IPA releases.
