import '../constants.dart';
import '../services/user_service.dart';
import '../widgets/custom_font.dart';
import '../widgets/custom_inkwell_button.dart';
import '../widgets/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/custom_dialogs.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController mobilenumController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> register() async {
    if (firstnameController.text.isEmpty ||
        lastnameController.text.isEmpty ||
        mobilenumController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmpasswordController.text.isEmpty) {
      customDialog(context, title: 'Error', content: 'All fields are required');
      return;
    }

    if (mobilenumController.text.length != 11 ||
        !RegExp(r'^[0-9]+$').hasMatch(mobilenumController.text)) {
      customDialog(
        context,
        title: 'Error',
        content: 'Enter a valid 11-digit mobile number',
      );
      return;
    }

    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );

    if (!passwordRegex.hasMatch(passwordController.text)) {
      customDialog(
        context,
        title: 'Error',
        content:
            'Password must be at least 8 characters long, contain at least one uppercase letter, one lowercase letter, one number, and one special character.',
      );
      return;
    }

    if (passwordController.text != confirmpasswordController.text) {
      customDialog(context, title: 'Error', content: 'Passwords do not match');
      return;
    }

    try {
      await UserService().registerUser(
        firstName: firstnameController.text.trim(),
        lastName: lastnameController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text,
        email: '${usernameController.text.trim()}@turno.local',
        mobile: mobilenumController.text.trim(),
      );

      if (!mounted) return;

      customDialog(
        context,
        title: 'Success',
        content: 'Registration successful! You can now sign in.',
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.popAndPushNamed(context, '/signin');
      });
    } catch (error) {
      if (!mounted) return;
      customDialog(
        context,
        title: 'Error',
        content: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 480.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
              Center(
                child: CustomFont(
                text: 'Register Here',
                fontSize: ScreenUtil().setSp(36),
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                ),
              ),
              SizedBox(height: 22.h),
              CustomTextformfield(
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                onSaved: null,
                fontColor: Colors.grey,
                hintText: 'First Name',
                validator: (value) => null,
                hintTextSize: ScreenUtil().setSp(15),
                fontSize: ScreenUtil().setSp(15),
                controller: firstnameController,
                fillColor: FB_LIGHT_PRIMARY,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              CustomTextformfield(
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                onSaved: null,
                fontColor: Colors.grey,
                hintText: 'Last Name',
                validator: (value) => null,
                hintTextSize: ScreenUtil().setSp(15),
                fontSize: ScreenUtil().setSp(15),
                controller: lastnameController,
                fillColor: FB_LIGHT_PRIMARY,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              CustomTextformfield(
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                onSaved: null,
                fontColor: Colors.grey,
                hintText: 'Mobile Number',
                validator: (value) => null,
                hintTextSize: ScreenUtil().setSp(15),
                fontSize: ScreenUtil().setSp(15),
                controller: mobilenumController,
                fillColor: FB_LIGHT_PRIMARY,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              CustomTextformfield(
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                onSaved: null,
                fontColor: Colors.grey,
                hintText: 'Username',
                validator: (value) => null,
                hintTextSize: ScreenUtil().setSp(15),
                fontSize: ScreenUtil().setSp(15),
                controller: usernameController,
                fillColor: FB_LIGHT_PRIMARY,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              CustomTextformfield(
                isObscure: _obscurePassword,
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                onSaved: null,
                fontColor: Colors.grey,
                hintText: 'Password',
                validator: (value) => null,
                hintTextSize: ScreenUtil().setSp(15),
                fontSize: ScreenUtil().setSp(15),
                controller: passwordController,
                fillColor: FB_LIGHT_PRIMARY,
                toggleIcon: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              Text(
                '(Password must be at least 8 characters long, contain at least one uppercase letter, one lowercase letter, one number, and one special character.)',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: ScreenUtil().setSp(10),
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              CustomTextformfield(
                isObscure: _obscureConfirmPassword,
                hintText: 'Confirm Password',
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                onSaved: null,
                fontColor: Colors.grey,
                validator: (value) => null,
                hintTextSize: ScreenUtil().setSp(15),
                fontSize: ScreenUtil().setSp(15),
                controller: confirmpasswordController,
                fillColor: FB_LIGHT_PRIMARY,
                toggleIcon: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              SizedBox(height: 20.h),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'You have an account already? ',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(15),
                      color: Colors.grey,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.popAndPushNamed(context, '/signin'),
                    child: Text(
                      'Login here',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(15),
                        color: FB_PRIMARY,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              CustomInkwellButton(
                onTap: () => register(),
                bgColor: FB_PRIMARY,
                height: ScreenUtil().setHeight(45),
                width: ScreenUtil().screenWidth,
                fontSize: ScreenUtil().setSp(15),
                fontWeight: FontWeight.bold,
                buttonName: 'Submit',
              ),
            ],
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