import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Add this import for kDebugMode
import '../theme/colors.dart';
import 'signup.dart';
import '../services/api_service.dart';

class PasswordrecoveryForm extends StatefulWidget {
  const PasswordrecoveryForm({super.key});

  @override
  State<PasswordrecoveryForm> createState() => _PasswordrecoveryFormState();
}

class _PasswordrecoveryFormState extends State<PasswordrecoveryForm> {
  final TextEditingController _usernameController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _getSecurityQuestion() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (_usernameController.text.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter a username';
      });
      return;
    }

    try {
      final securityQuestion = await _apiService.getSecurityQuestion(_usernameController.text);
      
      if (securityQuestion != null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Navigate to security module with the question
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SecurityModule(
                username: _usernameController.text,
                securityQuestion: securityQuestion,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'User not found';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.white,
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpForm(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: ThemeColor.secondaryColor,
                          size: 50,
                        ),
                      ),
                      const Text(
                        "Forget Password",
                        style: TextStyle(
                          color: ThemeColor.secondaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 48,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
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
                    TextButton(
                      onPressed: _isLoading ? null : _getSecurityQuestion,
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
                              "Confirm",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SecurityModule extends StatefulWidget {
  final String username;
  final String securityQuestion;
  
  const SecurityModule({
    super.key,
    required this.username,
    required this.securityQuestion,
  });

  @override
  State<SecurityModule> createState() => _SecurityModuleState();
}

class _SecurityModuleState extends State<SecurityModule> {
  final TextEditingController _answerController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _errorMessage = '';
  String? _resetToken;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _verifySecurityAnswer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (_answerController.text.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter your answer';
      });
      return;
    }

    try {
      final resetToken = await _apiService.verifySecurityAnswer(
        widget.username,
        _answerController.text,
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (kDebugMode) {
          print('Navigating to reset form with token (length: ${resetToken.length})');
        }

        // Navigate to password reset form
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordResetForm(resetToken: resetToken),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.white,
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PasswordrecoveryForm(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: ThemeColor.secondaryColor,
                          size: 50,
                        ),
                      ),
                      const Text(
                        "Forget Password",
                        style: TextStyle(
                          color: ThemeColor.secondaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 48,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                      child: Container(
                        width: 635,
                        height: 60,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: ThemeColor.grey,
                            width: 1.0
                          ),
                          borderRadius: BorderRadius.circular(9)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: Text(
                            widget.securityQuestion,
                            style: const TextStyle(
                              fontSize: 20,
                              color: ThemeColor.primaryColor
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 635,
                      height: 75,
                      child: TextField(
                        controller: _answerController,
                        style: const TextStyle(
                          color: ThemeColor.primaryColor,
                          fontSize: 20,
                        ),
                        decoration: InputDecoration(
                          hintText: "Answer",
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
                    TextButton(
                      onPressed: _isLoading ? null : _verifySecurityAnswer,
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
                              "Confirm",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordResetForm extends StatefulWidget {
  final String resetToken;
  
  const PasswordResetForm({
    super.key,
    required this.resetToken,
  });

  @override
  State<PasswordResetForm> createState() => _PasswordResetFormState();
}

class _PasswordResetFormState extends State<PasswordResetForm> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    if (_passwordController.text.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter a new password';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    try {
      final success = await _apiService.resetPassword(
        widget.resetToken,
        _passwordController.text,
      );
      
      if (success) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _successMessage = 'Password reset successful! Redirecting to login...';
          });
          
          // Wait a moment and then navigate to login
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignUpForm(),
                ),
                (route) => false,
              );
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to reset password';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.white,
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: Text(
                    "Reset Password",
                    style: TextStyle(
                      color: ThemeColor.secondaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 48,
                    ),
                  ),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                if (_successMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      _successMessage,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
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
                          hintText: "New Password",
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
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 635,
                      height: 75,
                      child: TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        style: const TextStyle(
                          color: ThemeColor.primaryColor,
                          fontSize: 20,
                        ),
                        decoration: InputDecoration(
                          hintText: "Confirm New Password",
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
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _isLoading ? null : _resetPassword,
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
                              "Reset Password",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}