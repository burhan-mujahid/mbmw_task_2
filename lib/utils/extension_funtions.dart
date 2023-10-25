import 'package:flutter/material.dart';

extension ValidationExtensions on String {
  bool isValidEmail() {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  bool isValidPassword() {
    return RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{6,}$')
        .hasMatch(this);
  }

  String? validateFirstName() {
    if (this.isEmpty) {
      return "Please enter your first name";
    }
    return null;
  }

  String? validateLastName() {
    if (this.isEmpty) {
      return "Please enter your last name";
    }
    return null;
  }

  String? validateEmail() {
    if (this.isEmpty) {
      return "Please enter your email";
    }
    if (!this.isValidEmail()) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword() {
    if (this.isEmpty) {
      return "Please enter your password";
    }

    if (this.length < 8) {
      return "Password must be at least 8 characters long";
    }
    if (!this.isValidPassword()) {
      return 'Password must contain at least one letter and one number';
    }
    return null;
  }
}

extension ErrorContextExtensions on BuildContext {
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message),
      ),
    );
  }
}

extension SuccessContextExtensions on BuildContext {
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blueAccent,
        content: Text(message),
      ),
    );
  }
}
