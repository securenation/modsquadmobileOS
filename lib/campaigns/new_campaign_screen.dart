import 'package:flutter/material.dart';
import 'package:modsquad_meetings/auth/signed_in_profile.dart';
import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/shared/form_widgets.dart';
import 'package:modsquad_meetings/startups/startups_repository.dart';

class NewCampaignScreen extends StatefulWidget {
  const NewCampaignScreen({
    super.key,
    required this.repository,
    required this.startups,
    required this.profile,
  });

  final CampaignsRepository repository;
  final StartupsRepository startups;
  final SignedInProfile profile;

  @override
  State<NewCampaignScreen> createState() => _NewCampaignScreenState();
}

class _NewCampaignScreenState extends State<NewCampaignScreen> {
  final _name = TextEditingController();
  final _eventName = TextEditingController();
  final _eventCity = TextEditingController();
  final _goal = TextEditingController();
  List<Startup> _startups = const [];
  String? _startupId;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.startups.listStartups().then((rows) {
      if (!mounted) return;
      setState(() {
        _startups = rows;
        _startupId = rows.isEmpty ? null : rows.first.id;
        _loading = false;
      });
    }).catchError((Object error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _eventName.dispose();
    _eventCity.dispose();
    _goal.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Campaign name is required.');
      return;
    }
    if (_startupId == null) {
      setState(() => _error = 'Select a startup.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final campaign = await widget.repository.createCampaign(
        CreateCampaignInput(
          name: _name.text,
          startupId: _startupId!,
          eventName: _eventName.text,
          eventCity: _eventCity.text,
          targetMeetingGoal: int.tryParse(_goal.text.trim()),
        ),
        widget.profile,
      );
      if (mounted) Navigator.of(context).pop(campaign);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return FormPage(
      title: 'New campaign',
      submitLabel: 'Create campaign',
      submitting: _submitting,
      error: _error,
      onSubmit: _submit,
      children: [
        const FormLabel('Campaign name'),
        TextField(controller: _name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(hintText: 'Dante @ Black Hat USA 2026')),
        const FormLabel('Startup'),
        OptionField(
          value: _startupId,
          options: [for (final startup in _startups) (startup.id, startup.name)],
          onChanged: (value) => setState(() => _startupId = value),
          placeholder: 'Select a startup',
        ),
        const FormLabel('Event name'),
        TextField(controller: _eventName, decoration: const InputDecoration(hintText: 'Black Hat USA 2026')),
        const FormLabel('Event city'),
        TextField(controller: _eventCity, decoration: const InputDecoration(hintText: 'Las Vegas, NV')),
        const FormLabel('Target meeting goal'),
        TextField(controller: _goal, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '20')),
      ],
    );
  }
}
