class Startup {
  const Startup({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.website,
    required this.isPlaceholderContent,
  });

  final String id;
  final String name;
  final String? shortDescription;
  final String? website;
  final bool isPlaceholderContent;
}

abstract class StartupsRepository {
  Future<List<Startup>> listStartups();
}
