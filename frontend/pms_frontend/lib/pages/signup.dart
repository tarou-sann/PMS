import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pms_frontend/pages/passwordrecovery.dart';
import 'package:pms_frontend/pages/register.dart';
import 'package:pms_frontend/services/api_service.dart';
import '../theme/colors.dart';
import '../theme/themedata.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'Please enter both username and password';
    });
    return;
  }

  try {
    final success = await _apiService.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (success) {
      if (mounted) {
        // Directly navigate to the main screen after successful login
        // No need to check user data/role here as we'll assume all logged-in users
        // can access the RegisterBase screen for now
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const RegisterBase(),
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid username or password';
        });
      }
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Login failed: $e';
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/images/Straw_innovations_small2.png',
                width: 300,
              ),
              const Padding(
                padding: EdgeInsets.all(3.0),
                child: Text(
                  "Sign In",
                  style: TextStyle(
                    color: ThemeColor.secondaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 48,
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: SizedBox(
                  width: 635,
                  height: 75,
                  child: TextField(
                    controller: _usernameController,
                    style: const TextStyle(
                      color: ThemeColor.primaryColor,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      hintText: "Username",
                      hintStyle: const TextStyle(
                        color: ThemeColor.grey,
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: ThemeColor.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: SizedBox(
                  width: 635,
                  height: 75,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(
                      color: ThemeColor.primaryColor,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: const TextStyle(
                        color: ThemeColor.grey,
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: ThemeColor.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: _isLoading ? null : _login,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (states) {
                      if (states.contains(WidgetState.disabled)) {
                        return ThemeColor.grey;
                      }
                      return ThemeColor.secondaryColor;
                    },
                  ),
                  foregroundColor: WidgetStateProperty.all(ThemeColor.white),
                  minimumSize: WidgetStateProperty.all(const Size(635, 75)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: ThemeColor.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(45.0),
                child: Text.rich(
                  TextSpan(
                    text: "Forget Password?",
                    style: const TextStyle(
                      fontSize: 20,
                      decoration: TextDecoration.underline,
                      color: ThemeColor.primaryColor,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PasswordrecoveryForm(),
                          ),
                        );
                      },
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