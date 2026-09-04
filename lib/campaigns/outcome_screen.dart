import 'package:flutter/material.dart';
import 'package:modsquad_meetings/auth/signed_in_profile.dart';
import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/campaigns/workspace_models.dart';
import 'package:modsquad_meetings/shared/form_widgets.dart';
import 'package:modsquad_meetings/shared/labels.dart';

class OutcomeScreen extends StatefulWidget {
  const OutcomeScreen({
    super.key,
    required this.meeting,
    required this.repository,
    required this.profile,
  });

  final CampaignMeeting meeting;
  final CampaignsRepository repository;
  final SignedInProfile profile;

  @override
  State<OutcomeScreen> createState() => _OutcomeScreenState();
}

class _OutcomeScreenState extends State<OutcomeScreen> {
  final _attendees = TextEditingController();
  final _interest = TextEditingController();
  final _problems = TextEditingController();
  final _tools = TextEditingController();
  final _buying = TextEditingController();
  final _feedback = TextEditingController();
  final _objections = TextEditingController();
  final _nextStep = TextEditingController();
  final _value = TextEditingController();
  final _notes = TextEditingController();
  bool _didOccur = true;
  String? _outcomeCategory;
  String? _opportunityType;
  String? _ownerId;
  String? _dueDate;
  List<OwnerOption> _owners = const [];
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _outcomeCategory = widget.meeting.outcome;
    widget.repository.listOwners().then((owners) {
      if (mounted) setState(() => _owners = owners);
    });
  }

  @override
  void dispose() {
    _attendees.dispose();
    _interest.dispose();
    _problems.dispose();
    _tools.dispose();
    _buying.dispose();
    _feedback.dispose();
    _objections.dispose();
    _nextStep.dispose();
    _value.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.repository.recordMeetingOutcome(
        MeetingOutcomeInput(
          meetingId: widget.meeting.id,
          didMeetingOccur: _didOccur,
          attendeesActual: _attendees.text,
          interestLevel: _interest.text,
          problemsDiscussed: _problems.text,
          existingTools: _tools.text,
          buyingProcess: _buying.text,
          productFeedback: _feedback.text,
          objections: _objections.text,
          desiredNextStep: _nextStep.text,
          followUpOwnerId: _ownerId,
          followUpDueDate: _dueDate,
          opportunityType: _opportunityType,
          estimatedValueDollars: double.tryParse(_value.text.trim()),
          outcomeCategory: _outcomeCategory,
          notes: _notes.text,
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
      title: 'Meeting outcome',
      submitLabel: 'Save outcome',
      submitting: _submitting,
      error: _error,
      onSubmit: _submit,
      children: [
        Text(
          widget.meeting.targetPersonName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const FormLabel('Did the meeting occur?'),
        OptionField(
          value: _didOccur ? 'true' : 'false',
          options: const [('true', 'Yes'), ('false', 'No')],
          onChanged: (value) => setState(() => _didOccur = value == 'true'),
        ),
        const FormLabel('Who actually attended'),
        TextField(controller: _attendees),
        const FormLabel('Interest level'),
        TextField(controller: _interest, decoration: const InputDecoration(hintText: 'high, lukewarm, not a fit')),
        const FormLabel('Problems discussed'),
        TextField(controller: _problems, maxLines: 2),
        const FormLabel('Existing tools'),
        TextField(controller: _tools, maxLines: 2),
        const FormLabel('Buying process'),
        TextField(controller: _buying, maxLines: 2),
        const FormLabel('Product feedback'),
        TextField(controller: _feedback, maxLines: 2),
        const FormLabel('Objections'),
        TextField(controller: _objections, maxLines: 2),
        const FormLabel('Desired next step'),
        TextField(controller: _nextStep, maxLines: 2),
        const FormLabel('Follow-up owner'),
        OptionField(
          value: _ownerId,
          options: [for (final owner in _owners) (owner.memberId, owner.name)],
          onChanged: (value) => setState(() => _ownerId = value),
          placeholder: 'Unassigned',
        ),
        const FormLabel('Follow-up due'),
        DateFieldButton(value: _dueDate, onPicked: (value) => setState(() => _dueDate = value)),
        const FormLabel('Outcome category'),
        OptionField(
          value: _outcomeCategory,
          options: [for (final entry in meetingOutcomeTypeLabels.entries) (entry.key, entry.value)],
          onChanged: (value) => setState(() => _outcomeCategory = value),
          placeholder: 'Select what this meeting resulted in',
        ),
        const FormLabel('Opportunity type'),
        OptionField(
          value: _opportunityType,
          options: [for (final entry in meetingObjectiveLabels.entries) (entry.key, entry.value)],
          onChanged: (value) => setState(() => _opportunityType = value),
          placeholder: 'None',
        ),
        const FormLabel('Est. value, \$'),
        TextField(controller: _value, keyboardType: TextInputType.number),
        const FormLabel('Notes'),
        TextField(controller: _notes, maxLines: 3),
      ],
    );
  }
}
