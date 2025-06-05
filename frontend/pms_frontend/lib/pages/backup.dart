// Update frontend/pms_frontend/lib/pages/backup.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:web/web.dart' as web;
import '../services/api_service.dart';
import '../services/archive_service.dart'; // Add this import
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import 'maintenance.dart';
import 'archive.dart'; 

class BackUpNav extends StatefulWidget {
  const BackUpNav({super.key});

  @override
  State<BackUpNav> createState() => _BackUpNavState();
}

class _BackUpNavState extends State<BackUpNav> {
  final ApiService _apiService = ApiService();
  final ArchiveService _archiveService = ArchiveService(); // Add this
  bool _isBackingUp = false;
  String _statusMessage = '';

  // Updated backup function that saves to archives
  Future<void> _backupData() async {
    setState(() {
      _isBackingUp = true;
      _statusMessage = 'Starting backup...';
    });

    try {
      setState(() {
        _statusMessage = 'Fetching data...';
      });

      // Fetch all data from APIs
      final machinery = await _apiService.getMachinery();
      final riceVarieties = await _apiService.getRiceVarieties();
      final users = await _apiService.getUsers();

      setState(() {
        _statusMessage = 'Creating backup files...';
      });

      // Create backup data structure
      final backupData = {
        'backup_info': {
          'created_at': DateTime.now().toIso8601String(),
          'version': '1.0',
          'total_records': {
            'machinery': machinery?.length ?? 0,
            'rice_varieties': riceVarieties?.length ?? 0,
            'users': users?.length ?? 0,
          }
        },
        'data': {
          'machinery': machinery ?? [],
          'rice_varieties': riceVarieties ?? [],
          'users': users ?? [],
        }
      };

      // Generate filename with timestamp
      final timestamp = DateTime.now().toString().replaceAll(' ', '_').replaceAll(':', '-').split('.')[0];
      final filename = 'PMS_Backup_$timestamp.json';

      // Convert to JSON string
      final jsonString = jsonEncode(backupData);

      setState(() {
        _statusMessage = 'Saving to archives...';
      });

      // Save to archives - THIS IS THE KEY ADDITION
      try {
        await _archiveService.saveBackupToArchive(
          jsonString, 
          filename, 
          backupData['backup_info'] as Map<String, dynamic>
        );
        
        setState(() {
          _statusMessage = 'Backup saved to archives successfully!';
        });
      } catch (archiveError) {
        if (kDebugMode) {
          print('Archive save error: $archiveError');
        }
        setState(() {
          _statusMessage = 'Backup created but failed to save to archives: $archiveError';
        });
      }

      // Also provide download/display for immediate use
      if (kIsWeb) {
        _downloadFileWeb(jsonString, filename);
      } else {
        _showBackupDataDialog(jsonString, filename);
      }

      setState(() {
        _isBackingUp = false;
        if (!_statusMessage.contains('failed')) {
          _statusMessage = 'Backup completed and saved to archives!';
        }
      });

      // Show success dialog
      _showBackupSuccessDialog(filename);

    } catch (e) {
      setState(() {
        _isBackingUp = false;
        _statusMessage = 'Backup failed: $e';
      });
    }
  }

  // Rest of your methods remain the same...
  void _downloadFileWeb(String content, String filename) {
    try {
      final encodedContent = Uri.encodeComponent(content);
      final dataUrl = 'data:application/json;charset=utf-8,$encodedContent';
      
      final anchor = web.HTMLAnchorElement()
        ..href = dataUrl
        ..style.display = 'none'
        ..download = filename;
      
      web.document.body?.appendChild(anchor);
      anchor.click();
      web.document.body?.removeChild(anchor);
      
    } catch (e) {
      print('Web download failed: $e');
      _showBackupDataDialog(content, filename);
    }
  }

  void _showBackupDataDialog(String content, String filename) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Backup Data - $filename'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Copy the text below and save it as a .json file. This backup has also been saved to your archives.',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      content,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Backup saved to archives and ready for download as "$filename"'),
                  backgroundColor: ThemeColor.secondaryColor,
                ),
              );
            },
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showBackupSuccessDialog(String filename) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Backup Completed',
            style: TextStyle(
              color: ThemeColor.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your data has been successfully backed up!'),
              const SizedBox(height: 10),
              Text('File: $filename'),
              const SizedBox(height: 10),
              const Text(
                'The backup includes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• All machinery data'),
              const Text('• All rice varieties'),
              const Text('• All user accounts'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.archive, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Backup has been saved to Archives for 30 days',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (kIsWeb)
                const Text(
                  'The file has also been downloaded to your Downloads folder.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                )
              else
                const Text(
                  'The backup data was also displayed for manual saving.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to archives page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ArchivesPage(),
                  ),
                );
              },
              child: const Text('View Archives'),
            ),
          ],
        );
      },
    );
  }

  // Rest of your build method remains the same...
  @override
  Widget build(BuildContext context) {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Back button and title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
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
                    'Backup & Archives',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: ThemeColor.secondaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Status message
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _statusMessage.contains('failed') 
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _statusMessage.contains('failed') 
                            ? Colors.red 
                            : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // Backup buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Backup Data Button
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: GestureDetector(
                      onTap: _isBackingUp ? null : _backupData,
                      child: Container(
                        width: 450,
                        height: 450,
                        decoration: BoxDecoration(
                          color: _isBackingUp 
                              ? Colors.grey.withOpacity(0.3)
                              : ThemeColor.white2,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 3,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isBackingUp)
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ThemeColor.secondaryColor,
                                ),
                              )
                            else
                              const Icon(
                                Icons.settings_backup_restore,
                                size: 225,
                                color: ThemeColor.secondaryColor,
                              ),
                            const SizedBox(height: 20),
                            Text(
                              _isBackingUp ? "Backing Up..." : "Back Up Data",
                              style: const TextStyle(fontSize: 24),
                            ),
                            if (!_isBackingUp)
                              const Text(
                                "Create backup and save to archives",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Archives Button
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ArchivesPage(),
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
                              Icons.archive_outlined,
                              size: 225,
                              color: ThemeColor.secondaryColor,
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Archives",
                              style: TextStyle(fontSize: 24),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                "View and manage backup archives",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}