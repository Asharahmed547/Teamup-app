import 'package:flutter/material.dart';
import 'app_state.dart';

// =============================================================================
// Design tokens
// =============================================================================

const kPrimaryColor = Color(0xFF4F46E5);
const kSecondaryColor = Color(0xFF7C3AED);
const kAccentColor = Color(0xFF10B981);
const kWarnColor = Color(0xFFF59E0B);
const kDangerColor = Color(0xFFEF4444);
const kInk = Color(0xFF0F172A);
const kMuted = Color(0xFF64748B);
const kBorder = Color(0xFFE5E7EF);
const kBg = Color(0xFFF4F5FA);
const kSoftPrimary = Color(0xFFEEF0FF);

const kGradient = LinearGradient(
  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kHeaderGradient = LinearGradient(
  colors: [Color(0xFF4338CA), Color(0xFF6D28D9), Color(0xFF9333EA)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

List<BoxShadow> get kSoftShadow => [
      BoxShadow(
        color: const Color(0xFF1E1B4B).withValues(alpha: 0.06),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];

/// Colour for a match score: green = great, indigo = good, amber = ok, grey = low.
Color scoreColor(int score) {
  if (score >= 70) return kAccentColor;
  if (score >= 50) return kPrimaryColor;
  if (score >= 35) return kWarnColor;
  return const Color(0xFF94A3B8);
}

String scoreLabel(int score) {
  if (score >= 70) return 'Great match';
  if (score >= 50) return 'Good match';
  if (score >= 35) return 'Fair match';
  return 'Low match';
}

Color parseHexColor(String? hex) {
  try {
    final clean = (hex ?? '#4F46E5').replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {
    return kPrimaryColor;
  }
}

/// App-wide Material 3 theme.
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kPrimaryColor,
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    surface: Colors.white,
  );
  final radius12 = BorderRadius.circular(14);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: kBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: kBg,
      surfaceTintColor: Colors.transparent,
      foregroundColor: kInk,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: kInk,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.w800, color: kInk),
      titleMedium: TextStyle(fontWeight: FontWeight.w700, color: kInk),
      bodyMedium: TextStyle(color: kInk),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: radius12,
        borderSide: const BorderSide(color: kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius12,
        borderSide: const BorderSide(color: kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius12,
        borderSide: const BorderSide(color: kPrimaryColor, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius12,
        borderSide: const BorderSide(color: kDangerColor),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: radius12),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: radius12),
        side: const BorderSide(color: kBorder),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: kSoftPrimary,
      side: const BorderSide(color: kBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: const TextStyle(fontSize: 12.5, color: kInk),
      checkmarkColor: kPrimaryColor,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: kSoftPrimary,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
            fontSize: 11.5,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? kPrimaryColor : kMuted,
          )),
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? kPrimaryColor : kMuted,
          )),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kInk,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13.5),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      dividerColor: Colors.transparent,
      labelColor: kPrimaryColor,
      unselectedLabelColor: kMuted,
    ),
    dividerTheme: const DividerThemeData(color: kBorder, thickness: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: kPrimaryColor,
    ),
  );
}

// =============================================================================
// Small reusable widgets
// =============================================================================

String initialOf(dynamic name) {
  final n = (name ?? '').toString().trim();
  return n.isEmpty ? '?' : n.substring(0, 1).toUpperCase();
}

/// Fades + slides a child in. [index] staggers items in a list.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int index;
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final delay = (index.clamp(0, 8)) * 45;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Animated circular match score.
class ScoreRing extends StatelessWidget {
  final int score;
  final double size;
  final bool light;
  const ScoreRing(
      {super.key, required this.score, this.size = 52, this.light = false});

