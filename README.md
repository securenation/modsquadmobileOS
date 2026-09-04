# Mod Squad Meetings (mobile)

Flutter app for Mod Squad's conference-meeting engine. Starts with email/password sign-in against the same Supabase project as the web prototype.

## Run

```bash
flutter pub get
flutter run
```

Sign in with a seeded demo account, for example `priya.natarajan@modsquad-demo.test`. After login the app opens **Mission Control**. Use the bottom navigation to switch to **Campaigns** and **Startups**.

Open a campaign for Overview, Pipeline (targets, companies, intros, outreach, scoring), Calendar (scheduling and meetings), and Results (tasks, opportunities, reports). Tap a startup for its profile.

Admins can create campaigns and startups, add targets, request intros, assign owners, and create tasks. Dante members can record meeting outcomes, add availability, and update their tasks. The Startups tab is hidden from Dante members, matching the web app.

CSV import, the advisor response portal, and AI follow-up drafts stay on the web app. Intro messages include a link to the web prototype (`WEB_BASE_URL`, default `http://localhost:3000`).

## Config

The app uses the prototype Supabase URL and anon key by default. Override at build time if needed:

```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## Tests

```bash
flutter test
flutter analyze
```
