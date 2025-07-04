import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/user_activity_service.dart';
import '../theme/colors.dart';
import '../theme/inputtheme.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../widget/textfield.dart';
import '../utils/formatters.dart';
import '../utils/responsive_helper.dart';
import 'backup.dart';

class MaintenanceNav extends StatelessWidget {
  const MaintenanceNav({super.key});

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Page Header
              const Text(
                "Maintenance",
                style: TextStyle(
                  color: ThemeColor.secondaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              
              LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;
                  double scaleFactor = (screenWidth / 1200).clamp(0.7, 0.9); // Increased scaling factor

                  // Increased card dimensions
                  double cardWidth = 380 * scaleFactor; // Increased from 320
                  double cardHeight = 380 * scaleFactor; // Increased from 320
                  double iconSize = 180 * scaleFactor; // Increased from 190
                  double fontSize = 22 * scaleFactor; // Increased from 20
                  double spacing = 35 * scaleFactor; // Increased from 30

                  // Ensure cards don't get too big or too small with updated limits
                  cardWidth = cardWidth.clamp(300.0, 380.0); // Increased from 250-320
                  cardHeight = cardHeight.clamp(300.0, 380.0); // Increased from 250-320
                  iconSize = iconSize.clamp(140.0, 180.0); // Increased from 120-160
                  fontSize = fontSize.clamp(18.0, 22.0); // Increased from 16-20
                  spacing = spacing.clamp(25.0, 35.0); // Increased from 20-30
                  
                  return Center( // Center the content
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildMaintenanceCard(
                          context,
                          "Edit Machine Details",
                          Icons.agriculture,
                          cardWidth,
                          cardHeight,
                          iconSize,
                          fontSize,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditMachinery())),
                        ),
                        _buildMaintenanceCard(
                          context,
                          "Edit Rice Variety",
                          Icons.grass,
                          cardWidth,
                          cardHeight,
                          iconSize,
                          fontSize,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditRice())),
                        ),
                        _buildMaintenanceCard(
                          context,
                          "Edit Users",
                          Icons.people,
                          cardWidth,
                          cardHeight,
                          iconSize,
                          fontSize,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditUsers())),
                        ),
                        _buildMaintenanceCard(
                          context,
                          "Back Up",
                          Icons.backup,
                          cardWidth,
                          cardHeight,
                          iconSize,
                          fontSize,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BackUpNav())),
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

  Widget _buildMaintenanceCard(BuildContext context, String title, IconData icon, 
      double cardWidth, double cardHeight, double iconSize, double fontSize, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: ThemeColor.white2,
          boxShadow: [
            BoxShadow(
              color: ThemeColor.grey.withOpacity(0.2),
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
    final hourMeterController = TextEditingController(text: '${machine['hour_meter'] ?? 0}');
    bool mobility = machine['is_mobile'] ?? false;
    bool status = machine['is_active'] ?? false;
    bool isLoading = false;
    String errorMessage = '';

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: ThemeColor.white,
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
                            style: const TextStyle(color: ThemeColor.red),
                          ),
                        ),

                      // Machine Name field
                      const Text(
                        'Machine Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.primaryColor,
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

                      // Hour Meter field
                      const Text(
                        'Hour Meter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ThemedTextFormField(
                        controller: hourMeterController,
                        hintText: 'Enter hour meter reading',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter hour meter reading';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Mobility field with radio buttons
                      const Text(
                        'Mobility',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Radio<bool>(
                            fillColor: MaterialStateProperty.all(ThemeColor.secondaryColor),
                            value: true,
                            groupValue: mobility,
                            onChanged: (bool? value) {
                              setState(() {
                                mobility = value!;
                              });
                            },
                          ),
                          const Text('Yes'),
                          const SizedBox(width: 20),
                          Radio<bool>(
                            fillColor: MaterialStateProperty.all(ThemeColor.secondaryColor),
                            value: false,
                            groupValue: mobility,
                            onChanged: (bool? value) {
                              setState(() {
                                mobility = value!;
                              });
                            },
                          ),
                          const Text('No'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Harvest Status field with radio buttons
                      const Text(
                        'Harvest Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Radio<bool>(
                            fillColor: MaterialStateProperty.all(ThemeColor.secondaryColor),
                            value: true,
                            groupValue: status,
                            onChanged: (bool? value) {
                              setState(() {
                                status = value!;
                              });
                            },
                          ),
                          const Text('Yes'),
                          const SizedBox(width: 20),
                          Radio<bool>(
                            fillColor: MaterialStateProperty.all(ThemeColor.secondaryColor),
                            value: false,
                            groupValue: status,
                            onChanged: (bool? value) {
                              setState(() {
                                status = value!;
                              });
                            },
                          ),
                          const Text('No'),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                            final hourMeter = int.parse(hourMeterController.text);

                            // Prepare update data
                            final machineryData = {
                              'machine_name': machineNameController.text,
                              'is_mobile': mobility,
                              'is_active': status,
                              'hour_meter': hourMeter,
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
                color: ThemeColor.red,
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
                      style: const TextStyle(color: ThemeColor.red),
                    ),
                  ),
                Text(
                  'Are you sure you want to delete the machine "${machine['machine_name']}"?',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This action cannot be undone and will also delete all related repair records.',
                  style: TextStyle(fontSize: 14, color: ThemeColor.red),
                ),
              ],
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
              isDeleting
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.red),
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
                        backgroundColor: WidgetStateProperty.all(ThemeColor.red),
                        foregroundColor: WidgetStateProperty.all(ThemeColor.white),
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
                  style: const TextStyle(color: ThemeColor.red),
                ),
              ),
            if (_successMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _successMessage,
                  style: const TextStyle(color: ThemeColor.green),
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
                            style: const TextStyle(color: ThemeColor.red),
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
                                            textAlign: TextAlign.center,
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
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Hour Meter',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Repairs Needed',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                            textAlign: TextAlign.center,
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
                                                      Formatters.formatId(machine['id']),
                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),

                                              // Machine Name
                                              Expanded(
                                                flex: 3,
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.agriculture, color: ThemeColor.primaryColor, size: 16),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        machine['machine_name'] ?? 'Unknown',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          color: ThemeColor.primaryColor,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),

                                              // Mobility
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    constraints: const BoxConstraints(
                                                      minWidth: 40,
                                                      maxWidth: 60,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: (machine['is_mobile'] == true)
                                                          ? ThemeColor.green.withOpacity(0.1)
                                                          : ThemeColor.secondaryColor.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      (machine['is_mobile'] == true) ? 'Yes' : 'No',
                                                      style: TextStyle(
                                                        color: (machine['is_mobile'] == true) ? ThemeColor.green : ThemeColor.secondaryColor,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 11,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),

                                              // Harvest Status
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    constraints: const BoxConstraints(
                                                      minWidth: 40,
                                                      maxWidth: 60,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: (machine['is_active'] == true)
                                                          ? ThemeColor.green.withOpacity(0.1)
                                                          : ThemeColor.red.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      (machine['is_active'] == true) ? 'Yes' : 'No',
                                                      style: TextStyle(
                                                        color: (machine['is_active'] == true) ? ThemeColor.green : ThemeColor.red,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 11,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),

                                              // Hour Meter
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.schedule, color: ThemeColor.secondaryColor, size: 16),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '${machine['hour_meter'] ?? 0} hrs',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: ThemeColor.secondaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),

                                              // Repairs Needed
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    constraints: const BoxConstraints(
                                                      minWidth: 40,
                                                      maxWidth: 60,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: (machine['needs_repair'] == true)
                                                          ? ThemeColor.red.withOpacity(0.1)
                                                          : ThemeColor.green.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      (machine['needs_repair'] == true) ? 'Yes' : 'No',
                                                      style: TextStyle(
                                                        color: (machine['needs_repair'] == true) ? ThemeColor.red : ThemeColor.green,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 11,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),

                                              // Actions
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    // Edit button
                                                    IconButton(
                                                      onPressed: () => _showEditMachineDialog(context, machine),
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        color: ThemeColor.secondaryColor,
                                                        size: 20,
                                                      ),
                                                      constraints: const BoxConstraints(
                                                        minWidth: 32,
                                                        minHeight: 32,
                                                      ),
                                                      tooltip: 'Edit machine',
                                                    ),
                                                    const SizedBox(width: 8),
                                                    // Delete button
                                                    IconButton(
                                                      onPressed: () => _showDeleteConfirmationDialog(context, machine),
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: ThemeColor.red,
                                                        size: 20,
                                                      ),
                                                      constraints: const BoxConstraints(
                                                        minWidth: 32,
                                                        minHeight: 32,
                                                      ),
                                                      tooltip: 'Delete machine',
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
    final expectedYieldController = TextEditingController(
      text: rice['expected_yield_per_hectare']?.toString() ?? ''
    );
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
                    ThemedTextFormField(
                      controller: varietyNameController,
                      hintText: 'Enter variety name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter variety name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Quality Grade dropdown
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
                      style: InputTheme.inputTextStyle,
                      decoration: InputTheme.getInputDecoration('Select quality grade'),
                      items: ['Shatter', 'Non-Shattering'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          qualityGrade = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Expected Yield field
                    const Text(
                      'Expected Yield (kg/ha)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ThemeColor.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ThemedTextFormField(
                      controller: expectedYieldController,
                      hintText: 'Expected yield per hectare (optional)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'This baseline yield helps predict harvest amounts when farmers plant this variety',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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
                            final updateData = <String, dynamic>{
                              'variety_name': varietyNameController.text,
                              'quality_grade': qualityGrade,
                            };

                            // Add expected yield if provided
                            if (expectedYieldController.text.isNotEmpty) {
                              updateData['expected_yield_per_hectare'] = double.parse(expectedYieldController.text);
                            } else {
                              updateData['expected_yield_per_hectare'] = null;
                            }

                            final result = await _apiService.updateRiceVariety(rice['id'], updateData);

                            if (result != null) {
                              await UserActivityService().logActivity(
                                'Edit Rice Variety',
                                'Updated rice variety: ${varietyNameController.text}',
                                target: 'Rice Management',
                              );
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
                color: ThemeColor.red,
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
                      style: const TextStyle(color: ThemeColor.red),
                    ),
                  ),
                Text(
                  'Are you sure you want to delete the rice variety "${rice['variety_name']}"?',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This action cannot be undone and will also delete all related records.',
                  style: TextStyle(fontSize: 14, color: ThemeColor.red),
                ),
              ],
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
              isDeleting
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.red),
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
                        backgroundColor: WidgetStateProperty.all(ThemeColor.red),
                        foregroundColor: WidgetStateProperty.all(ThemeColor.white),
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
                  style: const TextStyle(color: ThemeColor.red),
                ),
              ),
            if (_successMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _successMessage,
                  style: const TextStyle(color: ThemeColor.green),
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
                                                      Formatters.formatId(rice['id']),
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
        return ThemeColor.green;
      default:
        return ThemeColor.grey;
    }
  }
}

