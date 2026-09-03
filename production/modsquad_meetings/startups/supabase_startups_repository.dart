import 'package:modsquad_meetings/startups/startups_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStartupsRepository implements StartupsRepository {
  SupabaseStartupsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Startup>> listStartups() async {
    final rows = await _client
        .from('startups')
        .select('id, name, short_description, website, is_placeholder_content')
        .isFilter('deleted_at', null)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(rows as List)
        .map(
          (row) => Startup(
            id: row['id'] as String,
            name: row['name'] as String,
            shortDescription: row['short_description'] as String?,
            website: row['website'] as String?,
            isPlaceholderContent: row['is_placeholder_content'] as bool? ?? false,
          ),
        )
        .toList();
  }
}
