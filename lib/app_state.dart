import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = 'https://pysmntwwmugwnyezewjk.supabase.co';
const String supabaseAnonKey = 'sb_publishable_wia2oE7N7aApwMkDbzoIMg_igU9is3u';

final supabase = Supabase.instance.client;

/// Fixed id for the person using the app (single-user demo app).
const String kMyId = 'me_user';

/// Pending requests older than this are shown as "Expired".
/// Used only when a request has no `expires_at` value (DB default is 3 days).
const Duration kRequestExpiry = Duration(days: 3);

/// Sample students reply to your invites automatically after this delay.
const Duration kAutoReplyDelay = Duration(seconds: 8);

/// A sample student accepts your invite if their match score is at least this.
const int kAutoAcceptScore = 70;

const List availableDepartments = [
  'Computer Science',
  'Software Engineering',
  'Artificial Intelligence',
  'Data Science',
  'Cyber Security',
  'Computer Engineering',
];

const List availableSkills = [
  'Flutter',
  'UI/UX Design',
  'Figma',
  'Python',
  'Machine Learning',
  'Node.js',
  'Supabase',
  'PostgreSQL',
  'React',
  'Docker',
  'Testing & QA',
  'Report Writing',
  'C++',
  'Git',
  'SQL',
  'Data Analysis',
  'Network Security',
  'Linux',
];

const List availableInterests = [
  'Mobile Apps',
  'AI & ML',
  'Web Apps',
  'FinTech',
  'HealthTech',
  'EdTech',
  'Startups',
  'Cloud & DevOps',
  'Cybersecurity',
  'Smart Cities',
  'Design Systems',
  'E-Commerce',
];

const List availableProjectTypes = [
  'FYP',
  'Semester Project',
];

const List availableAvailabilities = [
  'Evenings & Weekends',
  'Evenings',
  'Weekends Only',
  'Flexible',
];

const List availableRoles = [
  'Developer',
  'UI/UX Designer',
  'AI/ML Developer',
  'Backend Developer',
  'Tester / QA',
  'Report Writer',
];

/// Weights used by the Smart Match score (they add up to 100).
const int kWeightSkills = 40;
const int kWeightInterests = 25;
const int kWeightProjectType = 15;
const int kWeightAvailability = 10;
const int kWeightSemester = 10;

class TeamUpState extends ChangeNotifier {
  static final TeamUpState instance = TeamUpState._();
  TeamUpState._();

  bool loading = true;
  bool offline = false;
  String? errorMessage;

  Map? currentUser;
  List allStudents = [];
  Map? myTeam;
  List teamMembers = [];
  List sentRequests = [];
  List receivedRequests = [];
  List teamTasks = [];
  List teamMessages = [];

  // Discover Filters & Sort
  String searchQuery = '';
  String selectedDept = 'All';
  int selectedSemester = 0;
  String selectedSkill = 'All';
  String selectedProjectType = 'All';
  String sortBy = 'Match Score';

  /// Saved filter presets (bonus). Each item: {name, dept, sem, skill, type, sort}
  List savedFilters = [];

  /// One-time message for the UI (shown as a snackbar by the main screen).
  String? notice;

  final Set _autoReplyScheduled = {};

  String get myId => (currentUser?['id'] ?? kMyId).toString();
  bool get hasProfile => currentUser != null;
  bool get isTeamOwner => myTeam != null && myTeam!['owner_id'] == myId;

  int get unreadReceivedCount =>
      receivedRequests.where((r) => effectiveStatus(r) == 'Pending').length;

  // ---------------------------------------------------------------------------
  // Loading, syncing and local storage
  // ---------------------------------------------------------------------------

