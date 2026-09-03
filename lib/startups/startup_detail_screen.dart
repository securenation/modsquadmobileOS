import 'package:flutter/material.dart';
import 'package:modsquad_meetings/shared/entity_ui.dart';
import 'package:modsquad_meetings/shared/json.dart';
import 'package:modsquad_meetings/startups/startups_repository.dart';

class StartupDetailScreen extends StatelessWidget {
  const StartupDetailScreen({super.key, required this.startup});

  final Startup startup;

  @override
  Widget build(BuildContext context) {
    return DetailFieldsScreen(
      title: startup.name,
      fields: [
        ('Website', startup.website ?? 'Not set'),
        ('Demo URL', startup.demoUrl ?? 'Not set'),
        ('Pitch deck', startup.pitchDeckUrl ?? 'Not set'),
        (
          'Meeting objectives',
          startup.meetingObjectives.isEmpty ? 'Not set' : startup.meetingObjectives.map(humanize).join(', '),
        ),
        ('Short description', startup.shortDescription ?? 'Not set'),
        ('Elevator pitch', startup.elevatorPitch ?? 'Not set'),
        ('Ideal customer profile', startup.idealCustomerProfile ?? 'Not set'),
        (
          'Target personas',
          startup.targetPersonas.isEmpty ? 'Not set' : startup.targetPersonas.join(', '),
        ),
        ('Placeholder content', startup.isPlaceholderContent ? 'Yes — confirm before use' : 'No'),
      ],
    );
  }
}
