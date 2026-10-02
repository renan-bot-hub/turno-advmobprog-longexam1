import '../models/user.dart';
import '../providers/theme_provider.dart';
import '../screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../screens/newsfeed_screen.dart';
import '../screens/notification_screen.dart';
import '../services/user_service.dart';
import '../widgets/nansux_logo.dart';
import '../widgets/user_avatar.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can sign back in any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: FB_PRIMARY),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await UserService().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: _buildDrawer(theme),
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black26,
        titleSpacing: 0,
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Menu',
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _selectedIndex == 0
              ? const NansuXLogo(key: ValueKey('logo'), size: 30)
              : Text(
                  _selectedIndex == 1 ? 'Notifications' : 'Profile',
                  key: ValueKey(_selectedIndex),
                  style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          Padding(
            padding: EdgeInsets.only(right: 12.w, left: 4.w),
            child: GestureDetector(
              onTap: () => _goTo(2),
              child: UserAvatar(user: widget.user, radius: 16),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) => setState(() => _selectedIndex = page),
        children: <Widget>[
          NewsFeedScreen(user: widget.user),
          const NotificationScreen(),
          ProfileScreen(user: widget.user),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _goTo,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: FB_PRIMARY.withValues(alpha: 0.15),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: FB_PRIMARY),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded, color: FB_PRIMARY),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: UserAvatar(user: widget.user, radius: 12),
            selectedIcon: UserAvatar(
              user: widget.user,
              radius: 12,
              borderWidth: 2,
              borderColor: FB_PRIMARY,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(ThemeData theme) {
    final colors = theme.colorScheme;
    final themeProvider = context.watch<ThemeProvider>();

    Widget item(
      IconData icon,
      String label,
      VoidCallback onTap, {
      bool selected = false,
    }) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
        child: ListTile(
          leading: Icon(icon, color: selected ? FB_PRIMARY : null),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? FB_PRIMARY : colors.onSurface,
            ),
          ),
          selected: selected,
          selectedTileColor: FB_PRIMARY.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: onTap,
        ),
      );
    }

    void navigate(int index) {
      Navigator.pop(context);
      _goTo(index);
    }

    return Drawer(
      backgroundColor: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ProfileCover(user: widget.user, aspectRatio: 16 / 7),
              Positioned(
                left: 20.w,
                bottom: -32,
                child: UserAvatar(
                  user: widget.user,
                  radius: 34,
                  borderWidth: 3,
                  borderColor: colors.surface,
                ),
              ),
            ],
          ),
          SizedBox(height: 42.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.fullName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  widget.user.email.isNotEmpty
                      ? widget.user.email
                      : '@${widget.user.username}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Divider(color: colors.onSurface.withValues(alpha: 0.08)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                item(
                  Icons.home_outlined,
                  'Home',
                  () => navigate(0),
                  selected: _selectedIndex == 0,
                ),
                item(
                  Icons.notifications_none_rounded,
                  'Notifications',
                  () => navigate(1),
                  selected: _selectedIndex == 1,
                ),
                item(
                  Icons.person_outline,
                  'Profile',
                  () => navigate(2),
                  selected: _selectedIndex == 2,
                ),
                item(Icons.settings_outlined, 'Settings', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                }),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: SwitchListTile(
                    secondary: Icon(
                      themeProvider.isDark
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                    ),
                    title: const Text('Dark mode'),
                    value: themeProvider.isDark,
                    activeThumbColor: FB_PRIMARY,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(
                      color: colors.error.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmLogout();
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log out'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
