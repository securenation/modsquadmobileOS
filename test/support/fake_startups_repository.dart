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
}

const sampleStartup = Startup(
  id: 's1',
  name: 'Dante Security',
  shortDescription: 'Identity for the enterprise.',
  website: 'https://dante.example',
  isPlaceholderContent: false,
);
