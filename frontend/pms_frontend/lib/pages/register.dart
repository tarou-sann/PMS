import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/user_activity_service.dart';
import '../theme/colors.dart';
import '../widget/calendar.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../widget/textfield.dart';

class RegisterBase extends StatelessWidget {
  const RegisterBase({super.key});

  @override
  Widget build(BuildContext context) {
    const TextStyle listTileTextStyle = TextStyle(
      fontSize: 20,
      color: ThemeColor.primaryColor,
    );

    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Page Header
              const Text(
                "Registration",
                style: TextStyle(
                  color: ThemeColor.secondaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),

              // Responsive card layout with size limits
              LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;
                  double scaleFactor = (screenWidth / 1200).clamp(0.7, 1.0); // Conservative scaling

                  double cardWidth = 450 * scaleFactor;
                  double cardHeight = 450 * scaleFactor;
                  double iconSize = 225 * scaleFactor;
                  double fontSize = 24 * scaleFactor;
                  double spacing = 40 * scaleFactor;

                  cardWidth = cardWidth.clamp(350.0, 450.0);
                  cardHeight = cardHeight.clamp(350.0, 450.0);
                  iconSize = iconSize.clamp(180.0, 225.0);
                  fontSize = fontSize.clamp(20.0, 24.0);
                  spacing = spacing.clamp(30.0, 40.0);

                  return Center(
                    // Center the content
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildRegistrationCard(
                          context,
                          "Add New User",
                          Icons.person_add,
                          cardWidth,
                          cardHeight,
                          iconSize,
                          fontSize,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterUser())),
                        ),
                        _buildRegistrationCard(
                          context,
                          "Add Machinery",
                          Icons.agriculture,
                          cardWidth,
                          cardHeight,
                          iconSize,
                          fontSize,
                          () => Navigator.push(
                              context, MaterialPageRoute(builder: (context) => const RegisterMachinery())),
                        ),
                        _buildRegistrationCard(
                          context,
                          "Add Rice Variety",
                          Icons.grass,
                          cardWidth,
                          cardHeight,
                          iconSize,
                          fontSize,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterRice())),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationCard(BuildContext context, String title, IconData icon, double cardWidth, double cardHeight,
      double iconSize, double fontSize, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: ThemeColor.white2,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: ThemeColor.secondaryColor,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: ThemeColor.secondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterUser extends StatefulWidget {
  const RegisterUser({super.key});

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _securityAnswerController = TextEditingController();

  String _userRole = "user";
  String _securityQuestion = "What is your favorite color?";
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _securityAnswerController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    setState(() {
      _errorMessage = '';
      _successMessage = '';
      _isLoading = true;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await _apiService.createUser(
        _usernameController.text,
        _passwordController.text,
        _securityQuestion,
        _securityAnswerController.text,
        _userRole == "admin",
      );

      if (response['success'] == true) {
        // Log the activity
        await UserActivityService().logActivity(
          'Register User',
          'Successfully registered new user: ${_usernameController.text}',
          target: 'User Management',
        );

        setState(() {
          _successMessage = 'User registered successfully!'; // Add this line
          _errorMessage = ''; // Clear any previous error
          _isLoading = false; // Stop loading
        });

        // Reset the form completely
        _usernameController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _securityAnswerController.clear();
        _userRole = "user";
        _securityQuestion = "What is your favorite color?";

        // This is important - reset form validation state
        _formKey.currentState?.reset();
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to register user';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        // Handle specific duplicate error messages
        String errorMsg = e.toString();
        if (errorMsg.contains('already exists')) {
          _errorMessage = errorMsg.replaceAll('Exception: ', '');
        } else {
          _errorMessage = 'Error: $e';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Container(
              width: 753,
              height: 606,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeColor.white2,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Header with back button and title
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: ThemeColor.secondaryColor, size: 32),
                        onPressed: () {
                          Navigator.pop(context, MaterialPageRoute(builder: (context) => const RegisterBase()));
                        },
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Register User",
                            style: TextStyle(
                              color: ThemeColor.secondaryColor,
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Error/Success messages
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: ThemeColor.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: ThemeColor.red),
                      ),
                    ),
                  if (_successMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: ThemeColor.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _successMessage,
                        style: const TextStyle(color: ThemeColor.green),
                      ),
                    ),

                  // Main form in two columns
                  Expanded(
                    child: SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Username field
                                  RichText(
                                    text: const TextSpan(
                                      text: 'Username ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: ThemeColor.primaryColor,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '*',
                                          style: TextStyle(
                                            color: ThemeColor.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ThemedTextFormField(
                                    controller: _usernameController,
                                    hintText: 'Username',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter username';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Password field
                                  RichText(
                                    text: const TextSpan(
                                      text: 'Password ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: ThemeColor.primaryColor,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '*',
                                          style: TextStyle(
                                            color: ThemeColor.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ThemedTextFormField(
                                    controller: _passwordController,
                                    hintText: 'Password',
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter password';
                                      }
                                      if (value.length < 8) {
                                        return 'Password must be at least 8 characters.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Confirm Password field
                                  RichText(
                                    text: const TextSpan(
                                      text: 'Confirm Password',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: ThemeColor.primaryColor,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '*',
                                          style: TextStyle(
                                            color: ThemeColor.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ThemedTextFormField(
                                    controller: _confirmPasswordController,
                                    hintText: 'Confirm Password',
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm password';
                                      } else if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      } else if (value.length < 8) {
                                        return 'Password must be at least 8 characters.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Security Question
                                  RichText(
                                    text: const TextSpan(
                                      text: 'Security Question ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: ThemeColor.primaryColor,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '*',
                                          style: TextStyle(
                                            color: ThemeColor.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: _securityQuestion,
                                    style: const TextStyle(
                                      color: ThemeColor.primaryColor,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 10,
                                      ),
                                      fillColor: Colors.grey[50],
                                      filled: true,
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: ThemeColor.primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    dropdownColor: Colors.white,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _securityQuestion = newValue!;
                                      });
                                    },
                                    items: <String>[
                                      'What is your favorite color?',
                                      'What is your mother\'s maiden name?',
                                      'What was your first pet\'s name?',
                                      'What city were you born in?',
                                      'What is your favorite food?'
                                    ].map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: ThemeColor.primaryColor,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Right column
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Level of Access (User Role)
                                  RichText(
                                    text: const TextSpan(
                                      text: 'Level of Access ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: ThemeColor.primaryColor,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '*',
                                          style: TextStyle(
                                            color: ThemeColor.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: _userRole,
                                    style: const TextStyle(
                                      color: ThemeColor.primaryColor,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 10,
                                      ),
                                      fillColor: Colors.grey[50],
                                      filled: true,
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: ThemeColor.primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    dropdownColor: Colors.white,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _userRole = newValue!;
                                      });
                                    },
                                    items: <String>[
                                      'user',
                                      'admin',
                                    ].map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: ThemeColor.primaryColor,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                  const SizedBox(height: 16),

                                  // Security Answer
                                  RichText(
                                    text: const TextSpan(
                                      text: 'Security Answer ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: ThemeColor.primaryColor,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '*',
                                          style: TextStyle(
                                            color: ThemeColor.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ThemedTextFormField(
                                    controller: _securityAnswerController,
                                    hintText: 'Security Answer',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter security answer';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Register Button at bottom right
                  Align(
                    alignment: Alignment.bottomRight,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA67C52)), // Gold/bronze color
                          )
                        : SizedBox(
                            width: 200,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _registerUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA67C52), // Gold/bronze color
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
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

class RegisterMachinery extends StatefulWidget {
  const RegisterMachinery({super.key});

  @override
  State<RegisterMachinery> createState() => _RegisterMachineryState();
}

class _RegisterMachineryState extends State<RegisterMachinery> {
  // Remove the repairs needed state variable
  String _mobility = "Yes";
  String _status = "Yes";

  // Keep other existing state variables
  final _formKey = GlobalKey<FormState>();
  final _machineNameController = TextEditingController();
  final _hourMeterController = TextEditingController(text: '0');
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _machineNameController.dispose();
    _hourMeterController.dispose();
    super.dispose();
  }

  // Update the _registerMachinery method
  Future<void> _registerMachinery() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      // Convert string values to booleans
      final isMobile = _mobility == "Yes";
      final canHarvest = _status == "Yes";
      final hourMeter = int.parse(_hourMeterController.text);

      // Prepare machinery data (repairs_needed defaults to false)
      final machineryData = {
        'machine_name': _machineNameController.text,
        'is_mobile': isMobile,
        'is_active': canHarvest,
        'hour_meter': hourMeter,
        'repairs_needed': false, // Always false for new machinery
      };

      // Call API to register machinery
      final result = await _apiService.createMachinery(machineryData);

      if (result != null) {
        // Log the activity
        await UserActivityService().logActivity(
          'Add Machinery',
          'Added new machinery: ${_machineNameController.text}',
          target: 'Machinery Management',
        );
      }

      setState(() {
        _isLoading = false;
        if (result != null) {
          _successMessage = 'Machinery registered successfully!';
          _errorMessage = '';
          // Clear form
          _machineNameController.clear();
          _hourMeterController.text = '0';
          _mobility = "Yes";
          _status = "Yes";
        } else {
          _errorMessage = 'Failed to register machinery';
          _successMessage = '';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        String errorMsg = e.toString();
        if (errorMsg.contains('already exists')) {
          _errorMessage = 'A machine with this name already exists. Please choose a different name.';
        } else {
          _errorMessage = 'Failed to register machinery: $errorMsg';
        }
        _successMessage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle labelStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: ThemeColor.secondaryColor,
      fontFamily: 'Lexend',
    );
    const TextStyle listTileTextStyle = TextStyle(
      fontSize: 20,
      color: ThemeColor.primaryColor,
    );

    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 753,
            height: 606,
            decoration: BoxDecoration(
              color: ThemeColor.white2,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context, MaterialPageRoute(builder: (context) => const RegisterBase()));
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: ThemeColor.secondaryColor,
                          size: 30,
                        ),
                      ),
                      const Text(
                        "Register Machinery",
                        style: TextStyle(
                          color: ThemeColor.secondaryColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Display status messages
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: ThemeColor.red),
                      ),
                    ),
                  if (_successMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _successMessage,
                        style: const TextStyle(color: ThemeColor.green),
                      ),
                    ),

                  // Machine Name
                  RichText(
                    text: const TextSpan(
                      text: 'Machine Name',
                      style: labelStyle,
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: ThemeColor.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ThemedTextFormField(
                    controller: _machineNameController,
                    hintText: 'Machine Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter machine name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Hour Meter field
                  RichText(
                    text: const TextSpan(
                      text: 'Hour Meter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: ThemeColor.secondaryColor,
                      ),
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: ThemeColor.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ThemedTextFormField(
                    controller: _hourMeterController,
                    hintText: 'Enter hour meter reading (0 for new machines)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter hour meter reading';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if (int.parse(value) < 0) {
                        return 'Hour meter cannot be negative';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Mobility
                  const Text(
                    'Is Mobile?', // Changed from "Mobility" to "Is Mobile?"
                    style: labelStyle,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Radio<String>(
                        activeColor: ThemeColor.secondaryColor,
                        value: 'Yes', // Changed from "Mobile" to "Yes"
                        groupValue: _mobility,
                        onChanged: (value) {
                          setState(() {
                            _mobility = value!;
                          });
                        },
                      ),
                      const Text(
                        'Yes', // Changed from "Mobile" to "Yes"
                        style: listTileTextStyle,
                      ),
                      const SizedBox(width: 40),
                      Radio<String>(
                        activeColor: ThemeColor.secondaryColor,
                        value: 'No', // Changed from "Static" to "No"
                        groupValue: _mobility,
                        onChanged: (value) {
                          setState(() {
                            _mobility = value!;
                          });
                        },
                      ),
                      const Text(
                        'No', // Changed from "Static" to "No"
                        style: listTileTextStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Status
                  const Text(
                    'Can Harvest?', // Changed from "Status" to "Can Harvest?"
                    style: labelStyle,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Radio<String>(
                        activeColor: ThemeColor.secondaryColor,
                        value: 'Yes', // Changed from "Active" to "Yes"
                        groupValue: _status,
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                      ),
                      const Text(
                        'Yes', // Changed from "Active" to "Yes"
                        style: listTileTextStyle,
                      ),
                      const SizedBox(width: 40),
                      Radio<String>(
                        activeColor: ThemeColor.secondaryColor,
                        value: 'No', // Changed from "Inactive" to "No"
                        groupValue: _status,
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                      ),
                      const Text(
                        'No', // Changed from "Inactive" to "No"
                        style: listTileTextStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Register Button
                  Align(
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.secondaryColor),
                          )
                        : TextButton(
                            onPressed: _registerMachinery,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(ThemeColor.secondaryColor),
                              foregroundColor: WidgetStateProperty.all(ThemeColor.white),
                              minimumSize: WidgetStateProperty.all(const Size(213, 65)),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                            ),
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
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

class RegisterRice extends StatefulWidget {
  const RegisterRice({super.key});

  @override
  State<RegisterRice> createState() => _RegisterRiceState();
}

class _RegisterRiceState extends State<RegisterRice> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Form controllers and state variables
  final TextEditingController _varietyNameController = TextEditingController();
  // final TextEditingController _productionDateController = TextEditingController();
  // final TextEditingController _expirationDateController = TextEditingController();
  String _qualityGrade = "Shatter";
  final TextEditingController _expectedYieldController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void dispose() {
    _varietyNameController.dispose();
    // _productionDateController.dispose();
    // _expirationDateController.dispose();
    _expectedYieldController.dispose();
    super.dispose();
  }

  // Date picker method
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await CalendarTheme.showCustomDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Select Date',
    );

    if (picked != null) {
      setState(() {
        // Format date as YYYY-MM-DD for API compatibility
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Method to register rice variety
  Future<void> _registerRiceVariety() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate dates
    // if (_productionDateController.text.isEmpty) {
    //   setState(() {
    //     _errorMessage = 'Production date is required';
    //   });
    //   return;
    // }

    // if (_expirationDateController.text.isEmpty) {
    //   setState(() {
    //     _errorMessage = 'Expiration date is required';
    //   });
    //   return;
    // }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      // Prepare rice variety data
      final riceData = {
        'variety_name': _varietyNameController.text,
        'quality_grade': _qualityGrade,
        // 'production_date': _productionDateController.text,
        // 'expiration_date': _expirationDateController.text,
        'expected_yield': int.tryParse(_expectedYieldController.text) ?? 0,
      };

      // Call API to create rice variety
      final result = await _apiService.createRiceVariety(riceData);

      if (result == null) {
        // Log the activity
        await UserActivityService().logActivity(
          'Add Rice Variety',
          'Added new rice variety: ${_varietyNameController.text}',
          target: 'Rice Management',
        );
      }

      setState(() {
        _isLoading = false;
        if (result != null) {
          _successMessage = 'Rice variety registered successfully!';

          UserActivityService().logActivity(
            'Add Rice Variety',
            'Added new rice variety: ${_varietyNameController.text}',
            target: 'Rice Management',
          );

          // Clear form after successful submission
          _varietyNameController.clear();
          // _productionDateController.clear();
          // _expirationDateController.clear();
          _qualityGrade = "Shatter";
          _expectedYieldController.clear();
        } else {
          _errorMessage = 'Failed to register rice variety';
        }
      });
      // In the catch block of _registerRiceVariety:
    } catch (e) {
      setState(() {
        _isLoading = false;
        // Handle specific duplicate error messages
        String errorMsg = e.toString();
        if (errorMsg.contains('already exists')) {
          _errorMessage = errorMsg.replaceAll('Exception: ', '');
        } else {
          _errorMessage = 'Error: $e';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle labelStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: ThemeColor.secondaryColor,
    );
    const TextStyle listTileTextStyle = TextStyle(
      fontSize: 20,
      color: ThemeColor.primaryColor,
    );

    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 753,
            height: 650,
            decoration: BoxDecoration(
              color: ThemeColor.white2,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context, MaterialPageRoute(builder: (context) => const RegisterBase()));
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: ThemeColor.secondaryColor,
                          size: 30,
                        ),
                      ),
                      const Text(
                        "Register Rice Variety",
                        style: TextStyle(
                          color: ThemeColor.secondaryColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Display status messages
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: ThemeColor.red),
                      ),
                    ),
                  if (_successMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _successMessage,
                        style: const TextStyle(color: ThemeColor.green),
                      ),
                    ),

                  // Rice Variety Name
                  RichText(
                    text: const TextSpan(
                      text: 'Rice Variety',
                      style: labelStyle,
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: ThemeColor.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ThemedTextFormField(
                    controller: _varietyNameController,
                    hintText: 'Rice Variety Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter rice variety name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Quality Grade
                  const Text(
                    'Quality Grade',
                    style: labelStyle,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4.0),
                      color: Colors.grey[50],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: DropdownButton<String>(
                      value: _qualityGrade,
                      isExpanded: true,
                      underline: Container(),
                      dropdownColor: Colors.white,
                      style: const TextStyle(
                        color: ThemeColor.primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _qualityGrade = newValue!;
                        });
                      },
                      items: <String>[
                        'Shatter',
                        'Non-Shattering',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: ThemeColor.primaryColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Expected Yield Per Hectare - UPDATE THIS SECTION
                  const Text(
                    'Expected Yield per Hectare (kg/ha)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ThemeColor.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ThemedTextFormField(
                    controller: _expectedYieldController,
                    hintText: 'Enter baseline expected yield for this variety',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This is the typical expected yield for this rice variety. It will be used to predict total harvest amounts when farmers plant this variety.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // // Production Date
                  // const Text(
                  //   'Production Date',
                  //   style: labelStyle,
                  // ),
                  // const SizedBox(height: 10),
                  // ThemedTextFormField(
                  //   controller: _productionDateController,
                  //   hintText: 'Select Production Date',
                  //   readOnly: true,
                  //   onTap: () => _selectDate(context, _productionDateController),
                  //   suffixIcon: IconButton(
                  //     icon: const Icon(Icons.calendar_today),
                  //     onPressed: () => _selectDate(context, _productionDateController),
                  //   ),
                  // ),
                  // const SizedBox(height: 30),

                  // // Expiration Date
                  // const Text(
                  //   'Expiration Date',
                  //   style: labelStyle,
                  // ),
                  // const SizedBox(height: 10),
                  // ThemedTextFormField(
                  //   controller: _expirationDateController,
                  //   hintText: 'Select Expiration Date',
                  //   readOnly: true,
                  //   onTap: () => _selectDate(context, _expirationDateController),
                  //   suffixIcon: IconButton(
                  //     icon: const Icon(Icons.calendar_today),
                  //     onPressed: () => _selectDate(context, _expirationDateController),
                  //   ),
                  // ),
                  // const SizedBox(height: 30),

                  // Register Button
                  Align(
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.secondaryColor),
                          )
                        : TextButton(
                            onPressed: _registerRiceVariety,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(ThemeColor.secondaryColor),
                              foregroundColor: WidgetStateProperty.all(ThemeColor.white),
                              minimumSize: WidgetStateProperty.all(const Size(213, 65)),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                            ),
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
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

