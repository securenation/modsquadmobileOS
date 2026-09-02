import 'package:modsquad_meetings/mission_control/models.dart';

abstract class MissionControlRepository {
  Future<MissionControlSnapshot?> load();
}
