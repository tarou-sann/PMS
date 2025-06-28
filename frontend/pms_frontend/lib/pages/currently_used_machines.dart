import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/user_activity_service.dart';
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../widget/textfield.dart';
import '../utils/formatters.dart';
import 'machinespage.dart';

class CurrentlyUsedMachines extends StatefulWidget {
  const CurrentlyUsedMachines({super.key});

  @override
  State<CurrentlyUsedMachines> createState() => _CurrentlyUsedMachinesState();
}

class _CurrentlyUsedMachinesState extends State<CurrentlyUsedMachines> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _activeAssignments = [];
  List<Map<String, dynamic>> _availableMachinery = [];
  bool _isLoading = true;
  bool _isLoadingMachinery = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadActiveAssignments(),
      _loadAvailableMachinery(),
    ]);
  }

  Future<void> _loadActiveAssignments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final assignments = await _apiService.getActiveAssignments();
      setState(() {
        _isLoading = false;
        if (assignments != null) {
          _activeAssignments = assignments;
        } else {
          _errorMessage = 'Failed to load active assignments';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _loadAvailableMachinery() async {
    setState(() {
      _isLoadingMachinery = true;
    });

    try {
      print('Loading available machinery...');  // Debug log
      final machinery = await _apiService.getAvailableMachinery();
      
      print('Available machinery result: $machinery');  // Debug log
      
      setState(() {
        _isLoadingMachinery = false;
        if (machinery != null) {
          _availableMachinery = machinery;
          print('Loaded ${_availableMachinery.length} available machines');
          
          // Clear any previous error if successful
          if (_errorMessage.contains('Failed to load available machinery')) {
            _errorMessage = '';
          }
        } else {
          _availableMachinery = [];
          print('No available machinery returned (null response)');
          // Don't set error message for empty list, as it might be legitimate
        }
      });
    } catch (e) {
      print('Error loading available machinery: $e');  // Debug log
      setState(() {
        _isLoadingMachinery = false;
        _availableMachinery = [];
        
        // Only show error if it's a real connection/server error
        if (e.toString().contains('Failed host lookup') || 
            e.toString().contains('Connection refused') ||
            e.toString().contains('SocketException')) {
          _errorMessage = 'Connection error: Please check your network connection.';
        } else {
          _errorMessage = 'Failed to load available machinery. Please try refreshing.';
        }
      });
    }
  }

  Future<void> _showAssignMachineDialog() async {
    // Refresh available machinery before showing dialog
    await _loadAvailableMachinery();
    
    if (_availableMachinery.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'No machines available for assignment.\n'
            '• Machines must be mobile and active\n'
            '• Machines cannot need repairs\n'
            '• Machines cannot be currently assigned',
          ),
          backgroundColor: ThemeColor.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Refresh',
            textColor: ThemeColor.white,
            onPressed: () {
              _loadData(); // Refresh all data
            },
          ),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final renteeController = TextEditingController();
    final hourMeterController = TextEditingController();
    final notesController = TextEditingController();
    int? selectedMachineryId = _availableMachinery.isNotEmpty ? _availableMachinery[0]['id'] : null;
    bool isLoading = false;
    String errorMessage = '';

    // Set initial hour meter value
    if (selectedMachineryId != null) {
      final selectedMachine = _availableMachinery.firstWhere((m) => m['id'] == selectedMachineryId);
      hourMeterController.text = '${selectedMachine['hour_meter'] ?? 0}';
    }

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: ThemeColor.white,
            title: const Text(
              'Assign Machine for Daily Use',
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

                      // Machine Selection
                      const Text(
                        'Select Machine',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: selectedMachineryId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Choose a machine',
                        ),
                        items: _availableMachinery.map((machine) {
                          return DropdownMenuItem<int>(
                            value: machine['id'],
                            child: Text(
                              '${machine['machine_name']} (${machine['hour_meter']} hrs)',
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMachineryId = value;
                            if (value != null) {
                              final selectedMachine = _availableMachinery.firstWhere((m) => m['id'] == value);
                              hourMeterController.text = '${selectedMachine['hour_meter'] ?? 0}';
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a machine';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Rentee Name
                      const Text(
                        'Rentee Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ThemedTextFormField(
                        controller: renteeController,
                        hintText: 'Enter rentee name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter rentee name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Hour Meter
                      const Text(
                        'Current Hour Meter Reading',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ThemedTextFormField(
                        controller: hourMeterController,
                        hintText: 'Enter current hour meter reading',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter hour meter reading';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          if (selectedMachineryId != null) {
                            final selectedMachine = _availableMachinery.firstWhere((m) => m['id'] == selectedMachineryId);
                            final currentMeter = selectedMachine['hour_meter'] ?? 0;
                            if (int.parse(value) < currentMeter) {
                              return 'Hour meter cannot be less than current reading ($currentMeter)';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Notes (Optional)
                      const Text(
                        'Notes (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ThemedTextFormField(
                        controller: notesController,
                        hintText: 'Enter any additional notes',
                        maxLines: 3,
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
                            final assignmentData = {
                              'machinery_id': selectedMachineryId,
                              'rentee_name': renteeController.text,
                              'start_hour_meter': int.parse(hourMeterController.text),
                              'notes': notesController.text.isNotEmpty ? notesController.text : null,
                            };

                            final result = await _apiService.createAssignment(assignmentData);

                            if (result != null) {
                              await UserActivityService().logActivity(
                                'Assign Machine',
                                'Assigned machine to ${renteeController.text}',
                                target: 'Machine Assignment',
                              );
                              
                              // Close dialog and refresh data
                              Navigator.of(dialogContext).pop();
                              await _loadData();
                              setState(() {
                                _successMessage = 'Machine assigned successfully!';
                              });
                            } else {
                              setState(() {
                                isLoading = false;
                                errorMessage = 'Failed to assign machine';
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
                      child: const Text('Assign Machine'),
                    ),
            ],
          );
        });
      },
    );
  }

  Future<void> _showReturnMachineDialog(Map<String, dynamic> assignment) async {
    final formKey = GlobalKey<FormState>();
    final endHourMeterController = TextEditingController(text: '${assignment['start_hour_meter']}');
    final notesController = TextEditingController(text: assignment['notes'] ?? '');
    bool isLoading = false;
    String errorMessage = '';

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: ThemeColor.white,
            title: const Text(
              'Return Machine',
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

                    // Assignment Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ThemeColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Machine: ${assignment['machinery_name']}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text('Rentee: ${assignment['rentee_name']}'),
                          Text('Start Hour Meter: ${assignment['start_hour_meter']} hrs'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // End Hour Meter
                    const Text(
                      'End Hour Meter Reading',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ThemeColor.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ThemedTextFormField(
                      controller: endHourMeterController,
                      hintText: 'Enter final hour meter reading',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter end hour meter reading';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (int.parse(value) < assignment['start_hour_meter']) {
                          return 'End hour meter cannot be less than start meter (${assignment['start_hour_meter']})';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    const Text(
                      'Return Notes (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ThemeColor.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ThemedTextFormField(
                      controller: notesController,
                      hintText: 'Enter return notes',
                      maxLines: 3,
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
                      valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.primaryColor),
                    )
                  : TextButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                            errorMessage = '';
                          });

                          try {
                            final returnData = {
                              'end_hour_meter': int.parse(endHourMeterController.text),
                              'notes': notesController.text.isNotEmpty ? notesController.text : null,
                            };

                            final result = await _apiService.returnAssignment(assignment['id'], returnData);

                            if (result != null) {
                              await UserActivityService().logActivity(
                                'Return Machine',
                                'Returned machine from ${assignment['rentee_name']}',
                                target: 'Machine Assignment',
                              );
                              
                              // Close dialog and refresh data
                              Navigator.of(dialogContext).pop();
                              await _loadData();
                              setState(() {
                                _successMessage = 'Machine returned successfully!';
                              });
                            } else {
                              setState(() {
                                isLoading = false;
                                errorMessage = 'Failed to return machine';
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
                        backgroundColor: WidgetStateProperty.all(ThemeColor.primaryColor),
                        foregroundColor: WidgetStateProperty.all(ThemeColor.white),
                      ),
                      child: const Text('Return Machine'),
                    ),
            ],
          );
        });
      },
    );
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
        child: Column(
          children: [
            // Header with back button
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
                  "Currently Used Machines",
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

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoadingMachinery ? null : _showAssignMachineDialog,
                  icon: _isLoadingMachinery 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.white),
                          ),
                        )
                      : const Icon(Icons.add, color: ThemeColor.white),
                  label: Text(
                    _isLoadingMachinery ? 'Loading...' : 'Assign Machine',
                    style: const TextStyle(color: ThemeColor.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColor.secondaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                Row(
                  children: [
                    if (_isLoadingMachinery)
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Text(
                          'Loading machinery...',
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeColor.grey,
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: _loadData,
                      icon: const Icon(
                        Icons.refresh,
                        color: ThemeColor.secondaryColor,
                      ),
                      tooltip: 'Refresh all data',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Active assignments table
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _activeAssignments.isEmpty
                      ? const Center(
                          child: Text(
                            'No machines currently assigned',
                            style: TextStyle(fontSize: 16, color: ThemeColor.grey),
                          ),
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
                              // Table Header
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
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Machine',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: ThemeColor.secondaryColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Rentee',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: ThemeColor.secondaryColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Start Hour Meter',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: ThemeColor.secondaryColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Assignment Date',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: ThemeColor.secondaryColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'Actions',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: ThemeColor.secondaryColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Table Body
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _activeAssignments.length,
                                  itemBuilder: (context, index) {
                                    final assignment = _activeAssignments[index];
                                    final assignmentDate = assignment['assignment_date'] != null
                                        ? DateTime.parse(assignment['assignment_date']).toString().split(' ')[0]
                                        : 'N/A';

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
                                            child: Text(
                                              Formatters.formatId(assignment['id']),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: ThemeColor.primaryColor,
                                              ),
                                            ),
                                          ),

                                          // Machine Name
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              children: [
                                                const Icon(Icons.agriculture,
                                                    color: ThemeColor.primaryColor, size: 20),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    assignment['machinery_name'] ?? 'Unknown',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      color: ThemeColor.primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Rentee Name
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              assignment['rentee_name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),

                                          // Start Hour Meter
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              children: [
                                                const Icon(Icons.schedule,
                                                    color: ThemeColor.secondaryColor, size: 16),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${assignment['start_hour_meter']} hrs',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: ThemeColor.secondaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Assignment Date
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              assignmentDate,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),

                                          // Actions
                                          Expanded(
                                            flex: 1,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.assignment_return,
                                                color: ThemeColor.primaryColor,
                                              ),
                                              onPressed: () {
                                                _showReturnMachineDialog(assignment);
                                              },
                                              tooltip: 'Return Machine',
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