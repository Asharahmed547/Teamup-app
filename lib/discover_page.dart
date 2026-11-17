import 'package:flutter/material.dart';
import 'app_state.dart';
import 'theme.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final _searchCtrl = TextEditingController();
  final _state = TeamUpState.instance;

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = _state.searchQuery;
    _state.addListener(_onState);
  }

  void _onState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _state.removeListener(_onState);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openAddStudentModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final bioCtrl = TextEditingController();
    String dept = availableDepartments.first;
    int semester = 6;
    String projectType = 'FYP';
    String availability = 'Evenings & Weekends';
    String avatarColor = '#0EA5E9';
    final List selectedSkills = ['Flutter'];
    final List selectedInterests = ['Mobile Apps'];
    bool saving = false;

    final colors = [
      '#4F46E5',
      '#EC4899',
      '#0EA5E9',
      '#10B981',
      '#F59E0B',
      '#8B5CF6',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            MediaQuery.of(ctx).viewInsets.bottom + 18,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: kGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person_add_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Add New Student Profile',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Student Full Name *',
                    hintText: 'e.g. Usman Tariq',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  initialValue: dept,
                  decoration: const InputDecoration(labelText: 'Department'),
                  items: availableDepartments
                      .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setModalState(() => dept = v.toString());
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        initialValue: semester,
                        decoration:
                            const InputDecoration(labelText: 'Semester'),
                        items: [1, 2, 3, 4, 5, 6, 7, 8]
                            .map((s) => DropdownMenuItem(
                                value: s, child: Text('Sem $s')))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setModalState(() => semester = v as int);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField(
                        initialValue: projectType,
                        decoration:
                            const InputDecoration(labelText: 'Project Type'),
                        items: availableProjectTypes
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text('$p')))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setModalState(() => projectType = v.toString());
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  initialValue: availability,
                  decoration: const InputDecoration(labelText: 'Availability'),
                  items: availableAvailabilities
                      .map((a) => DropdownMenuItem(value: a, child: Text('$a')))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setModalState(() => availability = v.toString());
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Short Bio',
                    hintText: 'Skills, past projects, or goals...',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Badge Color: ',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    ...colors.map((hex) => GestureDetector(
                          onTap: () => setModalState(() => avatarColor = hex),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: parseHexColor(hex),
                              shape: BoxShape.circle,
                              border: avatarColor == hex
                                  ? Border.all(color: Colors.black, width: 2.5)
                                  : null,
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Skills:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: availableSkills.take(12).map((sk) {
                    final sel = selectedSkills.contains(sk);
                    return FilterChip(
                      label: Text('$sk', style: const TextStyle(fontSize: 12)),
                      selected: sel,
                      onSelected: (val) => setModalState(() {
                        val
                            ? selectedSkills.add(sk)
                            : selectedSkills.remove(sk);
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Text('Interests:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: availableInterests.take(8).map((item) {
                    final sel = selectedInterests.contains(item);
                    return FilterChip(
                      label:
                          Text('$item', style: const TextStyle(fontSize: 12)),
                      selected: sel,
                      onSelected: (val) => setModalState(() {
                        val
                            ? selectedInterests.add(item)
                            : selectedInterests.remove(item);
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: saving
                        ? null
                        : () async {
                            if (nameCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Please enter student name!')),
                              );
                              return;
                            }
                            setModalState(() => saving = true);
                            try {
                            await _state.addNewStudent(
                              name: nameCtrl.text,
                              department: dept,
                              semester: semester,
                              skills: selectedSkills,
                              interests: selectedInterests,
                              projectType: projectType,
                              availability: availability,
                              bio: bioCtrl.text,
                              avatarColor: avatarColor,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            setState(() {});
                            if (context.mounted) {
                              showAppSnack(context,
                                  '${nameCtrl.text.trim()} added to TeamUp!');
                            }
                            } catch (e) {
                              setModalState(() => saving = false);
                              if (context.mounted) showErrorSnack(context, e);
                            }
                          },
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(saving ? 'Adding...' : 'Save & Add Student'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sync() async {
    final ok = await _state.refresh();
    if (!mounted) return;
    ok
        ? showAppSnack(context, 'Synced with server')
        : showErrorSnack(context, 'Offline - showing saved data on this device');
  }

  void _resetFilters() {
    _searchCtrl.clear();
    _state.searchQuery = '';
    _state.selectedDept = 'All';
    _state.selectedSkill = 'All';
    _state.selectedProjectType = 'All';
    _state.selectedSemester = 0;
    setState(() {});
  }

  void _openSortSheet(BuildContext context) {
    const options = [
      ['Match Score', 'Highest match first', Icons.auto_awesome],
      ['Semester', 'Senior students first', Icons.school_rounded],
      ['Name', 'Alphabetical (A-Z)', Icons.sort_by_alpha_rounded],
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 6, bottom: 10),
                child: Text('Sort students',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800, color: kInk)),
              ),
              ...options.map((o) {
                final sel = _state.sortBy == o[0];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: sel ? kSoftPrimary : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      leading: Icon(o[2] as IconData,
                          color: sel ? kPrimaryColor : kMuted),
                      title: Text('${o[0]}',
                          style: TextStyle(
                              fontWeight:
                                  sel ? FontWeight.w800 : FontWeight.w600)),
                      subtitle: Text('${o[1]}',
                          style: const TextStyle(fontSize: 12)),
                      trailing: sel
                          ? const Icon(Icons.check_circle_rounded,
                              color: kPrimaryColor)
                          : null,
                      onTap: () {
                        _state.sortBy = o[0].toString();
                        Navigator.pop(ctx);
                        setState(() {});
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _state.filteredStudents;
    final firstName =
        (_state.currentUser?['name'] ?? '').toString().trim().split(' ').first;
    final pendingOut = _state.sentRequests
        .where((r) => _state.effectiveStatus(r) == 'Pending')
        .length;
    final anyFilter = _filtersActive || _state.searchQuery.isNotEmpty;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _state.refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: PageHeader(
                title: firstName.isEmpty ? 'Discover' : 'Hi, $firstName',
                subtitle: 'Find the right teammates for your project',
                actions: [
                  HeaderIconButton(
                    icon: Icons.tune_rounded,
                    tooltip: 'Sort students',
                    onPressed: () => _openSortSheet(context),
                  ),
                  HeaderIconButton(
                    icon: Icons.person_add_alt_1_rounded,
                    tooltip: 'Add sample student',
                    onPressed: () => _openAddStudentModal(context),
                  ),
                  HeaderIconButton(
                    icon: Icons.sync_rounded,
                    tooltip: 'Sync data',
                    onPressed: _sync,
                  ),
                ],
                bottom: Column(
                  children: [
                    Row(
                      children: [
                        StatPill(
                          value: '${_state.otherStudents.length}',
                          label: 'Students',
                          icon: Icons.people_alt_rounded,
                        ),
                        const SizedBox(width: 8),
                        StatPill(
                          value: '${_state.teamMembers.length}',
                          label: 'In my team',
                          icon: Icons.groups_rounded,
                        ),
                        const SizedBox(width: 8),
                        StatPill(
                          value: '$pendingOut',
                          label: 'Invites out',
                          icon: Icons.send_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) {
                        _state.searchQuery = v;
                        setState(() {});
                      },
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search name, skill or department...',
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: kPrimaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                              color: Colors.white, width: 2),
                        ),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _state.searchQuery = '';
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 58,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  children: [
                    _buildFilterDropdown(
                      label: 'Dept',
                      icon: Icons.apartment_rounded,
                      value: _state.selectedDept,
                      items: ['All', ...availableDepartments],
                      onChanged: (v) =>
                          setState(() => _state.selectedDept = v.toString()),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterDropdown(
                      label: 'Skill',
                      icon: Icons.code_rounded,
                      value: _state.selectedSkill,
                      items: ['All', ..._state.allSkillOptions],
                      onChanged: (v) =>
                          setState(() => _state.selectedSkill = v.toString()),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterDropdown(
                      label: 'Type',
                      icon: Icons.school_rounded,
                      value: _state.selectedProjectType,
                      items: ['All', ...availableProjectTypes],
                      onChanged: (v) => setState(
                          () => _state.selectedProjectType = v.toString()),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterDropdown(
                      label: 'Sem',
                      icon: Icons.calendar_today_rounded,
                      value: _state.selectedSemester == 0
                          ? 'All'
                          : 'Sem ${_state.selectedSemester}',
                      items: ['All', for (int i = 1; i <= 8; i++) 'Sem $i'],
                      onChanged: (v) {
                        setState(() {
                          _state.selectedSemester = v == 'All'
                              ? 0
                              : int.parse(
                                  v.toString().replaceFirst('Sem ', ''));
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_state.savedFilters.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 46,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                    children: _state.savedFilters
                        .map((f) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: InputChip(
                                avatar: const Icon(Icons.bookmark_rounded,
                                    size: 15, color: kSecondaryColor),
                                label: Text('${f['name']}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                                backgroundColor: const Color(0xFFF5F3FF),
                                side: BorderSide.none,
                                onPressed: () {
                                  _state.applySavedFilter(f);
                                  setState(() {});
                                },
                                onDeleted: () async {
                                  await _state.deleteSavedFilter(f);
                                  setState(() {});
                                },
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 6),
                child: Row(
                  children: [
                    Text(
                      '${results.length} students',
                      style: const TextStyle(
                        color: kInk,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• sorted by ${_state.sortBy.toLowerCase()}',
                      style: const TextStyle(color: kMuted, fontSize: 12),
                    ),
                    const Spacer(),
                    if (_filtersActive)
                      IconButton(
                        tooltip: 'Save these filters',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _saveFilterDialog(context),
                        icon: const Icon(Icons.bookmark_add_outlined,
                            size: 20, color: kSecondaryColor),
                      ),
                    if (anyFilter)
                      TextButton.icon(
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.filter_alt_off_rounded,
                            size: 16),
                        label: const Text('Reset'),
                      ),
                  ],
                ),
              ),
            ),
            if (results.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateView(
                  icon: Icons.person_search_rounded,
                  title: 'No students found',
                  subtitle: 'Try another search or reset your filters.',
                  scrollable: false,
                  action: anyFilter
                      ? OutlinedButton.icon(
                          onPressed: _resetFilters,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reset filters'),
                        )
                      : null,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => FadeSlideIn(
                      index: i,
                      child: StudentProfileCard(student: results[i]),
                    ),
                    childCount: results.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool get _filtersActive =>
      _state.selectedDept != 'All' ||
      _state.selectedSkill != 'All' ||
      _state.selectedProjectType != 'All' ||
      _state.selectedSemester != 0;

  void _saveFilterDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Save filters'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 20,
          decoration: const InputDecoration(hintText: 'e.g. Flutter devs'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) {
                showErrorSnack(context, 'Please enter a name');
                return;
              }
              Navigator.pop(ctx);
              await _state.saveCurrentFilter(name);
              if (mounted) setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List items,
    required ValueChanged onChanged,
  }) {
    final active = value != 'All';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.only(left: 10, right: 6),
      decoration: BoxDecoration(
        color: active ? kPrimaryColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? kPrimaryColor : kBorder),
        boxShadow: active
            ? [
                BoxShadow(
                  color: kPrimaryColor.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: active ? Colors.white : kMuted),
          const SizedBox(width: 4),
          DropdownButtonHideUnderline(
            child: DropdownButton(
              value: value,
              isDense: true,
              borderRadius: BorderRadius.circular(14),
              dropdownColor: Colors.white,
              iconEnabledColor: active ? Colors.white : kMuted,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
              selectedItemBuilder: (_) => items
                  .map((item) => Center(
                        child: Text(
                          item == 'All' ? label : '$item',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: active ? Colors.white : kInk,
                            fontWeight:
                                active ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item == 'All' ? 'All ${label}s' : '$item',
                          style: const TextStyle(fontSize: 13, color: kInk),
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}