class EditUsers extends StatefulWidget {
  const EditUsers({super.key});

  @override
  State<EditUsers> createState() => _EditUsersState();
}

class _EditUsersState extends State<EditUsers> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final users = await _apiService.getUsers();
      setState(() {
        _isLoading = false;
        if (users != null) {
          _users = users;
        } else {
          _errorMessage = 'Failed to load user data';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _showEditUserDialog(BuildContext context, Map<String, dynamic> user) async {
    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController(text: user['username']);
    final securityAnswerController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    // Predefined security questions
    final List<String> securityQuestions = [
      'What is your favorite color?',
      'What is your mother\'s maiden name?',
      'What was your first pet\'s name?',
      'What city were you born in?',
      'What is your favorite food?'
    ];
    
    // Ensure the security question from the database matches one of our options
    String securityQuestion = user['security_question'] ?? 'What is your favorite color?';
    if (!securityQuestions.contains(securityQuestion)) {
      securityQuestion = 'What is your favorite color?'; // Default fallback
    }
    
    bool isAdmin = user['is_admin'] ?? false;
    bool isLoading = false;
    String errorMessage = '';

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: ThemeColor.white,
            title: const Text(
              'Edit User Details',
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
                            style: const TextStyle(color: ThemeColor.red),
                          ),
                        ),

                      // Username field (read-only)
                      const Text(
                        'Username',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ThemedTextFormField(
                        controller: usernameController,
                        readOnly: true,
                        hintText: 'Username',
                      ),
                      const SizedBox(height: 16),

                      // New Password field
                      const Text(
                        'New Password (optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ThemedTextFormField(
                        controller: passwordController,
                        obscureText: true,
                        hintText: 'Leave blank to keep current password',
                        validator: (value) {
                          if (value != null && value.isNotEmpty && value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password field
                      const Text(
                        'Confirm Password (if changing password)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ThemedTextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        hintText: 'Confirm new password',
                        validator: (value) {
                          if (passwordController.text.isNotEmpty) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm new password';
                            }
                            if (value != passwordController.text) {
                              return 'Passwords do not match';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Security Question field
                      const Text(
                        'Security Question',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: securityQuestion,
                        style: InputTheme.inputTextStyle,
                        decoration: InputTheme.getInputDecoration('Select security question'),
                        items: securityQuestions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            securityQuestion = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Security Answer field
                      const Text(
                        'Security Answer (optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ThemedTextFormField(
                        controller: securityAnswerController,
                        hintText: 'Enter security answer',
                      ),
                      const SizedBox(height: 16),

                      // Admin Status checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: isAdmin,
                            onChanged: (bool? value) {
                              setState(() {
                                isAdmin = value ?? false;
                              });
                            },
                          ),
                          const Text(
                            'Administrator privileges',
                            style: TextStyle(
                              fontSize: 16,
                              color: ThemeColor.primaryColor,
                            ),
                          ),
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
                            // Prepare update data
                            final userData = <String, dynamic>{
                              'security_question': securityQuestion,
                              'is_admin': isAdmin,
                            };

                            // Only include password if provided
                            if (passwordController.text.isNotEmpty) {
                              userData['password'] = passwordController.text;
                            }

                            // Only include security answer if provided
                            if (securityAnswerController.text.isNotEmpty) {
                              userData['security_answer'] = securityAnswerController.text;
                            }

                            // Call API to update user
                            final result = await _apiService.updateUser(user['id'], userData);

                            if (result != null) {
                              await UserActivityService().logActivity(
                                'Edit User',
                                'Updated user: ${user['username']} ${passwordController.text.isNotEmpty ? '(password changed)' : ''}',
                                target: 'User Management',
                              );
                              // Close the dialog and reload the users list
                              Navigator.of(dialogContext).pop();
                              _loadUsers();
                              _successMessage = 'User updated successfully${passwordController.text.isNotEmpty ? ' (password changed)' : ''}';
                            } else {
                              setState(() {
                                isLoading = false;
                                errorMessage = 'Failed to update user';
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

  Future<void> _showDeleteUserDialog(BuildContext context, Map<String, dynamic> user) async {
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
                color: ThemeColor.red,
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
                      style: const TextStyle(color: ThemeColor.red),
                    ),
                  ),
                Text(
                  'Are you sure you want to delete the user "${user['username']}"?',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This action cannot be undone and will also delete all related activity logs.',
                  style: TextStyle(fontSize: 14, color: ThemeColor.red),
                ),
              ],
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
              isDeleting
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.red),
                    )
                  : TextButton(
                      onPressed: () async {
                        setState(() {
                          isDeleting = true;
                          errorMessage = '';
                        });

                        try {
                          // Call API to delete user
                          final success = await _apiService.deleteUser(user['id']);

                          if (success) {
                            await UserActivityService().logActivity(
                              'Delete User',
                              'Deleted user: ${user['username']}',
                              target: 'User Management',
                            );
                            // Close the dialog and reload the users list
                            Navigator.of(dialogContext).pop();
                            _loadUsers();
                            _successMessage = 'User deleted successfully';
                          } else {
                            setState(() {
                              isDeleting = false;
                              errorMessage = 'Failed to delete user';
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
                        backgroundColor: WidgetStateProperty.all(ThemeColor.red),
                        foregroundColor: WidgetStateProperty.all(ThemeColor.white),
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
                  "Edit Users",
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
                  style: const TextStyle(color: ThemeColor.red),
                ),
              ),
            if (_successMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _successMessage,
                  style: const TextStyle(color: ThemeColor.green),
                ),
              ),

            // Refresh button
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: _loadUsers,
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
                  : _errorMessage.isNotEmpty && _users.isEmpty
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
                      : _users.isEmpty
                          ? const Center(
                              child: Text('No users found'),
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
                                            style: tableHeaderStyle,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            'Username',
                                            style: tableHeaderStyle,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Admin Status',
                                            style: tableHeaderStyle,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            'Security Question',
                                            style: tableHeaderStyle,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Actions',
                                            style: tableHeaderStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // User List
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _users.length,
                                      itemBuilder: (context, index) {
                                        final user = _users[index];
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
                                                      Formatters.formatId(user['id']),
                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Username
                                              Expanded(
                                                flex: 3,
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.person,
                                                        color: ThemeColor.primaryColor, size: 20),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        user['username'],
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          color: ThemeColor.primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Admin Status
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: user['is_admin']
                                                        ? ThemeColor.secondaryColor.withOpacity(0.2)
                                                        : ThemeColor.primaryColor.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    user['is_admin'] ? 'Admin' : 'User',
                                                    style: TextStyle(
                                                      color: user['is_admin']
                                                          ? ThemeColor.secondaryColor
                                                          : ThemeColor.primaryColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),

                                              // Security Question
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  user['security_question'] ?? 'Not set',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
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
                                                        _showEditUserDialog(context, user);
                                                      },
                                                      tooltip: 'Edit',
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: ThemeColor.red,
                                                      ),
                                                      onPressed: () {
                                                        _showDeleteUserDialog(context, user);
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
