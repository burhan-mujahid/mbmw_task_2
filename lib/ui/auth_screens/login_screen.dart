import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mbmw_task_2/ui/auth_screens/signup_screen.dart';
import 'package:mbmw_task_2/utils/extension_funtions.dart';

import '../../widgets/auth_button.dart';
import '../../widgets/auth_screen_heading.dart';
import '../../widgets/credential_input_field.dart';
import '../../widgets/password_input_field.dart';
import '../user_screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void login() {
    setState(() {
      loading = true;
    });
    _auth
        .signInWithEmailAndPassword(
      email: emailController.text.toString(),
      password: passwordController.text.toString(),
    )
        .then((value) {
      setState(() {
        loading = false;
      });

      context.showSuccessSnackBar('Login Successful');
      //Utils().toastMessage('Login Successful');
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainScreen()));
    }).onError((error, stackTrace) {
      debugPrint(error.toString());
      context.showErrorSnackBar(error.toString());
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.1,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AuthScreenHeading(
                  heading: 'Login', subHeading: 'Login to your account'),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CredentialInputField(
                      keyboardType: TextInputType.emailAddress,
                      hintText: 'Enter Email',
                      prefixIcon: Icon(Icons.email),
                      controller: emailController,
                      validator: (value) => value?.validateEmail(),
                      inputFormatter:
                          FilteringTextInputFormatter.singleLineFormatter,
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    PasswordInputField(
                      keyboardType: TextInputType.visiblePassword,
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      controller: passwordController,
                      validator: (value) => value?.validatePassword(),
                      inputFormatter:
                          FilteringTextInputFormatter.singleLineFormatter,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.05,
              ),
              AuthButton(
                title: 'Login',
                loading: loading,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    login();
                    (Route<dynamic> route) => false;
                  }
                },
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                    child: Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
