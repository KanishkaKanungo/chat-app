import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  var _email;
  var _pass;
  File? _selectedImage;
  var _isAuthenticated = false;
  @override

  // ignore: override_on_non_overriding_member
  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || !_isLogin && _selectedImage == null) {
      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
    }

    try {
      if (!_isAuthenticated) {
        setState(() {
          _isAuthenticated = true;
        });
      }
      if (_isLogin) {
        // ignore: unused_local_variable
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _email, password: _pass);
      } else {
        // ignore: unused_local_variable
        final userCredential = await _firebase.createUserWithEmailAndPassword(
            email: _email, password: _pass);

        final awsFile = AWSFile.fromPath(_selectedImage!.path);
        final generatedKey =
            'uploads/${DateTime.now().millisecondsSinceEpoch}.jpg';

        final uploadResult =
            await Amplify.Storage.uploadFile(localFile: awsFile, key: generatedKey);
            print('File uploaded successfully: ${generatedKey}');
        
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {}
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).clearSnackBars();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication failed.')));

      setState(() {
        _isAuthenticated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    left: 20, right: 20, top: 30, bottom: 20),
                width: 200,
                child: Image.asset('lib/assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 20, left: 20, top: 20, bottom: 10),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLogin)
                              UserImagePicker(
                                onSelectImage: (pickedImage) {
                                  _selectedImage = pickedImage;
                                },
                              ),
                            const SizedBox(
                              height: 8,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Email',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  prefixIcon: const Icon(Icons.mail)),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              autofillHints: const [AutofillHints.email],
                              textCapitalization: TextCapitalization.none,
                              onSaved: (newValue) {
                                _email = newValue;
                              },
                              validator: (value) {
                                if (value == null ||
                                    !EmailValidator.validate(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Password',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  prefixIcon: const Icon(Icons.lock)),
                              obscureText: true,
                              onSaved: (newValue) {
                                _pass = newValue;
                              },
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be atleast 6 characters long';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            if (_isAuthenticated)
                              const CircularProgressIndicator(),
                            if (!_isAuthenticated)
                              ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer),
                                  child: Text(_isLogin ? 'LOG IN' : 'SIGN UP')),
                            if (!_isAuthenticated)
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                    });
                                  },
                                  child: Text(_isLogin
                                      ? 'Create an account'
                                      : 'I already have an account'))
                          ],
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
