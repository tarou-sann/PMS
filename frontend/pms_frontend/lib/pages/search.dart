import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../services/api_service.dart';
import '../utils/formatters.dart';


class SearchNav extends StatelessWidget {
  const SearchNav({super.key});

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
        padding: const EdgeInsets.all(45),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
               Center(
                 child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PartsNeededSearch()),
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
                                Icons.handyman_outlined,
                                weight: 200,
                                size: 225,
                                color: ThemeColor.secondaryColor,
                              ),
                              Text(
                                "Parts Needed Search",
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
                            MaterialPageRoute(builder: (context) => const RiceVarietySearch()),
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
                                weight: 22,
                                size: 225,
                                color: ThemeColor.secondaryColor,
                              ),
                              Text(
                                "Rice Variety",
                                style: TextStyle(fontSize: 24),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                               ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}

class PartsNeededSearch extends StatefulWidget {
  const PartsNeededSearch({super.key});

  @override
  State<PartsNeededSearch> createState() => _PartsNeededSearchState();
}

class _PartsNeededSearchState extends State<PartsNeededSearch> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _errorMessage = '';
  String _selectedPart = 'Reaper'; // Changed from TextEditingController to String

  @override
  void dispose() {
    // Removed _searchController.dispose() since we're no longer using it
    super.dispose();
  }

  Future<void> _searchParts() async {
    // Removed the query validation since we're using dropdown selection
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await _apiService.searchRepairsByParts(_selectedPart);
      setState(() {
        _isLoading = false;
        _hasSearched = true;
        if (results != null) {
          _searchResults = results;
        } else {
          _errorMessage = 'Failed to retrieve search results';
          _searchResults = [];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasSearched = true;
        _errorMessage = 'Error: $e';
        _searchResults = [];
      });
    }
  }

  // Helper function to get status color
  Color _getStatusColor(String status) {
    switch(status) {
      case 'pending':
        return const Color(0xFFFFA726); // Orange
      case 'in_progress':
        return const Color(0xFF2196F3); // Blue
      case 'completed':
        return const Color(0xFF4CAF50); // Green
      default:
        return const Color(0xFF757575); // Grey
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
                    Navigator.pop(context, 
                    MaterialPageRoute(builder: (context) => const SearchNav()));
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: ThemeColor.secondaryColor,
                    size: 30,
                  ),
                ),
                const Text(
                  "Parts Needed Search",
                  style: TextStyle(
                    color: ThemeColor.secondaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Search dropdown and button (Changed from search bar to dropdown)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: ThemeColor.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedPart,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text("Select Part Type"),
                      dropdownColor: ThemeColor.white,
                      items: const [
                        // Replace all existing items with these new ones from repair.dart:
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
                          value: 'Hydraulics',
                          child: Text("Hydraulics"),
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
                          value: 'Electrical',
                          child: Text("Electrical"),
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
                            _selectedPart = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: _searchParts,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(ThemeColor.secondaryColor),
                    foregroundColor: WidgetStateProperty.all(ThemeColor.white),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  child: const Text("Search"),
                ),
              ],
            ),
            
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: ThemeColor.red), // Changed to ThemeColor.red
                ),
              ),
              
            _isLoading
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.secondaryColor),
                      ),
                    ),
                  )
                : _hasSearched
                    ? Expanded(
                        child: _searchResults.isEmpty
                            ? const Center(
                                child: Text(
                                  "No parts found matching your search",
                                  style: TextStyle(fontSize: 16, color: ThemeColor.grey), // Added ThemeColor
                                ),
                              )
                            : Column(
                                children: [
                                  // Search results count
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: Text(
                                      "Found ${_searchResults.length} repair order(s) with part type: $_selectedPart", // Updated message
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeColor.primaryColor, // Added ThemeColor
                                      ),
                                    ),
                                  ),
                                  
                                  // Table header
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    decoration: BoxDecoration(
                                      color: ThemeColor.secondaryColor.withOpacity(0.1), // Changed to match other tables
                                      border: Border.all(color: ThemeColor.white2), // Changed border color
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
                                          flex: 2,
                                          child: Text('Machine', style: tableHeaderStyle),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text('Part Needed', style: tableHeaderStyle),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text('Issue', style: tableHeaderStyle),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text('Status', style: tableHeaderStyle),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text('Urgent', style: tableHeaderStyle),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Table content
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: ThemeColor.white2, // Changed border color
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        ),
                                      ),
                                      child: ListView.builder(
                                        itemCount: _searchResults.length,
                                        itemBuilder: (context, index) {
                                          final repair = _searchResults[index];
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: index % 2 == 0
                                                  ? ThemeColor.white
                                                  : ThemeColor.white2, // Changed to ThemeColor
                                              border: index < _searchResults.length - 1
                                                  ? Border(
                                                      bottom: BorderSide(
                                                        color: ThemeColor.grey.withOpacity(0.2), // Changed to ThemeColor
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
                                                        Formatters.formatId(repair['id']),
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          color: ThemeColor.primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Machine Name
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      repair['machinery_name'] ?? 'Unknown',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w400,
                                                        color: ThemeColor.primaryColor, 
                                                      ),
                                                    ),
                                                  ),
                                                  // Parts (notes field)
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      repair['notes'] ?? 'Not specified',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: ThemeColor.primaryColor, // Added ThemeColor
                                                      ),
                                                    ),
                                                  ),
                                                  // Issue
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      repair['issue_description'],
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: const TextStyle(color: ThemeColor.primaryColor), // Added ThemeColor
                                                    ),
                                                  ),
                                                  // Status
                                                  Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                          width: 120,
                                                          alignment: Alignment.center,
                                                          decoration: BoxDecoration(
                                                            color: _getStatusColor(repair['status']).withOpacity(0.2),
                                                            borderRadius: BorderRadius.circular(16),
                                                          ),
                                                          child: Text(
                                                            repair['status'].toString().toUpperCase(),
                                                            style: TextStyle(
                                                              color: _getStatusColor(repair['status']),
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Urgent
                                                  Expanded(
                                                    flex: 1,
                                                    child: repair['is_urgent'] 
                                                      ? const Icon(Icons.warning, color: ThemeColor.red) // Changed to ThemeColor.red
                                                      : const SizedBox(),
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
                      )
                    : const Expanded(
                        child: Center(
                          child: Text(
                            "Select a part type and click search", // Updated message
                            style: TextStyle(fontSize: 16, color: ThemeColor.grey), // Added ThemeColor
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

class RiceVarietySearch extends StatefulWidget {
  const RiceVarietySearch({super.key});

  @override
  State<RiceVarietySearch> createState() => _RiceVarietySearchState();
}

class _RiceVarietySearchState extends State<RiceVarietySearch> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _errorMessage = '';
  String _selectedGrade = 'Shatter';

  Future<void> _searchRiceVarieties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await _apiService.searchRiceVarietiesByGrade(_selectedGrade);
      setState(() {
        _isLoading = false;
        _hasSearched = true;
        if (results != null) {
          _searchResults = results;
        } else {
          _errorMessage = 'Failed to retrieve search results';
          _searchResults = [];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasSearched = true;
        _errorMessage = 'Error: $e';
        _searchResults = [];
      });
    }
  }

  // Helper function to get quality grade color
  Color _getQualityColor(String grade) {
    switch(grade.toLowerCase()) {
      case 'shatter':
        return Colors.purple;
      case 'non-shattering':
        return ThemeColor.primaryColor;
      default:
        return ThemeColor.grey;
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
                    Navigator.pop(context, 
                    MaterialPageRoute(builder: (context) => const SearchNav()));
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: ThemeColor.secondaryColor,
                    size: 30,
                  ),
                ),
                const Text(
                  "Rice Variety Search",
                  style: TextStyle(
                    color: ThemeColor.secondaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Search dropdown and button
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedGrade,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text("Select Quality Grade"),
                      items: const [
                        DropdownMenuItem(
                          value: 'Shatter',
                          child: Text("Shatter"),
                        ),
                        DropdownMenuItem(
                          value: 'Non-Shattering',
                          child: Text("Non-Shattering"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedGrade = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: _searchRiceVarieties,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(ThemeColor.secondaryColor),
                    foregroundColor: WidgetStateProperty.all(ThemeColor.white),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  child: const Text("Search"),
                ),
              ],
            ),
            
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              
            _isLoading
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.secondaryColor),
                      ),
                    ),
                  )
                : _hasSearched
                    ? _searchResults.isEmpty
                        ? const Expanded(
                            child: Center(
                              child: Text(
                                "No rice varieties found matching your search",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        : Expanded(
                            child: Container(
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
                                  // Search results count
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      "Found ${_searchResults.length} rice varieties with grade: $_selectedGrade",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  
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
                                            'Variety Name',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Quality Grade',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColor.secondaryColor,
                                            ),
                                          ),
                                        ),
                                        // Expanded(
                                        //   flex: 2,
                                        //   child: Text(
                                        //     'Production Date',
                                        //     style: TextStyle(
                                        //       fontWeight: FontWeight.bold,
                                        //       color: ThemeColor.secondaryColor,
                                        //     ),
                                        //   ),
                                        // ),
                                        // Expanded(
                                        //   flex: 2,
                                        //   child: Text(
                                        //     'Expiration Date',
                                        //     style: TextStyle(
                                        //       fontWeight: FontWeight.bold,
                                        //       color: ThemeColor.secondaryColor,
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Rice Varieties List
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _searchResults.length,
                                      itemBuilder: (context, index) {
                                        final rice = _searchResults[index];
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
                                                    Formatters.formatId(rice['id']), // Change from rice['id'].toString()
                                                    style: const TextStyle(
                                                      color: ThemeColor.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 10, // Smaller font to fit 4 digits
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              
                                              // Variety Name
                                              Expanded(
                                                flex: 3,
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.grass, color: ThemeColor.primaryColor, size: 20),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        rice['variety_name'] ?? 'Unknown',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          color: ThemeColor.primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              
                                              // Quality Grade
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getQualityColor(rice['quality_grade'] ?? '').withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    rice['quality_grade'] ?? 'N/A',
                                                    style: TextStyle(
                                                      color: _getQualityColor(rice['quality_grade'] ?? ''),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              
                                              // // Production Date
                                              // Expanded(
                                              //   flex: 2,
                                              //   child: Row(
                                              //     children: [
                                              //       const Icon(Icons.calendar_today, color: ThemeColor.secondaryColor, size: 16),
                                              //       const SizedBox(width: 8),
                                              //       Text(
                                              //         rice['production_date'] ?? 'N/A',
                                              //         style: const TextStyle(
                                              //           fontSize: 12,
                                              //           color: ThemeColor.secondaryColor,
                                              //           fontWeight: FontWeight.w500,
                                              //         ),
                                              //       ),
                                              //     ],
                                              //   ),
                                              // ),
                                              
                                              // // Expiration Date
                                              // Expanded(
                                              //   flex: 2,
                                              //   child: Row(
                                              //     children: [
                                              //       const Icon(Icons.event_busy, color: Colors.red, size: 16),
                                              //       const SizedBox(width: 8),
                                              //       Text(
                                              //         rice['expiration_date'] ?? 'N/A',
                                              //         style: const TextStyle(
                                              //           fontSize: 12,
                                              //           color: Colors.red,
                                              //           fontWeight: FontWeight.w500,
                                              //         ),
                                              //       ),
                                              //     ],
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                    : const Expanded(
                        child: Center(
                          child: Text(
                            "Select a quality grade and click search",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}