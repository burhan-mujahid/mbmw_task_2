import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mbmw_task_2/utils/extension_funtions.dart';

import '../../widgets/auth_button.dart';
import '../../widgets/auth_screen_heading.dart';
import '../../widgets/credential_input_field.dart';
import '../../widgets/password_input_field.dart';
import '../user_screens/main_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;

  void signUp() async {
    setState(() {
      loading = true;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.toString(),
        password: passwordController.text.toString(),
      );

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await addUserInfoToFirestore(currentUser);
        context.showSuccessSnackBar('User Successfully Registered');
        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      context.showErrorSnackBar(e.message!);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> addUserInfoToFirestore(User currentUser) async {
    final CollectionReference<Map<String, dynamic>> databaseRef =
        FirebaseFirestore.instance.collection('Users');
    try {
      await databaseRef.doc(currentUser.uid).set({
        'uid': currentUser.uid,
        'first_name': firstnameController.text.trim(),
        'last_name': lastnameController.text.trim(),
        'email': emailController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      context.showErrorSnackBar('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                  heading: 'Sign Up', subHeading: 'Create your account'),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CredentialInputField(
                      keyboardType: TextInputType.text,
                      hintText: 'First Name',
                      prefixIcon: Icon(Icons.person),
                      controller: firstnameController,
                      validator: (value) => value?.validateFirstName(),
                      inputFormatter:
                          FilteringTextInputFormatter.singleLineFormatter,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    CredentialInputField(
                      keyboardType: TextInputType.text,
                      hintText: 'Last Name',
                      prefixIcon: Icon(Icons.person),
                      controller: lastnameController,
                      validator: (value) => value?.validateLastName(),
                      inputFormatter:
                          FilteringTextInputFormatter.singleLineFormatter,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    CredentialInputField(
                      keyboardType: TextInputType.emailAddress,
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      controller: emailController,
                      validator: (value) => value?.validateEmail(),
                      inputFormatter:
                          FilteringTextInputFormatter.singleLineFormatter,
                    ),
                    SizedBox(height: screenHeight * 0.02),
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
              SizedBox(height: screenHeight * 0.04),
              AuthButton(
                title: 'Sign Up',
                loading: loading,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    signUp();
                  }
                },
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text('Log in'),
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
