import 'package:flutter/material.dart';
import 'dart:ui';
import '../models.dart';
import '../storage.dart';
import 'dashboard.dart';
import 'cravings_list.dart';
import 'progress.dart';
import 'milestones.dart';
import 'sos_breathe.dart';

class HomeShell extends StatefulWidget {
  final UserProfile profile;
  final StorageService storage;
  const HomeShell({super.key, required this.profile, required this.storage});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  late UserProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(
        profile: _profile,
        storage: widget.storage,
        onProfileUpdated: (p) => setState(() => _profile = p),
      ),
      CravingsListScreen(storage: widget.storage),
      ProgressScreen(profile: _profile, storage: widget.storage),
      MilestonesScreen(profile: _profile),
    ];
    const double navReserved = 120; // space to avoid overlap with floating glass bar and SOS island
    return Scaffold(
      extendBody: true,
      body: Padding(
        padding: const EdgeInsets.only(bottom: navReserved),
        child: pages[index],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: SizedBox(
          height: 96,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: _GlassBottomNav(index: index, onTap: (i) => setState(() => index = i)),
              ),
              Positioned(
                top: -22,
                left: 0,
                right: 0,
                child: Center(
                  child: _PulsingFab(
                    onPressed: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => SosBreatheScreen(storage: widget.storage)));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingFab extends StatefulWidget {
  final VoidCallback onPressed;
  const _PulsingFab({required this.onPressed});
  @override
  State<_PulsingFab> createState() => _PulsingFabState();
}

class _PulsingFabState extends State<_PulsingFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.9),
            Theme.of(context).colorScheme.secondary.withOpacity(0.9),
          ]),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 12)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onPressed,
            child: const Center(child: Icon(Icons.self_improvement, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}


class _GlassBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _GlassBottomNav({required this.index, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.4),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 20)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavIcon(
                label: 'Home',
                icon: index == 0 ? Icons.home : Icons.home_outlined,
                active: index == 0,
                onTap: () => onTap(0),
              ),
              _NavIcon(
                label: 'Cravings',
                icon: index == 1 ? Icons.local_fire_department : Icons.local_fire_department_outlined,
                active: index == 1,
                onTap: () => onTap(1),
              ),
              const SizedBox(width: 64),
              _NavIcon(
                label: 'Progress',
                icon: index == 2 ? Icons.show_chart : Icons.show_chart_outlined,
                active: index == 2,
                onTap: () => onTap(2),
              ),
              _NavIcon(
                label: 'Milestones',
                icon: index == 3 ? Icons.emoji_events : Icons.emoji_events_outlined,
                active: index == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _NavIcon({required this.label, required this.icon, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurface.withOpacity(0.6);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? activeColor : inactiveColor),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: active ? activeColor : inactiveColor, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