  Future<void> initLoad() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    await _loadLocalCache();
    try {
      await syncFromSupabase();
      offline = false;
    } catch (e) {
      offline = true;
      // Only show the full error screen if there is nothing cached to show.
      if (allStudents.isEmpty && currentUser == null) {
        errorMessage =
            'Could not connect to the server.\nCheck your internet and try again.\n\n($e)';
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Pull-to-refresh / manual sync. Never throws.
  Future<bool> refresh() async {
    try {
      await syncFromSupabase();
      offline = false;
      notifyListeners();
      return true;
    } catch (_) {
      offline = true;
      notifyListeners();
      return false;
    }
  }

  List _decodeList(String? raw) {
    if (raw == null) return [];
    try {
      return List.from(jsonDecode(raw) as List);
    } catch (_) {
      return [];
    }
  }

  Map? _decodeMap(String? raw) {
    if (raw == null) return null;
    try {
      return Map.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      currentUser = _decodeMap(prefs.getString('teamup_current_user'));
      allStudents = _decodeList(prefs.getString('teamup_students'));
      myTeam = _decodeMap(prefs.getString('teamup_my_team'));
      teamMembers = _decodeList(prefs.getString('teamup_team_members'));
      sentRequests = _decodeList(prefs.getString('teamup_sent_requests'));
      receivedRequests =
          _decodeList(prefs.getString('teamup_received_requests'));
      teamTasks = _decodeList(prefs.getString('teamup_team_tasks'));
      teamMessages = _decodeList(prefs.getString('teamup_team_messages'));
      savedFilters = _decodeList(prefs.getString('teamup_saved_filters'));
    } catch (_) {
      // Corrupt cache should never crash the app.
    }
  }

  Future<void> _saveLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (currentUser != null) {
        await prefs.setString('teamup_current_user', jsonEncode(currentUser));
      }
      await prefs.setString('teamup_students', jsonEncode(allStudents));
      if (myTeam != null) {
        await prefs.setString('teamup_my_team', jsonEncode(myTeam));
      } else {
        await prefs.remove('teamup_my_team');
      }
      await prefs.setString('teamup_team_members', jsonEncode(teamMembers));
      await prefs.setString('teamup_sent_requests', jsonEncode(sentRequests));
      await prefs.setString(
          'teamup_received_requests', jsonEncode(receivedRequests));
      await prefs.setString('teamup_team_tasks', jsonEncode(teamTasks));
      await prefs.setString('teamup_team_messages', jsonEncode(teamMessages));
    } catch (_) {}
  }

  Future<void> syncFromSupabase() async {
    final studentsRes = await supabase
        .from('students')
        .select()
        .order('created_at', ascending: true);

    allStudents = List.from(studentsRes);

    Map? serverMe;
    for (final s in allStudents) {
      if (s['id'] == kMyId || s['is_current_user'] == true) {
        serverMe = Map.from(s);
        break;
      }
    }

    if (serverMe != null) {
      currentUser = serverMe;
    } else if (currentUser != null) {
      // Profile exists only on this device: push it to the server.
      try {
        await supabase.from('students').upsert(_profileRow(currentUser!));
        allStudents.add(currentUser);
      } catch (_) {}
    }

    final id = myId;

    final ownedTeams =
        await supabase.from('teams').select().eq('owner_id', id).limit(1);

    if (ownedTeams.isNotEmpty) {
      myTeam = Map.from(ownedTeams.first);
    } else {
      final memberOf = await supabase
          .from('team_members')
          .select('team_id, teams(*)')
          .eq('student_id', id)
          .limit(1);
      if (memberOf.isNotEmpty && memberOf.first['teams'] != null) {
        myTeam = Map.from(memberOf.first['teams']);
      } else {
        myTeam = null;
      }
    }

    if (myTeam != null) {
      final tId = myTeam!['id'];
      teamMembers = List.from(await supabase
          .from('team_members')
          .select('id, role, student_id, students(*)')
          .eq('team_id', tId));

      teamTasks = List.from(await supabase
          .from('team_tasks')
          .select()
          .eq('team_id', tId)
          .order('created_at', ascending: true));

      teamMessages = List.from(await supabase
          .from('team_messages')
          .select()
          .eq('team_id', tId)
          .order('created_at', ascending: true));
    } else {
      teamMembers = [];
      teamTasks = [];
      teamMessages = [];
    }

    sentRequests = List.from(await supabase
        .from('team_requests')
        .select('*, receiver:students!team_requests_to_student_id_fkey(*)')
        .eq('from_student_id', id)
        .order('created_at', ascending: false));

    receivedRequests = List.from(await supabase
        .from('team_requests')
        .select('*, sender:students!team_requests_from_student_id_fkey(*)')
        .eq('to_student_id', id)
        .order('created_at', ascending: false));

    await _saveLocalCache();
    notifyListeners();

    // Pending invites I sent: let the sample students answer them.
    for (final r in sentRequests) {
      if (effectiveStatus(r) == 'Pending') _scheduleAutoReply(r['id']);
    }
  }

