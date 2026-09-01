/// Public Supabase client config — same project the web prototype uses.
/// Override at build time with `--dart-define=SUPABASE_URL=...` and
/// `--dart-define=SUPABASE_ANON_KEY=...`.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gqzhnipbfrilaunushva.supabase.co',
  );

  static const publishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdxemhuaXBiZnJpbGF1bnVzaHZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0MDg2MjAsImV4cCI6MjA5OTk4NDYyMH0.C5awHyNGhLZsXrCJKowOurdo_K-mZVGYJW082xxv-nw',
  );
}
