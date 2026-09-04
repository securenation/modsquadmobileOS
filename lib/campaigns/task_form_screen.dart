import 'package:flutter/material.dart';
import 'package:modsquad_meetings/auth/signed_in_profile.dart';
import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/campaigns/workspace_models.dart';
import 'package:modsquad_meetings/shared/form_widgets.dart';
import 'package:modsquad_meetings/shared/labels.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({
    super.key,
    required this.campaignId,
    required this.repository,
    required this.profile,
    required this.targets,
    this.existing,
  });

  final String campaignId;
  final CampaignsRepository repository;
  final SignedInProfile profile;
  final List<CampaignTarget> targets;
  final CampaignTask? existing;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  String? _targetId;
  String? _ownerId;
  String? _dueDate;
  String _priority = 'medium';
  List<OwnerOption> _owners = const [];
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _title = TextEditingController(text: existing?.title ?? '');
    _description = TextEditingController(text: existing?.description ?? '');
    _targetId = existing?.campaignTargetId;
    _ownerId = existing?.ownerId;
    _dueDate = existing?.dueDate;
    _priority = existing?.priority ?? 'medium';
    widget.repository.listOwners().then((owners) {
      if (mounted) setState(() => _owners = owners);
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Title is required.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final existing = widget.existing;
      if (existing == null) {
        await widget.repository.createTask(
          CreateTaskInput(
            campaignId: widget.campaignId,
            title: _title.text,
            description: _description.text,
            campaignTargetId: _targetId,
            ownerId: _ownerId,
            dueDate: _dueDate,
            priority: _priority,
          ),
          widget.profile,
        );
      } else {
        await widget.repository.updateTask(
          taskId: existing.id,
          title: _title.text,
          description: _description.text,
          ownerId: _ownerId,
          dueDate: _dueDate,
          priority: _priority,
        );
      }
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
      title: widget.existing == null ? 'New task' : 'Edit task',
      submitLabel: widget.existing == null ? 'Create task' : 'Save task',
      submitting: _submitting,
      error: _error,
      onSubmit: _submit,
      children: [
        const FormLabel('Title'),
        TextField(controller: _title),
        const FormLabel('Description'),
        TextField(controller: _description, maxLines: 3),
        const FormLabel('Target'),
        OptionField(
          value: _targetId,
          options: [
            for (final target in widget.targets)
              (target.id, [target.fullName, if (target.companyName != null) target.companyName!].join(' · ')),
          ],
          onChanged: (value) => setState(() => _targetId = value),
          placeholder: 'None',
        ),
        const FormLabel('Owner'),
        OptionField(
          value: _ownerId,
          options: [for (final owner in _owners) (owner.memberId, owner.name)],
          onChanged: (value) => setState(() => _ownerId = value),
          placeholder: 'Unassigned',
        ),
        const FormLabel('Due date'),
        DateFieldButton(value: _dueDate, onPicked: (value) => setState(() => _dueDate = value)),
        const FormLabel('Priority'),
        OptionField(
          value: _priority,
          options: [for (final entry in taskPriorityLabels.entries) (entry.key, entry.value)],
          onChanged: (value) => setState(() => _priority = value ?? 'medium'),
        ),
      ],
    );
  }
}
