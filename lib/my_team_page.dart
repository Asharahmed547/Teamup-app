import 'package:flutter/material.dart';
import 'app_state.dart';
import 'theme.dart';

/// Module 5: My Team — create a team, see members and open roles,
/// plus a team checklist and simple team chat (bonus).
class MyTeamPage extends StatefulWidget {
  final VoidCallback? onGoToProfile;
  final VoidCallback? onFindTeammates;

  const MyTeamPage({super.key, this.onGoToProfile, this.onFindTeammates});

  @override
  State<MyTeamPage> createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  final _state = TeamUpState.instance;
  final _taskCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _taskCtrl.dispose();
    super.dispose();
  }

  Future<void> _guard(Future<void> Function() action, [String? okMsg]) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted && okMsg != null) showAppSnack(context, okMsg);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        final team = _state.myTeam;
        if (team != null && _state.hasProfile) {
          return Scaffold(body: _buildTeam(context, team));
        }
        return Scaffold(
          body: Column(
            children: [
              const PageHeader(
                title: 'My Team',
                subtitle: 'Build your dream project team',
                icon: Icons.groups_rounded,
              ),
              Expanded(
                child: !_state.hasProfile
                    ? EmptyStateView(
                        icon: Icons.person_outline_rounded,
                        title: 'Create your profile first',
                        subtitle:
                            'You need a profile before you can build a team.',
                        action: FilledButton(
                          onPressed: widget.onGoToProfile,
                          child: const Text('Go to Profile'),
                        ),
                      )
                    : EmptyStateView(
                        icon: Icons.groups_rounded,
                        title: 'You are not in a team yet',
                        subtitle:
                            'Create a team for your project, or accept a request on the Requests tab.',
                        action: FilledButton.icon(
                          onPressed: () => _openTeamForm(context, null),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Create a team'),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeam(BuildContext context, Map team) {
    final members = _state.teamMembers;
    final openRoles = List.from(team['needed_roles'] ?? []);
    final neededSkills = List.from(team['needed_skills'] ?? []);
    final missing = _state.missingTeamSkills;
    final tasks = _state.teamTasks;
    final doneCount = tasks.where((t) => t['is_done'] == true).length;

    return RefreshIndicator(
      onRefresh: _state.refresh,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          PageHeader(
            title: '${team['title']}',
            subtitle:
                '${team['project_type']} • ${_state.isTeamOwner ? "You lead this team" : "You are a member"}',
            icon: Icons.groups_rounded,
            actions: [
              if (_state.isTeamOwner)
                HeaderIconButton(
                  icon: Icons.edit_rounded,
                  tooltip: 'Edit team',
                  onPressed: () => _openTeamForm(context, team),
                ),
              HeaderIconButton(
                icon: Icons.chat_bubble_rounded,
                tooltip: 'Team chat',
                badge: _state.teamMessages.length,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TeamChatScreen()),
                ),
              ),
            ],
            bottom: Row(
              children: [
                StatPill(
                  value: '${members.length}',
                  label: 'Members',
                  icon: Icons.people_alt_rounded,
                ),
                const SizedBox(width: 8),
                StatPill(
                  value: '${openRoles.length}',
                  label: 'Open roles',
                  icon: Icons.work_rounded,
                ),
                const SizedBox(width: 8),
                StatPill(
                  value: tasks.isEmpty
                      ? '0%'
                      : '${(doneCount * 100 / tasks.length).round()}%',
                  label: 'Tasks done',
                  icon: Icons.task_alt_rounded,
                ),
              ],
            ),
          ),
          if (_busy) const LinearProgressIndicator(minHeight: 3),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // Members
          SectionTitle('Members (${members.length})'),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: members.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('No members yet'),
                  )
                : Column(
                    children: members.map((m) {
                      final st = m['students'] is Map ? m['students'] : null;
                      final isMe = m['student_id'] == _state.myId;
                      return ListTile(
                        leading: AppAvatar(student: st, size: 40),
                        title: Text(
                          '${st?['name'] ?? m['student_id']}${isMe ? " (You)" : ""}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${m['role'] ?? 'Member'} • ${List.from(st?['skills'] ?? []).take(3).join(", ")}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: _state.isTeamOwner && !isMe
                            ? IconButton(
                                tooltip: 'Remove member',
                                icon: const Icon(Icons.person_remove_outlined,
                                    size: 20),
                                onPressed: () async {
                                  final ok = await confirmAction(
                                    context,
                                    title: 'Remove member?',
                                    message:
                                        'Remove ${st?['name'] ?? 'this student'} from the team?',
                                    confirmLabel: 'Remove',
                                  );
                                  if (ok) {
                                    _guard(() => _state.removeMember(m),
                                        'Member removed');
                                  }
                                },
                              )
                            : (m['student_id'] == team['owner_id']
                                ? const Icon(Icons.star_rounded,
                                    color: Color(0xFFF59E0B))
                                : null),
                      );
                    }).toList(),
                  ),
          ),

          // Open roles
          SectionTitle(
            'Open roles (${openRoles.length})',
            trailing: openRoles.isNotEmpty && widget.onFindTeammates != null
                ? TextButton(
                    onPressed: widget.onFindTeammates,
                    child: const Text('Find people'),
                  )
                : null,
          ),
          if (openRoles.isEmpty)
            Text('All roles are filled.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13))
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: openRoles
                  .map((r) => Chip(
                        avatar: const Icon(Icons.work_outline, size: 15),
                        label: Text('$r', style: const TextStyle(fontSize: 12)),
                        backgroundColor: const Color(0xFFFEF3C7),
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),

          // Skills
          if (neededSkills.isNotEmpty) ...[
            const SectionTitle('Skills needed'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: neededSkills.map((sk) {
                final covered = !missing.contains(sk);
                return Chip(
                  avatar: Icon(
                    covered ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 15,
                    color: covered
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                  ),
                  label: Text('$sk', style: const TextStyle(fontSize: 12)),
                  backgroundColor: covered
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ],

          // Checklist (bonus)
          SectionTitle(
            'Team checklist',
            trailing: Text('$doneCount / ${tasks.length} done',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ),
          AppCard(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Column(
              children: [
                if (tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('No tasks yet. Add your first one below.',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13)),
                  ),
                ...tasks.map((t) => Row(
                      children: [
                        Checkbox(
                          value: t['is_done'] == true,
                          onChanged: _busy
                              ? null
                              : (_) => _guard(() => _state.toggleTeamTask(t)),
                        ),
                        Expanded(
                          child: Text(
                            '${t['title']}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              decoration: t['is_done'] == true
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: t['is_done'] == true
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete task',
                          icon: Icon(Icons.delete_outline,
                              size: 19, color: Colors.grey.shade500),
                          onPressed: _busy
                              ? null
                              : () => _guard(() => _state.deleteTeamTask(t)),
                        ),
                      ],
                    )),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _taskCtrl,
                        maxLength: 80,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addTask(),
                        decoration: const InputDecoration(
                          hintText: 'Add a task (e.g. Make wireframes)',
                          isDense: true,
                          counterText: '',
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Add task',
                      onPressed: _busy ? null : _addTask,
                      icon: const Icon(Icons.add_circle,
                          color: kPrimaryColor, size: 30),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chat entry
          const SizedBox(height: 14),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEEF2FF),
                child: Icon(Icons.forum_outlined, color: kPrimaryColor),
              ),
              title: const Text('Team chat',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                _state.teamMessages.isEmpty
                    ? 'Say hi to your team'
                    : '${_state.teamMessages.last['sender_name']}: ${_state.teamMessages.last['text']}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TeamChatScreen()),
              ),
            ),
          ),

          // Leave / delete
          const SizedBox(height: 22),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
              side: const BorderSide(color: Color(0xFFFCA5A5)),
              minimumSize: const Size.fromHeight(46),
            ),
            onPressed: _busy
                ? null
                : () async {
                    final owner = _state.isTeamOwner;
                    final ok = await confirmAction(
                      context,
                      title: owner ? 'Delete team?' : 'Leave team?',
                      message: owner
                          ? 'You are the team lead. Deleting "${team['title']}" removes all members, tasks and chat.'
                          : 'Are you sure you want to leave "${team['title']}"?',
                      confirmLabel: owner ? 'Delete team' : 'Leave team',
                    );
                    if (ok) {
                      _guard(_state.leaveOrDeleteTeam,
                          owner ? 'Team deleted' : 'You left the team');
                    }
                  },
            icon: Icon(_state.isTeamOwner
                ? Icons.delete_forever_outlined
                : Icons.logout),
            label: Text(_state.isTeamOwner ? 'Delete team' : 'Leave team'),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addTask() {
    final text = _taskCtrl.text.trim();
    if (text.isEmpty) {
      showErrorSnack(context, 'Task cannot be empty');
      return;
    }
    _taskCtrl.clear();
    FocusScope.of(context).unfocus();
    _guard(() => _state.addTeamTask(text));
  }

  void _openTeamForm(BuildContext context, Map? team) {
    final titleCtrl = TextEditingController(text: team?['title'] ?? '');
    String type = availableProjectTypes.contains(team?['project_type'])
        ? team!['project_type']
        : (_state.currentUser?['project_type'] ?? availableProjectTypes.first)
            .toString();
    final List roles = List.from(team?['needed_roles'] ?? []);
    final List skills = List.from(team?['needed_skills'] ?? []);
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              18, 18, 18, MediaQuery.of(ctx).viewInsets.bottom + 18),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        team == null ? 'Create your team' : 'Edit team',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleCtrl,
                  maxLength: 50,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Project title *',
                    hintText: 'e.g. Smart Campus Navigator',
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Project type',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: availableProjectTypes
                      .map((t) => ChoiceChip(
                            label: Text('$t'),
                            selected: type == t,
                            onSelected: (_) =>
                                setSheet(() => type = t.toString()),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),
                const Text('Roles needed',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: {..._state.allRoleOptions, ...roles}.toList().map((r) {
                    final sel = roles.contains(r);
                    return FilterChip(
                      label: Text('$r', style: const TextStyle(fontSize: 12)),
                      selected: sel,
                      onSelected: (v) => setSheet(
                          () => v ? roles.add(r) : roles.remove(r)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Text('Skills needed',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: {..._state.allSkillOptions, ...skills}.toList().map((s) {
                    final sel = skills.contains(s);
                    return FilterChip(
                      label: Text('$s', style: const TextStyle(fontSize: 12)),
                      selected: sel,
                      onSelected: (v) => setSheet(
                          () => v ? skills.add(s) : skills.remove(s)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: saving
                        ? null
                        : () async {
                            if (titleCtrl.text.trim().isEmpty) {
                              showErrorSnack(
                                  context, 'Please enter a project title');
                              return;
                            }
                            setSheet(() => saving = true);
                            try {
                              await _state.createOrUpdateTeam(
                                title: titleCtrl.text,
                                projectType: type,
                                neededRoles: roles,
                                neededSkills: skills,
                              );
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) {
                                showAppSnack(context,
                                    team == null ? 'Team created!' : 'Team updated');
                              }
                            } catch (e) {
                              setSheet(() => saving = false);
                              if (context.mounted) showErrorSnack(context, e);
                            }
                          },
                    icon: const Icon(Icons.check),
                    label: Text(saving
                        ? 'Saving...'
                        : team == null
                            ? 'Create team'
                            : 'Save changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bonus: simple team chat.
class TeamChatScreen extends StatefulWidget {
  const TeamChatScreen({super.key});

  @override
  State<TeamChatScreen> createState() => _TeamChatScreenState();
}

class _TeamChatScreenState extends State<TeamChatScreen> {
  final _state = TeamUpState.instance;
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await _state.sendTeamChat(text);
      _ctrl.clear();
      _scrollToEnd();
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        final msgs = _state.teamMessages;
        final myName = _state.currentUser?['name'];
        _scrollToEnd();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${_state.myTeam?['title'] ?? 'Team'} chat',
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: _state.refresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: _state.myTeam == null
              ? const EmptyStateView(
                  icon: Icons.forum_outlined,
                  title: 'You are not in a team',
                )
              : Column(
                  children: [
                    Expanded(
                      child: msgs.isEmpty
                          ? const EmptyStateView(
                              icon: Icons.forum_outlined,
                              title: 'No messages yet',
                              subtitle: 'Start the conversation with your team.',
                            )
                          : ListView.builder(
                              controller: _scroll,
                              padding: const EdgeInsets.all(14),
                              itemCount: msgs.length,
                              itemBuilder: (_, i) {
                                final m = msgs[i];
                                final mine = m['sender_name'] == myName;
                                return Align(
                                  alignment: mine
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.75),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: mine ? kGradient : null,
                                      color: mine ? null : Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(18),
                                        topRight: const Radius.circular(18),
                                        bottomLeft:
                                            Radius.circular(mine ? 18 : 4),
                                        bottomRight:
                                            Radius.circular(mine ? 4 : 18),
                                      ),
                                      border: mine
                                          ? null
                                          : Border.all(
                                              color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (!mine)
                                          Text('${m['sender_name']}',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: kPrimaryColor)),
                                        Text(
                                          '${m['text']}',
                                          style: TextStyle(
                                              color: mine
                                                  ? Colors.white
                                                  : Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 6, 8, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _ctrl,
                                maxLength: 300,
                                minLines: 1,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  hintText: 'Type a message',
                                  isDense: true,
                                  counterText: '',
                                ),
                              ),
                            ),
                            IconButton.filled(
                              onPressed: _sending ? null : _send,
                              icon: const Icon(Icons.send_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}