import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../theme/colors.dart';
import '../widget/navbar.dart';
import '../widget/enddrawer.dart';
import 'backup.dart';

class MaintenanceNav extends StatelessWidget {
  const MaintenanceNav ({super.key});

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
                        builder: (context) => const EditMachinery(),
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
                          "Edit Machine Details",
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
                        builder: (context) => const EditRice(),
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
                          "Edit Rice Variety",
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
                        builder: (context) => const BackUpNav()
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
                          Icons.backup,
                          weight: 200,
                          size: 225,
                          color: ThemeColor.secondaryColor,
                        ),
                        Text(
                          "Back Up",
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

class EditMachinery extends StatefulWidget {
  const EditMachinery({super.key});

  @override
  State<EditMachinery> createState() => _EditMachineryState();
}

class _EditMachineryState extends State<EditMachinery> {
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
                    MaterialPageRoute(builder: (context) => const MaintenanceNav()));
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: ThemeColor.secondaryColor,
                        size: 30,
                      ),
                    ),
                    const Text(
                      "Edit Machinery",
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

                // Confirm and Cancel Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
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
                        "Confirm",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(ThemeColor.white2),
                        foregroundColor: MaterialStateProperty.all(ThemeColor.primaryColor),
                        minimumSize: MaterialStateProperty.all(const Size(213, 65)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                            side: const BorderSide(
                              color: ThemeColor.grey
                            )
                          ),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditRice extends StatefulWidget {
  const EditRice({super.key});

  @override
  State<EditRice> createState() => _EditRiceState();
}

class _EditRiceState extends State<EditRice> {
  String _qualityGrade = "Premium";
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
                          Navigator.pop(context, 
                    MaterialPageRoute(builder: (context) => const MaintenanceNav()));
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: ThemeColor.secondaryColor,
                          size: 30,
                        ),
                      ),
                      const Text(
                        "Edit Rice Variety",
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
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ThemeColor.primaryColor))),
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
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {

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
                        "Confirm",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(ThemeColor.white2),
                        foregroundColor: MaterialStateProperty.all(ThemeColor.primaryColor),
                        minimumSize: MaterialStateProperty.all(const Size(213, 65)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                            side: const BorderSide(
                              color: ThemeColor.grey
                            )
                          ),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
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
