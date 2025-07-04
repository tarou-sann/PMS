import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pms_frontend/pages/passwordrecovery.dart';
import 'package:pms_frontend/services/api_service.dart';

import '../theme/colors.dart';
import '../widget/textfield.dart';
import 'dashboard.dart'; // Add this import

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

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Validate inputs first
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter both username and password';
      });
      return;
    }

    try {
      bool loginSuccess = await _apiService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (loginSuccess) {
        // Navigate to dashboard after successful login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardNav(),
          ),
          (route) => false, // This clears the navigation stack
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Login failed. Please check your credentials.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
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
                'lib/assets/images/Straw_Innovations_Vertical.png',
                width: 200,
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
                  child: ThemedTextFormField(
                    controller: _usernameController,
                    hintText: 'Username',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: SizedBox(
                  width: 635,
                  height: 75,
                  child: ThemedTextFormField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                ),
              ),
              TextButton(
                onPressed: _isLoading ? null : _handleLogin,
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
