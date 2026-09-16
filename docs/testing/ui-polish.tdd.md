# TDD Evidence — UI polish: branding, responsive nav, hero, theme

## Source plan

A planner subagent produced an orchestration plan for three
workstreams (icon from the brand vector, Windows white screen, UI/UX).
Its repo claims were verified before use: `windows/` and `android/`
hold only `.gitkeep` (runners are CI-generated, so hand-writing them
was rejected), and the 1024 launcher raster was byte-checked locally —
dominant pixels are exactly the brand indigo, white, and amber, so no
regeneration was needed. Journeys below are derived from that plan.

## User journeys

1. As a student, I want the app to carry its brand identity inside,
   so that it feels like one product.
2. As a student on desktop, I want navigation suited to a wide window,
   so that the app does not feel like a stretched phone screen.
3. As a student, I want the next class to stand out with a countdown,
   so that I see what matters at a glance.
4. As a student, I want empty and failing lists to explain themselves,
   so that I always know the next step.
5. As a student, I want a consistent look across inputs, dialogs, and
   snackbars in both themes.

## Task report

| Task | Summary | Validation | Outcome |
|------|---------|------------|---------|
| Reproducers (RED) | 6 test files for logo, empty/error views, responsive scaffold, hero card, theme wiring | CI `35137590165`: `completed failure` — new widgets undefined | Compile-time RED |
| Brand/theme/hero/nav (GREEN attempt) | New widgets, completed theme, rail, hero, startup fallback | CI `35142091322`: failed — `withValues` does not exist on Flutter 3.24; one non-const test bundle | API-level failure, fixed by reverting to `withOpacity` |
| Compat fix | `withValues` reverted, test const fixed | CI `35143401152`: 65 passed / 1 failed — scaffold test used width 800, which is the rail breakpoint | Off-by-breakpoint test fixed to phone size |
| Narrow test fix | Phone-size surface | CI `35144173681`: 65 passed / 1 failed — hero empty-card row overflows under the wide test font | Real layout defect, fixed with `Expanded`/ellipsis |
| Overflow fix | Constrained hero texts | CI `35145173865`: `completed success` | 66/66 GREEN |

Icon verification (local, Python PNG decode with full unfiltering):
1024x1024, 8-bit RGBA, top colors `(30,27,75)`, `(255,255,255)`,
`(244,163,0)` — exact brand indigo, white, amber. Center pixel white
(the logo dot), matching the vector source.

## Test specification

| # | Guarantee | Test | Type | Result |
|---|-----------|------|------|--------|
| 1 | Brand mark renders with semantics and size | `test/widgets/brand_logo_test.dart` | widget | PASS (CI `35145173865`) |
| 2 | Empty state shows copy and fires its action | `test/widgets/empty_state_test.dart` | widget | PASS (CI `35145173865`) |
| 3 | Error view shows message and retries | `test/widgets/app_error_view_test.dart` | widget | PASS (CI `35145173865`) |
| 4 | Rail on wide screens, bar on narrow ones | `test/widgets/app_scaffold_test.dart` | widget | PASS (CI `35145173865`) |
| 5 | Hero shows next class, countdown, room; calm empty state | `test/widgets/next_class_card_test.dart` | widget | PASS (CI `35145173865`) |
| 6 | Both themes wire brand inputs and floating snackbars | `test/core/theme_test.dart` | unit | PASS (CI `35145173865`) |

All v0.1.0/v0.2.0 tests still pass unmodified (regression).

## Coverage and known gaps

- `flutter test --coverage` ran green in CI; exact percentage not
  captured, so no number is claimed.
- `SvgPicture` decoding in widgets is covered structurally (fake asset
  bundle); real-asset decode is exercised implicitly by every screen
  test through the branded app bars.
- Native runners (`windows/`, `android/`) remain CI-generated; the
  Windows runbook documents setup and the white-screen checklist.
- Manual pass still recommended: wide-window rail, icon on device,
  Windows first paint.

## Merge evidence

Checkpoint commits on `main` for this task, in order:

- `39f6861` test: add reproducers for branding, responsive nav, hero
  card, and theme (ui polish, RED)
- `57b8cf7` feat: brand logo, responsive nav, hero card, completed
  theme, startup fallback (ui polish, GREEN)
- `eff425f` fix: use withOpacity for Flutter 3.24 and non-const test
  bundle
- `9fd4e8d` test: use phone-size surface for narrow nav assertion
- `10a6903` fix: constrain hero texts to prevent row overflow on
  narrow screens

Each message describes its stage and evidence; all are reachable from
`HEAD` on `main`.
