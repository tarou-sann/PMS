import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'package:flutter/foundation.dart';

import 'machinerymanagement.dart';
import 'reports.dart';
import 'search.dart';

class RegisterBase extends StatelessWidget {
  const RegisterBase({super.key});

  @override
  Widget build(BuildContext context) {
    const TextStyle listTileTextStyle = TextStyle(
      fontSize: 20,
      color: Colors.black,
    );

    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDraw(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterUser(),
                      ),
                    );
                  },
                  child: Container(
                    width: 450,
                    height: 450,
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
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add,
                          weight: 200,
                          size: 225,
                          color: ThemeColor.secondaryColor,
                        ),
                        Text(
                          "Add New User",
                          style: TextStyle(fontSize: 24),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterMachinery(),
                      ),
                    );
                  },
                  child: Container(
                    width: 450,
                    height: 450,
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
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.agriculture,
                          weight: 200,
                          size: 225,
                          color: ThemeColor.secondaryColor,
                        ),
                        Text(
                          "Add Machinery",
                          style: TextStyle(fontSize: 24),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterRice(),
                      ),
                    );
                  },
                  child: Container(
                    width: 450,
                    height: 450,
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
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.grass,
                          weight: 200,
                          size: 225,
                          color: ThemeColor.secondaryColor,
                        ),
                        Text(
                          "Add Rice Variety",
                          style: TextStyle(fontSize: 24),
                        )
                      ],
                    ),
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

class RegisterUser extends StatefulWidget {
  const RegisterUser({super.key});

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _securityAnswerController = TextEditingController();
  String _securityQuestion = "What is your pet's name?";
  String _userRole = "user"; // Changed from boolean to string
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _securityAnswerController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
        _successMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      // Call API to register user
      final response = await _apiService.createUser(
        _usernameController.text,
        _passwordController.text,
        _securityQuestion,
        _securityAnswerController.text,
        _userRole == "admin", // Convert to boolean for API
      );

