import 'package:flutter/material.dart';
import 'package:pms_frontend/pages/machinerymanagement.dart';

import '../services/api_service.dart';
import '../services/user_activity_service.dart';
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../widget/textfield.dart';
import 'repairstatus.dart';
import '../utils/formatters.dart';

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
      endDrawer: const EndDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Page Header
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
              const SizedBox(height: 40),
              
              // Responsive card layout with size limits
              LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;
                  double scaleFactor = (screenWidth / 1200).clamp(0.7, 1.0); // Conservative scaling
                  
                  // Fixed card dimensions with scaling
                  double cardWidth = 450 * scaleFactor;
                  double cardHeight = 450 * scaleFactor;
                  double iconSize = 225 * scaleFactor;
                  double fontSize = 24 * scaleFactor;
                  double spacing = 40 * scaleFactor;
                  
                  // Clamp to reasonable limits
                  cardWidth = cardWidth.clamp(350.0, 450.0);
                  cardHeight = cardHeight.clamp(350.0, 450.0);
                  iconSize = iconSize.clamp(180.0, 225.0);
                  fontSize = fontSize.clamp(20.0, 24.0);
                  spacing = spacing.clamp(30.0, 40.0);
                  
                  return Center( // Center the content
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildRepairCard(
                          context,
                          "Repair Status",
                          Icons.handyman_outlined,
                          cardWidth,
                          cardHeight,
                          iconSize,
                          fontSize,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RepairstatusNav())),
                        ),
                        _buildRepairCard(
                          context,
                          "Create Repair Order",
                          Icons.receipt_long_outlined,
                          cardWidth,
                          cardHeight,
                          iconSize,
                          fontSize,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRepairOrder())),
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

  // Add this helper method with fixed dimensions
  Widget _buildRepairCard(BuildContext context, String title, IconData icon,
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
  String _partsConcerned = '';

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

  // Update the _createRepair method
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

      if (result != null) {
        // Set repairs_needed to true for the selected machinery
        final machineryUpdateData = {
          'repairs_needed': true,
        };
        
        // Update the machinery to indicate it needs repairs
        await _apiService.updateMachinery(_selectedMachineryId!, machineryUpdateData);
        
        // Log the activity for both repair creation and machinery update
        await UserActivityService().logActivity(
          'Create Repair Order',
          'Created repair order for machinery ID: ${Formatters.formatId(_selectedMachineryId!)}',
          target: 'Repair Management',
        );
      }

      setState(() {
        _isLoading = false;
        if (result != null) {
          _successMessage = 'Repair order created successfully! Machinery status updated to "Repairs Needed".';
          // Clear form
          _issueController.clear();
          _partsConcerned = '';
          _status = 'pending';
          _isUrgent = false;
          // Reset machinery selection
          if (_machinery.isNotEmpty) {
            _selectedMachineryId = _machinery[0]['id'];
          }
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
      endDrawer: const EndDrawer(),
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
                          style: const TextStyle(color: ThemeColor.red),
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
                              color: ThemeColor.red,
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
                                    child: Text('${Formatters.formatId(machinery['id'])} - ${machinery['machine_name']}'),
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
                              color: ThemeColor.red,
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

                    // Parts Concerned dropdown
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
                          value: '',
                          child: Text("Select Part"),
                        ),
                        DropdownMenuItem(
                          value: 'Reaper',
                          child: Text("Reaper"),
                        ),
                        DropdownMenuItem(
                          value: 'Crop & Straw Conveyance',
                          child: Text("Crop & Straw Conveyance"),
                        ),
                        DropdownMenuItem(
                          value: 'Threshing',
                          child: Text("Threshing"),
                        ),
                        DropdownMenuItem(
                          value: 'Grain Cleaning',
                          child: Text("Grain Cleaning"),
                        ),
                        DropdownMenuItem(
                          value: 'Grain Storage & Dispensing',
                          child: Text("Grain Storage & Dispensing"),
                        ),
                        DropdownMenuItem(
                          value: 'Straw Dispensing System',
                          child: Text("Straw Dispensing System"),
                        ),
                        DropdownMenuItem(
                          value: 'Engine',
                          child: Text("Engine"),
                        ),
                        DropdownMenuItem(
                          value: 'Transmission',
                          child: Text("Transmission"),
                        ),
                        DropdownMenuItem(
                          value: 'Lubrication Systems',
                          child: Text("Lubrication Systems"),
                        ),
                        DropdownMenuItem(
                          value: 'Chassis',
                          child: Text("Chassis"),
                        ),
                        DropdownMenuItem(
                          value: 'Control System',
                          child: Text("Control System"),
                        ),
                        DropdownMenuItem(
                          value: 'Tracks',
                          child: Text("Tracks"),
                        ),
                        DropdownMenuItem(
                          value: 'Electrical ',
                          child: Text("Electrical "),
                        ),
                        DropdownMenuItem(
                          value: 'General',
                          child: Text("General"),
                        ),
                        DropdownMenuItem(
                          value: 'Others',
                          child: Text("Others"),
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
                      onChanged: (value) {
                        setState(() {
                          _isUrgent = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createRepair,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: ThemeColor.secondaryColor,
                            foregroundColor: ThemeColor.white,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.white),
                                )
                              : const Text(
                                  'Create Repair Order',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
