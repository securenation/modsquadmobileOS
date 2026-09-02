import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCampaignsRepository implements CampaignsRepository {
  SupabaseCampaignsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Campaign>> listCampaigns() async {
    final rows = await _client
        .from('campaigns')
        .select('*, startups(name)')
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(rows as List).map(_fromRow).toList();
  }

  Campaign _fromRow(Map<String, dynamic> row) {
    return Campaign(
      id: row['id'] as String,
      name: row['name'] as String,
      status: row['status'] as String,
      startupName: _startupName(row['startups']),
      eventName: row['event_name'] as String?,
      eventCity: row['event_city'] as String?,
      eventVenue: row['event_venue'] as String?,
      startDate: row['start_date'] as String?,
      endDate: row['end_date'] as String?,
      timezone: row['default_timezone'] as String? ?? 'UTC',
      targetMeetingGoal: row['target_meeting_goal'] as int?,
      targetMeetingTypes: _stringList(row['target_meeting_types']),
      targetAccountList: _stringList(row['target_account_list']),
      datesConfirmed: row['dates_confirmed'] as bool? ?? true,
      notes: row['notes'] as String?,
    );
  }

  String? _startupName(dynamic value) {
    if (value is Map<String, dynamic>) return value['name'] as String?;
    if (value is List && value.isNotEmpty && value.first is Map) {
      return (value.first as Map)['name'] as String?;
    }
    return null;
  }

  List<String> _stringList(dynamic value) {
    if (value is List) return value.map((item) => item.toString()).toList();
    return const [];
  }
}
