import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widget/navbar.dart';
import 'package:intl/intl.dart';


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
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterBase(),
                  ),
                );
                print("moving to registration");
              },
              title: const Text('Registration', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Machine Management', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Production Tracking', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Forecasting', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Search', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Help', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('About', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Logout', style: listTileTextStyle),
            ),
          ],
        ),
      ),
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

class RegisterUser extends StatelessWidget {
  const RegisterUser({super.key});

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
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterBase(),
                  ),
                );
                print("moving to registration");
              },
              title: const Text('Registration', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Machine Management', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Production Tracking', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Forecasting', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Search', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Help', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('About', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Logout', style: listTileTextStyle),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button and title
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
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
            // Form fields
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'Username',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
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
                        const SizedBox(height: 10),
                        const TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Enter username",
                          ),
                        ),
                        const SizedBox(height: 20),
                        RichText(
                          text: const TextSpan(
                            text: 'Password',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
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
                        const SizedBox(height: 10),
                        const TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Enter password",
                          ),
                        ),
                        const SizedBox(height: 20),
                        RichText(
                          text: const TextSpan(
                            text: 'Confirm Password',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
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
                        const SizedBox(height: 10),
                        const TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Enter confirm password",
                          ),
                        ),
                        const SizedBox(height: 20),
                        RichText(
                          text: const TextSpan(
                            text: 'Security Question',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
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
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          dropdownColor: ThemeColor.white2,
                          focusColor: ThemeColor.white2,
                          items: const [
                            DropdownMenuItem(
                              value: "What is your pet's name?",
                              child: Text("What is your pet's name?"),
                            ),
                            DropdownMenuItem(
                              value: "What is your mother's maiden name?",
                              child: Text("What is your mother's maiden name?"),
                            ),
                          ],
                          onChanged: (value) {},
                          decoration: const InputDecoration(
                            border:  OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: ThemeColor.primaryColor
                              )
                            )
                          ),
                        ),
                        const SizedBox(height: 20),
                        RichText(
                          text: const TextSpan(
                            text: 'Security Answer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
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
                        const SizedBox(height: 10),
                        const TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Enter security answer",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Right column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'E-mail',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
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
                        const SizedBox(height: 10),
                        const TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Enter e-mail",
                          ),
                        ),
                        const SizedBox(height: 20),
                        RichText(
                          text: const TextSpan(
                            text: 'Level of Access',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
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
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          dropdownColor: ThemeColor.white2,
                          focusColor: ThemeColor.white2,
                          items: const [
                            DropdownMenuItem(
                              value: "Admin",
                              child: Text("Admin"),
                            ),
                            DropdownMenuItem(
                              value: "User",
                              child: Text("User"),
                            ),
                          ],
                          onChanged: (value) {},
                          decoration: const InputDecoration(
                            border:  OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: ThemeColor.primaryColor
                              )
                            )
                          ),
                        ),
                        const Spacer(),
                        // Register button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
              onPressed: () {},
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
                ],
              ),
            ),
          ],
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
  String _mobility = "Mobile";
  String _status = "Active";


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
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterBase(),
                  ),
                );
                print("moving to registration");
              },
              title: const Text('Registration', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Machine Management', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Production Tracking', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Forecasting', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Search', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Help', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('About', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Logout', style: listTileTextStyle),
            ),
          ],
        ),
      ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                    onPressed: () {
                      Navigator.pop(context);
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
                const TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter machine name",
                  ),
                ),
                const SizedBox(height: 20),
                
                // Machine Mobility
                RichText(
                  text: const TextSpan(
                    text: 'Machine Mobility',
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
                
                // Fix: Using Column instead of Row for radio buttons
                Row(
                  children: [
                    // Fix: Wrap RadioListTile with Expanded to provide constraints
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Mobile"),
                        value: "Mobile",
                        groupValue: _mobility,
                        activeColor: ThemeColor.secondaryColor,
                        onChanged: (value) {
                          setState(() {
                            _mobility = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Not Mobile"),
                        value: "Not Mobile",
                        groupValue: _mobility,
                        activeColor: ThemeColor.secondaryColor,
                        onChanged: (value) {
                          setState(() {
                            _mobility = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Machine Status
                RichText(
                  text: const TextSpan(
                    text: 'Machine Status',
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
                
                // Fix: Using Column instead of Row for radio buttons
                Row(
                  children: [
                    // Fix: Wrap RadioListTile with Expanded to provide constraints
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Active"),
                        value: "Active",
                        groupValue: _status,
                        activeColor: ThemeColor.secondaryColor,
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Inactive"),
                        value: "Inactive",
                        groupValue: _status,
                        activeColor: ThemeColor.secondaryColor,
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Machine ID Note
                const Center(
                  child: Text(
                    "Machine ID is automatically assigned*",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Register Button
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      print("Register Machinery: $_mobility, $_status");
                    },
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
    );
  }
}

class RegisterRice extends StatefulWidget {
  const RegisterRice({super.key});

  @override
  State<RegisterRice> createState() => _RegisterRiceState();
}

class _RegisterRiceState extends State<RegisterRice> {
  String _qualityGrade = "Premium";
  // Add date controllers
  final TextEditingController _productionDateController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();

  @override
  void dispose() {
    _productionDateController.dispose();
    _expirationDateController.dispose();
    super.dispose();
  }

  // Date picker method
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ThemeColor.secondaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('MM / dd / yyyy').format(picked);
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
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterBase(),
                  ),
                );
                print("moving to registration");
              },
              title: const Text('Registration', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Machine Management', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Production Tracking', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Forecasting', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Search', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Help', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('About', style: listTileTextStyle),
            ),
            const ListTile(
              title: Text('Logout', style: listTileTextStyle),
            ),
          ],
        ),
      ),
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
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
                  const SizedBox(height: 20),
                  // Rice Variety
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
                  const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter Rice Variety",
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quality Grade
                  RichText(
                    text: const TextSpan(
                      text: 'Quality Grade',
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
                  DropdownButtonFormField<String>(
                    dropdownColor: ThemeColor.white2,
                    focusColor: ThemeColor.white2,
                    value: _qualityGrade,
                    items: const [
                      DropdownMenuItem(
                        value: "Premium",
                        child: Text("Premium"),
                      ),
                      DropdownMenuItem(
                        value: "Grade A",
                        child: Text("Grade A"),
                      ),
                      DropdownMenuItem(
                        value: "Grade B",
                        child: Text("Grade B"),
                      ),
                      DropdownMenuItem(
                        value: "Grade C",
                        child: Text("Grade C"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _qualityGrade = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: ThemeColor.primaryColor
                        )
                      )
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Production Date - Added as requested
                  RichText(
                    text: const TextSpan(
                      text: 'Production Date',
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
                  TextField(
                    controller: _productionDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: "MM / DD / YYYY",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today, color: ThemeColor.secondaryColor),
                        onPressed: () => _selectDate(context, _productionDateController),
                      ),
                    ),
                    onTap: () => _selectDate(context, _productionDateController),
                  ),
                  const SizedBox(height: 20),
                  
                  // Expiration Date - Added as requested
                  RichText(
                    text: const TextSpan(
                      text: 'Expiration Date',
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
                  TextField(
                    controller: _expirationDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: "MM / DD / YYYY",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today, color: ThemeColor.secondaryColor),
                        onPressed: () => _selectDate(context, _expirationDateController),
                      ),
                    ),
                    onTap: () => _selectDate(context, _expirationDateController),
                  ),
                  const SizedBox(height: 30),
                
                  // Register Button
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        print("Register Rice Variety: $_qualityGrade");
                        print("Production Date: ${_productionDateController.text}");
                        print("Expiration Date: ${_expirationDateController.text}");
                      },
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