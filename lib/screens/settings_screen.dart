import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        themeProvider.isDark
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        size: 24.sp,
                      ),

                      SizedBox(width: 16.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              themeProvider.isDark
                                  ? 'Dark Mode'
                                  : 'Light Mode',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              themeProvider.isDark
                                  ? 'Dark theme enabled'
                                  : 'Light theme enabled',
                              style: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Switch(
                        value: themeProvider.isDark,
                        onChanged: (_) {
                          themeProvider.toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}