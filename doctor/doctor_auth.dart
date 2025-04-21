//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_app/doctor/Splash_doctor.dart';
import 'package:doctors_app/doctor/doctor_auth_logic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';

//final _firebase = FirebaseAuth.instance;

class DoctorAuthScreen extends StatefulWidget {
  const DoctorAuthScreen({super.key});

  @override
  State<DoctorAuthScreen> createState() {
    return _DoctorAuthScreenState();
  }
}

class _DoctorAuthScreenState extends State<DoctorAuthScreen> {
  final _auth = AuthService();
  final _fire = DoctorDatabase();
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  final _enteredEmail = TextEditingController();
  final _enteredPassword = TextEditingController();
  final _enteredName = TextEditingController();
  final _renteredPassword = TextEditingController();
  Gender _gender = Gender.male;
  final _age = TextEditingController();
  final _phone = TextEditingController();
  final _experience = TextEditingController();
  Specialization _special = Specialization.Medicine;
  final _regno = TextEditingController();
  var _isAuthenticating = false;

  @override
  void dispose() {
    _enteredEmail.dispose();
    _enteredPassword.dispose();
    _renteredPassword.dispose();
    _enteredName.dispose();
    _age.dispose();
    _phone.dispose();
    _experience.dispose();
    _regno.dispose();
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
          int? exp = int.tryParse(_experience.text);
          if (age == null || exp == null) return;

          String name = _enteredName.text.trim();
          String phone = _phone.text.trim();
          String gender = _gender.toString().split('.').last;
          String specialization = _special.toString().split('.').last;
          String registration_no = _regno.text.trim();

          await _fire.addDoctorDataFirestore(userId, name, email, password,
              gender, specialization, age, phone, exp, registration_no);
          Map<String, dynamic>? doctorData = await _fire.getDoctorData(userId);

          if (doctorData == null) {
            throw Exception("User type is incorrect.");
          }
          List<String> patientIds =
              List<String>.from(doctorData['patient'] ?? []);
          if (patientIds.isNotEmpty) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (ctx) =>
                    Splash(doctorData: doctorData, patientIds: patientIds),
              ),
            );
          } else {
            print("No patient avialable");
          }
        }
      } else {
        final dynamic user = await _auth.loginWithEmailAndPassword(
            _enteredEmail.text.trim(), _enteredPassword.text.trim());
        {
          Map<String, dynamic>? doctorData =
              await _fire.getDoctorData(user.uid);
          if (doctorData == null) {
            _showErrorDialog("User type is incorrect or data not found.");
            return;
          }
          List<String> patientIds =
              List<String>.from(doctorData['patient'] ?? []);
          //print(patientIds);
          if (patientIds.isNotEmpty) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (ctx) =>
                    Splash(doctorData: doctorData, patientIds: patientIds),
              ),
            );
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
                              keyboardType: TextInputType.number,
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
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Experience(in years)'),
                              keyboardType: TextInputType.number,
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
                              controller: _experience,
                            ),
                          if (!_isLogin) const SizedBox(height: 12),

                          if (!_isLogin) const SizedBox(height: 12),
                          if (!_isLogin)
                            TextFormField(
                              controller: _regno,
                              decoration: const InputDecoration(
                                  labelText: 'Registration Number'),
                              keyboardType: TextInputType.text,
                              enableSuggestions: false,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.characters,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length != 6) {
                                  return 'Please enter a valid rgistration Number.';
                                }
                                return null;
                              },
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

                          if (!_isLogin) const SizedBox(height: 12),
                          if (!_isLogin)
                            DropdownButtonFormField(
                                value: _special,
                                items: Specialization.values
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
                                    _special = value;
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
                              _experience.clear();
                              _regno.clear();
                              _special = Specialization.Medicine;
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
