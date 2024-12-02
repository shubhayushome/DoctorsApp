//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_app/Splash.dart';
import 'package:doctors_app/profiler.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';

//final _firebase = FirebaseAuth.instance;

class PatientAuthScreen extends StatefulWidget {
  const PatientAuthScreen({super.key});

  @override
  State<PatientAuthScreen> createState() {
    return _PatientAuthScreenState();
  }
}

class _PatientAuthScreenState extends State<PatientAuthScreen> {
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  final _enteredEmail = TextEditingController();
  final _enteredPassword = TextEditingController();
  final _enteredName = TextEditingController();
  final _renteredPassword = TextEditingController();
  Gender _gender = Gender.male;
  final _age = TextEditingController();
  final _phone = TextEditingController();
  //var _isAuthenticating = false;

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
    print(int.tryParse(_age.text));
    print(int.tryParse(_phone.text));
    print(_enteredEmail.text);
    print(_enteredName.text);
    print(_enteredPassword.text);
    print(_renteredPassword.text);
    print(_gender);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Splash(),
      ),
    );
    // final isValid = _form.currentState!.validate();

    // if (!isValid) {
    //   // || !_isLogin && _selectedImage == null) {
    //   // show error message ...
    //   return;
    // }

    // _form.currentState!.save();

    // try {
    //   setState(() {
    //     _isAuthenticating = true;
    //   });
    //   if (_isLogin) {
    //     final userCredentials = await _firebase.signInWithEmailAndPassword(
    //         email: _enteredEmail, password: _enteredPassword);
    //   } else {
    //     final userCredentials = await _firebase.createUserWithEmailAndPassword(
    //         email: _enteredEmail, password: _enteredPassword);

    //     // final storageRef = FirebaseStorage.instance
    //     //     .ref()
    //     //     .child('user_images')
    //     //     .child('${userCredentials.user!.uid}.jpg');

    //     // await storageRef.putFile(_selectedImage!);
    //     // final imageUrl = await storageRef.getDownloadURL();
    //     // print(imageUrl);
    //     FirebaseFirestore.instance
    //         .collection('users')
    //         .doc(userCredentials.user!.uid)
    //         .set({
    //       'username': _enteredName,
    //       'email': _enteredEmail,
    //       //'image_Url' : imageUrl,
    //     });
    //   }
    // } on FirebaseAuthException catch (error) {
    //   if (error.code == 'email-already-in-use') {
    //     // ...
    //   }
    //   ScaffoldMessenger.of(context).clearSnackBars();
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(error.message ?? 'Authentication failed.'),
    //     ),
    //   );
    //   setState(() {
    //     _isAuthenticating = false;
    //   });
    // }
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
                          // if (_isAuthenticating)
                          //   const CircularProgressIndicator(),
                          // if (!_isAuthenticating)
                          ElevatedButton(
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
