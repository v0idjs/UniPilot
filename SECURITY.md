# Security Policy

## Reporting a Vulnerability
Please report security issues via GitHub Security Advisories (Security → Report a vulnerability) or email the maintainers. Do not open a public issue.

We will respond within 72 hours and coordinate a fix before public disclosure.

## Supported Versions
Only the latest `v0.x` release is actively supported.

## Local Data

UniPilot is offline-first: all data lives in a local SQLite database
on the device, stored unencrypted. No account, backend, or network
sync exists, so there are no credentials or tokens to protect. Timetable
imports are capped by size and row count, and user input is length-limited
before storage.