      setState(() {
        _isLoading = false;
        if (response['success'] == true) {
          _successMessage = 'User registered successfully!';
          _errorMessage = '';
          // Clear form
          _usernameController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          _securityAnswerController.clear();
          _userRole = "user";
        } else {
          // More descriptive error message
          if (response['message']?.contains('already exists') ?? false) {
            _errorMessage = 'Username already exists. Please choose a different username.';
          } else {
            _errorMessage = response['message'] ?? 'Failed to register user';
          }
          _successMessage = '';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
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
    );

    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDraw(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 753,
            height: 635,
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
                          Navigator.pop(context, 
                            MaterialPageRoute(builder: (context) => const RegisterBase()));
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: ThemeColor.secondaryColor,
                          size: 30,
                        ),
                      ),
                      const Text(
                        "Register User",
                        style: TextStyle(
                          color: ThemeColor.secondaryColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Show errors/success without changing layout
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  if (_successMessage.isNotEmpty)
                    Text(
                      _successMessage,
                      style: const TextStyle(color: Colors.green),
                    ),
                    
                  // Form fields in two columns - keeping original layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username
                            RichText(
                              text: const TextSpan(
                                text: 'Username',
                                style: labelStyle,
                                children: [
                                  TextSpan(
                                    text: '*',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _usernameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter username';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Enter username",
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Password
                            RichText(
                              text: const TextSpan(
                                text: 'Password',
                                style: labelStyle,
                                children: [
                                  TextSpan(
                                    text: '*',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Enter password",
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      
                      // Right column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Confirm Password
                            RichText(
                              text: const TextSpan(
                                text: 'Confirm Password',
                                style: labelStyle,
                                children: [
                                  TextSpan(
                                    text: '*',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm password';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Enter confirm password",
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Security Question
                            RichText(
                              text: const TextSpan(
                                text: 'Security Question',
                                style: labelStyle,
                                children: [
                                  TextSpan(
                                    text: '*',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: _securityQuestion,
                              dropdownColor: ThemeColor.white2,
                              focusColor: ThemeColor.white2,
                              items: const [
                                DropdownMenuItem(
                                  value: "What is your pet's name?",
                                  child: Text("What is your pet's name?"),
                                ),
                                DropdownMenuItem(
                                  value: "What is your favorite color?",
                                  child: Text("What is your favorite color?"),
                                ),
                                DropdownMenuItem(
                                  value: "What is your mother's maiden name?",
                                  child: Text("What is your mother's maiden name?"),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _securityQuestion = value;
                                  });
                                }
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: ThemeColor.primaryColor)
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Security Answer
                  RichText(
                    text: const TextSpan(
                      text: 'Security Answer',
                      style: labelStyle,
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _securityAnswerController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter security answer';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter security answer",
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // User Role dropdown (replacing the Admin checkbox)
                  RichText(
                    text: const TextSpan(
                      text: 'User Role',
                      style: labelStyle,
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _userRole,
                    dropdownColor: ThemeColor.white2,
                    focusColor: ThemeColor.white2,
                    items: const [
                      DropdownMenuItem(
                        value: "admin",
                        child: Text("Admin"),
                      ),
                      DropdownMenuItem(
                        value: "user",
                        child: Text("User"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _userRole = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ThemeColor.primaryColor)
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Register button
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ThemeColor.secondaryColor),
                          )
                        : TextButton(
                            onPressed: _registerUser,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  ThemeColor.secondaryColor),
                              foregroundColor:
                                  WidgetStateProperty.all(ThemeColor.white),
                              minimumSize: WidgetStateProperty.all(
                                  const Size(213, 65)),
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

class RegisterMachinery extends StatefulWidget {
  const RegisterMachinery({super.key});

  @override
  State<RegisterMachinery> createState() => _RegisterMachineryState();
}

class _RegisterMachineryState extends State<RegisterMachinery> {
  // Maintain existing state variables
  String _mobility = "Mobile";
  String _status = "Active";
  
  // Add new functionality variables
  final _formKey = GlobalKey<FormState>();
  final _machineNameController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _machineNameController.dispose();
    super.dispose();
  }

  // Function to register machinery
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
      final isMobile = _mobility == "Mobile";
      final isActive = _status == "Active";
      
      // Prepare machinery data
      final machineryData = {
        'machine_name': _machineNameController.text,
        'is_mobile': isMobile,
        'is_active': isActive,
      };
      
      // Call API to register machinery
      final result = await _apiService.createMachinery(machineryData);
      
      setState(() {
        _isLoading = false;
        if (result != null) {
          _successMessage = 'Machinery registered successfully!';
          _errorMessage = '';
          // Clear form
          _machineNameController.clear();
          _mobility = "Mobile";
          _status = "Active";
        } else {
          _errorMessage = 'Failed to register machinery';
          _successMessage = '';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
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
    );
    const TextStyle listTileTextStyle = TextStyle(
      fontSize: 20,
      color: Colors.black,
    );

    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDraw(),
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
                          Navigator.pop(context, 
                      MaterialPageRoute(builder: (context) => const RegisterBase()));
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
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (_successMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _successMessage,
                        style: const TextStyle(color: Colors.green),
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
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _machineNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter machine name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter machine name",
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Mobility
                  const Text(
                    'Mobility',
                    style: labelStyle,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Radio<String>(
                        activeColor: ThemeColor.secondaryColor,
                        value: 'Mobile',
                        groupValue: _mobility,
                        onChanged: (value) {
                          setState(() {
                            _mobility = value!;
                          });
                        },
                      ),
                      const Text(
                        'Mobile',
                        style: listTileTextStyle,
                      ),
                      const SizedBox(width: 40),
                      Radio<String>(
                        activeColor: ThemeColor.secondaryColor,
                        value: 'Static',
                        groupValue: _mobility,
                        onChanged: (value) {
                          setState(() {
                            _mobility = value!;
                          });
                        },
                      ),
                      const Text(
                        'Static',
                        style: listTileTextStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Status
                  const Text(
                    'Status',
                    style: labelStyle,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Radio<String>(
                        activeColor: ThemeColor.secondaryColor,
                        value: 'Active',
                        groupValue: _status,
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                      ),
                      const Text(
                        'Active',
                        style: listTileTextStyle,
                      ),
                      const SizedBox(width: 40),
                      Radio<String>(
                        activeColor: ThemeColor.secondaryColor,
                        value: 'Inactive',
                        groupValue: _status,
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                      ),
                      const Text(
                        'Inactive',
                        style: listTileTextStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Register Button
                  Align(
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ThemeColor.secondaryColor),
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

// Update the _RegisterRiceState class to match the machinery layout
class _RegisterRiceState extends State<RegisterRice> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers and state variables
  final TextEditingController _varietyNameController = TextEditingController();
  final TextEditingController _productionDateController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  String _qualityGrade = "Premium";
  
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void dispose() {
    _varietyNameController.dispose();
    _productionDateController.dispose();
    _expirationDateController.dispose();
    super.dispose();
  }

  // Date picker method
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        // Format date as YYYY-MM-DD for API compatibility
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Method to register rice variety
  Future<void> _registerRiceVariety() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate dates
    if (_productionDateController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Production date is required';
      });
      return;
    }

    if (_expirationDateController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Expiration date is required';
      });
      return;
    }

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
        'production_date': _productionDateController.text,
        'expiration_date': _expirationDateController.text,
      };

      // Call API to create rice variety
      final result = await _apiService.createRiceVariety(riceData);

      setState(() {
        _isLoading = false;
        if (result != null) {
          _successMessage = 'Rice variety registered successfully!';
          
          // Clear form after successful submission
          _varietyNameController.clear();
          _productionDateController.clear();
          _expirationDateController.clear();
          _qualityGrade = "Premium";
        } else {
          _errorMessage = 'Failed to register rice variety';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle labelStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: ThemeColor.secondaryColor,
    );
    const TextStyle listTileTextStyle = TextStyle(
      fontSize: 20,
      color: Colors.black,
    );

    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDraw(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 753,
            height: 606,  // Match machinery height
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
                          Navigator.pop(context, 
                            MaterialPageRoute(builder: (context) => const RegisterBase()));
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
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (_successMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _successMessage,
                        style: const TextStyle(color: Colors.green),
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
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _varietyNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter rice variety name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter rice variety name",
                    ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<String>(
                      value: _qualityGrade,
                      isExpanded: true,
                      underline: Container(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _qualityGrade = newValue!;
                        });
                      },
                      items: <String>[
                        'Premium',
                        'Grade A',
                        'Grade B',
                        'Grade C'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: listTileTextStyle),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Production Date
                  const Text(
                    'Production Date',
                    style: labelStyle,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _productionDateController,
                    readOnly: true,
                    onTap: () {
                      _selectDate(context, _productionDateController);
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: "Select Production Date",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () {
                          _selectDate(context, _productionDateController);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Expiration Date
                  const Text(
                    'Expiration Date',
                    style: labelStyle,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _expirationDateController,
                    readOnly: true,
                    onTap: () {
                      _selectDate(context, _expirationDateController);
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: "Select Expiration Date",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () {
                          _selectDate(context, _expirationDateController);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Register Button
                  Align(
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ThemeColor.secondaryColor),
                          )
                        : TextButton(
                            onPressed: _registerRiceVariety,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(ThemeColor.secondaryColor),
                              foregroundColor: MaterialStateProperty.all(ThemeColor.white),
                              minimumSize: MaterialStateProperty.all(const Size(213, 65)),
                              shape: MaterialStateProperty.all(
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