  // ---------------------------------------------------------------------------
  // Module 1: Profile
  // ---------------------------------------------------------------------------

  int calculateProfileCompleteness(Map? user) {
    if (user == null) return 0;
    int score = 0;
    if ((user['name'] ?? '').toString().trim().isNotEmpty) score += 15;
    if ((user['department'] ?? '').toString().trim().isNotEmpty) score += 15;
    if (((user['semester'] ?? 0) as num) > 0) score += 10;
    if (((user['skills'] as List?) ?? []).isNotEmpty) score += 20;
    if (((user['interests'] as List?) ?? []).isNotEmpty) score += 15;
    if ((user['project_type'] ?? '').toString().isNotEmpty) score += 10;
    if ((user['availability'] ?? '').toString().isNotEmpty) score += 5;
    if ((user['bio'] ?? '').toString().trim().length >= 10) score += 10;
    return score.clamp(0, 100);
  }

  /// Tips shown under the completeness meter.
  List profileMissingItems(Map? user) {
    final List items = [];
    if (user == null) return ['Create your profile'];
    if ((user['bio'] ?? '').toString().trim().length < 10) {
      items.add('Write a short bio (10+ characters)');
    }
    if (((user['skills'] as List?) ?? []).length < 3) {
      items.add('Add at least 3 skills');
    }
    if (((user['interests'] as List?) ?? []).length < 2) {
      items.add('Add at least 2 interests');
    }
    return items;
  }

  Map _profileRow(Map p) => {
        'id': p['id'] ?? kMyId,
        'name': p['name'],
        'department': p['department'],
        'semester': p['semester'],
        'skills': p['skills'],
        'interests': p['interests'],
        'project_type': p['project_type'],
        'availability': p['availability'],
        'bio': p['bio'],
        'avatar_color': p['avatar_color'],
        'is_current_user': true,
      };

  /// Saves the profile on the device first (so it survives restarts even
  /// offline) and then on Supabase. Returns false if only the local save worked.
  Future<bool> saveProfile({
    required String name,
    required String department,
    required int semester,
    required List skills,
    required List interests,
    required String projectType,
    required String availability,
    required String bio,
    required String avatarColor,
  }) async {
    final isNewProfile = currentUser == null;
    final profile = {
      ...?currentUser,
      'id': currentUser?['id'] ?? kMyId,
      'name': name.trim(),
      'department': department,
      'semester': semester,
      'skills': List.from(skills),
      'interests': List.from(interests),
      'project_type': projectType,
      'availability': availability,
      'bio': bio.trim(),
      'avatar_color': avatarColor,
      'is_current_user': true,
    };

    currentUser = profile;
    final idx = allStudents.indexWhere((s) => s['id'] == profile['id']);
    if (idx >= 0) {
      allStudents[idx] = profile;
    } else {
      allStudents.add(profile);
    }
    await _saveLocalCache();
    notifyListeners();

    try {
      await supabase.from('students').upsert(_profileRow(profile));
      await syncFromSupabase();
      if (isNewProfile && receivedRequests.isEmpty) {
        await _seedSampleReceivedRequests();
      }
      offline = false;
      return true;
    } catch (_) {
      offline = true;
      notifyListeners();
      return false;
    }
  }

  /// Creates a few sample requests sent TO me, so accept / reject can be
  /// tested right after creating a profile.
  Future<void> _seedSampleReceivedRequests() async {
    try {
      final others = otherStudents.take(3).toList();
      if (others.isEmpty) return;
      const roles = ['Developer', 'UI/UX Designer', 'Report Writer'];
      final rows = <Map<String, dynamic>>[];
      for (int i = 0; i < others.length; i++) {
        final s = others[i];
        final skills = List.from(s['skills'] ?? []).take(2).join(' & ');
        rows.add({
          'from_student_id': s['id'],
          'to_student_id': myId,
          'team_id': null,
          'role_offered': roles[i % roles.length],
          'message':
              'Hi! I am ${s['name']}. I know $skills and would love to join your team.',
          'status': 'Pending',
        });
      }
      await supabase.from('team_requests').insert(rows);
      await syncFromSupabase();
    } catch (_) {
      // Sample data is optional; ignore failures.
    }
  }

