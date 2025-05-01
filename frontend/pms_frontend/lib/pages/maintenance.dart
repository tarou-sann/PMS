import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../theme/colors.dart';
import '../widget/navbar.dart';
import '../widget/enddrawer.dart';
import 'backup.dart';
import '../services/api_service.dart';

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
    final _formKey = GlobalKey<FormState>();
    final _machineNameController = TextEditingController(text: machine['machine_name']);
    String _mobility = machine['is_mobile'] ? 'Mobile' : 'Static';
    String _status = machine['is_active'] ? 'Active' : 'Inactive';
    bool _isLoading = false;
    String _errorMessage = '';

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                          'Machine Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ThemeColor.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                              value: 'Mobile',
                              groupValue: _mobility,
                              onChanged: (value) {
                                setState(() {
                                  _mobility = value!;
                                });
                              },
                            ),
                            const Text('Mobile'),
                            const SizedBox(width: 20),
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
                            const Text('Static'),
                          ],
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
                            const Text('Active'),
                            const SizedBox(width: 20),
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
                            const Text('Inactive'),
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
                            final isMobile = _mobility == 'Mobile';
                            final isActive = _status == 'Active';
                            
                            // Prepare update data
                            final machineryData = {
                              'machine_name': _machineNameController.text,
                              'is_mobile': isMobile,
                              'is_active': isActive,
                            };
                            
                            // Call API to update machinery
                            final result = await _apiService.updateMachinery(
                              machine['id'], 
                              machineryData
                            );
                            
                            if (result != null) {
                              // Close the dialog and reload the machinery list
                              Navigator.of(dialogContext).pop();
                              this._loadMachinery();
                              this._successMessage = 'Machine updated successfully';
                            } else {
                              setState(() {
                                _isLoading = false;
                                _errorMessage = 'Failed to update machinery';
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

  Future<void> _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> machine) async {
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
                          // Call API to delete machinery
                          final success = await _apiService.deleteMachinery(machine['id']);
                          
                          if (success) {
                            // Close the dialog and reload the machinery list
                            Navigator.of(dialogContext).pop();
                            this._loadMachinery();
                            this._successMessage = 'Machine deleted successfully';
                          } else {
                            setState(() {
                              _isDeleting = false;
                              _errorMessage = 'Failed to delete machinery';
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
      endDrawer: const EndDraw(),
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
            
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor.withOpacity(0.1),
                border: Border.all(color: ThemeColor.primaryColor),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text('ID', style: tableHeaderStyle),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('Machine Name', style: tableHeaderStyle),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Mobility', style: tableHeaderStyle),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Status', style: tableHeaderStyle),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Actions', style: tableHeaderStyle),
                  ),
                ],
              ),
            ),
            
            // Table content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeColor.secondaryColor,
                        ),
                      ),
                    )
                  : _errorMessage.isNotEmpty && _machinery.isEmpty
                      ? Center(
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
                                border: Border.all(
                                  color: ThemeColor.primaryColor,
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: ListView.builder(
                                itemCount: _machinery.length,
                                itemBuilder: (context, index) {
                                  final machine = _machinery[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0
                                          ? Colors.white
                                          : Colors.grey.withOpacity(0.1),
                                      border: index < _machinery.length - 1
                                          ? const Border(
                                              bottom: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5,
                                              ),
                                            )
                                          : null,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      child: Row(
                                        children: [
                                          // ID
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 16.0,
                                              ),
                                              child: Text(
                                                machine['id'].toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Machine Name
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              machine['machine_name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          // Mobility
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              machine['is_mobile'] ? 'Mobile' : 'Static',
                                              style: TextStyle(
                                                color: machine['is_mobile']
                                                    ? Colors.blue
                                                    : Colors.purple,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          // Status
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              machine['is_active'] ? 'Active' : 'Inactive',
                                              style: TextStyle(
                                                color: machine['is_active']
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.w500,
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
                                    ),
                                  );
                                },
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
    final _formKey = GlobalKey<FormState>();
    final _varietyNameController = TextEditingController(text: rice['variety_name']);
    final _productionDateController = TextEditingController(text: rice['production_date']);
    final _expirationDateController = TextEditingController(text: rice['expiration_date']);
    String _qualityGrade = rice['quality_grade'] ?? 'Premium';
    bool _isLoading = false;
    String _errorMessage = '';

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

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Edit Rice Variety',
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
                          'Variety Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ThemeColor.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _varietyNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter variety name';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Enter rice variety name",
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        const Text(
                          'Quality Grade',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ThemeColor.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        const Text(
                          'Production Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ThemeColor.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                        const SizedBox(height: 16),
                        
                        const Text(
                          'Expiration Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ThemeColor.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                            final riceData = {
                              'variety_name': _varietyNameController.text,
                              'quality_grade': _qualityGrade,
                              'production_date': _productionDateController.text,
                              'expiration_date': _expirationDateController.text,
                            };
                            
                            // Call API to update rice variety
                            final result = await _apiService.updateRiceVariety(
                              rice['id'], 
                              riceData
                            );
                            
                            if (result != null) {
                              // Close the dialog and reload the rice varieties list
                              Navigator.of(dialogContext).pop();
                              this._loadRiceVarieties();
                              this._successMessage = 'Rice variety updated successfully';
                            } else {
                              setState(() {
                                _isLoading = false;
                                _errorMessage = 'Failed to update rice variety';
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

  Future<void> _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> rice) async {
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
                          // Call API to delete rice variety
                          final success = await _apiService.deleteRiceVariety(rice['id']);
                          
                          if (success) {
                            // Close the dialog and reload the rice varieties list
                            Navigator.of(dialogContext).pop();
                            this._loadRiceVarieties();
                            this._successMessage = 'Rice variety deleted successfully';
                          } else {
                            setState(() {
                              _isDeleting = false;
                              _errorMessage = 'Failed to delete rice variety';
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
      endDrawer: const EndDraw(),
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
            
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor.withOpacity(0.1),
                border: Border.all(color: ThemeColor.primaryColor),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text('ID', style: tableHeaderStyle),
                    ),
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
                    child: Text('Expiration Date', style: tableHeaderStyle),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Actions', style: tableHeaderStyle),
                  ),
                ],
              ),
            ),
            
            // Table content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeColor.secondaryColor,
                        ),
                      ),
                    )
                  : _errorMessage.isNotEmpty && _riceVarieties.isEmpty
                      ? Center(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : _riceVarieties.isEmpty
                          ? const Center(
                              child: Text('No rice varieties found'),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: ThemeColor.primaryColor,
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: ListView.builder(
                                itemCount: _riceVarieties.length,
                                itemBuilder: (context, index) {
                                  final rice = _riceVarieties[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0
                                          ? Colors.white
                                          : Colors.grey.withOpacity(0.1),
                                      border: index < _riceVarieties.length - 1
                                          ? const Border(
                                              bottom: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5,
                                              ),
                                            )
                                          : null,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      child: Row(
                                        children: [
                                          // ID
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 16.0,
                                              ),
                                              child: Text(
                                                rice['id'].toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Variety Name
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              rice['variety_name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          // Quality Grade
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              rice['quality_grade'] ?? 'N/A',
                                              style: TextStyle(
                                                color: _getQualityColor(rice['quality_grade']),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          // Expiration Date
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              rice['expiration_date'] ?? 'N/A',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
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
                                                    _showEditRiceDialog(context, rice);
                                                  },
                                                  tooltip: 'Edit',
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    _showDeleteConfirmationDialog(context, rice);
                                                  },
                                                  tooltip: 'Delete',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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
      case 'Premium':
        return Colors.purple;
      case 'Grade A':
        return Colors.green;
      case 'Grade B':
        return Colors.blue;
      case 'Grade C':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
