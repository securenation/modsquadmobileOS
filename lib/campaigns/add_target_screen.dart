import 'package:flutter/material.dart';
import 'package:modsquad_meetings/auth/signed_in_profile.dart';
import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/shared/form_widgets.dart';

class AddTargetScreen extends StatefulWidget {
  const AddTargetScreen({
    super.key,
    required this.campaignId,
    required this.repository,
    required this.profile,
  });

  final String campaignId;
  final CampaignsRepository repository;
  final SignedInProfile profile;

  @override
  State<AddTargetScreen> createState() => _AddTargetScreenState();
}

class _AddTargetScreenState extends State<AddTargetScreen> {
  final _name = TextEditingController();
  final _title = TextEditingController();
  final _email = TextEditingController();
  final _company = TextEditingController();
  String? _ownerId;
  List<OwnerOption> _owners = const [];
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.repository.listOwners().then((owners) {
      if (mounted) setState(() => _owners = owners);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _title.dispose();
    _email.dispose();
    _company.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Full name is required.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.repository.addTarget(
        AddTargetInput(
          campaignId: widget.campaignId,
          fullName: _name.text,
          jobTitle: _title.text,
          email: _email.text,
          companyName: _company.text,
          ownerId: _ownerId,
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
      title: 'Add target',
      submitLabel: 'Add target',
      submitting: _submitting,
      error: _error,
      onSubmit: _submit,
      children: [
        const FormLabel('Full name'),
        TextField(controller: _name, textCapitalization: TextCapitalization.words),
        const FormLabel('Job title'),
        TextField(controller: _title),
        const FormLabel('Email'),
        TextField(controller: _email, keyboardType: TextInputType.emailAddress),
        const FormLabel('Company'),
        TextField(controller: _company),
        const FormLabel('Owner'),
        OptionField(
          value: _ownerId,
          options: [for (final owner in _owners) (owner.memberId, owner.name)],
          onChanged: (value) => setState(() => _ownerId = value),
          placeholder: 'Unassigned',
        ),
      ],
    );
  }
}
