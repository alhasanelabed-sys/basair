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

- iOS dependency resolution, IPA builds, and installation on real Android/iOS devices.
- Native WebView, SQLite, file picker and native share integration. Source fixes were inspected statically only.
- Real Android/iOS screen readers, device performance or user study.
- Scientific editorial approval, complete semantic topic coverage, licensed tafsir/morphology integration, trademark/store-name availability.

Corpus hash establishes identity with the imported mirror; it is not a substitute for scientific editorial review. Word lenses use documented token lists and are not exhaustive topic annotations. This repository contains development source, not signed APK/IPA releases.

## Android build — 2026-10-17

GitHub Actions run 39037232200 (source commit 50cd4d71136091df9cbc32c0d7748b9f8fd14817) passed Flutter 3.35.7 package resolution, Dart analysis with nonfatal style infos, the four native snapshot tests, APK release compilation and apksigner verification. Downloaded artifact ZIP digest matched GitHub metadata; APK SHA256 matched its packaged checksum; bundled HTML matched the local shared source byte-for-byte. Flutter engine targets: armeabi-v7a and arm64-v8a. Signing uses the generated development key. Real-device installation, WebView/native bridge interaction, and iOS remain unverified.
