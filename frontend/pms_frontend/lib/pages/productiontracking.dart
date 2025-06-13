import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../theme/colors.dart';
import '../widget/navbar.dart';
import '../widget/calendar.dart';
import '../widget/enddrawer.dart';
import '../services/api_service.dart';
import '../services/user_activity_service.dart';
import '../widget/textfield.dart';

class ProductionTrackingNav extends StatefulWidget {
  const ProductionTrackingNav({super.key});

  @override
  State<ProductionTrackingNav> createState() => _ProductionTrackingState();
}

class _ProductionTrackingState extends State<ProductionTrackingNav> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _productionRecords = [];
  List<Map<String, dynamic>> _riceVarieties = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadProductionRecords(),
      _loadRiceVarieties(),
    ]);
  }

  Future<void> _loadProductionRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final records = await _apiService.getProductionRecords();
      setState(() {
        _isLoading = false;
        if (records != null) {
          _productionRecords = records;
        } else {
          _errorMessage = 'Failed to load production records';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _loadRiceVarieties() async {
    try {
      final varieties = await _apiService.getRiceVarieties();
      if (varieties != null) {
        setState(() {
          _riceVarieties = varieties;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading rice varieties: $e');
      }
    }
  }

  Future<void> _showAddProductionDialog() async {
    final formKey = GlobalKey<FormState>();
    final hectaresController = TextEditingController();
    final quantityController = TextEditingController();
    final harvestDateController = TextEditingController();
    int? selectedRiceVarietyId;
    bool isLoading = false;
    String errorMessage = '';

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: ThemeColor.white,
            title: const Text(
              'Add Production Record',
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

                      // Rice Variety Dropdown
                      const Text(
                        'Rice Variety',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: selectedRiceVarietyId,
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a rice variety';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Select rice variety",
                        ),
                        items: _riceVarieties.map((variety) {
                          return DropdownMenuItem<int>(
                            value: variety['id'],
                            child: Text(variety['variety_name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedRiceVarietyId = value;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Hectares
                      const Text(
                        'Hectares',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ThemedTextFormField(
                        controller: hectaresController,
                        hintText: 'Enter hectares (e.g., 5.5)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter hectares';
                          }
                          final hectares = double.tryParse(value);
                          if (hectares == null || hectares <= 0) {
                            return 'Please enter a valid number greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Quantity Harvested
                      const Text(
                        'Quantity Harvested (kg)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ThemedTextFormField(
                        controller: quantityController,
                        hintText: 'Enter quantity in kilograms',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity harvested';
                          }
                          final quantity = double.tryParse(value);
                          if (quantity == null || quantity <= 0) {
                            return 'Please enter a valid number greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Harvest Date
                      const Text(
                        'Harvest Date',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ThemedTextFormField(
                        controller: harvestDateController,
                        hintText: 'Select harvest date',
                        readOnly: true,
                        onTap: () async {
                          final DateTime? picked = await CalendarTheme.showCustomDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            helpText: 'Select Harvest Date',
                          );

                          if (picked != null) {
                            setState(() {
                              harvestDateController.text =
                                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                            });
                          }
                        },
                        suffixIcon: const Icon(Icons.calendar_today),
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
                            final productionData = {
                              'rice_variety_id': selectedRiceVarietyId,
                              'hectares': double.parse(hectaresController.text),
                              'quantity_harvested': double.parse(quantityController.text),
                              'harvest_date': harvestDateController.text,
                            };

                            final result = await _apiService.createProductionRecord(productionData);

                            if (result != null) {
                              final riceVariety = _riceVarieties.firstWhere(
                                (variety) => variety['id'] == selectedRiceVarietyId,
                                orElse: () => {'variety_name': 'Unknown'},
                              );

                              await UserActivityService().logActivity(
                                'Add Production Record',
                                'Added production record for ${riceVariety['variety_name']}: ${hectaresController.text} hectares, ${quantityController.text} kg',
                                target: 'Production Tracking',
                              );

                              Navigator.of(dialogContext).pop();
                              _loadProductionRecords();
                              _successMessage = 'Production record added successfully';
                            } else {
                              setState(() {
                                isLoading = false;
                                errorMessage = 'Failed to add production record';
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
                      child: const Text('Add Record'),
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
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDraw(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  'Production Tracking',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.secondaryColor,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showAddProductionDialog,
                      icon: const Icon(Icons.add, color: ThemeColor.white),
                      label: const Text('Add Record', style: TextStyle(color: ThemeColor.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColor.secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: _loadProductionRecords,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Error/Success Messages
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

            // Table Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeColor.secondaryColor,
                        ),
                      ),
                    )
                  : _errorMessage.isNotEmpty && _productionRecords.isEmpty
                      ? Center(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: ThemeColor.red),
                          ),
                        )
                      : _productionRecords.isEmpty
                          ? const Center(
                              child: Text('No production records found'),
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
                                            'Rice Variety',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Hectares',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Quantity (kg)',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Yield/Hectare',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Harvest Date',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Production Records List
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _productionRecords.length,
                                      itemBuilder: (context, index) {
                                        final record = _productionRecords[index];
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
                                                      record['id'].toString(),
                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Rice Variety
                                              Expanded(
                                                flex: 3,
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.grass, color: ThemeColor.green, size: 20),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        record['rice_variety_name'] ?? 'Unknown',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          color: ThemeColor.green,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Hectares
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.landscape,
                                                        color: ThemeColor.secondaryColor, size: 16),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '${record['hectares']} ha',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: ThemeColor.secondaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Quantity
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.scale, color: ThemeColor.grey, size: 16),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '${record['quantity_harvested']} kg',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: ThemeColor.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Yield per Hectare
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: ThemeColor.green.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    '${record['yield_per_hectare']} kg/ha',
                                                    style: const TextStyle(
                                                      color: ThemeColor.green,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),

                                              // Harvest Date
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.calendar_today,
                                                        color: ThemeColor.secondaryColor, size: 16),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      record['harvest_date'] ?? 'N/A',
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
