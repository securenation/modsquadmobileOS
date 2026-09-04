import 'package:modsquad_meetings/startups/startups_repository.dart';

class FakeStartupsRepository implements StartupsRepository {
  FakeStartupsRepository({this.startups = const [], this.error});

  List<Startup> startups;
  Object? error;

  @override
  Future<List<Startup>> listStartups() async {
    final thrown = error;
    if (thrown != null) throw thrown;
    return startups;
  }

  @override
  Future<Startup> createStartup({
    required String name,
    String? website,
    String? shortDescription,
    required String orgId,
    required String userId,
  }) async {
    final thrown = error;
    if (thrown != null) throw thrown;
    final startup = Startup(
      id: 's-${startups.length + 1}',
      name: name,
      shortDescription: shortDescription,
      website: website,
      demoUrl: null,
      pitchDeckUrl: null,
      elevatorPitch: null,
      idealCustomerProfile: null,
      meetingObjectives: const [],
      targetPersonas: const [],
      isPlaceholderContent: true,
    );
    startups = [...startups, startup];
    return startup;
  }
}

const sampleStartup = Startup(
  id: 's1',
  name: 'Dante Security',
  shortDescription: 'Identity for the enterprise.',
  website: 'https://dante.example',
  demoUrl: 'https://demo.dante.example',
  pitchDeckUrl: null,
  elevatorPitch: 'Stop identity attacks before they start.',
  idealCustomerProfile: 'Security teams at large enterprises.',
  meetingObjectives: ['enterprise_sales', 'design_partner'],
  targetPersonas: ['CISO', 'VP Engineering'],
  isPlaceholderContent: false,
);