  @override
  Widget build(BuildContext context) {
    final color = light ? Colors.white : scoreColor(score);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score / 100),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: v,
                strokeWidth: size * 0.1,
                strokeCap: StrokeCap.round,
                backgroundColor: light
                    ? Colors.white.withValues(alpha: 0.25)
                    : color.withValues(alpha: 0.14),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            Text(
              '${(v * 100).round()}%',
              style: TextStyle(
                fontSize: size * 0.26,
                fontWeight: FontWeight.w800,
                color: light ? Colors.white : kInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient header used at the top of every main page.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget> actions;
  final Widget? bottom;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actions = const [],
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: kHeaderGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -40,
            top: -30,
            child: _bubble(140, 0.08),
          ),
          Positioned(
            right: 60,
            bottom: -50,
            child: _bubble(110, 0.06),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 12, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (icon != null) ...[
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            if (subtitle != null)
                              Text(
                                subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                      ...actions,
                    ],
                  ),
                  if (bottom != null) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: bottom!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );
}

/// Round translucent icon button for use on gradient headers.
class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final int badge;

  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Material(
        color: Colors.white.withValues(alpha: 0.16),
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Badge(
            isLabelVisible: badge > 0,
            label: Text('$badge'),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
        ),
      ),
    );
  }
}

/// Small stat shown in headers, e.g. "18 Students".
class StatPill extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const StatPill(
      {super.key, required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small rounded tag used for skills, interests and info.
class TagChip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;
  const TagChip(
    this.text, {
    super.key,
    this.bg = kSoftPrimary,
    this.fg = const Color(0xFF3730A3),
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11.5, color: fg, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

void showAppSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF34D399), size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(msg)),
        ],
      ),
    ));
}

void showErrorSnack(BuildContext context, Object error) {
  var msg = error.toString();
  if (msg.startsWith('Exception: ')) msg = msg.substring(11);
  if (msg.contains('SocketException') ||
      msg.contains('ClientException') ||
      msg.contains('Failed host lookup')) {
    msg = 'No internet connection. Please try again.';
  }
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      backgroundColor: const Color(0xFFB91C1C),
      content: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg, maxLines: 3, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    ));
}

/// Asks the user to confirm a destructive action. Returns true if confirmed.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = true,
}) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: (destructive ? kDangerColor : kPrimaryColor)
              .withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          destructive ? Icons.warning_amber_rounded : Icons.help_outline,
          color: destructive ? kDangerColor : kPrimaryColor,
          size: 28,
        ),
      ),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: kMuted, height: 1.4),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('No, go back'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                style: destructive
                    ? FilledButton.styleFrom(backgroundColor: kDangerColor)
                    : null,
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(confirmLabel,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return res == true;
}

class AppAvatar extends StatelessWidget {
  final Map? student;
  final double size;
  const AppAvatar({super.key, required this.student, this.size = 42});

  @override
  Widget build(BuildContext context) {
    final base = parseHexColor(student?['avatar_color']);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [base, Color.lerp(base, Colors.white, 0.35)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initialOf(student?['name']),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  /// Set to false when placed inside another scroll view (e.g. a ListView).
  final bool scrollable;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kPrimaryColor.withValues(alpha: 0.14),
                    kSecondaryColor.withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: kPrimaryColor),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800, color: kInk),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: kMuted, fontSize: 13.5, height: 1.4),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 18),
              action!,
            ],
          ],
        ),
      ),
    );
    if (!scrollable) return Center(child: content);
    return Center(child: SingleChildScrollView(child: content));
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late Color bg, fg;
    late IconData icon;
    switch (status) {
      case 'Accepted':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        icon = Icons.check_circle_rounded;
        break;
      case 'Rejected':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        icon = Icons.cancel_rounded;
        break;
      case 'Cancelled':
      case 'Expired':
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        icon = status == 'Expired' ? Icons.timer_off_rounded : Icons.block;
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        icon = Icons.hourglass_top_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w800, color: fg),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: kGradient,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: kInk),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// White rounded card used on all pages.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kBorder.withValues(alpha: 0.7)),
        boxShadow: kSoftShadow,
      ),
      // Material ancestor so ListTiles / InkWells inside the card paint correctly.
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

// =============================================================================
// Invite sheet (send a team request)
// =============================================================================

