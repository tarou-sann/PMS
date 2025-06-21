import 'package:flutter/material.dart';
import 'package:pms_frontend/pages/machinerymanagement.dart';

import '../services/api_service.dart';
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../widget/textfield.dart';
import 'repairstatus.dart';

class RepairNav extends StatelessWidget {
  const RepairNav({super.key});

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
      endDrawer: const EndDrawer_Admin(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MachineryManagementNav()));
                      },
                      icon: const Icon(Icons.arrow_back_ios),
                      color: ThemeColor.secondaryColor,
                      iconSize: 30,
                  ),
                  const Text(
                    "Repairs",
                    style: TextStyle(
                      color: ThemeColor.secondaryColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RepairstatusNav()));
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
                              Icons.handyman_outlined,
                              weight: 200,
                              size: 225,
                              color: ThemeColor.secondaryColor,
                            ),
                            Text(
                              "Repair Status",
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRepairOrder()));
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
                              Icons.receipt_long_outlined,
                              weight: 22,
                              size: 225,
                              color: ThemeColor.secondaryColor,
                            ),
                            Text(
                              "Create Repair Order",
                              style: TextStyle(fontSize: 24),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateRepairOrder extends StatefulWidget {
  const CreateRepairOrder({super.key});

  @override
  State<CreateRepairOrder> createState() => _CreateRepairOrderState();
}

class _CreateRepairOrderState extends State<CreateRepairOrder> {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _issueController = TextEditingController();

  // State variables
  int? _selectedMachineryId;
  String _status = 'pending';
  bool _isUrgent = false;
  bool _isLoading = false;
  bool _isLoadingMachinery = true;
  String _errorMessage = '';
  String _successMessage = '';
  List<Map<String, dynamic>> _machinery = [];
  String _partsConcerned = 'Engine';

  // Services
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadMachinery();
  }

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  Future<void> _loadMachinery() async {
    try {
      final machinery = await _apiService.getMachinery();
      setState(() {
        _isLoadingMachinery = false;
        if (machinery != null) {
          _machinery = machinery;
          // Preselect the first machinery if available
          if (_machinery.isNotEmpty) {
            _selectedMachineryId = _machinery[0]['id'];
          }
        } else {
          _errorMessage = 'Failed to load machinery data';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingMachinery = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _createRepair() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMachineryId == null) {
      setState(() {
        _errorMessage = 'Please select a machinery';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final repairData = {
        'machinery_id': _selectedMachineryId,
        'issue_description': _issueController.text,
        'status': _status,
        'notes': _partsConcerned,
        'is_urgent': _isUrgent,
      };

      final result = await _apiService.createRepair(repairData);

      setState(() {
        _isLoading = false;
        if (result != null) {
          _successMessage = 'Repair order created successfully!';
          // Clear form
          _issueController.clear();
          _partsConcerned = 'Engine';
          _status = 'pending';
          _isUrgent = false;
        } else {
          _errorMessage = 'Failed to create repair order';
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

    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDrawer_Admin(),
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
                            Navigator.pop(context, MaterialPageRoute(builder: (context) => const RepairNav()));
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: ThemeColor.secondaryColor,
                            size: 30,
                          ),
                        ),
                        const Text(
                          "Create Repair Order",
                          style: TextStyle(
                            color: ThemeColor.secondaryColor,
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Messages
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    if (_successMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _successMessage,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),

                    // Machinery Selection
                    RichText(
                      text: const TextSpan(
                        text: 'Select Machinery',
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
                    _isLoadingMachinery
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.secondaryColor),
                            ),
                          )
                        : _machinery.isEmpty
                            ? const Text('No machinery available. Please add machinery first.')
                            : DropdownButtonFormField<int>(
                                value: _selectedMachineryId,
                                dropdownColor: ThemeColor.white2,
                                focusColor: ThemeColor.white2,
                                items: _machinery.map((machinery) {
                                  return DropdownMenuItem<int>(
                                    value: machinery['id'],
                                    child: Text(machinery['machine_name']),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMachineryId = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  focusedBorder:
                                      OutlineInputBorder(borderSide: BorderSide(color: ThemeColor.primaryColor)),
                                ),
                              ),
                    const SizedBox(height: 20),

                    // Issue Description
                    RichText(
                      text: const TextSpan(
                        text: 'Issue Description',
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
                    ThemedTextFormField(
                      controller: _issueController,
                      hintText: 'Describe the issue with the machinery',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter issue description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Parts Concerned dropdown (replacing the Additional Notes field)
                    const Text(
                      'Parts Concerned',
                      style: labelStyle,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _partsConcerned,
                      dropdownColor: ThemeColor.white2,
                      focusColor: ThemeColor.white2,
                      items: const [
                        DropdownMenuItem(
                          value: 'Engine',
                          child: Text("Engine"),
                        ),
                        DropdownMenuItem(
                          value: 'Transmission',
                          child: Text("Transmission"),
                        ),
                        DropdownMenuItem(
                          value: 'Electrical',
                          child: Text("Electrical"),
                        ),
                        DropdownMenuItem(
                          value: 'Hydraulics',
                          child: Text("Hydraulics"),
                        ),
                        DropdownMenuItem(
                          value: 'Controls',
                          child: Text("Controls"),
                        ),
                        DropdownMenuItem(
                          value: 'Structure',
                          child: Text("Structure"),
                        ),
                        DropdownMenuItem(
                          value: 'Other',
                          child: Text("Other"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _partsConcerned = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ThemeColor.primaryColor)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Status
                    const Text(
                      'Status',
                      style: labelStyle,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _status,
                      dropdownColor: ThemeColor.white2,
                      focusColor: ThemeColor.white2,
                      items: const [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text("Pending"),
                        ),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text("In Progress"),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text("Completed"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _status = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ThemeColor.primaryColor)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Urgent Checkbox
                    CheckboxListTile(
                      title: const Text('Mark as Urgent', style: labelStyle),
                      value: _isUrgent,
                      activeColor: ThemeColor.secondaryColor,
                      onChanged: (bool? value) {
                        setState(() {
                          _isUrgent = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),

                    const SizedBox(height: 30),

                    // Submit Button
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.secondaryColor),
                            )
                          : TextButton(
                              onPressed: _createRepair,
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
                                "Create Repair Order",
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
      ),
    );
  }
}
