import 'package:flutter/material.dart';
import 'package:modsquad_meetings/auth/signed_in_profile.dart';
import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/shared/form_widgets.dart';

class AvailabilityFormScreen extends StatefulWidget {
  const AvailabilityFormScreen({
    super.key,
    required this.campaignId,
    required this.timezone,
    required this.repository,
    required this.profile,
  });

  final String campaignId;
  final String timezone;
  final CampaignsRepository repository;
  final SignedInProfile profile;

  @override
  State<AvailabilityFormScreen> createState() => _AvailabilityFormScreenState();
}

class _AvailabilityFormScreenState extends State<AvailabilityFormScreen> {
  final _location = TextEditingController();
  final _capacity = TextEditingController(text: '1');
  String? _date;
  String? _start;
  String? _end;
  late final TextEditingController _timezone;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _timezone = TextEditingController(text: widget.timezone);
  }

  @override
  void dispose() {
    _location.dispose();
    _capacity.dispose();
    _timezone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_date == null || _start == null || _end == null) {
      setState(() => _error = 'Date, start time, and end time are required.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.repository.addAvailabilityWindow(
        CreateAvailabilityInput(
          campaignId: widget.campaignId,
          windowDate: _date!,
          startTime: _start!,
          endTime: _end!,
          timezone: _timezone.text.trim().isEmpty ? 'UTC' : _timezone.text.trim(),
          location: _location.text,
          capacity: int.tryParse(_capacity.text.trim()) ?? 1,
        ),
        widget.profile,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: 'Add availability',
      submitLabel: 'Save window',
      submitting: _submitting,
      error: _error,
      onSubmit: _submit,
      children: [
        const FormLabel('Date'),
        DateFieldButton(value: _date, onPicked: (value) => setState(() => _date = value)),
        const FormLabel('Start'),
        TimeFieldButton(value: _start, onPicked: (value) => setState(() => _start = value)),
        const FormLabel('End'),
        TimeFieldButton(value: _end, onPicked: (value) => setState(() => _end = value)),
        const FormLabel('Timezone'),
        TextField(controller: _timezone),
        const FormLabel('Location'),
        TextField(controller: _location),
        const FormLabel('Capacity'),
        TextField(controller: _capacity, keyboardType: TextInputType.number),
      ],
    );
  }
}
