import 'package:flutter/material.dart';
import 'package:modsquad_meetings/auth/signed_in_profile.dart';
import 'package:modsquad_meetings/shared/form_widgets.dart';
import 'package:modsquad_meetings/startups/startups_repository.dart';

class NewStartupScreen extends StatefulWidget {
  const NewStartupScreen({super.key, required this.repository, required this.profile});

  final StartupsRepository repository;
  final SignedInProfile profile;

  @override
  State<NewStartupScreen> createState() => _NewStartupScreenState();
}

class _NewStartupScreenState extends State<NewStartupScreen> {
  final _name = TextEditingController();
  final _website = TextEditingController();
  final _description = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _website.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Name is required.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final startup = await widget.repository.createStartup(
        name: _name.text,
        website: _website.text,
        shortDescription: _description.text,
        orgId: widget.profile.orgId,
        userId: widget.profile.userId,
      );
      if (mounted) Navigator.of(context).pop(startup);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: 'New startup',
      submitLabel: 'Create startup',
      submitting: _submitting,
      error: _error,
      onSubmit: _submit,
      children: [
        const FormLabel('Name'),
        TextField(controller: _name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(hintText: 'Dante Security')),
        const FormLabel('Website'),
        TextField(controller: _website, keyboardType: TextInputType.url, decoration: const InputDecoration(hintText: 'https://')),
        const FormLabel('Short description'),
        TextField(controller: _description, maxLines: 3, decoration: const InputDecoration(hintText: 'One-line pitch')),
      ],
    );
  }
}
