import 'package:flutter/material.dart';
import 'app_state.dart';
import 'theme.dart';

/// Module 1: Profile setup — create / view / edit your own profile.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _state = TeamUpState.instance;
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        final me = _state.currentUser;
        final showForm = me == null || _editing;
        if (!showForm) {
          return Scaffold(
            body: _ProfileView(
              user: me!,
              onEdit: () => setState(() => _editing = true),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(me == null ? 'Create your profile' : 'Edit profile'),
            leading: me == null
                ? null
                : IconButton(
                    tooltip: 'Cancel',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() => _editing = false),
                  ),
          ),
          body: ProfileForm(
            key: ValueKey(me?['id'] ?? 'new'),
            initial: me,
            onCancel:
                me == null ? null : () => setState(() => _editing = false),
            onSaved: () => setState(() => _editing = false),
          ),
        );
      },
    );
  }
}

class _ProfileView extends StatelessWidget {
  final Map user;
  final VoidCallback onEdit;
  const _ProfileView({required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final state = TeamUpState.instance;
    final pct = state.calculateProfileCompleteness(user);
    final tips = state.profileMissingItems(user);
    final skills = List.from(user['skills'] ?? []);
    final interests = List.from(user['interests'] ?? []);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        PageHeader(
          title: 'My Profile',
          subtitle: 'This is how teammates see you',
          icon: Icons.person_rounded,
          actions: [
            HeaderIconButton(
              icon: Icons.edit_rounded,
              tooltip: 'Edit profile',
              onPressed: onEdit,
            ),
          ],
          bottom: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: AppAvatar(student: user, size: 66),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user['name']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${user['department']} • Semester ${user['semester']}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  ScoreRing(score: pct, size: 58, light: true),
                  const SizedBox(height: 4),
                  Text(
                    'Complete',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_outlined,
                      size: 18, color: kPrimaryColor),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text('Profile completeness',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Text('$pct%',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: kPrimaryColor)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 9,
                  backgroundColor: Colors.grey.shade200,
                  color: pct >= 80 ? const Color(0xFF10B981) : kPrimaryColor,
                ),
              ),
              if (tips.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...tips.map((t) => Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text('$t',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.grey.shade700)),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionTitle('About'),
        AppCard(
          child: Text(
            (user['bio'] ?? '').toString().trim().isEmpty
                ? 'No bio yet. Tap edit to add one.'
                : '${user['bio']}',
            style: TextStyle(color: Colors.grey.shade800, height: 1.4),
          ),
        ),
        const SectionTitle('Skills'),
        _ChipWrap(items: skills, color: const Color(0xFFEEF2FF)),
        const SectionTitle('Interests'),
        _ChipWrap(items: interests, color: const Color(0xFFFCE7F3)),
        const SectionTitle('Project preferences'),
        AppCard(
          child: Column(
            children: [
              _InfoRow(
                  icon: Icons.school_outlined,
                  label: 'Project type',
                  value: '${user['project_type']}'),
              const Divider(height: 20),
              _InfoRow(
                  icon: Icons.schedule,
                  label: 'Availability',
                  value: '${user['availability']}'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (state.offline)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.cloud_off, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Offline: your profile is saved on this device.',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChipWrap extends StatelessWidget {
  final List items;
  final Color color;
  const _ChipWrap({required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text('None added yet',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13));
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items
          .map((e) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text('$e',
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w600)),
              ))
          .toList(),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kPrimaryColor),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Create / edit form. Used on the Profile tab and as first-run onboarding.
class ProfileForm extends StatefulWidget {
  final Map? initial;
  final VoidCallback? onCancel;
  final VoidCallback? onSaved;

  const ProfileForm({super.key, this.initial, this.onCancel, this.onSaved});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late String _dept;
  late int _semester;
  late String _projectType;
  late String _availability;
  late String _avatarColor;
  late List _skills;
  late List _interests;
  bool _saving = false;

  static const _colors = [
    '#4F46E5',
    '#EC4899',
    '#0EA5E9',
    '#10B981',
    '#F59E0B',
    '#8B5CF6',
    '#EF4444',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _nameCtrl = TextEditingController(text: p?['name'] ?? '');
    _bioCtrl = TextEditingController(text: p?['bio'] ?? '');
    _dept = availableDepartments.contains(p?['department'])
        ? p!['department']
        : availableDepartments.first;
    final sem = ((p?['semester'] ?? 6) as num).toInt();
    _semester = sem >= 1 && sem <= 8 ? sem : 6;
    _projectType = availableProjectTypes.contains(p?['project_type'])
        ? p!['project_type']
        : availableProjectTypes.first;
    _availability = availableAvailabilities.contains(p?['availability'])
        ? p!['availability']
        : availableAvailabilities.first;
    _avatarColor = (p?['avatar_color'] ?? _colors.first).toString();
    _skills = List.from(p?['skills'] ?? []);
    _interests = List.from(p?['interests'] ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Map get _draft => {
        'name': _nameCtrl.text,
        'department': _dept,
        'semester': _semester,
        'skills': _skills,
        'interests': _interests,
        'project_type': _projectType,
        'availability': _availability,
        'bio': _bioCtrl.text,
      };

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_skills.isEmpty) {
      showErrorSnack(context, 'Pick at least one skill');
      return;
    }
    if (_interests.isEmpty) {
      showErrorSnack(context, 'Pick at least one interest');
      return;
    }
    setState(() => _saving = true);
    try {
      final synced = await TeamUpState.instance.saveProfile(
        name: _nameCtrl.text,
        department: _dept,
        semester: _semester,
        skills: _skills,
        interests: _interests,
        projectType: _projectType,
        availability: _availability,
        bio: _bioCtrl.text,
        avatarColor: _avatarColor,
      );
      if (!mounted) return;
      showAppSnack(
          context,
          synced
              ? 'Profile saved!'
              : 'Saved on this device (offline). It will sync later.');
      widget.onSaved?.call();
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = TeamUpState.instance.calculateProfileCompleteness(_draft);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                AppAvatar(
                  student: {'name': _nameCtrl.text, 'avatar_color': _avatarColor},
                  size: 52,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Profile $pct% complete',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: pct / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionTitle('Avatar colour'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _colors.map((c) {
              final sel = c == _avatarColor;
              return GestureDetector(
                onTap: () => setState(() => _avatarColor = c),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: parseHexColor(c),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: sel ? Colors.black87 : Colors.transparent,
                        width: 2.5),
                  ),
                  child: sel
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SectionTitle('Basic info'),
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            maxLength: 40,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Full name *',
              prefixIcon: Icon(Icons.person_outline),
              counterText: '',
            ),
            validator: (v) {
              final t = (v ?? '').trim();
              if (t.isEmpty) return 'Name is required';
              if (t.length < 2) return 'Name is too short';
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField(
            initialValue: _dept,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Department',
              prefixIcon: Icon(Icons.apartment_outlined),
            ),
            items: availableDepartments
                .map((d) => DropdownMenuItem(
                    value: d,
                    child: Text('$d', overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) => setState(() => _dept = v.toString()),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  initialValue: _semester,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Semester'),
                  items: List.generate(8, (i) => i + 1)
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text('Sem $s')))
                      .toList(),
                  onChanged: (v) => setState(() => _semester = v ?? 6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField(
                  initialValue: _projectType,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Project type'),
                  items: availableProjectTypes
                      .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text('$t', overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() => _projectType = v.toString()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField(
            initialValue: _availability,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Availability',
              prefixIcon: Icon(Icons.schedule),
            ),
            items: availableAvailabilities
                .map((a) => DropdownMenuItem(value: a, child: Text('$a')))
                .toList(),
            onChanged: (v) => setState(() => _availability = v.toString()),
          ),
          SectionTitle('Skills (${_skills.length} selected) *'),
          _chipPicker(
              {...TeamUpState.instance.allSkillOptions, ..._skills}.toList(),
              _skills),
          SectionTitle('Interests (${_interests.length} selected) *'),
          _chipPicker(
              {...TeamUpState.instance.allInterestOptions, ..._interests}
                  .toList(),
              _interests),
          const SectionTitle('Short bio'),
          TextFormField(
            controller: _bioCtrl,
            maxLines: 3,
            maxLength: 200,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'e.g. Flutter dev who loves clean UI. Looking for an FYP team.',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_outline),
              label: Text(_saving ? 'Saving...' : 'Save profile'),
            ),
          ),
          if (widget.onCancel != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _saving ? null : widget.onCancel,
              child: const Text('Cancel'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chipPicker(List options, List selected) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: options.map((o) {
        final sel = selected.contains(o);
        return FilterChip(
          label: Text('$o', style: const TextStyle(fontSize: 12.5)),
          selected: sel,
          onSelected: (v) => setState(() {
            v ? selected.add(o) : selected.remove(o);
          }),
        );
      }).toList(),
    );
  }
}