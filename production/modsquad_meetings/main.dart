import 'package:flutter/material.dart';
import 'package:modsquad_meetings/app.dart';
import 'package:modsquad_meetings/auth/supabase_auth_repository.dart';
import 'package:modsquad_meetings/config/supabase_config.dart';
import 'package:modsquad_meetings/mission_control/supabase_mission_control_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  final client = Supabase.instance.client;
  runApp(
    ModSquadApp(
      auth: SupabaseAuthRepository(client),
      missionControl: SupabaseMissionControlRepository(client),
    ),
  );
}
