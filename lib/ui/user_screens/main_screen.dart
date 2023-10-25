import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mbmw_task_2/utils/extension_funtions.dart';
import 'package:provider/provider.dart';

import '../../widgets/credential_input_field.dart';
import '../auth_screens/login_screen.dart';
import 'details_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _formKey = GlobalKey<FormState>();
  late MainScreenProvider provider;

  @override
  void initState() {
    super.initState();
    provider = MainScreenProvider();
    provider.initializeData();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider.value(
      value: provider,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('Main Screen'),
          leading: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DetailsScreen()));
              },
              icon: const Icon(Icons.person)),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text("Log Out"),
                  )
                ];
              },
              onSelected: (value) {
                if (value == 'logout') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            child: const Text("No"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text("Yes"),
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              context.showSuccessSnackBar('Logout Success');
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                                (Route<dynamic> route) => false,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
        body: provider == null
            ? Container()
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenWidth * 0.02),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.05),
                        Consumer<MainScreenProvider>(
                          builder: (context, provider, child) =>
                              CredentialInputField(
                            keyboardType: TextInputType.text,
                            hintText: 'First name',
                            prefixIcon: Icon(Icons.person),
                            controller: provider.firstnameController,
                            enabled: provider.isEditable,
                            validator: (value) => value?.validateFirstName(),
                            inputFormatter:
                                FilteringTextInputFormatter.singleLineFormatter,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Consumer<MainScreenProvider>(
                          builder: (context, provider, child) =>
                              CredentialInputField(
                            keyboardType: TextInputType.text,
                            hintText: 'Last Name',
                            prefixIcon: Icon(Icons.person),
                            controller: provider.lastnameController,
                            enabled: provider.isEditable,
                            validator: (value) => value?.validateLastName(),
                            inputFormatter:
                                FilteringTextInputFormatter.singleLineFormatter,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Consumer<MainScreenProvider>(
                          builder: (context, provider, child) =>
                              CredentialInputField(
                            keyboardType: TextInputType.emailAddress,
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            controller: provider.emailController,
                            enabled: provider.isEditable,
                            validator: (value) => value?.validateEmail(),
                            inputFormatter:
                                FilteringTextInputFormatter.singleLineFormatter,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Consumer<MainScreenProvider>(
                          builder: (context, provider, child) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Visibility(
                                  visible: !provider.isEditable,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        provider.setIsEditable(true);
                                      });
                                    },
                                    child: Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.035),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: provider.isEditable,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        await provider.updatedData();
                                        provider.setIsEditable(false);
                                        context.showSuccessSnackBar(
                                            'User data updated');
                                      }
                                    },
                                    child: Text(
                                      'Done',
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.035),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class MainScreenProvider with ChangeNotifier {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isEditable = false;

  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> initializeData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    final CollectionReference<Map<String, dynamic>> databaseRef =
        FirebaseFirestore.instance.collection('Users');

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await databaseRef.doc(currentUser!.uid).get();
    firstnameController.text = snapshot.data()?['first_name'] ?? '';
    lastnameController.text = snapshot.data()?['last_name'] ?? '';
    emailController.text = snapshot.data()?['email'] ?? '';
  }

  Future<void> updatedData() async {
    final CollectionReference<Map<String, dynamic>> databaseRef =
        FirebaseFirestore.instance.collection('Users');

    final User? currentUser = FirebaseAuth.instance.currentUser;

    await databaseRef.doc(currentUser!.uid).update({
      'uid': currentUser!.uid,
      'first_name': firstnameController.text,
      'last_name': lastnameController.text,
      'email': emailController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void setIsEditable(bool value) {
    isEditable = value;
    notifyListeners();
  }

}
