import 'package:flutter/material.dart';
import 'app_state.dart';
import 'theme.dart';

/// Module 4: Team requests — Sent and Received tabs with status badges.
class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final _state = TeamUpState.instance;
  final Set _busy = {};

  Future<void> _run(Map r, Future<void> Function() action, String okMsg) async {
    setState(() => _busy.add(r['id']));
    try {
      await action();
      if (mounted) showAppSnack(context, okMsg);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy.remove(r['id']));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        final received = _state.receivedRequests;
        final sent = _state.sentRequests;
        final pendingIn = _state.unreadReceivedCount;
        final pendingOut =
            sent.where((r) => _state.effectiveStatus(r) == 'Pending').length;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            body: Column(
              children: [
                PageHeader(
                  title: 'Requests',
                  subtitle: '$pendingIn waiting for you • $pendingOut sent',
                  icon: Icons.mail_rounded,
                  bottom: Container(
                    height: 46,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: kPrimaryColor,
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 13.5),
                      unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13.5),
                      tabs: [
                        Tab(child: _tabLabel('Received', pendingIn)),
                        Tab(child: _tabLabel('Sent', pendingOut)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildList(
                        received,
                        incoming: true,
                        empty: const EmptyStateView(
                          icon: Icons.inbox_rounded,
                          title: 'No requests yet',
                          subtitle:
                              'When someone wants to team up with you, it shows up here.',
                          scrollable: false,
                        ),
                      ),
                      _buildList(
                        sent,
                        incoming: false,
                        empty: const EmptyStateView(
                          icon: Icons.outbox_rounded,
                          title: 'You haven\'t sent any requests',
                          subtitle:
                              'Find teammates on Discover or Matches and tap Invite.',
                          scrollable: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tabLabel(String text, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        if (count > 0) ...[
          const SizedBox(width: 6),
          Badge(
            label: Text('$count'),
            backgroundColor: kDangerColor,
          ),
        ],
      ],
    );
  }

  Widget _buildList(List items, {required bool incoming, required Widget empty}) {
    return RefreshIndicator(
      onRefresh: _state.refresh,
      child: items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                empty,
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: items.length,
              itemBuilder: (_, i) => FadeSlideIn(
                index: i,
                child: _requestCard(items[i], incoming),
              ),
            ),
    );
  }

  Map? _otherPerson(Map r, bool incoming) {
    final joined = incoming ? r['sender'] : r['receiver'];
    if (joined is Map) return joined;
    final id = incoming ? r['from_student_id'] : r['to_student_id'];
    for (final s in _state.allStudents) {
      if (s['id'] == id) return s;
    }
    return null;
  }

  String _timeAgo(dynamic v) {
    final d = v == null ? null : DateTime.tryParse(v.toString())?.toLocal();
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _requestCard(Map r, bool incoming) {
    final person = _otherPerson(r, incoming);
    final status = _state.effectiveStatus(r);
    final expiry = _state.expiryText(r);
    final busy = _busy.contains(r['id']);
    final isPending = status == 'Pending';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        onTap: person == null ? null : () => showMatchBreakdown(context, person),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppAvatar(student: person, size: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${incoming ? "From" : "To"} ${person?['name'] ?? 'Unknown student'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            color: kInk),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        [
                          if (person?['department'] != null)
                            person!['department'],
                          _timeAgo(r['created_at']),
                        ].where((e) => '$e'.isNotEmpty).join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: kMuted),
                      ),
                      const SizedBox(height: 6),
                      StatusBadge(status: status),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (person != null)
                  ScoreRing(
                    score: _state.computeSmartMatch(person)['score'] as int,
                    size: 46,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TagChip(
                'Role: ${r['role_offered'] ?? 'Member'}',
                icon: Icons.work_rounded,
              ),
            ),
            if ((r['message'] ?? '').toString().trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    topLeft: Radius.circular(4),
                  ),
                  border: Border.all(color: kBorder),
                ),
                child: Text(
                  '"${r['message']}"',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      fontStyle: FontStyle.italic,
                      height: 1.35),
                ),
              ),
            ],
            if (expiry != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer_outlined,
                      size: 14, color: Colors.orange.shade700),
                  const SizedBox(width: 4),
                  Text(expiry,
                      style: TextStyle(
                          fontSize: 11.5, color: Colors.orange.shade800)),
                ],
              ),
            ],
            if (isPending) ...[
              const SizedBox(height: 12),
              if (busy)
                const Center(
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5)),
                )
              else if (incoming)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626)),
                        onPressed: () => _run(
                          r,
                          () => _state.respondToRequest(
                              request: r, accept: false),
                          'Request rejected',
                        ),
                        icon: const Icon(Icons.close, size: 17),
                        label: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A)),
                        onPressed: () => _run(
                          r,
                          () =>
                              _state.respondToRequest(request: r, accept: true),
                          '${person?['name'] ?? 'Student'} is now in your team!',
                        ),
                        icon: const Icon(Icons.check, size: 17),
                        label: const Text('Accept'),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626)),
                        onPressed: () async {
                          final ok = await confirmAction(
                            context,
                            title: 'Cancel request?',
                            message:
                                'Your request to ${person?['name'] ?? 'this student'} will be cancelled.',
                            confirmLabel: 'Yes, cancel',
                          );
                          if (ok) {
                            _run(
                              r,
                              () => _state.cancelSentRequest(r['id']),
                              'Request cancelled',
                            );
                          }
                        },
                        icon: const Icon(Icons.undo, size: 17),
                        label: const Text('Cancel request'),
                      ),
                    ),
                    PopupMenuButton<bool>(
                      tooltip: 'Demo: simulate their reply',
                      icon: const Icon(Icons.more_vert),
                      onSelected: (accept) => _run(
                        r,
                        () => _state.simulateReply(r, accept),
                        accept
                            ? '${person?['name'] ?? 'Student'} accepted and joined your team!'
                            : '${person?['name'] ?? 'Student'} rejected your request',
                      ),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: true,
                          child: Text('Demo: they accept'),
                        ),
                        PopupMenuItem(
                          value: false,
                          child: Text('Demo: they reject'),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}