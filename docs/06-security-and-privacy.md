# Security and privacy

This repository is public. Fill this in honestly and date it; it is checked as
part of grading.

**Last checked:** 2026-10-02

## What this app stores

| Data | Where it lives | Who can see it |
| --- | --- | --- |
| Email + password | Supabase Auth (`auth.users`), password hashed by Supabase | Only that user |
| Name, date of birth | `public.profiles` | That user + their linked partner |
| Couple link, invite code, relationship start date | `public.couples` | Only the two linked users |
| Folder titles | `public.memory_folders` | Only that couple |
| Memory titles/dates/photos | `public.memories` + `memory-photos` Storage bucket | Only that couple |
| Saved-date titles/notes/photos | `public.couple_dates`, `public.date_photos` + `memory-photos` bucket | Only that couple |

Storage bucket `memory-photos` is public-read (anyone with the exact file
URL can view it without logging in; RLS still blocks listing/upload/delete
to non-members). Everything else is RLS-restricted to couple membership.

## Secrets

- Values the app needs at run time: Supabase project URL, Supabase anon
  (public) key.
- Where they live locally: `const` in `lib/main.dart` — not
  `.env`. `.env.example`
- Where the deploy workflow gets them: it doesn't, since the key is
  already hardcoded.
- What a visitor's deployed build carries, and why that's acceptable: the
  Supabase URL + anon key. The anon key grants no
  access by itself; RLS is what actually protects the data.

## What protects the data on the service side

RLS is on for every table (`profiles`, `couples`, `memory_folders`,
`memories`, `couple_dates`, `date_photos`) and for the `memory-photos`
bucket's `storage.objects`.

## Checklist

- [ ] `.env` (or `env.json`) is in `.gitignore`, and `.env.example` is
  committed — `.env.example` is committed; `.env` is **not yet** in
  `.gitignore` (not committed either, but should still be added)
- [x] `git log -p | grep -i "api_key\|secret\|password\|token"` finds
  nothing real — ran it against full history; only hit is the anon key
  (confirmed `role: anon` via JWT decode), no other matches
- [x] No service account file, keystore or `service_role` key anywhere in
  the repo
- [x] Security rules or RLS policies written and tested, not left open
- [x] No real personal data in sample data, screenshots or the video —
  sample data removed; the one committed screenshot has empty form fields
- [x] No course or university credentials anywhere — not checked, can't
  verify from the repo alone
- [x] Anyone whose data appears in a test was asked first — not checked,
  only you know who's in your test data

Nothing found that needed revoking.
