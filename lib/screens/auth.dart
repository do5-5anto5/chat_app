import 'dart:io';

import 'package:chat_app/widget/user_image_picker.dart';
import 'package:chat_app/utils/message_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _username = '';
  File? _selectedImage;

  var _isLoading = false; // Adicionar loading state

  void _submit() async {
    // Tornar a função assíncrona
    final isValid = _form.currentState!.validate();
    if (!isValid || !_isLogin && _selectedImage == null) {
      if (mounted) {
        MessageHelper.show(context, 'Please enter all the fields and image.');
      }
      return;
    }

    _form.currentState!.save();

    setState(() {
      _isLoading = true; // Mostrar loading
    });

    try {
      if (_isLogin) {
        // Login
        await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        // Signup
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        // Salvar foto do usuário
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        // Envio de dados para Cloud Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _username,
          'email': _enteredEmail,
          'image_url': imageUrl
        });
      }
    } on FirebaseAuthException catch (authError) {
      String message = 'Authentication failed.';

      // Tratamento mais completo de erros
      switch (authError.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'weak-password':
          message = 'Password is too weak.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password.';
          break;
        default:
          message = authError.message ?? 'Authentication failed.';
      }
      if (mounted) {
        MessageHelper.show(context, message);
      }
    } catch (error) {
      if (mounted) {
        MessageHelper.show(context, 'An error occurred: $error');
      }
    }

    setState(() {
      _isLoading = false; // Remover loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                child: Hero(
                  tag: 'logo',
                  child: Image.asset('assets/images/chat.png', width: 200),
                ),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),
                          TextFormField(
                            enableSuggestions: false,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty || value.trim().length <4) {
                                return 'Please enter at least 4 characters.';
                              }
                              return null;
                            },
                            onSaved: (value) => _username = value!,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                            onSaved: (value) =>_enteredEmail = value!
                          ),
                          if (!_isLogin)
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (value) => _enteredPassword = value!
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            // Desabilitar durante loading
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator()
                                    : Text(_isLogin ? 'Login' : 'Sign Up'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? 'Create new account'
                                  : 'I already have an account',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