  /// Adds a sample student profile (used by the "Add Student" sheet on Discover).
  Future<void> addNewStudent({
    required String name,
    required String department,
    required int semester,
    required List skills,
    required List interests,
    required String projectType,
    required String availability,
    required String bio,
    required String avatarColor,
  }) async {
    final id = 'stu_${DateTime.now().millisecondsSinceEpoch}';
    await supabase.from('students').insert({
      'id': id,
      'name': name.trim(),
      'department': department,
      'semester': semester,
      'skills': List.from(skills),
      'interests': List.from(interests),
      'project_type': projectType,
      'availability': availability,
      'bio': bio.trim().isEmpty
          ? '$department student, semester $semester.'
          : bio.trim(),
      'avatar_color': avatarColor,
      'is_current_user': false,
    });
    await syncFromSupabase();
  }

  // ---------------------------------------------------------------------------
  // Module 3: Smart Match
  // ---------------------------------------------------------------------------

  /// The skills "I need" from a teammate:
  /// - if I have a team: the team's needed skills that nobody covers yet
  /// - otherwise: every skill I don't have myself (complementary skills)
  List get skillsINeed {
    if (myTeam != null) {
      final needed = List.from(myTeam!['needed_skills'] ?? []);
      if (needed.isNotEmpty) return missingTeamSkills;
    }
    final mine = List.from(currentUser?['skills'] ?? []);
    return allSkillOptions.where((s) => !mine.contains(s)).toList();
  }

  /// Fixed lists plus anything found in the database (e.g. "FastAPI").
  List _union(List base, String key) {
    final out = [...base];
    for (final s in allStudents) {
      for (final v in List.from(s[key] ?? [])) {
        if (!out.contains(v)) out.add(v);
      }
    }
    return out;
  }

  List get allSkillOptions => _union(availableSkills, 'skills');
  List get allInterestOptions => _union(availableInterests, 'interests');

  List get allRoleOptions {
    final out = [...availableRoles];
    for (final r in List.from(myTeam?['needed_roles'] ?? [])) {
      if (!out.contains(r)) out.add(r);
    }
    return out;
  }

