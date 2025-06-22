import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/user_activity_service.dart';
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../widget/textfield.dart';
import '../utils/formatters.dart';
import 'backup.dart';

class MaintenanceNav extends StatelessWidget {
  const MaintenanceNav({super.key});

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
      endDrawer: const EndDrawer(),
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
                          color: ThemeColor.grey.withOpacity(0.2),
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
                          color: ThemeColor.grey.withOpacity(0.2),
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
                      MaterialPageRoute(builder: (context) => const BackUpNav()),
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
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _machinery = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMachinery();
  }

  Future<void> _loadMachinery() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final machinery = await _apiService.getMachinery();
      setState(() {
        _isLoading = false;
        if (machinery != null) {
          _machinery = machinery;
        } else {
          _errorMessage = 'Failed to load machinery data';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _showEditMachineDialog(BuildContext context, Map<String, dynamic> machine) async {
    final formKey = GlobalKey<FormState>();
    final machineNameController = TextEditingController(text: machine['machine_name']);
    String mobility = machine['is_mobile'] ? 'Yes' : 'No';
    String status = machine['is_active'] ? 'Yes' : 'No';
    bool isLoading = false;
    String errorMessage = '';

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Edit Machine Details',
              style: TextStyle(
                color: ThemeColor.secondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SizedBox(
              width: 500,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const Text(
                        'Machine Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ThemedTextFormField(
                        controller: machineNameController,
                        hintText: 'Enter machine name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter machine name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Mobility',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Radio<String>(
                            activeColor: ThemeColor.secondaryColor,
                            value: 'Yes',
                            groupValue: mobility,
                            onChanged: (value) {
                              setState(() {
                                mobility = value!;
                              });
                            },
                          ),
                          const Text('Yes'),
                          const SizedBox(width: 20),
                          Radio<String>(
                            activeColor: ThemeColor.secondaryColor,
                            value: 'No',
                            groupValue: mobility,
                            onChanged: (value) {
                              setState(() {
                                mobility = value!;
                              });
                            },
                          ),
                          const Text('No'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Harvest Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Radio<String>(
                            activeColor: ThemeColor.secondaryColor,
                            value: 'Yes',
                            groupValue: status,
                            onChanged: (value) {
                              setState(() {
                                status = value!;
                              });
                            },
                          ),
                          const Text('Yes'),
                          const SizedBox(width: 20),
                          Radio<String>(
                            activeColor: ThemeColor.secondaryColor,
                            value: 'No',
                            groupValue: status,
                            onChanged: (value) {
                              setState(() {
                                status = value!;
                              });
                            },
                          ),
                          const Text('No'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(Colors.grey),
                ),
                child: const Text('Cancel'),
              ),
              isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.secondaryColor),
                    )
                  : TextButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                            errorMessage = '';
                          });

                          try {
                            final isMobile = mobility == 'Yes';
                            final isActive = status == 'Yes';

                            // Prepare update data
                            final machineryData = {
                              'machine_name': machineNameController.text,
                              'is_mobile': isMobile,
                              'is_active': isActive,
                            };

                            // Call API to update machinery
                            final result = await _apiService.updateMachinery(machine['id'], machineryData);

                            if (result != null) {
                              await UserActivityService().logActivity(
                                'Edit Machinery',
                                'Updated machinery: ${machineNameController.text}',
                                target: 'Machinery Management',
                              );
                              // Close the dialog and reload the machinery list
                              Navigator.of(dialogContext).pop();
                              _loadMachinery();
                              _successMessage = 'Machine updated successfully';
                            } else {
                              setState(() {
                                isLoading = false;
                                errorMessage = 'Failed to update machinery';
                              });
                            }
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                              errorMessage = 'Error: $e';
                            });
                          }
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(ThemeColor.secondaryColor),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                      ),
                      child: const Text('Update'),
                    ),
            ],
          );
        });
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> machine) async {
    bool isDeleting = false;
    String errorMessage = '';

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Confirm Deletion',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Text(
                  'Are you sure you want to delete the machine "${machine['machine_name']}"?',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This action cannot be undone and will also delete all related repair records.',
                  style: TextStyle(fontSize: 14, color: Colors.red),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(Colors.grey),
                ),
                child: const Text('Cancel'),
              ),
              isDeleting
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    )
                  : TextButton(
                      onPressed: () async {
                        setState(() {
                          isDeleting = true;
                          errorMessage = '';
                        });

                        try {
                          // Call API to delete machinery
                          final success = await _apiService.deleteMachinery(machine['id']);

                          if (success) {
                            await UserActivityService().logActivity(
                              'Delete Machinery',
                              'Deleted machinery: ${machine['machine_name']}',
                              target: 'Machinery Management',
                            );
                            // Close the dialog and reload the machinery list
                            Navigator.of(dialogContext).pop();
                            _loadMachinery();
                            _successMessage = 'Machine deleted successfully';
                          } else {
                            setState(() {
                              isDeleting = false;
                              errorMessage = 'Failed to delete machinery';
                            });
                          }
                        } catch (e) {
                          setState(() {
                            isDeleting = false;
                            errorMessage = 'Error: $e';
                          });
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.red),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                      ),
                      child: const Text('Delete'),
                    ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle tableHeaderStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: ThemeColor.secondaryColor,
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
        child: Column(
          children: [
            // Back arrow and title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MaintenanceNav(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: ThemeColor.secondaryColor,
                    size: 30,
                  ),
                ),
                const Text(
                  "Edit Machine Details",
                  style: TextStyle(
                    color: ThemeColor.secondaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Success or error messages
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_successMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _successMessage,
                  style: const TextStyle(color: Colors.green),
                ),
              ),

            // Refresh button
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: _loadMachinery,
                icon: const Icon(
                  Icons.refresh,
                  color: ThemeColor.secondaryColor,
                ),
                tooltip: 'Refresh data',
              ),
            ),

            // Table content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty && _machinery.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ThemeColor.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : _machinery.isEmpty
                          ? const Center(
                              child: Text('No machinery found'),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: ThemeColor.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: ThemeColor.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Header
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: ThemeColor.secondaryColor.withOpacity(0.1),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'ID',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            'Machine Name',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Mobility',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Harvest Status',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Actions',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Machine List
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _machinery.length,
                                      itemBuilder: (context, index) {
                                        final machine = _machinery[index];
                                        return Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: ThemeColor.grey.withOpacity(0.2),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              // ID
                                              Expanded(
                                                flex: 1,
                                                child: Row(
                                                  children: [
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      Formatters.formatId(machine['id']), // Change from machine['id'].toString()
                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Machine Name
                                              Expanded(
                                                flex: 3,
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.agriculture,
                                                        color: ThemeColor.primaryColor, size: 20),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        machine['machine_name'],
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          color: ThemeColor.primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Mobility
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: machine['is_mobile']
                                                        ? ThemeColor.primaryColor.withOpacity(0.2)
                                                        : ThemeColor.secondaryColor.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    machine['is_mobile'] ? 'Yes' : 'No',
                                                    style: TextStyle(
                                                      color: machine['is_mobile']
                                                          ? ThemeColor.primaryColor
                                                          : ThemeColor.secondaryColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),

                                              // Status
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: machine['is_active']
                                                        ? ThemeColor.primaryColor.withOpacity(0.2)
                                                        : ThemeColor.red.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    machine['is_active'] ? 'Yes' : 'No',
                                                    style: TextStyle(
                                                      color:
                                                          machine['is_active'] ? ThemeColor.primaryColor : Colors.red,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),

                                              // Actions
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        color: ThemeColor.secondaryColor,
                                                      ),
                                                      onPressed: () {
                                                        _showEditMachineDialog(context, machine);
                                                      },
                                                      tooltip: 'Edit',
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () {
                                                        _showDeleteConfirmationDialog(context, machine);
                                                      },
                                                      tooltip: 'Delete',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
            ),
          ],
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
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _riceVarieties = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRiceVarieties();
  }

  Future<void> _loadRiceVarieties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final varieties = await _apiService.getRiceVarieties();
      setState(() {
        _isLoading = false;
        if (varieties != null) {
          _riceVarieties = varieties;
        } else {
          _errorMessage = 'Failed to load rice variety data';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _showEditRiceDialog(BuildContext context, Map<String, dynamic> rice) async {
    final formKey = GlobalKey<FormState>();
    final varietyNameController = TextEditingController(text: rice['variety_name']);
    String qualityGrade = rice['quality_grade'] ?? 'Shatter';
    bool isLoading = false;
    String errorMessage = '';

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: ThemeColor.white,
            title: const Text(
              'Edit Rice Variety',
              style: TextStyle(
                color: ThemeColor.secondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SizedBox(
              width: 400,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: ThemeColor.red),
                        ),
                      ),

                    // Variety Name
                    const Text(
                      'Variety Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ThemeColor.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: varietyNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter variety name",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter variety name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Quality Grade
                    const Text(
                      'Quality Grade',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ThemeColor.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: qualityGrade,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Shatter", child: Text("Shatter")),
                        DropdownMenuItem(value: "Non-Shattering", child: Text("Non-Shattering")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          qualityGrade = value;
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(ThemeColor.grey),
                ),
                child: const Text('Cancel'),
              ),
              isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.secondaryColor),
                    )
                  : TextButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                            errorMessage = '';
                          });

                          try {
                            // Prepare update data - removed dates
                            final riceData = {
                              'variety_name': varietyNameController.text,
                              'quality_grade': qualityGrade,
                            };

                            // Call API to update rice variety
                            final result = await _apiService.updateRiceVariety(rice['id'], riceData);

                            if (result != null) {
                              await UserActivityService().logActivity(
                                'Edit Rice Variety',
                                'Updated rice variety: ${varietyNameController.text}',
                                target: 'Rice Management',
                              );
                              // Close the dialog and reload the rice varieties list
                              Navigator.of(dialogContext).pop();
                              _loadRiceVarieties();
                              _successMessage = 'Rice variety updated successfully';
                            } else {
                              setState(() {
                                isLoading = false;
                                errorMessage = 'Failed to update rice variety';
                              });
                            }
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                              errorMessage = 'Error: $e';
                            });
                          }
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(ThemeColor.secondaryColor),
                        foregroundColor: WidgetStateProperty.all(ThemeColor.white),
                      ),
                      child: const Text('Update'),
                    ),
            ],
          );
        });
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> rice) async {
    bool isDeleting = false;
    String errorMessage = '';

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Confirm Deletion',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Text(
                  'Are you sure you want to delete the rice variety "${rice['variety_name']}"?',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This action cannot be undone and will also delete all related records.',
                  style: TextStyle(fontSize: 14, color: Colors.red),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(Colors.grey),
                ),
                child: const Text('Cancel'),
              ),
              isDeleting
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    )
                  : TextButton(
                      onPressed: () async {
                        setState(() {
                          isDeleting = true;
                          errorMessage = '';
                        });

                        try {
                          // Call API to delete rice variety
                          final success = await _apiService.deleteRiceVariety(rice['id']);

                          if (success) {
                            await UserActivityService().logActivity(
                              'Delete Rice Variety',
                              'Deleted rice variety: ${rice['variety_name']}',
                              target: 'Rice Management',
                            );
                            // Close the dialog and reload the rice varieties list
                            Navigator.of(dialogContext).pop();
                            _loadRiceVarieties();
                            _successMessage = 'Rice variety deleted successfully';
                          } else {
                            setState(() {
                              isDeleting = false;
                              errorMessage = 'Failed to delete rice variety';
                            });
                          }
                        } catch (e) {
                          setState(() {
                            isDeleting = false;
                            errorMessage = 'Error: $e';
                          });
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.red),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                      ),
                      child: const Text('Delete'),
                    ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle tableHeaderStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: ThemeColor.secondaryColor,
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
        child: Column(
          children: [
            // Back arrow and title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MaintenanceNav(),
                      ),
                    );
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

            // Success or error messages
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_successMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _successMessage,
                  style: const TextStyle(color: Colors.green),
                ),
              ),

            // Refresh button
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: _loadRiceVarieties,
                icon: const Icon(
                  Icons.refresh,
                  color: ThemeColor.secondaryColor,
                ),
                tooltip: 'Refresh data',
              ),
            ),

            // Table content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty && _riceVarieties.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ThemeColor.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: ThemeColor.red),
                          ),
                        )
                      : _riceVarieties.isEmpty
                          ? const Center(
                              child: Text('No rice varieties found'),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: ThemeColor.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: ThemeColor.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Header
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: ThemeColor.secondaryColor.withOpacity(0.1),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text('ID', style: tableHeaderStyle),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text('Variety Name', style: tableHeaderStyle),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text('Quality Grade', style: tableHeaderStyle),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text('Actions', style: tableHeaderStyle),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Rice Varieties List
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _riceVarieties.length,
                                      itemBuilder: (context, index) {
                                        final rice = _riceVarieties[index];
                                        return Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: ThemeColor.grey.withOpacity(0.2),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              // ID
                                              Expanded(
                                                flex: 1,
                                                child: Row(
                                                  children: [
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      Formatters.formatId(rice['id']), // Change from rice['id'].toString()
                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Variety Name
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  rice['variety_name'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: ThemeColor.primaryColor,
                                                  ),
                                                ),
                                              ),

                                              // Quality Grade
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: ThemeColor.secondaryColor.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Text(
                                                    rice['quality_grade'],
                                                    style: const TextStyle(
                                                      color: ThemeColor.secondaryColor,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Actions
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () => _showEditRiceDialog(context, rice),
                                                      icon: const Icon(Icons.edit, color: ThemeColor.secondaryColor),
                                                      tooltip: 'Edit',
                                                    ),
                                                    IconButton(
                                                      onPressed: () => _showDeleteConfirmationDialog(context, rice),
                                                      icon: const Icon(Icons.delete, color: ThemeColor.red),
                                                      tooltip: 'Delete',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to determine quality grade color
  Color _getQualityColor(String? grade) {
    switch (grade) {
      case 'Shatter':
        return Colors.purple;
      case 'Non-Shattering':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
