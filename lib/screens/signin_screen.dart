import '../constants.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/custom_font.dart';
import '../widgets/custom_inkwell_button.dart';
import '../widgets/custom_textformfield.dart';
import '../services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _userService.loginUser(
        usernameController.text.trim(),
        passwordController.text,
      );

      await _userService.saveUserData(userData);
      final user = await _userService.getUser();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: user,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      customDialog(
        context,
        title: 'Error',
        content: 'Username and password does not match',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 480.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: CustomFont(
                            text: AppStrings.appName,
                            fontSize: ScreenUtil().setSp(38),
                            color: FB_PRIMARY,
                            fontFamily: 'Klavika',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 28.h),
                        CustomTextformfield(
                          height: ScreenUtil().setHeight(12),
                          width: ScreenUtil().setWidth(14),
                          controller: usernameController,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter username' : null,
                          onSaved: (value) => usernameController.text = value!,
                          fontSize: ScreenUtil().setSp(15),
                          fontColor: colors.onSurface,
                          hintTextSize: ScreenUtil().setSp(15),
                          hintText: 'Username',
                          fillColor: colors.surface,
                        ),
                        SizedBox(height: 12.h),
                        CustomTextformfield(
                          height: ScreenUtil().setHeight(12),
                          width: ScreenUtil().setWidth(14),
                          controller: passwordController,
                          isObscure: _obscurePassword,
                          validator: (value) => value!.isEmpty
                              ? 'Enter your password'
                              : null,
                          onSaved: (value) => passwordController.text = value!,
                          fontSize: ScreenUtil().setSp(15),
                          fontColor: colors.onSurface,
                          hintTextSize: ScreenUtil().setSp(15),
                          hintText: 'Password',
                          fillColor: colors.surface,
                          toggleIcon: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        SizedBox(height: 28.h),
                        CustomInkwellButton(
                          onTap: _isLoading ? null : _login,
                          bgColor: FB_PRIMARY,
                          height: ScreenUtil().setHeight(44),
                          width: double.infinity,
                          buttonName: 'Login',
                          fontSize: ScreenUtil().setSp(15),
                          loading: _isLoading,
                        ),
                        SizedBox(height: 24.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          color: colors.surface,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'You don\'t have an account? ',
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: ScreenUtil().setSp(12),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.popAndPushNamed(
                                  context,
                                  '/signup',
                                ),
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    color: FB_PRIMARY,
                                    fontSize: ScreenUtil().setSp(15),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