  /// Returns {score: int 0-100, reasons: List<String>, breakdown: List<Map>}.
  ///
  /// Score = skills (40) + interests (25) + project type (15)
  ///       + availability (10) + semester closeness (10).
  Map computeSmartMatch(Map candidate) {
    final me = currentUser;
    if (me == null) {
      return {
        'score': 0,
        'reasons': ['Create your profile to see personalised matches'],
        'breakdown': [],
      };
    }

    final myInterests = List.from(me['interests'] ?? []);
    final candSkills = List.from(candidate['skills'] ?? []);
    final candInterests = List.from(candidate['interests'] ?? []);
    final List reasons = [];
    final List breakdown = [];

    // 1) Skills I need (40)
    final hasTeamNeeds =
        myTeam != null && List.from(myTeam!['needed_skills'] ?? []).isNotEmpty;
    final need = skillsINeed;
    final brings = candSkills.where((s) => need.contains(s)).toList();
    int skillPts;
    if (hasTeamNeeds) {
      // Ratio of the team's missing skills that this person covers.
      skillPts = need.isEmpty
          ? kWeightSkills
          : ((brings.length / need.length).clamp(0.0, 1.0) * kWeightSkills)
              .round();
    } else {
      // No team needs defined: each new (complementary) skill = 1/3 of points.
      skillPts =
          ((brings.length / 3).clamp(0.0, 1.0) * kWeightSkills).round();
    }
    breakdown.add({
      'label': hasTeamNeeds ? 'Team needed skills' : 'New skills for you',
      'points': skillPts,
      'max': kWeightSkills,
    });
    if (brings.isNotEmpty) {
      reasons.add(hasTeamNeeds
          ? 'Has skills your team needs: ${brings.join(", ")}'
          : 'Brings skills you lack: ${brings.take(3).join(", ")}');
    }

    // 2) Shared interests (25)
    final shared = candInterests.where((i) => myInterests.contains(i)).toList();
    final intPts = myInterests.isEmpty
        ? 0
        : ((shared.length / (myInterests.length < 2 ? 1 : 2))
                    .clamp(0.0, 1.0) *
                kWeightInterests)
            .round();
    breakdown.add(
        {'label': 'Shared interests', 'points': intPts, 'max': kWeightInterests});
    if (shared.isNotEmpty) {
      reasons.add('Shared interests: ${shared.join(", ")}');
    }

    // 3) Same project type (15)
    final sameType = candidate['project_type'] == me['project_type'];
    final typePts = sameType ? kWeightProjectType : 0;
    breakdown.add({
      'label': 'Same project type',
      'points': typePts,
      'max': kWeightProjectType
    });
    if (sameType) reasons.add('Both want a ${candidate['project_type']}');

    // 4) Availability (10)
    final ca = (candidate['availability'] ?? '').toString();
    final ma = (me['availability'] ?? '').toString();
    int availPts = 0;
    if (ca == ma || ca == 'Flexible' || ma == 'Flexible') {
      availPts = kWeightAvailability;
    } else if ((ca.contains('Evenings') && ma.contains('Evenings')) ||
        (ca.contains('Weekends') && ma.contains('Weekends'))) {
      availPts = (kWeightAvailability / 2).round();
    }
    breakdown.add({
      'label': 'Availability overlap',
      'points': availPts,
      'max': kWeightAvailability
    });
    if (availPts == kWeightAvailability) {
      reasons.add('Free at the same time ($ca)');
    }

    // 5) Semester closeness (10)
    final cs = ((candidate['semester'] ?? 0) as num).toInt();
    final ms = ((me['semester'] ?? 0) as num).toInt();
    final diff = (cs - ms).abs();
    final semPts = diff == 0
        ? kWeightSemester
        : diff == 1
            ? (kWeightSemester * 0.6).round()
            : diff == 2
                ? (kWeightSemester * 0.3).round()
                : 0;
    breakdown.add(
        {'label': 'Same semester', 'points': semPts, 'max': kWeightSemester});
    if (diff == 0) reasons.add('Same semester ($cs)');

    if (reasons.isEmpty) {
      reasons.add('Low overlap with your profile');
    }

    final total = skillPts + intPts + typePts + availPts + semPts;
    return {
      'score': total.clamp(0, 100),
      'reasons': reasons,
      'breakdown': breakdown,
    };
  }

  List get otherStudents =>
      allStudents.where((s) => s['id'] != myId).toList();

  List get filteredStudents {
    final q = searchQuery.trim().toLowerCase();
    final list = otherStudents.where((s) {
      final name = (s['name'] ?? '').toString().toLowerCase();
      final dept = (s['department'] ?? '').toString();
      final sem = ((s['semester'] ?? 0) as num).toInt();
      final pType = (s['project_type'] ?? '').toString();
      final skills = List.from(s['skills'] ?? []);

      if (q.isNotEmpty) {
        final inName = name.contains(q);
        final inSkill =
            skills.any((sk) => sk.toString().toLowerCase().contains(q));
        final inDept = dept.toLowerCase().contains(q);
        if (!inName && !inSkill && !inDept) return false;
      }
      if (selectedDept != 'All' && dept != selectedDept) return false;
      if (selectedSemester != 0 && sem != selectedSemester) return false;
      if (selectedSkill != 'All' && !skills.contains(selectedSkill)) {
        return false;
      }
      if (selectedProjectType != 'All' && pType != selectedProjectType) {
        return false;
      }
      return true;
    }).toList();

    if (sortBy == 'Match Score') {
      final scores = {
        for (final s in list) s['id']: computeSmartMatch(s)['score'] as int
      };
      list.sort((a, b) => scores[b['id']]!.compareTo(scores[a['id']]!));
    } else if (sortBy == 'Semester') {
      list.sort((a, b) => ((b['semester'] ?? 0) as num)
          .compareTo((a['semester'] ?? 0) as num));
    } else {
      list.sort(
          (a, b) => a['name'].toString().compareTo(b['name'].toString()));
    }
    return list;
  }

