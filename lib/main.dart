import 'package:flutter/material.dart';
import 'package:modsquad_meetings/app.dart';
import 'package:modsquad_meetings/auth/supabase_auth_repository.dart';
import 'package:modsquad_meetings/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  runApp(ModSquadApp(auth: SupabaseAuthRepository(Supabase.instance.client)));
}
