import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import 'machinerymanagement.dart';
import 'register.dart';
import 'repair.dart';
import 'reports.dart';
import 'search.dart';

class MachinesNav extends StatefulWidget {
  const MachinesNav({super.key});

  @override
  State<MachinesNav> createState() => _MachinesNavState();
}

class _MachinesNavState extends State<MachinesNav> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _machinery = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMachinery();
  }

  Future<void> _loadMachinery() async {
    setState(() {
      _isLoading = true;
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

  @override
  Widget build(BuildContext context) {
    const TextStyle listTileTextStyle = TextStyle(
      fontSize: 20,
      color: Colors.black,
    );

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
                        builder: (context) => const MachineryManagementNav(),
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
                  "Machines",
                  style: TextStyle(
                    color: ThemeColor.secondaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
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
                    child: Text('Is Mobile?', style: tableHeaderStyle),  // Changed from "Mobility" to "Is Mobile?"
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Harvest Status', style: tableHeaderStyle),
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
                  : _errorMessage.isNotEmpty
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
                                          // Is Mobile?
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              machine['is_mobile'] ? 'Yes' : 'No',  // Changed from "Mobile"/"Static" to "Yes"/"No"
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