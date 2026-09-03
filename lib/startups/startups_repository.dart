class Startup {
  const Startup({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.website,
    required this.demoUrl,
    required this.pitchDeckUrl,
    required this.elevatorPitch,
    required this.idealCustomerProfile,
    required this.meetingObjectives,
    required this.targetPersonas,
    required this.isPlaceholderContent,
  });

  final String id;
  final String name;
  final String? shortDescription;
  final String? website;
  final String? demoUrl;
  final String? pitchDeckUrl;
  final String? elevatorPitch;
  final String? idealCustomerProfile;
  final List<String> meetingObjectives;
  final List<String> targetPersonas;
  final bool isPlaceholderContent;
}

abstract class StartupsRepository {
  Future<List<Startup>> listStartups();
}
