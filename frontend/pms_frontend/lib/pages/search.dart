import 'package:flutter/material.dart';
import 'package:pms_frontend/pages/machinerymanagement.dart';

import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import '../services/api_service.dart';
import 'maintenance.dart';
import 'register.dart';
import 'reports.dart';

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
      endDrawer: const EndDraw(),
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
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchParts() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a part name to search';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await _apiService.searchRepairsByParts(query);
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
            
            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Enter part name (Engine, Transmission, etc.)",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchParts(),
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
                    ? Expanded(
                        child: _searchResults.isEmpty
                            ? const Center(
                                child: Text(
                                  "No parts found matching your search",
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : Column(
                                children: [
                                  // Search results count
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: Text(
                                      "Found ${_searchResults.length} repair order(s) with matching parts",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                          color: ThemeColor.primaryColor,
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
                                                  ? Colors.white
                                                  : Colors.grey.withOpacity(0.1),
                                              border: index < _searchResults.length - 1
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
                                                        repair['id'].toString(),
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w500,
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
                                                    ),
                                                  ),
                                                  // Status
                                                  Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center, // Center the container horizontally
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                          width: 120, // Fixed width
                                                          alignment: Alignment.center, // Center text within container
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
                                                      ? const Icon(Icons.warning, color: Colors.red)
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
                            "Enter a part name to search for repairs",
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