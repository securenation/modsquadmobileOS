# Mod Squad Meetings (mobile)

Flutter app for Mod Squad's conference-meeting engine. Starts with email/password sign-in against the same Supabase project as the web prototype.

## Run

```bash
flutter pub get
flutter run
```

Sign in with a seeded demo account, for example `priya.natarajan@modsquad-demo.test`. After login the app opens **Mission Control**. Use the bottom navigation to switch to **Campaigns** (tap a card for the overview) and **Startups**.

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
