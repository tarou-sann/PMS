import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../theme/colors.dart';
import '../theme/inputtheme.dart';
import '../widget/navbar.dart';
import '../widget/calendar.dart';
import '../widget/enddrawer.dart';
import '../services/api_service.dart';
import '../services/user_activity_service.dart';
import '../widget/textfield.dart';
import '../utils/formatters.dart';
import '../constants/municipalities.dart';
import '../widget/table.dart';
import '../widget/calendar.dart';
import '../widget/cellbuilder.dart';

class ProductionTrackingNav extends StatefulWidget {
  const ProductionTrackingNav({super.key});

  @override
  State<ProductionTrackingNav> createState() => _ProductionTrackingState();
}

class _ProductionTrackingState extends State<ProductionTrackingNav> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _productionRecords = [];
  List<Map<String, dynamic>> _filteredRecords = []; // Add filtered records list
  List<Map<String, dynamic>> _riceVarieties = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _successMessage = '';
  
  // Add filter and sort variables
  DateTime? _startDate;
  DateTime? _endDate;
  String _sortBy = 'harvest_date'; // Default sort by harvest date
  bool _sortAscending = false; // Default descending (newest first)
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Add method to apply filters and sorting
  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> filtered = List.from(_productionRecords);
    
    // Apply date range filter
    if (_startDate != null || _endDate != null) {
      filtered = filtered.where((record) {
        final harvestDateStr = record['harvest_date'] as String?;
        if (harvestDateStr == null) return false;
        
        try {
          final harvestDate = DateTime.parse(harvestDateStr);
          
          if (_startDate != null && harvestDate.isBefore(_startDate!)) {
            return false;
          }
          if (_endDate != null && harvestDate.isAfter(_endDate!.add(const Duration(days: 1)))) {
            return false;
          }
          
          return true;
        } catch (e) {
          return false;
        }
      }).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((record) {
        final query = _searchQuery.toLowerCase();
        final riceVariety = (record['rice_variety_name'] ?? '').toString().toLowerCase();
        final farmerName = (record['farmer_name'] ?? '').toString().toLowerCase();
        final municipality = (record['municipality'] ?? '').toString().toLowerCase();
        
        return riceVariety.contains(query) || 
               farmerName.contains(query) || 
               municipality.contains(query);
      }).toList();
    }
    
    // Apply sorting
    filtered.sort((a, b) {
      dynamic valueA = a[_sortBy];
      dynamic valueB = b[_sortBy];
      
      // Handle different data types
      if (_sortBy == 'harvest_date') {
        try {
          valueA = DateTime.parse(valueA ?? '');
          valueB = DateTime.parse(valueB ?? '');
        } catch (e) {
          valueA = DateTime(1970);
          valueB = DateTime(1970);
        }
      } else if (_sortBy == 'hectares' || 
                 _sortBy == 'quantity_harvested' || 
                 _sortBy == 'actual_yield_per_hectare' || 
                 _sortBy == 'predicted_total_yield' || 
                 _sortBy == 'yield_variance') {
        valueA = (valueA ?? 0).toDouble();
        valueB = (valueB ?? 0).toDouble();
      } else {
        valueA = (valueA ?? '').toString();
        valueB = (valueB ?? '').toString();
      }
      
      int comparison = 0;
      if (valueA is Comparable && valueB is Comparable) {
        comparison = valueA.compareTo(valueB);
      }
      
      return _sortAscending ? comparison : -comparison;
    });
    
    setState(() {
      _filteredRecords = filtered;
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadProductionRecords(),
      _loadRiceVarieties(),
    ]);
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
          _applyFiltersAndSort(); // Apply filters after loading
        } else {
          _errorMessage = 'Failed to load production records';
          _filteredRecords = [];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
        _filteredRecords = [];
      });
    }
  }

  Future<void> _showDateFilterDialog() async {
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: ThemeColor.white,
              title: const Text(
                'Filter by Date Range',
                style: TextStyle(
                  color: ThemeColor.secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Start Date
                    Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'From:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: ThemeColor.secondaryColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await CalendarTheme.showCustomDatePicker(
                                context: context,
                                initialDate: tempStartDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                helpText: 'Select Start Date',
                              );
                              if (picked != null) {
                                setState(() {
                                  tempStartDate = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tempStartDate != null
                                    ? '${tempStartDate!.day}/${tempStartDate!.month}/${tempStartDate!.year}'
                                    : 'Select date',
                                style: TextStyle(
                                  color: tempStartDate != null ? Colors.black : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // End Date
                    Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'To:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: ThemeColor.secondaryColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await CalendarTheme.showCustomDatePicker(
                                context: context,
                                initialDate: tempEndDate ?? DateTime.now(),
                                firstDate: tempStartDate ?? DateTime(2020),
                                lastDate: DateTime.now(),
                                helpText: 'Select End Date',
                              );
                              if (picked != null) {
                                setState(() {
                                  tempEndDate = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tempEndDate != null
                                    ? '${tempEndDate!.day}/${tempEndDate!.month}/${tempEndDate!.year}'
                                    : 'Select date',
                                style: TextStyle(
                                  color: tempEndDate != null ? Colors.black : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: ThemeColor.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                      tempStartDate = null;
                      tempEndDate = null;
                    });
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: ThemeColor.red),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _startDate = tempStartDate;
                      _endDate = tempEndDate;
                    });
                    _applyFiltersAndSort();
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: ThemeColor.secondaryColor,
                    foregroundColor: ThemeColor.white,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // Existing _showAddProductionDialog method remains the same...
  Future<void> _showAddProductionDialog() async {
    final formKey = GlobalKey<FormState>();
    final hectaresController = TextEditingController();
    final quantityController = TextEditingController();
    final harvestDateController = TextEditingController();
    final farmerNameController = TextEditingController();  // Add this line
    int? selectedRiceVarietyId;
    String selectedMunicipality = Municipalities.municipalityOptions.first;  // Add this line
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

                      const SizedBox(height: 16),

                      // Farmer Name
                      const Text(
                        'Farmer Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ThemedTextFormField(
                        controller: farmerNameController,
                        hintText: 'Enter farmer name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter farmer name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Municipality
                      const Text(
                        'Municipality',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedMunicipality,
                        style: InputTheme.inputTextStyle,
                        decoration: InputTheme.getInputDecoration('Select municipality'),
                        items: Municipalities.getDropdownItems(),
                        onChanged: (value) {
                          if (value != null) {
                            selectedMunicipality = value;
                          }
                        },
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
                              'farmer_name': farmerNameController.text,  // Add this line
                              'municipality': selectedMunicipality,  // Add this line
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
      endDrawer: const EndDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                  'Production Tracking',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search and Filter Row
            Row(
              children: [
                // Search Field
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by rice variety, farmer, or municipality...',
                      prefixIcon: const Icon(Icons.search, color: ThemeColor.secondaryColor),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: ThemeColor.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                _applyFiltersAndSort();
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _applyFiltersAndSort();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                
                // Date Filter Button
                Container(
                  decoration: BoxDecoration(
                    color: (_startDate != null || _endDate != null) 
                        ? ThemeColor.primaryColor.withOpacity(0.1)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (_startDate != null || _endDate != null)
                          ? ThemeColor.primaryColor
                          : ThemeColor.grey,
                    ),
                  ),
                  child: IconButton(
                    onPressed: _showDateFilterDialog,
                    icon: Icon(
                      Icons.date_range,
                      color: (_startDate != null || _endDate != null)
                          ? ThemeColor.primaryColor
                          : ThemeColor.secondaryColor,
                    ),
                    tooltip: 'Filter by date range',
                  ),
                ),
                const SizedBox(width: 8),
                
                // Sort Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: ThemeColor.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    underline: const SizedBox(),
                    icon: Icon(
                      _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: ThemeColor.secondaryColor,
                      size: 18,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'harvest_date', child: Text('Date')),
                      DropdownMenuItem(value: 'rice_variety_name', child: Text('Rice Variety')),
                      DropdownMenuItem(value: 'farmer_name', child: Text('Farmer')),
                      DropdownMenuItem(value: 'municipality', child: Text('Municipality')),
                      DropdownMenuItem(value: 'hectares', child: Text('Hectares')),
                      DropdownMenuItem(value: 'quantity_harvested', child: Text('Actual Harvest')),
                      DropdownMenuItem(value: 'actual_yield_per_hectare', child: Text('Actual Yield/ha')),
                      DropdownMenuItem(value: 'predicted_total_yield', child: Text('Predicted Yield')),
                      DropdownMenuItem(value: 'yield_variance', child: Text('Variance')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          if (_sortBy == value) {
                            _sortAscending = !_sortAscending;
                          } else {
                            _sortBy = value;
                            _sortAscending = value == 'harvest_date' ? false : true;
                          }
                        });
                        _applyFiltersAndSort();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Active Filters Display
            if (_startDate != null || _endDate != null || _searchQuery.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ThemeColor.primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, color: ThemeColor.primaryColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (_searchQuery.isNotEmpty)
                            Chip(
                              label: Text('Search: "$_searchQuery"'),
                              backgroundColor: ThemeColor.white,
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                _applyFiltersAndSort();
                              },
                            ),
                          if (_startDate != null || _endDate != null)
                            Chip(
                              label: Text(
                                'Date: ${_startDate != null ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}' : 'Any'} - ${_endDate != null ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}' : 'Any'}'
                              ),
                              backgroundColor: ThemeColor.white,
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                });
                                _applyFiltersAndSort();
                              },
                            ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _startDate = null;
                          _endDate = null;
                        });
                        _applyFiltersAndSort();
                      },
                      child: const Text(
                        'Clear All',
                        style: TextStyle(color: ThemeColor.red),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Results Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${_filteredRecords.length} of ${_productionRecords.length} records',
                  style: TextStyle(
                    color: ThemeColor.grey,
                    fontSize: 14,
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
            const SizedBox(height: 16),

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
                  : ReusableTable(
                      columns: [
                        TableColumn(
                          title: 'ID',
                          dataKey: 'id',
                          flex: 1,
                          customBuilder: (value, row) => TableCellBuilders.idCell(value, row),
                        ),
                        TableColumn(
                          title: 'Rice Variety',
                          dataKey: 'rice_variety_name',
                          flex: 3,
                          customBuilder: (value, row) => TableCellBuilders.iconTextCell(
                            value, 
                            row, 
                            Icons.grass, 
                            ThemeColor.green
                          ),
                        ),
                        TableColumn(
                          title: 'Farmer Name',
                          dataKey: 'farmer_name',
                          flex: 2,
                          customBuilder: (value, row) => TableCellBuilders.iconTextCell(
                            value, 
                            row, 
                            Icons.person, 
                            ThemeColor.primaryColor
                          ),
                        ),
                        TableColumn(
                          title: 'Municipality',
                          dataKey: 'municipality',
                          flex: 2,
                          customBuilder: (value, row) => TableCellBuilders.iconTextCell(
                            value, 
                            row, 
                            Icons.location_city, 
                            ThemeColor.secondaryColor
                          ),
                        ),
                        TableColumn(
                          title: 'Hectares',
                          dataKey: 'hectares',
                          flex: 1,
                          customBuilder: (value, row) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ThemeColor.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${value ?? 0} ha',
                              style: const TextStyle(
                                color: ThemeColor.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        TableColumn(
                          title: 'Quantity (kg)',
                          dataKey: 'quantity_harvested',
                          flex: 2,
                          customBuilder: (value, row) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ThemeColor.secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${value ?? 0} kg',
                              style: const TextStyle(
                                color: ThemeColor.secondaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        TableColumn(
                          title: 'Actual Yield/ha',
                          dataKey: 'actual_yield_per_hectare',  // Updated key name
                          flex: 2,
                          customBuilder: (value, row) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ThemeColor.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${value ?? 0} kg/ha',
                              style: const TextStyle(
                                color: ThemeColor.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        TableColumn(
                          title: 'Predicted Yield',
                          dataKey: 'predicted_total_yield',  // Updated key name
                          flex: 2,
                          customBuilder: (value, row) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              value != null && value > 0 ? '${value} kg' : 'N/A',
                              style: TextStyle(
                                color: value != null && value > 0 ? Colors.blue[700] : ThemeColor.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        TableColumn(
                          title: 'Variance',
                          dataKey: 'yield_variance',  // New column showing difference
                          flex: 2,
                          customBuilder: (value, row) {
                            if (value == null || value == 0) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                  'N/A',
                                  style: TextStyle(
                                    color: ThemeColor.grey,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            
                            final isPositive = value > 0;
                            final percentage = row['yield_variance_percentage'] ?? 0;
                            
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPositive 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${isPositive ? '+' : ''}${value.toStringAsFixed(0)} kg',
                                    style: TextStyle(
                                      color: isPositive ? Colors.green[700] : Colors.red[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    '${isPositive ? '+' : ''}${percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: isPositive ? Colors.green[600] : Colors.red[600],
                                      fontSize: 9,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        TableColumn(
                          title: 'Harvest Date',
                          dataKey: 'harvest_date',
                          flex: 2,
                          customBuilder: (value, row) => TableCellBuilders.iconTextCell(
                            value, 
                            row, 
                            Icons.calendar_today, 
                            ThemeColor.secondaryColor
                          ),
                        ),
                      ],
                      data: _filteredRecords,
                      isLoading: _isLoading,
                      errorMessage: _errorMessage,
                      emptyMessage: _filteredRecords.isEmpty && _productionRecords.isNotEmpty 
                          ? 'No records match your filters'
                          : 'No production records found',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
