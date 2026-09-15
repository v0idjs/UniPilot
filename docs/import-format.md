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

Sample: `assets/samples/timetable_sample.csv`

## ICS
Parses VEVENT with DTSTART/DTEND, SUMMARY, LOCATION, RRULE (weekly expansion, capped 52), TZID (wall-time preserved). Unfolding supported. Sample: `assets/samples/timetable_sample.ics`

Flow: Pick file → parse → preview table with errors → confirm → bulk insert (no auto-insert without confirm).

## Grading Scales
- 4.0, 4.3, 5.0 presets + percentage + custom mapping.
- See `lib/features/gpa/grading_scales.dart`.
