import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

/// Main scaffold with role-tailored navigation bars and user profile header.
class MainShell extends StatelessWidget {
  final Widget child;
  final String location;

  const MainShell({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final isOwner = user?.isOwner ?? false;

    final sellerDestinations = const [
      _NavDestination(path: '/pos', icon: Icons.point_of_sale_rounded, label: 'Касса'),
      _NavDestination(path: '/products', icon: Icons.inventory_2_rounded, label: 'Товары'),
      _NavDestination(
        path: '/my-earnings',
        icon: Icons.account_balance_wallet_rounded,
        label: 'Заработок',
      ),
    ];

    final ownerDestinations = const [
      _NavDestination(path: '/dashboard', icon: Icons.dashboard_rounded, label: 'Обзор'),
      _NavDestination(path: '/pos', icon: Icons.point_of_sale_rounded, label: 'Касса'),
      _NavDestination(path: '/products', icon: Icons.inventory_2_rounded, label: 'Товары'),
      _NavDestination(path: '/expenses', icon: Icons.receipt_long_rounded, label: 'Расходы'),
      _NavDestination(path: '/sellers', icon: Icons.people_alt_rounded, label: 'Персонал'),
    ];

    final destinations = isOwner ? ownerDestinations : sellerDestinations;

    int currentIndex = destinations.indexWhere((d) => location.startsWith(d.path));
    if (currentIndex == -1) currentIndex = 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.point_of_sale_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isOwner ? 'POS Владелец' : 'POS Кассир',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (user != null) ...[
              const SizedBox(width: 12),
              _buildRoleBadge(user),
            ],
          ],
        ),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.analytics_rounded, color: Color(0xFFF59E0B)),
              tooltip: 'Аналитика',
              onPressed: () => context.go('/analytics'),
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF94A3B8)),
            tooltip: 'Выйти из системы',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final target = destinations[index].path;
          context.go(target);
        },
        backgroundColor: const Color(0xFF0F172A),
        indicatorColor: const Color(0xFF6366F1).withValues(alpha: 0.25),
        destinations: destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon, color: const Color(0xFF94A3B8)),
                selectedIcon: Icon(d.icon, color: const Color(0xFF818CF8)),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildRoleBadge(UserEntity user) {
    final isOwner = user.isOwner;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOwner
            ? const Color(0xFF6366F1).withValues(alpha: 0.2)
            : const Color(0xFF10B981).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isOwner
              ? const Color(0xFF818CF8).withValues(alpha: 0.4)
              : const Color(0xFF34D399).withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        isOwner ? 'Владелец' : 'Продавец',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isOwner ? const Color(0xFFA5B4FC) : const Color(0xFF6EE7B7),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Выйти из системы?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Текущая сессия будет завершена. Потребуется повторный ввод пароля.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}

class _NavDestination {
  final String path;
  final IconData icon;
  final String label;

  const _NavDestination({
    required this.path,
    required this.icon,
    required this.label,
  });
}
