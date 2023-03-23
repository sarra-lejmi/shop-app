import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/auth.dart';

enum AuthMode {
  signup,
  login,
}

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  AuthMode _authMode = AuthMode.login;
  final _passwordController = TextEditingController();
  final Map<String, String> _authData = {
    "email": "",
    "password": "",
  };
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signup;
      });
    } else {
      _authMode = AuthMode.login;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("An error occured!"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.login) {
        await Provider.of<Auth>(context, listen: false).login(
          _authData["email"]!,
          _authData["password"]!,
        );
      } else {
        await Provider.of<Auth>(context, listen: false).signup(
          _authData["email"]!,
          _authData["password"]!,
        );
      }
    } on HttpException catch (error) {
      var errorMessage = "Authentification failed!";

      if (error.toString().contains("EMAIL_EXISTS:")) {
        errorMessage = "This email address is already in use!";
      } else if (error.toString().contains("INVALID_EMAIL")) {
        errorMessage = "This is not a valid email address!";
      } else if (error.toString().contains("WEAK_PPASSWORD")) {
        errorMessage = "This password is too weak!";
      } else if (error.toString().contains("EMAIL_NOT_FOUND")) {
        errorMessage = "Could not find a user with that email!";
      } else if (error.toString().contains("INVALID_PASSWORD")) {
        errorMessage = "Invalid password!";
      }

      _showErrorDialog(errorMessage);
    } catch (e) {
      const errorMessage =
          "Could not authenticate you. Please try again later.";
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: deviceSize.width * 0.75,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text(
                      "E-Mail",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains("@")) {
                      return "Invalid email";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _authData["email"] = newValue!;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    label: Text(
                      "Password",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 6) {
                      return "Password is too short";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _authData["password"] = newValue!;
                  },
                ),
                if (_authMode == AuthMode.signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.signup,
                    obscureText: true,
                    decoration: const InputDecoration(
                      label: Text(
                        "Confirm Password",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    validator: _authMode == AuthMode.signup
                        // ignore: body_might_complete_normally_nullable
                        ? (value) {
                            // ignore: unrelated_type_equality_checks
                            if (value != _passwordController.text) {
                              return "Passwords do not match!";
                            }
                          }
                        : null,
                  ),
                const SizedBox(
                  height: 20.0,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child:
                        Text(_authMode == AuthMode.login ? "LOGIN" : "SIGNUP"),
                  ),
                TextButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                    "SIGNUP INSTEAD",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
