import '../constants.dart';
import '../services/user_service.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const List<String> _genders = ['Male', 'Female', 'Prefer not to say'];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController mobilenumController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();

  String? _gender;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    for (final controller in [
      firstnameController,
      lastnameController,
      ageController,
      mobilenumController,
      usernameController,
      emailController,
      passwordController,
      confirmpasswordController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value, String field) =>
      (value ?? '').trim().isEmpty ? '$field is required' : null;

  String? _validateAge(String? value) {
    final age = int.tryParse((value ?? '').trim());
    if (age == null) return 'Age is required';
    if (age < 13) return 'You must be at least 13 years old';
    if (age > 120) return 'Enter a valid age';
    return null;
  }

  String? _validateMobile(String? value) {
    final mobile = (value ?? '').trim();
    if (mobile.isEmpty) return 'Mobile number is required';
    if (!RegExp(r'^09\d{9}$').hasMatch(mobile)) {
      return 'Enter a valid 11-digit number (09XXXXXXXXX)';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Email is required';
    if (!UserService.isValidEmail(email)) return 'Enter a valid email address';
    return null;
  }

  String? _validateUsername(String? value) {
    final username = (value ?? '').trim();
    if (username.isEmpty) return 'Username is required';
    if (username.length < 3) return 'Use at least 3 characters';
    if (!RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(username)) {
      return 'Only letters, numbers, _ and . are allowed';
    }
    return null;
  }

  List<(String, bool)> get _passwordRules {
    final password = passwordController.text;
    return [
      ('8+ characters', password.length >= 8),
      ('Uppercase', RegExp(r'[A-Z]').hasMatch(password)),
      ('Lowercase', RegExp(r'[a-z]').hasMatch(password)),
      ('Number', RegExp(r'\d').hasMatch(password)),
      ('Symbol (@\$!%*?&)', RegExp(r'[@$!%*?&]').hasMatch(password)),
    ];
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'Password is required';
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return passwordRegex.hasMatch(value!)
        ? null
        : 'Password does not meet all requirements';
  }

  Future<void> register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await UserService().registerUser(
        firstName: firstnameController.text.trim(),
        lastName: lastnameController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text,
        email: emailController.text.trim(),
        mobile: mobilenumController.text.trim(),
        age: int.parse(ageController.text.trim()),
        gender: _gender!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! You can now sign in.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacementNamed(context, '/signin');
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      customDialog(
        context,
        title: 'Sign up failed',
        content: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: 14.h);
    final sectionGap = SizedBox(height: 22.h);

    return AuthScaffold(
      title: 'Create your account',
      subtitle: 'Join NansuX in less than a minute',
      footer: AuthSwitchPrompt(
        question: 'Already have an account?',
        action: 'Sign in',
        onTap: () => Navigator.popAndPushNamed(context, '/signin'),
      ),
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthSectionLabel('Personal info'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AuthTextField(
                      controller: firstnameController,
                      label: 'First name',
                      icon: Icons.badge_outlined,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.givenName],
                      validator: (v) => _required(v, 'First name'),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: AuthTextField(
                      controller: lastnameController,
                      label: 'Last name',
                      icon: Icons.badge_outlined,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.familyName],
                      validator: (v) => _required(v, 'Last name'),
                    ),
                  ),
                ],
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: AuthTextField(
                      controller: ageController,
                      label: 'Age',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: _validateAge,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 3,
                    child: AuthTextField(
                      controller: mobilenumController,
                      label: 'Mobile number',
                      hint: '09XXXXXXXXX',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      validator: _validateMobile,
                    ),
                  ),
                ],
              ),
              gap,
              _GenderField(
                options: _genders,
                value: _gender,
                onChanged: (value) => setState(() => _gender = value),
              ),
              sectionGap,
              const AuthSectionLabel('Account'),
              AuthTextField(
                controller: emailController,
                label: 'Email',
                hint: 'you@example.com',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: _validateEmail,
              ),
              gap,
              AuthTextField(
                controller: usernameController,
                label: 'Username',
                icon: Icons.person_outline,
                autofillHints: const [AutofillHints.newUsername],
                validator: _validateUsername,
              ),
              gap,
              AuthTextField(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.newPassword],
                onToggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onChanged: (_) => setState(() {}),
                validator: _validatePassword,
              ),
              SizedBox(height: 10.h),
              _PasswordChecklist(rules: _passwordRules),
              gap,
              AuthTextField(
                controller: confirmpasswordController,
                label: 'Confirm password',
                icon: Icons.lock_reset_outlined,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onToggleObscure: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
                onSubmitted: (_) => register(),
                validator: (value) {
                  if ((value ?? '').isEmpty) return 'Confirm your password';
                  return value != passwordController.text
                      ? 'Passwords do not match'
                      : null;
                },
              ),
              SizedBox(height: 24.h),
              AuthPrimaryButton(
                label: 'Create account',
                loading: _isLoading,
                onPressed: register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderField extends StatelessWidget {
  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;

  const _GenderField({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FormField<String>(
      initialValue: value,
      validator: (_) => value == null ? 'Please select your gender' : null,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 2.w, bottom: 8.h),
            child: Row(
              children: [
                Icon(
                  Icons.wc_outlined,
                  size: 18.sp,
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
                SizedBox(width: 6.w),
                Text(
                  'Gender',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colors.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final option in options)
                ChoiceChip(
                  label: Text(option),
                  selected: value == option,
                  showCheckmark: false,
                  selectedColor: FB_PRIMARY,
                  labelStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: value == option ? Colors.white : colors.onSurface,
                  ),
                  side: BorderSide(
                    color: value == option
                        ? FB_PRIMARY
                        : colors.onSurface.withValues(alpha: 0.15),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (_) {
                    onChanged(option);
                    field.didChange(option);
                  },
                ),
            ],
          ),
          if (field.hasError)
            Padding(
              padding: EdgeInsets.only(left: 12.w, top: 6.h),
              child: Text(
                field.errorText!,
                style: TextStyle(color: colors.error, fontSize: 12.sp),
              ),
            ),
        ],
      ),
    );
  }
}

class _PasswordChecklist extends StatelessWidget {
  final List<(String, bool)> rules;
  const _PasswordChecklist({required this.rules});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.5);

    return Wrap(
      spacing: 12.w,
      runSpacing: 6.h,
      children: [
        for (final (label, met) in rules)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                met ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 14.sp,
                color: met ? const Color(0xFF23A55A) : muted,
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: met ? const Color(0xFF23A55A) : muted,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
