import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../screens/home_screen.dart';
import '../screens/signin_screen.dart';
import '../screens/signup_screen.dart';
import 'constants.dart';
import 'models/user.dart';
import 'providers/theme_provider.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  } catch (error) {
    debugPrint('Could not set preferred orientation: $error');
  }

  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (error) {
    debugPrint('Could not load assets/.env; using DummyJSON: $error');
    dotenv.loadFromString(envString: 'HOST=https://dummyjson.com');
  }

  runApp(const TurnoFacebook());
}

class TurnoFacebook extends StatelessWidget {
  const TurnoFacebook({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: ScreenUtilInit(
        designSize: const Size(412, 715),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (build, child) {
          final themeModel = build.watch<ThemeProvider>();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeModel.lightTheme,
            darkTheme: themeModel.darkTheme,
            themeMode: themeModel.isDark ? ThemeMode.dark : ThemeMode.light,
            title: AppStrings.appName,
            initialRoute: '/splash',
            routes: {
              '/home': (context) {
                final arguments = ModalRoute.of(context)?.settings.arguments;

                if (arguments is User) {
                  return HomeScreen(user: arguments);
                }

                return const SignInScreen();
              },
              '/settings': (context) => const SettingsScreen(),
              '/signin': (context) => const SignInScreen(),
              '/signup': (context) => const SignUpScreen(),
              '/splash': (context) => const SplashScreen(),
            },
          );
        },
      ),
    );
  }
}
