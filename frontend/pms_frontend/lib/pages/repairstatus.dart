import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../services/api_service.dart';
import 'repair.dart';
import '../utils/formatters.dart';

class RepairstatusNav extends StatefulWidget {
  const RepairstatusNav({super.key});

  @override
  State<RepairstatusNav> createState() => _RepairstatusNavState();
}

class _RepairstatusNavState extends State<RepairstatusNav> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _repairs = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRepairs();
  }

  Future<void> _loadRepairs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repairs = await _apiService.getRepairs();
      setState(() {
        _isLoading = false;
        if (repairs != null) {
          _repairs = repairs;
        } else {
          _errorMessage = 'Failed to load repair data';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  String _getStatusColor(String status) {
    switch(status) {
      case 'pending':
        return '#FFA726'; // Orange
      case 'in_progress':
        return '#2196F3'; // Blue
      case 'completed':
        return '#4CAF50'; // Green
      default:
        return '#757575'; // Grey
    }
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
                        builder: (context) => const RepairNav(),
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
                  "Repair Status",
                  style: TextStyle(
                    color: ThemeColor.secondaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Refresh and Edit buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditRepairStatus(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text('Edit Repairs', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColor.secondaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _loadRepairs,
                  icon: const Icon(
                    Icons.refresh,
                    color: ThemeColor.secondaryColor,
                  ),
                  tooltip: 'Refresh data',
                ),
              ],
            ),
            
            // Table content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : _repairs.isEmpty
                          ? const Center(
                              child: Text('No repair records found'),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: ThemeColor.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
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
                                          flex: 2,
                                          child: Text(
                                            'Machine',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            'Issue',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Parts',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Status',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Date',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Repair Records List
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _repairs.length,
                                      itemBuilder: (context, index) {
                                        final repair = _repairs[index];
                                        return Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey.withOpacity(0.2),
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
                                                      Formatters.formatId(repair['id']),
                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              
                                              // Machine
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.build, color: ThemeColor.primaryColor, size: 20),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        repair['machine_name'] ?? 'Unknown',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          color: ThemeColor.primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              
                                              // Issue
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  repair['issue_description'] ?? 'No description',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              
                                              // Parts
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  repair['notes'].toString().toUpperCase() ?? 'N/A',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    color: ThemeColor.grey,
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
                                                    color: repair['status'].toString().toUpperCase() == 'completed'
                                                        ? ThemeColor.primaryColor.withOpacity(0.2)
                                                        : repair['status'].toString().toUpperCase() == 'in_progress'
                                                            ? Colors.orange.withOpacity(0.2)
                                                            : ThemeColor.red.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    repair['status'].toString().toUpperCase() ?? 'pending',
                                                    style: TextStyle(
                                                      color: repair['status'].toString().toUpperCase() == 'completed'
                                                          ? ThemeColor.primaryColor
                                                          : repair['status'].toString().toUpperCase() == 'in_progress'
                                                              ? Colors.orange
                                                              : ThemeColor.red,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              
                                              // Date
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.calendar_today, color: ThemeColor.secondaryColor, size: 16),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      repair['repair_date'] ?? 'N/A',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: ThemeColor.secondaryColor,
                                                        fontWeight: FontWeight.w500,
                                                      ),
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

class EditRepairStatus extends StatefulWidget {
  const EditRepairStatus({super.key});

  @override
  State<EditRepairStatus> createState() => _EditRepairStatusState();
}

class _EditRepairStatusState extends State<EditRepairStatus> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _repairs = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRepairs();
  }

  Future<void> _loadRepairs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final repairs = await _apiService.getRepairs();
      setState(() {
        _isLoading = false;
        if (repairs != null) {
          _repairs = repairs;
        } else {
          _errorMessage = 'Failed to load repair data';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _showEditRepairDialog(BuildContext context, Map<String, dynamic> repair) async {
    final _formKey = GlobalKey<FormState>();
    final _issueController = TextEditingController(text: repair['issue_description']);
    final _partsController = TextEditingController(text: repair['parts_concerned'] ?? '');
    String _status = repair['status'] ?? 'pending';
    bool _isLoading = false;
    String _errorMessage = '';

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Edit Repair Record',
                style: TextStyle(
                  color: ThemeColor.secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        
                        const Text(
                          'Issue Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ThemeColor.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _issueController,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter issue description';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Describe the issue",
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        const Text(
                          'Parts Concerned',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ThemeColor.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _partsController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Parts needed for repair",
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ThemeColor.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButton<String>(
                            value: _status,
                            isExpanded: true,
                            underline: Container(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _status = newValue!;
                              });
                            },
                            items: <String>[
                              'pending',
                              'in_progress',
                              'completed'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value.replaceAll('_', ' ').toUpperCase()),
                              );
                            }).toList(),
                          ),
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
                    foregroundColor: MaterialStateProperty.all(Colors.grey),
                  ),
                  child: const Text('Cancel'),
                ),
                _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeColor.secondaryColor),
                    )
                  : TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = '';
                          });

                          try {
                            // Prepare update data
                            final repairData = {
                              'issue_description': _issueController.text,
                              'parts_concerned': _partsController.text,
                              'status': _status,
                            };
                            
                            // Call API to update repair
                            final result = await _apiService.updateRepair(
                              repair['id'], 
                              repairData
                            );
                            
                            if (result != null) {
                              // Close the dialog and reload the repairs list
                              Navigator.of(dialogContext).pop();
                              this._loadRepairs();
                              this._successMessage = 'Repair record updated successfully';
                            } else {
                              setState(() {
                                _isLoading = false;
                                _errorMessage = 'Failed to update repair record';
                              });
                            }
                          } catch (e) {
                            setState(() {
                              _isLoading = false;
                              _errorMessage = 'Error: $e';
                            });
                          }
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(ThemeColor.secondaryColor),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                      ),
                      child: const Text('Update'),
                    ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> repair) async {
    bool _isDeleting = false;
    String _errorMessage = '';

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Text(
                    'Are you sure you want to delete repair record #${repair['id']}?',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This action cannot be undone.',
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
                    foregroundColor: MaterialStateProperty.all(Colors.grey),
                  ),
                  child: const Text('Cancel'),
                ),
                _isDeleting
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    )
                  : TextButton(
                      onPressed: () async {
                        setState(() {
                          _isDeleting = true;
                          _errorMessage = '';
                        });

                        try {
                          // Call API to delete repair
                          final success = await _apiService.deleteRepair(repair['id']);
                          
                          if (success) {
                            // Close the dialog and reload the repairs list
                            Navigator.of(dialogContext).pop();
                            this._loadRepairs();
                            this._successMessage = 'Repair record deleted successfully';
                          } else {
                            setState(() {
                              _isDeleting = false;
                              _errorMessage = 'Failed to delete repair record';
                            });
                          }
                        } catch (e) {
                          setState(() {
                            _isDeleting = false;
                            _errorMessage = 'Error: $e';
                          });
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                      ),
                      child: const Text('Delete'),
                    ),
              ],
            );
          }
        );
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
            // Back arrow and title
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
                  "Edit Repair Records",
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
                onPressed: _loadRepairs,
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
                  : _errorMessage.isNotEmpty && _repairs.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : _repairs.isEmpty
                          ? const Center(
                              child: Text('No repair records found'),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: ThemeColor.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
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
                                          flex: 2,
                                          child: Text(
                                            'Machine',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            'Issue',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Status',
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
                                  
                                  // Repair Records List
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _repairs.length,
                                      itemBuilder: (context, index) {
                                        final repair = _repairs[index];
                                        return Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey.withOpacity(0.2),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              // ID
                                              Expanded(
                                                flex: 1,
                                                child: CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor: ThemeColor.secondaryColor,
                                                  child: Text(
                                                    Formatters.formatId(repair['id']), // Change from order['id'].toString()
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      color: ThemeColor.primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              
                                              // Machine
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.build, color: ThemeColor.primaryColor, size: 20),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        repair['machine_name'] ?? 'Unknown',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          color: ThemeColor.primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              
                                              // Issue
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  repair['issue_description'] ?? 'No description',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
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
                                                    color: repair['status'] == 'completed'
                                                        ? ThemeColor.primaryColor.withOpacity(0.2)
                                                        : repair['status'] == 'in_progress'
                                                            ? Colors.orange.withOpacity(0.2)
                                                            : Colors.red.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    repair['status'] ?? 'pending',
                                                    style: TextStyle(
                                                      color: repair['status'] == 'completed'
                                                          ? ThemeColor.primaryColor
                                                          : repair['status'] == 'in_progress'
                                                              ? Colors.orange
                                                              : Colors.red,
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
                                                        _showEditRepairDialog(context, repair);
                                                      },
                                                      tooltip: 'Edit',
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () {
                                                        _showDeleteConfirmationDialog(context, repair);
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