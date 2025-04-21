//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_app/gaurdian/Splash_gaurdian.dart';
import 'package:doctors_app/gaurdian/gaurdian_auth_logic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';

//final _firebase = FirebaseAuth.instance;

class GaurdianAuthScreen extends StatefulWidget {
  const GaurdianAuthScreen({super.key});

  @override
  State<GaurdianAuthScreen> createState() {
    return _GaurdianAuthScreenState();
  }
}

class _GaurdianAuthScreenState extends State<GaurdianAuthScreen> {
  final _auth = AuthService();
  final _fire = GaurdianDatabase();
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  final _enteredEmail = TextEditingController();
  final _enteredPassword = TextEditingController();
  final _enteredName = TextEditingController();
  final _renteredPassword = TextEditingController();
  Gender _gender = Gender.male;
  final _age = TextEditingController();
  final _phone = TextEditingController();
  var _isAuthenticating = false;

  @override
  void dispose() {
    _enteredEmail.dispose();
    _enteredPassword.dispose();
    _renteredPassword.dispose();
    _enteredName.dispose();
    _age.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    setState(() {
      _isAuthenticating = true;
    });

    String email = _enteredEmail.text.trim();
    String password = _enteredPassword.text.trim();
    try {
      if (_isLogin == false) {
        String? userId =
            await _auth.createUserWithEmailAndPassword(email, password);
        if (userId != null) {
          int? age = int.tryParse(_age.text);
          if (age == null) return;

          String name = _enteredName.text.trim();
          String phone = _phone.text.trim();
          String gender = _gender.toString().split('.').last;

          await _fire.addGaurdianDataFirestore(
              userId, name, email, password, gender, age, phone);
          Map<String, dynamic>? gaurdianData =
              await _fire.getGaurdianData(userId);
          if (gaurdianData == null) {
            throw Exception("User type is incorrect.");
          }

          List<Map<String, dynamic>> patientIds =
              List<Map<String, dynamic>>.from(
                  gaurdianData['patient_gaurdian'] ?? []);
          List<String> patientUserIds = patientIds
              .map((patient) => patient['userId'] as String?)
              .where((userId) => userId != null)
              .cast<String>()
              .toList();

          if (patientIds.isNotEmpty) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (ctx) => Splash(
                    gaurdianData: gaurdianData, patientIds: patientUserIds),
              ),
            );
          } else {
            print("No patient avialable");
          }
        }
      } else {
        final dynamic user = await _auth.loginWithEmailAndPassword(
            _enteredEmail.text.trim(), _enteredPassword.text.trim());
        if (user == null) throw FirebaseAuthException(code: 'user-not-found');
        Map<String, dynamic>? gaurdianData =
            await _fire.getGaurdianData(user.uid);
        if (gaurdianData != null) {
          List<Map<String, dynamic>> patientIds =
              List<Map<String, dynamic>>.from(
                  gaurdianData['patient_gaurdian'] ?? []);
          List<String> patientUserIds = patientIds
              .map((patient) => patient['userId'] as String?)
              .where((userId) => userId != null)
              .cast<String>()
              .toList();

          if (patientIds.isNotEmpty) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (ctx) => Splash(
                    gaurdianData: gaurdianData, patientIds: patientUserIds),
              ),
            );
          } else {
            print("No patient avialable");
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      //print('$e');
      String message = 'Authentication failed';
      if (e.code == 'invalid-credential') {
        message = 'Either email or password is invalid';
      }
      _showErrorDialog(message);
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An error occurred'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Okay'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: const Text(
          'User Authentication Page',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 26, 26, 156),
                const Color.fromARGB(255, 145, 162, 235),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
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
                width: 200,
                child: Image.asset('assets/images/logo.png'),
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
                          // if (!_isLogin)
                          //   UserImagePicker(
                          //     onPickImage: (pickedImage) {
                          //       _selectedImage = pickedImage;
                          //     },
                          //   ),
                          if (!_isLogin) const SizedBox(height: 12),
                          if (!_isLogin)
                            TextFormField(
                              controller: _enteredName,
                              decoration:
                                  const InputDecoration(labelText: 'Username'),
                              keyboardType: TextInputType.text,
                              enableSuggestions: false,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Please enter a valid username.';
                                }
                                return null;
                              },
                            ),
                          if (!_isLogin) const SizedBox(height: 12),

                          if (!_isLogin) const SizedBox(height: 12),
                          if (!_isLogin)
                            TextFormField(
                              controller: _phone,
                              decoration:
                                  const InputDecoration(labelText: 'Phone No.'),
                              keyboardType: TextInputType.phone,
                              enableSuggestions: false,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 10) {
                                  return 'Please enter a valid phone no.';
                                }
                                return null;
                              },
                            ),
                          if (!_isLogin) const SizedBox(height: 12),

                          if (!_isLogin) const SizedBox(height: 12),
                          if (!_isLogin)
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Age'),
                              keyboardType: TextInputType.phone,
                              enableSuggestions: false,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().isEmpty) {
                                  return 'Please enter a valid phone no.';
                                }
                                return null;
                              },
                              controller: _age,
                            ),
                          if (!_isLogin) const SizedBox(height: 12),

                          if (!_isLogin) const SizedBox(height: 12),
                          if (!_isLogin)
                            DropdownButtonFormField(
                                value: _gender,
                                items: Gender.values
                                    .map((category) => DropdownMenuItem(
                                        value: category,
                                        child:
                                            Text(category.name.toUpperCase())))
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setState(() {
                                    _gender = value;
                                  });
                                }),
                          if (!_isLogin) const SizedBox(height: 12),

                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Email Address'),
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
                            controller: _enteredEmail,
                          ),

                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            controller: _enteredPassword,
                          ),

                          if (!_isLogin) const SizedBox(height: 12),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Re-enter Password'),
                              obscureText: true,
                              validator: (value) {
                                if (_enteredPassword.text.isEmpty) {
                                  return 'Choose a password first.';
                                }
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be at least 6 characters long.';
                                }
                                if (value != _enteredPassword.text.trim()) {
                                  return 'Password do not match';
                                }
                                return null;
                              },
                              controller: _renteredPassword,
                            ),
                          if (!_isLogin) const SizedBox(height: 12),

                          const SizedBox(height: 12),
                          _isAuthenticating
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  child: Text(_isLogin ? 'Login' : 'Signup'),
                                ),
                          //if (!_isAuthenticating)
                          TextButton(
                            onPressed: () {
                              _age.clear();
                              _enteredEmail.clear();
                              _enteredPassword.clear();
                              _enteredName.clear();
                              _renteredPassword.clear();
                              _age.clear();
                              _phone.clear();
                              _gender = Gender.male;
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(_isLogin
                                ? 'Create an account'
                                : 'I already have an account'),
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
