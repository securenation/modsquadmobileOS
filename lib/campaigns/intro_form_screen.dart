import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modsquad_meetings/auth/signed_in_profile.dart';
import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/campaigns/workspace_models.dart';
import 'package:modsquad_meetings/shared/form_widgets.dart';
import 'package:modsquad_meetings/theme/app_colors.dart';

class IntroFormScreen extends StatefulWidget {
  const IntroFormScreen({
    super.key,
    required this.target,
    required this.repository,
    required this.profile,
  });

  final CampaignTarget target;
  final CampaignsRepository repository;
  final SignedInProfile profile;

  @override
  State<IntroFormScreen> createState() => _IntroFormScreenState();
}

class _IntroFormScreenState extends State<IntroFormScreen> {
  final _reason = TextEditingController();
  final _language = TextEditingController();
  String? _introducerId;
  String? _dueDate;
  List<OwnerOption> _owners = const [];
  bool _submitting = false;
  String? _error;
  IntroRequestResult? _result;
  bool _markedSent = false;

  @override
  void initState() {
    super.initState();
    widget.repository.listOwners().then((owners) {
      if (mounted) setState(() => _owners = owners);
    });
  }

  @override
  void dispose() {
    _reason.dispose();
    _language.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_introducerId == null) {
      setState(() => _error = 'Choose who should make the introduction.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await widget.repository.createIntroduction(
        CreateIntroInput(
          campaignTargetId: widget.target.id,
          introducerMemberId: _introducerId!,
          reason: _reason.text,
          suggestedLanguage: _language.text,
          desiredResponseDate: _dueDate,
        ),
        widget.profile,
      );
      if (mounted) setState(() => _result = result);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _markSent() async {
    final result = _result;
    if (result == null) return;
    setState(() => _submitting = true);
    try {
      await widget.repository.markIntroductionSent(result.introductionRequestId, widget.profile);
      if (mounted) setState(() => _markedSent = true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    if (result != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.foreground,
          title: const Text('Introduction request', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            const Text('Copy this message and send it to the introducer.', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 12),
            SelectableText(result.message, style: const TextStyle(height: 1.45)),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.destructive)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: result.message));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message copied')));
                }
              },
              child: const Text('Copy message'),
            ),
            const SizedBox(height: 10),
            if (!_markedSent)
              OutlinedButton(
                onPressed: _submitting ? null : _markSent,
                child: const Text('Mark as sent'),
              )
            else
              const Text('Marked as sent.', style: TextStyle(color: AppColors.muted)),
          ],
        ),
      );
    }

    return FormPage(
      title: 'Request introduction',
      submitLabel: 'Create request',
      submitting: _submitting,
      error: _error,
      onSubmit: _submit,
      children: [
        Text(widget.target.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        if (widget.target.companyName != null)
          Text(widget.target.companyName!, style: const TextStyle(color: AppColors.muted)),
        const FormLabel('Who should ask?'),
        OptionField(
          value: _introducerId,
          options: [for (final owner in _owners) (owner.memberId, owner.name)],
          onChanged: (value) => setState(() => _introducerId = value),
          placeholder: 'Choose an introducer',
        ),
        const FormLabel('Reason'),
        TextField(controller: _reason, maxLines: 3),
        const FormLabel('Suggested language'),
        TextField(controller: _language, maxLines: 3),
        const FormLabel('Desired response date'),
        DateFieldButton(value: _dueDate, onPicked: (value) => setState(() => _dueDate = value)),
      ],
    );
  }
}
