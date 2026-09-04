import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/shared/json.dart';
import 'package:modsquad_meetings/startups/startups_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStartupsRepository implements StartupsRepository {
  SupabaseStartupsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Startup>> listStartups() async {
    final rows = await _client
        .from('startups')
        .select(
          'id, name, short_description, website, demo_url, pitch_deck_url, elevator_pitch, ideal_customer_profile, meeting_objectives, target_personas, is_placeholder_content',
        )
        .isFilter('deleted_at', null)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(rows as List)
        .map(
          (row) => Startup(
            id: row['id'] as String,
            name: row['name'] as String,
            shortDescription: row['short_description'] as String?,
            website: row['website'] as String?,
            demoUrl: row['demo_url'] as String?,
            pitchDeckUrl: row['pitch_deck_url'] as String?,
            elevatorPitch: row['elevator_pitch'] as String?,
            idealCustomerProfile: row['ideal_customer_profile'] as String?,
            meetingObjectives: asStringList(row['meeting_objectives']),
            targetPersonas: asStringList(row['target_personas']),
            isPlaceholderContent: row['is_placeholder_content'] as bool? ?? false,
          ),
        )
        .toList();
  }

  @override
  Future<Startup> createStartup({
    required String name,
    String? website,
    String? shortDescription,
    required String orgId,
    required String userId,
  }) async {
    try {
      final row = await _client
          .from('startups')
          .insert({
            'org_id': orgId,
            'name': name.trim(),
            'website': (website == null || website.trim().isEmpty) ? null : website.trim(),
            'short_description': (shortDescription == null || shortDescription.trim().isEmpty)
                ? null
                : shortDescription.trim(),
            'is_placeholder_content': true,
            'created_by': userId,
          })
          .select(
            'id, name, short_description, website, demo_url, pitch_deck_url, elevator_pitch, ideal_customer_profile, meeting_objectives, target_personas, is_placeholder_content',
          )
          .single();
      return Startup(
        id: row['id'] as String,
        name: row['name'] as String,
        shortDescription: row['short_description'] as String?,
        website: row['website'] as String?,
        demoUrl: row['demo_url'] as String?,
        pitchDeckUrl: row['pitch_deck_url'] as String?,
        elevatorPitch: row['elevator_pitch'] as String?,
        idealCustomerProfile: row['ideal_customer_profile'] as String?,
        meetingObjectives: asStringList(row['meeting_objectives']),
        targetPersonas: asStringList(row['target_personas']),
        isPlaceholderContent: row['is_placeholder_content'] as bool? ?? false,
      );
    } catch (error) {
      throw WorkspaceFailure('Could not create the startup. Please try again.');
    }
  }
}
