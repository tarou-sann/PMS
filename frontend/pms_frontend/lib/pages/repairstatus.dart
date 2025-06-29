import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../services/api_service.dart';
import '../services/user_activity_service.dart';
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

  Color _getStatusBackgroundColor(String? status) {
  switch (status?.toLowerCase()) {
    case 'completed':
      return ThemeColor.green.withOpacity(0.2);
    case 'in_progress':
      return Colors.orange.withOpacity(0.2);
    case 'pending':
      return ThemeColor.red.withOpacity(0.2);
    default:
      return ThemeColor.grey.withOpacity(0.2);
  }
}

Color _getStatusTextColor(String? status) {
  switch (status?.toLowerCase()) {
    case 'completed':
      return ThemeColor.green;
    case 'in_progress':
      return Colors.orange;
    case 'pending':
      return ThemeColor.red;
    default:
      return ThemeColor.grey;
  }
}

String _formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty || dateStr == 'N/A') {
    return 'N/A';
  }
  
  try {
    final date = DateTime.parse(dateStr);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  } catch (e) {
    return dateStr.substring(0, dateStr.length > 10 ? 10 : dateStr.length);
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
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Machine',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ThemeColor.secondaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Issue',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ThemeColor.secondaryColor,
                                fontSize: 14,
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
                                fontSize: 14,
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
                                fontSize: 14,
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
                                fontSize: 14,
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: index % 2 == 0 ? ThemeColor.white : ThemeColor.white2.withOpacity(0.3),
                              border: index < _repairs.length - 1
                                  ? Border(
                                      bottom: BorderSide(
                                        color: ThemeColor.grey.withOpacity(0.2),
                                        width: 0.5,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ID
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      Formatters.formatId(repair['id']),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: ThemeColor.primaryColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // Machine
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.precision_manufacturing,
                                          color: ThemeColor.secondaryColor,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            repair['machine_name'] ?? 'Unknown',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: ThemeColor.primaryColor,
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Issue
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      repair['issue_description'] ?? 'No description',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: ThemeColor.primaryColor,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                
                                // Parts
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      (repair['notes'] ?? 'N/A').toString().toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 11,
                                        color: ThemeColor.secondaryColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                
                                // Status
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusBackgroundColor(repair['status']),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        (repair['status'] ?? 'pending').toString().toUpperCase(),
                                        style: TextStyle(
                                          color: _getStatusTextColor(repair['status']),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // Date
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: ThemeColor.grey,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            _formatDate(repair['repair_date']),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: ThemeColor.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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

  Color _getStatusBackgroundColor(String? status) {
  switch (status?.toLowerCase()) {
    case 'completed':
      return ThemeColor.green.withOpacity(0.2);
    case 'in_progress':
      return Colors.orange.withOpacity(0.2);
    case 'pending':
      return ThemeColor.red.withOpacity(0.2);
    default:
      return ThemeColor.grey.withOpacity(0.2);
  }
}

Color _getStatusTextColor(String? status) {
  switch (status?.toLowerCase()) {
    case 'completed':
      return ThemeColor.green;
    case 'in_progress':
      return Colors.orange;
    case 'pending':
      return ThemeColor.red;
    default:
      return ThemeColor.grey;
  }
}

String _formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty || dateStr == 'N/A') {
    return 'N/A';
  }
  
  try {
    final date = DateTime.parse(dateStr);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  } catch (e) {
    return dateStr.substring(0, dateStr.length > 10 ? 10 : dateStr.length);
  }
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
                              // If repair is marked as completed, check if there are other pending repairs for this machine
                              if (_status == 'completed') {
                                final allRepairs = await _apiService.getRepairs();
                                if (allRepairs != null) {
                                  // Check if there are any other pending/in_progress repairs for this machine
                                  final otherPendingRepairs = allRepairs.where((r) => 
                                    r['machinery_id'] == repair['machinery_id'] && 
                                    r['id'] != repair['id'] && 
                                    (r['status'] == 'pending' || r['status'] == 'in_progress')
                                  ).toList();
                                  
                                  // If no other pending repairs, set repairs_needed to false
                                  if (otherPendingRepairs.isEmpty) {
                                    final machineryUpdateData = {
                                      'repairs_needed': false,
                                    };
                                    await _apiService.updateMachinery(repair['machinery_id'], machineryUpdateData);
                                    
                                    await UserActivityService().logActivity(
                                      'Complete Repair',
                                      'Completed repair and cleared repairs needed status for machinery: ${repair['machine_name']}',
                                      target: 'Repair Management',
                                    );
                                  }
                                }
                              }
                              
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
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Machine',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          'Issue',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemeColor.secondaryColor,
                                            fontSize: 14,
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
                                            fontSize: 14,
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
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
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
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: index % 2 == 0 ? ThemeColor.white : ThemeColor.white2.withOpacity(0.3),
                                          border: index < _repairs.length - 1
                                              ? Border(
                                                  bottom: BorderSide(
                                                    color: ThemeColor.grey.withOpacity(0.2),
                                                    width: 0.5,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // ID
                                            Expanded(
                                              flex: 1,
                                              child: CircleAvatar(
                                                radius: 18,
                                                backgroundColor: ThemeColor.secondaryColor,
                                                child: Text(
                                                  Formatters.formatId(repair['id']),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: ThemeColor.white,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            // Machine
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.precision_manufacturing,
                                                      color: ThemeColor.primaryColor,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        repair['machine_name'] ?? 'Unknown',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          color: ThemeColor.primaryColor,
                                                          fontSize: 13,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            
                                            // Issue
                                            Expanded(
                                              flex: 4,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                child: Text(
                                                  repair['issue_description'] ?? 'No description',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: ThemeColor.primaryColor,
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            
                                            // Status
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusBackgroundColor(repair['status']),
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Text(
                                                    (repair['status'] ?? 'pending').toString().toUpperCase(),
                                                    style: TextStyle(
                                                      color: _getStatusTextColor(repair['status']),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 10,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            // Actions
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      color: ThemeColor.secondaryColor,
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      _showEditRepairDialog(context, repair);
                                                    },
                                                    tooltip: 'Edit',
                                                    padding: const EdgeInsets.all(4),
                                                    constraints: const BoxConstraints(
                                                      minWidth: 32,
                                                      minHeight: 32,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: ThemeColor.red,
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      _showDeleteConfirmationDialog(context, repair);
                                                    },
                                                    tooltip: 'Delete',
                                                    padding: const EdgeInsets.all(4),
                                                    constraints: const BoxConstraints(
                                                      minWidth: 32,
                                                      minHeight: 32,
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