  List get bestMatches {
    final memberIds = teamMembers.map((m) => m['student_id']).toSet();
    final list =
        otherStudents.where((s) => !memberIds.contains(s['id'])).toList();
    final scores = {
      for (final s in list) s['id']: computeSmartMatch(s)['score'] as int
    };
    list.sort((a, b) => scores[b['id']]!.compareTo(scores[a['id']]!));
    return list;
  }

  /// Team needed skills that no current member has.
  List get missingTeamSkills {
    if (myTeam == null) return [];
    final needed = List.from(myTeam!['needed_skills'] ?? []);
    final covered = <dynamic>{};
    for (final m in teamMembers) {
      final st = m['students'];
      if (st != null) covered.addAll(List.from(st['skills'] ?? []));
    }
    return needed.where((sk) => !covered.contains(sk)).toList();
  }

  /// Best candidate (highest score) that has [skill], or null.
  Map? bestCandidateForSkill(String skill) {
    for (final s in bestMatches) {
      if (List.from(s['skills'] ?? []).contains(skill)) return s;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Saved filters (Discover bonus)
  // ---------------------------------------------------------------------------

  Future<void> saveCurrentFilter(String name) async {
    savedFilters.removeWhere((f) => f['name'] == name);
    savedFilters.add({
      'name': name,
      'dept': selectedDept,
      'sem': selectedSemester,
      'skill': selectedSkill,
      'type': selectedProjectType,
      'sort': sortBy,
    });
    await _persistFilters();
    notifyListeners();
  }

  void applySavedFilter(Map f) {
    selectedDept = (f['dept'] ?? 'All').toString();
    selectedSemester = ((f['sem'] ?? 0) as num).toInt();
    selectedSkill = (f['skill'] ?? 'All').toString();
    selectedProjectType = (f['type'] ?? 'All').toString();
    sortBy = (f['sort'] ?? 'Match Score').toString();
    notifyListeners();
  }

  Future<void> deleteSavedFilter(Map f) async {
    savedFilters.removeWhere((x) => x['name'] == f['name']);
    await _persistFilters();
    notifyListeners();
  }

  Future<void> _persistFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('teamup_saved_filters', jsonEncode(savedFilters));
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Module 4: Team requests
  // ---------------------------------------------------------------------------

  DateTime? _parseDate(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

  /// Expiry time: the `expires_at` column, or created_at + [kRequestExpiry].
  DateTime? expiryOf(Map r) {
    final exp = _parseDate(r['expires_at']);
    if (exp != null) return exp;
    return _parseDate(r['created_at'])?.add(kRequestExpiry);
  }

  /// "Pending" requests past their expiry time count as "Expired".
  String effectiveStatus(Map r) {
    final status = (r['status'] ?? 'Pending').toString();
    if (status != 'Pending') return status;
    final exp = expiryOf(r);
    if (exp != null && DateTime.now().isAfter(exp)) return 'Expired';
    return 'Pending';
  }

  /// Human text like "Expires in 3 days" for pending requests.
  String? expiryText(Map r) {
    if (effectiveStatus(r) != 'Pending') return null;
    final exp = expiryOf(r);
    if (exp == null) return null;
    final left = exp.difference(DateTime.now());
    if (left.inDays >= 1) {
      return 'Expires in ${left.inDays} day${left.inDays == 1 ? "" : "s"}';
    }
    if (left.inHours >= 1) return 'Expires in ${left.inHours}h';
    return 'Expires soon';
  }

  bool hasPendingRequestTo(String studentId) => sentRequests.any((r) =>
      r['to_student_id'] == studentId && effectiveStatus(r) == 'Pending');

  Future<void> sendTeamRequest({
    required String toStudentId,
    required String roleOffered,
    required String message,
  }) async {
    if (currentUser == null) {
      throw Exception('Create your profile first.');
    }
    if (hasPendingRequestTo(toStudentId)) {
      throw Exception('You already have a pending request to this student.');
    }
    await supabase.from('team_requests').insert({
      'from_student_id': myId,
      'to_student_id': toStudentId,
      'team_id': myTeam?['id'],
      'role_offered': roleOffered,
      'message': message.trim().isEmpty
          ? 'Hi! Would love to team up with you for our project.'
          : message.trim(),
      'status': 'Pending',
    });
    // syncFromSupabase also schedules the automatic reply for this invite.
    await syncFromSupabase();
  }

  // ---------------------------------------------------------------------------
  // Auto reply: the other student answers your invite
  // ---------------------------------------------------------------------------

  void _scheduleAutoReply(dynamic requestId) {
    if (requestId == null || _autoReplyScheduled.contains(requestId)) return;
    _autoReplyScheduled.add(requestId);
    Future.delayed(kAutoReplyDelay, () => _autoReply(requestId));
  }

  /// The invited student accepts if your match score is high enough,
  /// otherwise rejects. Accepted students join your team.
  Future<void> _autoReply(dynamic requestId) async {
    try {
      Map? req;
      for (final r in sentRequests) {
        if (r['id'] == requestId) req = r;
      }
      // Cancelled, expired or already answered -> nothing to do.
      if (req == null || effectiveStatus(req) != 'Pending') return;

      Map? student = req['receiver'] is Map ? req['receiver'] : null;
      if (student == null) {
        for (final s in allStudents) {
          if (s['id'] == req['to_student_id']) student = s;
        }
      }
      final name = (student?['name'] ?? 'Student').toString();
      final score = student == null
          ? 0
          : computeSmartMatch(student)['score'] as int;

      // If I am only a member (not the lead) the student can't be added.
      final canJoin = myTeam == null || isTeamOwner;
      final accept = canJoin && score >= kAutoAcceptScore;

      await simulateReply(req, accept);
      notice = accept
          ? '$name accepted your request and joined your team! ($score% match)'
          : '$name rejected your request ($score% match)';
      notifyListeners();
    } catch (_) {
      // Offline: try again on the next sync.
      _autoReplyScheduled.remove(requestId);
    }
  }

  /// Makes sure I own (or am in) a team and returns its id.
  Future<String> _ensureMyTeam() async {
    if (myTeam != null) return myTeam!['id'].toString();
    final first = (currentUser?['name'] ?? 'My').toString().split(' ').first;
    await createOrUpdateTeam(
      title: "$first's Team",
      projectType: (currentUser?['project_type'] ?? 'FYP').toString(),
      neededRoles: [],
      neededSkills: [],
    );
    return myTeam!['id'].toString();
  }

  Future<void> _addMember(String teamId, dynamic studentId, String role) async {
    await supabase.from('team_members').upsert({
      'team_id': teamId,
      'student_id': studentId,
      'role': role,
    }, onConflict: 'team_id,student_id');

    // Fill the open role if it was listed.
    if (myTeam != null && myTeam!['id'].toString() == teamId) {
      final openRoles = List.from(myTeam!['needed_roles'] ?? []);
      if (openRoles.remove(role)) {
        await supabase
            .from('teams')
            .update({'needed_roles': openRoles}).eq('id', teamId);
      }
    }
  }

  /// Accept or reject a request I RECEIVED.
  ///
  /// Accepting:
  /// - if I lead a team -> the sender joins my team
  /// - if I have no team and the sender attached their team -> I join it
  /// - if neither of us has a team -> a team is created for me and the sender joins
  Future<void> respondToRequest({
    required Map request,
    required bool accept,
  }) async {
    if (effectiveStatus(request) != 'Pending') {
      throw Exception('This request is no longer pending.');
    }

    if (accept) {
      final role = (request['role_offered'] ?? 'Member').toString();
      final reqTeamId = request['team_id'];

      if (myTeam != null && !isTeamOwner) {
        throw Exception(
            'You are already a member of "${myTeam!['title']}". Leave it first to accept.');
      }

      if (myTeam == null && reqTeamId != null) {
        // Join the sender's team.
        await _addMember(reqTeamId.toString(), myId, role);
      } else {
        final teamId = await _ensureMyTeam();
        await _addMember(teamId, request['from_student_id'], role);
      }
    }

    await supabase
        .from('team_requests')
        .update({'status': accept ? 'Accepted' : 'Rejected'}).eq(
            'id', request['id']);

    await syncFromSupabase();
  }

  /// Cancel a request I SENT (kept in the list with status "Cancelled").
  Future<void> cancelSentRequest(dynamic requestId) async {
    await supabase
        .from('team_requests')
        .update({'status': 'Cancelled'}).eq('id', requestId);
    await syncFromSupabase();
  }

  /// Demo helper: sample students can't answer by themselves, so the sender can
  /// simulate their reply to show the full flow during the demo.
  Future<void> simulateReply(Map request, bool accept) async {
    if (accept) {
      if (myTeam != null && !isTeamOwner) {
        throw Exception('Only the team lead can add members.');
      }
      final teamId = await _ensureMyTeam();
      await _addMember(teamId, request['to_student_id'],
          (request['role_offered'] ?? 'Member').toString());
    }
    await supabase
        .from('team_requests')
        .update({'status': accept ? 'Accepted' : 'Rejected'}).eq(
            'id', request['id']);
    await syncFromSupabase();
  }

  // ---------------------------------------------------------------------------
  // Module 5: My Team
  // ---------------------------------------------------------------------------

  Future<void> createOrUpdateTeam({
    required String title,
    required String projectType,
    required List neededRoles,
    required List neededSkills,
  }) async {
    if (currentUser == null) throw Exception('Create your profile first.');
    if (title.trim().isEmpty) throw Exception('Team title cannot be empty.');

    final teamId =
        myTeam?['id'] ?? 'team_${DateTime.now().millisecondsSinceEpoch}';

    await supabase.from('teams').upsert({
      'id': teamId,
      'title': title.trim(),
      'project_type': projectType,
      'owner_id': myTeam?['owner_id'] ?? myId,
      'needed_roles': neededRoles,
      'needed_skills': neededSkills,
    });

    if (myTeam == null) {
      await supabase.from('team_members').upsert({
        'team_id': teamId,
        'student_id': myId,
        'role': 'Team Lead',
      }, onConflict: 'team_id,student_id');
    }

    await syncFromSupabase();
  }

  Future<void> leaveOrDeleteTeam() async {
    if (myTeam == null) return;
    final tId = myTeam!['id'];
    if (isTeamOwner) {
      // Delete children first in case the DB has no ON DELETE CASCADE.
      await supabase.from('team_messages').delete().eq('team_id', tId);
      await supabase.from('team_tasks').delete().eq('team_id', tId);
      await supabase.from('team_members').delete().eq('team_id', tId);
      try {
        await supabase
            .from('team_requests')
            .update({'team_id': null}).eq('team_id', tId);
      } catch (_) {}
      await supabase.from('teams').delete().eq('id', tId);
    } else {
      await supabase
          .from('team_members')
          .delete()
          .eq('team_id', tId)
          .eq('student_id', myId);
    }
    myTeam = null;
    await syncFromSupabase();
  }

  Future<void> removeMember(Map member) async {
    if (!isTeamOwner || member['student_id'] == myId) return;
    await supabase.from('team_members').delete().eq('id', member['id']);
    // Re-open the role so it can be filled again.
    final role = (member['role'] ?? '').toString();
    if (role.isNotEmpty && role != 'Member') {
      final openRoles = List.from(myTeam!['needed_roles'] ?? []);
      if (!openRoles.contains(role)) {
        openRoles.add(role);
        await supabase
            .from('teams')
            .update({'needed_roles': openRoles}).eq('id', myTeam!['id']);
      }
    }
    await syncFromSupabase();
  }

  Future<void> addTeamTask(String title) async {
    if (myTeam == null || title.trim().isEmpty) return;
    await supabase.from('team_tasks').insert({
      'team_id': myTeam!['id'],
      'title': title.trim(),
      'is_done': false,
    });
    await syncFromSupabase();
  }

  Future<void> toggleTeamTask(Map task) async {
    await supabase
        .from('team_tasks')
        .update({'is_done': !(task['is_done'] == true)}).eq('id', task['id']);
    await syncFromSupabase();
  }

  Future<void> deleteTeamTask(Map task) async {
    await supabase.from('team_tasks').delete().eq('id', task['id']);
    await syncFromSupabase();
  }

  Future<void> sendTeamChat(String text) async {
    if (myTeam == null || text.trim().isEmpty) return;
    await supabase.from('team_messages').insert({
      'team_id': myTeam!['id'],
      'sender_name': currentUser?['name'] ?? 'Me',
      'text': text.trim(),
    });
    await syncFromSupabase();
  }
}