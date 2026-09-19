# Import Format — UniPilot v1

## CSV
Required columns (aliases supported):
- `code` ← `course`/`subject`/`module`/`course_code`
- `day` ← `dayOfWeek`/`weekday` — accepts Mon/Tue/…/Sun, monday…, 1-7
- `start` ← `start_time`/`begin`
- `end` ← `end_time`/`finish`
- `name` (optional) ← `course_name`/`title` — defaults to code
- `room` (optional) ← `location`

Delimiter auto-detected (comma vs semicolon). Time formats: HH:MM, H:MM, HH.MM, HHMM (0930).
All formats validate 00-23 hours and 00-59 minutes; out-of-range times are
reported as row errors (e.g. `25.00`, `10.99` rejected, `09.30` → 09:30).

Caps: 512KB input, 2000 rows (truncated with a warning).

Sample: `assets/samples/timetable_sample.csv`

## ICS
Parses VEVENT with DTSTART/DTEND, SUMMARY, LOCATION, RRULE (FREQ=WEEKLY
expansion, capped at 52 occurrences with a warning), TZID (kept as
wall time, no conversion). Folded lines are unfolded. EXDATE is not
supported; non-weekly frequencies import as a single instance.
Sample: `assets/samples/timetable_sample.ics`

Caps: 512KB input, 1000 events (truncated with a warning). A weekly
RRULE whose UNTIL is before DTSTART is rejected with an error and yields
no events.

Flow: Pick file → parse → preview table with errors → confirm → bulk insert (no auto-insert without confirm).

## Grading Scales
- 4.0, 4.3, 5.0 presets + percentage + custom mapping.
- Honors +0.5 per course, capped at the active scale max (e.g. A+honors on 4.0 stays 4.0). Applies to every scale, including percentage and custom.
- Invalid grades are filtered with an "N invalid skipped" note instead of crashing.
- See `lib/features/gpa/grading_scales.dart`.

## Validation Rules (DB layer)
- Courses/semesters/assignments/grades reject empty names/titles.
- Time slots require day 1-7 and 0-1439 minutes with end after start;
  out-of-range rows render a `Day N` fallback instead of crashing.
- Grades require credits > 0 and ≤ 100.
