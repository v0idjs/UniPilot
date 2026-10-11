# Repo settings (applied via GitHub UI or API — not in code)

These settings cannot live in the repo, so this file is the
copy-paste source of truth. They have **not** been applied yet;
a maintainer runs the command below once.

## Description

```text
Offline-first Flutter student co-pilot: schedule, deadlines, GPA and campus finder.
```

## Topics

```text
flutter, dart, drift, riverpod, offline-first, student, gpa-calculator, timetable
```

## Apply with `gh`

```bash
gh repo edit v0idjs/UniPilot \
  --description "Offline-first Flutter student co-pilot: schedule, deadlines, GPA and campus finder." \
  --add-topic flutter \
  --add-topic dart \
  --add-topic drift \
  --add-topic riverpod \
  --add-topic offline-first \
  --add-topic student \
  --add-topic gpa-calculator \
  --add-topic timetable
```

Verify with `gh repo view v0idjs/UniPilot --json description,repositoryTopics`.
