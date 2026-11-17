import 'package:flutter/material.dart';
import 'app_state.dart';
import 'theme.dart';

/// Module 3: Smart match — best matches sorted by score, with reasons
/// and a skill-gap view (bonus).
class BestMatchPage extends StatelessWidget {
  final VoidCallback? onGoToProfile;
  final VoidCallback? onGoToTeam;

  const BestMatchPage({super.key, this.onGoToProfile, this.onGoToTeam});

  @override
  Widget build(BuildContext context) {
    final state = TeamUpState.instance;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        if (!state.hasProfile) {
          return Scaffold(
            body: Column(
              children: [
                const PageHeader(
                  title: 'Best Matches',
                  subtitle: 'Smart teammate suggestions',
                  icon: Icons.auto_awesome,
                ),
                Expanded(
                  child: EmptyStateView(
                    icon: Icons.person_search_rounded,
                    title: 'Create your profile first',
                    subtitle:
                        'Matches are calculated from your skills, interests, project type and availability.',
                    action: FilledButton.icon(
                      onPressed: onGoToProfile,
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Create profile'),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(body: _buildList(context, state));
      },
    );
  }

  Widget _buildList(BuildContext context, TeamUpState state) {
    final matches = state.bestMatches;
    final great = matches
        .where((s) => (state.computeSmartMatch(s)['score'] as int) >= 70)
        .length;
    final topScore = matches.isEmpty
        ? 0
        : state.computeSmartMatch(matches.first)['score'] as int;

    return RefreshIndicator(
      onRefresh: state.refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: PageHeader(
              title: 'Best Matches',
              subtitle: 'Ranked by how well they fit you',
              icon: Icons.auto_awesome,
              actions: [
                HeaderIconButton(
                  icon: Icons.help_outline_rounded,
                  tooltip: 'How matching works',
                  onPressed: () => _showHowItWorks(context),
                ),
              ],
              bottom: Row(
                children: [
                  StatPill(
                    value: '$great',
                    label: 'Great matches',
                    icon: Icons.local_fire_department_rounded,
                  ),
                  const SizedBox(width: 8),
                  StatPill(
                    value: '$topScore%',
                    label: 'Top score',
                    icon: Icons.emoji_events_rounded,
                  ),
                  const SizedBox(width: 8),
                  StatPill(
                    value: '${state.missingTeamSkills.length}',
                    label: 'Skills missing',
                    icon: Icons.extension_rounded,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeSlideIn(child: _SkillGapCard(onGoToTeam: onGoToTeam)),
                SectionTitle(
                  'Top matches for you',
                  trailing: Text('${matches.length} students',
                      style: const TextStyle(fontSize: 12, color: kMuted)),
                ),
                if (matches.isEmpty)
                  const EmptyStateView(
                    icon: Icons.groups_2_outlined,
                    title: 'No students to match yet',
                    subtitle: 'Add students on the Discover tab.',
                    scrollable: false,
                  ),
                ...List.generate(
                  matches.length,
                  (i) => FadeSlideIn(
                    index: i,
                    child: StudentProfileCard(
                      student: matches[i],
                      showMatchReason: true,
                      rank: i < 3 ? i + 1 : null,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showHowItWorks(BuildContext context) {
    final rows = [
      ['Skills you need', kWeightSkills,
        'Team needed skills nobody has yet. No team? Skills you don\'t have.'],
      ['Shared interests', kWeightInterests, 'Interests you both picked.'],
      ['Same project type', kWeightProjectType, 'Both want an FYP / semester project.'],
      ['Availability', kWeightAvailability, 'Free at the same time (Flexible fits all).'],
      ['Same semester', kWeightSemester, 'Same semester = full points, ±1 or ±2 = partial.'],
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How the match score works',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 6),
              Text(
                'Every student gets a score out of 100 based on your profile. '
                'Tap the green reason box on any card to see their breakdown.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 14),
              ...rows.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text('${r[1]}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${r[0]}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text('${r[2]}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              const Divider(),
              Text(
                'Students already in your team are hidden from this list.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bonus: shows which skills the team still needs and who can fill them.
class _SkillGapCard extends StatelessWidget {
  final VoidCallback? onGoToTeam;
  const _SkillGapCard({this.onGoToTeam});

  @override
  Widget build(BuildContext context) {
    final state = TeamUpState.instance;
    final team = state.myTeam;
    final needed = List.from(team?['needed_skills'] ?? []);
    final missing = state.missingTeamSkills;

    Widget body;
    if (team == null || needed.isEmpty) {
      body = Row(
        children: [
          Expanded(
            child: Text(
              team == null
                  ? 'Create a team and list the skills you need to see your skill gap.'
                  : 'Add "skills needed" to your team to see your skill gap.',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
            ),
          ),
          TextButton(
            onPressed: onGoToTeam,
            child: Text(team == null ? 'Create' : 'Edit'),
          ),
        ],
      );
    } else if (missing.isEmpty) {
      body = const Row(
        children: [
          Icon(Icons.celebration, color: Color(0xFF10B981), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text('All needed skills are covered by your team!',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${needed.length - missing.length} of ${needed.length} needed skills covered',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (needed.length - missing.length) / needed.length,
              minHeight: 7,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 10),
          ...missing.map((sk) {
            final pick = state.bestCandidateForSkill(sk.toString());
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$sk',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB91C1C),
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pick == null
                          ? 'Nobody has this yet'
                          : 'Best pick: ${pick['name']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                  if (pick != null &&
                      !state.hasPendingRequestTo(pick['id'].toString()))
                    TextButton(
                      style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact),
                      onPressed: () => showSendRequestDialog(context, pick),
                      child: const Text('Invite'),
                    ),
                ],
              ),
            );
          }),
        ],
      );
    }

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.extension_outlined, size: 18, color: kPrimaryColor),
              SizedBox(width: 6),
              Text('Skill gap',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 8),
          body,
        ],
      ),
    );
  }
}