void showSendRequestDialog(BuildContext context, Map student) {
  final state = TeamUpState.instance;
  if (!state.hasProfile) {
    showErrorSnack(context, 'Create your profile first (Profile tab).');
    return;
  }
  final roleOptions = state.allRoleOptions;
  final openRoles = List.from(state.myTeam?['needed_roles'] ?? []);
  String selectedRole =
      (openRoles.isNotEmpty ? openRoles.first : roleOptions.first).toString();
  final score = state.computeSmartMatch(student)['score'] as int;
  final msgCtrl = TextEditingController(
    text:
        'Hi ${student['name']}! Your ${List.from(student['skills'] ?? []).take(2).join(" & ")} skills would be a great fit for our project.',
  );
  bool sending = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppAvatar(student: student, size: 54),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invite ${student['name']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: kInk),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${student['department']} • Semester ${student['semester']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: kMuted, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  ScoreRing(score: score, size: 50),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Role you are offering',
                  style: TextStyle(fontWeight: FontWeight.w800, color: kInk)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: roleOptions.map((r) {
                  final sel = r.toString() == selectedRole;
                  final isOpen = openRoles.contains(r);
                  return ChoiceChip(
                    label: Text('$r${isOpen ? "  • open" : ""}'),
                    selected: sel,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                      color: sel ? kPrimaryColor : kInk,
                    ),
                    side: BorderSide(color: sel ? kPrimaryColor : kBorder),
                    onSelected: (_) =>
                        setSheet(() => selectedRole = r.toString()),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              const Text('Personal message',
                  style: TextStyle(fontWeight: FontWeight.w800, color: kInk)),
              const SizedBox(height: 10),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                maxLength: 250,
                decoration: const InputDecoration(
                  hintText: 'Why should they join your team?',
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kSoftPrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded,
                        color: kPrimaryColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'They will reply in a few seconds. A $kAutoAcceptScore%+ match means they accept.',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF3730A3)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: sending
                      ? null
                      : () async {
                          setSheet(() => sending = true);
                          try {
                            await state.sendTeamRequest(
                              toStudentId: student['id'].toString(),
                              roleOffered: selectedRole,
                              message: msgCtrl.text,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              showAppSnack(
                                  context, 'Invite sent to ${student['name']}!');
                            }
                          } catch (e) {
                            setSheet(() => sending = false);
                            if (context.mounted) showErrorSnack(context, e);
                          }
                        },
                  icon: sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(sending ? 'Sending...' : 'Send invite'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// =============================================================================
// Student card (Discover + Best Match)
// =============================================================================

class StudentProfileCard extends StatelessWidget {
  final Map student;
  final bool showMatchReason;
  final int? rank;

  const StudentProfileCard({
    super.key,
    required this.student,
    this.showMatchReason = false,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final state = TeamUpState.instance;
    final match = state.computeSmartMatch(student);
    final score = match['score'] as int;
    final reasons = List.from(match['reasons'] ?? []);
    final skills = List.from(student['skills'] ?? []);
    final interests = List.from(student['interests'] ?? []);
    final need = state.skillsINeed;

    final alreadySent = state.hasPendingRequestTo(student['id'].toString());
    final alreadyMember =
        state.teamMembers.any((m) => m['student_id'] == student['id']);
    final highlight = showMatchReason && score >= 70;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: highlight ? kGradient : null,
        ),
        padding: EdgeInsets.all(highlight ? 1.6 : 0),
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          onTap: () => showMatchBreakdown(context, student),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AppAvatar(student: student, size: 52),
                      if (rank != null)
                        Positioned(
                          top: -6,
                          left: -6,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: rank == 1
                                  ? const Color(0xFFF59E0B)
                                  : rank == 2
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFFB45309),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              '$rank',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${student['name']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16.5,
                            color: kInk,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${student['department']} • Sem ${student['semester']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: kMuted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          scoreLabel(score),
                          style: TextStyle(
                            color: scoreColor(score),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ScoreRing(score: score, size: 52),
                ],
              ),
              if ((student['bio'] ?? '').toString().trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '${student['bio']}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13.2,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...skills.take(5).map((sk) {
                    final needed = need.contains(sk);
                    return TagChip(
                      '$sk',
                      icon: needed ? Icons.star_rounded : null,
                      bg: needed ? const Color(0xFFDCFCE7) : kSoftPrimary,
                      fg: needed
                          ? const Color(0xFF166534)
                          : const Color(0xFF3730A3),
                    );
                  }),
                  if (skills.length > 5)
                    TagChip('+${skills.length - 5}',
                        bg: const Color(0xFFF1F5F9), fg: kMuted),
                ],
              ),
              if (interests.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.favorite_rounded,
                        size: 14, color: Color(0xFFEC4899)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        interests.join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: kMuted),
                      ),
                    ),
                  ],
                ),
              ],
              if (showMatchReason) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 15, color: Color(0xFF059669)),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Why you match',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ),
                          Text(
                            'See breakdown',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF059669)
                                  .withValues(alpha: 0.85),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              size: 16, color: Color(0xFF059669)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...reasons.take(3).map((r) => Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 1),
                                  child: Icon(Icons.check_rounded,
                                      size: 14, color: Color(0xFF059669)),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '$r',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF065F46),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  Flexible(
                    child: TagChip(
                      '${student['project_type']}',
                      icon: Icons.school_rounded,
                      bg: const Color(0xFFF1F5F9),
                      fg: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: TagChip(
                      '${student['availability']}',
                      icon: Icons.schedule_rounded,
                      bg: const Color(0xFFF1F5F9),
                      fg: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (alreadyMember)
                    const TagChip(
                      'Teammate',
                      icon: Icons.check_circle_rounded,
                      bg: Color(0xFFDCFCE7),
                      fg: Color(0xFF15803D),
                    )
                  else if (alreadySent)
                    const TagChip(
                      'Pending',
                      icon: Icons.hourglass_top_rounded,
                      bg: Color(0xFFFEF3C7),
                      fg: Color(0xFFB45309),
                    )
                  else
                    _InviteButton(
                        onTap: () => showSendRequestDialog(context, student)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _InviteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add_alt_1_rounded,
                    size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Invite',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
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

// =============================================================================
// Match breakdown sheet
// =============================================================================

/// Bottom sheet that explains how a match score was calculated.
void showMatchBreakdown(BuildContext context, Map student) {
  final state = TeamUpState.instance;
  final m = state.computeSmartMatch(student);
  final score = m['score'] as int;
  final breakdown = List.from(m['breakdown'] ?? []);
  final reasons = List.from(m['reasons'] ?? []);
  final isMember =
      state.teamMembers.any((x) => x['student_id'] == student['id']);
  final pending = state.hasPendingRequestTo(student['id'].toString());

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
            Row(
              children: [
                AppAvatar(student: student, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${student['name']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: kInk),
                      ),
                      Text(
                        scoreLabel(score),
                        style: TextStyle(
                            color: scoreColor(score),
                            fontWeight: FontWeight.w800,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ScoreRing(score: score, size: 60),
              ],
            ),
            if (reasons.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: reasons
                    .map((r) => TagChip('$r',
                        icon: Icons.check_rounded,
                        bg: const Color(0xFFF0FDF4),
                        fg: const Color(0xFF166534)))
                    .toList(),
              ),
            ],
            const SizedBox(height: 18),
            const Text('Score breakdown',
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15, color: kInk)),
            const SizedBox(height: 12),
            if (breakdown.isEmpty)
              const Text('Create your profile to see a score breakdown.',
                  style: TextStyle(color: kMuted)),
            ...breakdown.map((b) {
              final pts = (b['points'] as num).toInt();
              final max = (b['max'] as num).toInt();
              final ratio = max == 0 ? 0.0 : pts / max;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('${b['label']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: kInk)),
                        ),
                        Text('$pts / $max',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: kInk)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: ratio),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: v,
                          minHeight: 9,
                          backgroundColor: const Color(0xFFEEF0F6),
                          color: ratio >= 0.7
                              ? kAccentColor
                              : ratio >= 0.4
                                  ? kPrimaryColor
                                  : kWarnColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Score = skills you need (40) + shared interests (25) + same '
                'project type (15) + availability (10) + same semester (10).',
                style: TextStyle(fontSize: 12, color: kMuted, height: 1.4),
              ),
            ),
            if (!isMember && !pending && state.hasProfile) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    showSendRequestDialog(context, student);
                  },
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: Text('Invite ${student['name']}'),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
