import '../widgets/auth_widgets.dart';
import '../widgets/custom_dialogs.dart';
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
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
    FocusScope.of(context).unfocus();
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

      Navigator.pushReplacementNamed(context, '/home', arguments: user);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      customDialog(
        context,
        title: 'Sign in failed',
        content: 'Your username or email and password do not match',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to keep scrolling with NansuX',
      footer: AuthSwitchPrompt(
        question: "Don't have an account?",
        action: 'Create one',
        onTap: () => Navigator.popAndPushNamed(context, '/signup'),
      ),
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: usernameController,
                label: 'Username or email',
                icon: Icons.person_outline,
                autofillHints: const [AutofillHints.username],
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Enter your username or email'
                    : null,
              ),
              SizedBox(height: 14.h),
              AuthTextField(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onToggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onSubmitted: (_) => _login(),
                validator: (value) =>
                    (value ?? '').isEmpty ? 'Enter your password' : null,
              ),
              SizedBox(height: 24.h),
              AuthPrimaryButton(
                label: 'Sign in',
                loading: _isLoading,
                onPressed: _login,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
