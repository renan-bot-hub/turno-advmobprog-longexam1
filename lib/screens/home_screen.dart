import '../models/user.dart';
import '../screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../screens/newsfeed_screen.dart';
import '../screens/notification_screen.dart';
import '../services/user_service.dart';
import '../widgets/custom_font.dart';

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: Drawer(
        backgroundColor: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(12),
                  ScreenUtil().setHeight(50),
                  ScreenUtil().setWidth(12),
                  0,
                ),
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(10)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: colors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: theme.scaffoldBackgroundColor,
                              radius: 20,
                              backgroundImage: NetworkImage(widget.user.image),
                            ),
                            SizedBox(width: ScreenUtil().setWidth(12)),
                            CustomFont(
                              text: widget.user.fullName,
                              fontSize: ScreenUtil().setSp(18),
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),

                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    onTap: () {
                      Navigator.pop(context);
                      _pageController.jumpToPage(2);
                    },
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: FB_PRIMARY,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await UserService().logout();

                    if (!context.mounted) return;

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/signin',
                      (route) => false,
                    );
                  },
                  child: const Text('Log out'),
                ),
              ),
            ),

            SizedBox(height: ScreenUtil().setHeight(13)),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: colors.surface,
        shadowColor: Colors.black,
        surfaceTintColor: theme.scaffoldBackgroundColor,
        elevation: 1,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: CustomFont(
          text: _getAppBarTitle(_selectedIndex),
          fontSize: ScreenUtil().setSp(25),
          color: _getAppBarTitleColor(_selectedIndex),
          fontFamily: 'Klavika',
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          NewsFeedScreen(user: widget.user),
          const NotificationScreen(),
          ProfileScreen(user: widget.user),
        ],
        onPageChanged: (page) {
          setState(() {
            _selectedIndex = page;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onTappedBar,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
      ),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return AppStrings.appName;
      case 1:
        return 'Notifications';
      case 2:
        return widget.user.fullName;
      default:
        return '';
    }
  }

  Color _getAppBarTitleColor(int index) {
    switch (index) {
      case 0:
        return FB_PRIMARY;
      case 1:
        return Theme.of(context).colorScheme.onSurface;
      case 2:
        return Theme.of(context).colorScheme.onSurface;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }
}
