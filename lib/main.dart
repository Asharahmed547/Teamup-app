import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_state.dart';
import 'theme.dart';
import 'discover_page.dart';
import 'best_match_page.dart';
import 'requests_page.dart';
import 'my_team_page.dart';
import 'profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  await TeamUpState.instance.initLoad();
  runApp(const TeamUpApp());
}

class TeamUpApp extends StatelessWidget {
  const TeamUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeamUp',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _tabIndex = 0;
  final _state = TeamUpState.instance;

  @override
  void initState() {
    super.initState();
    _state.addListener(_refresh);
    // First run: no profile yet -> open the Profile tab to create one.
    if (!_state.hasProfile) _tabIndex = 4;
  }

  void _goTo(int i) => setState(() => _tabIndex = i);

  @override
  void dispose() {
    _state.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {});
    final msg = _state.notice;
    if (msg != null) {
      _state.notice = null;
      final accepted = msg.contains('accepted');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          duration: const Duration(seconds: 5),
          backgroundColor:
              accepted ? const Color(0xFF065F46) : const Color(0xFF7F1D1D),
          content: Row(
            children: [
              Icon(
                accepted ? Icons.celebration_rounded : Icons.cancel_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(msg)),
            ],
          ),
          action: SnackBarAction(
            label: 'MY TEAM',
            textColor: Colors.white,
            onPressed: () => _goTo(3),
          ),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DiscoverPage(),
      BestMatchPage(
        onGoToProfile: () => _goTo(4),
        onGoToTeam: () => _goTo(3),
      ),
      const RequestsPage(),
      MyTeamPage(
        onGoToProfile: () => _goTo(4),
        onFindTeammates: () => _goTo(1),
      ),
      const ProfilePage(),
    ];

    final unread = _state.unreadReceivedCount;

    Widget body;
    if (_state.loading) {
      body = const _SplashLoader();
    } else if (_state.errorMessage != null) {
      body = EmptyStateView(
        icon: Icons.cloud_off_rounded,
        title: 'Can\'t reach the server',
        subtitle: _state.errorMessage,
        action: FilledButton.icon(
          onPressed: () => _state.initLoad(),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try again'),
        ),
      );
    } else {
      body = Column(
        children: [
          if (_state.offline) _OfflineBanner(onRetry: () => _state.refresh()),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: _state.offline,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.02),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_tabIndex),
                  child: pages[_tabIndex],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: _state.loading || _state.errorMessage != null
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E1B4B).withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: _tabIndex,
                onDestinationSelected: _goTo,
                labelBehavior:
                    NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.explore_outlined),
                    selectedIcon: Icon(Icons.explore_rounded),
                    label: 'Discover',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.auto_awesome_outlined),
                    selectedIcon: Icon(Icons.auto_awesome),
                    label: 'Matches',
                  ),
                  NavigationDestination(
                    icon: Badge(
                      isLabelVisible: unread > 0,
                      label: Text('$unread'),
                      child: const Icon(Icons.mail_outline_rounded),
                    ),
                    selectedIcon: Badge(
                      isLabelVisible: unread > 0,
                      label: Text('$unread'),
                      child: const Icon(Icons.mail_rounded),
                    ),
                    label: 'Requests',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.groups_outlined),
                    selectedIcon: Icon(Icons.groups_rounded),
                    label: 'My Team',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
    );
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: kHeaderGradient),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.hub_rounded,
                  color: Colors.white, size: 52),
            ),
            const SizedBox(height: 18),
            const Text(
              'TeamUp',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Find the right teammates',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final VoidCallback onRetry;
  const _OfflineBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFEF3C7),
      child: SafeArea(
        bottom: false,
        child: InkWell(
          onTap: onRetry,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.cloud_off_rounded,
                    size: 17, color: Color(0xFFB45309)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Offline - showing data saved on this device',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
                Text(
                  'RETRY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB45309),
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