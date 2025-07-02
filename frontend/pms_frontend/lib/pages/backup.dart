// Update frontend/pms_frontend/lib/pages/backup.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:web/web.dart' as web;
import '../services/api_service.dart';
import '../services/archive_service.dart';
import '../services/user_activity_service.dart'; // Add this import
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
  bool _isRestoring = false;
  String _statusMessage = '';

  Future<void> _uploadAndRestoreBackup() async {
    try {
      setState(() {
        _isRestoring = true;
        _statusMessage = 'Selecting file...';
      });

      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _statusMessage = 'Reading backup file...';
        });

        String fileContent;
        if (kIsWeb) {
          // For web
          final bytes = result.files.first.bytes;
          if (bytes != null) {
            fileContent = String.fromCharCodes(bytes);
          } else {
            throw Exception('Failed to read file content');
          }
        } else {
          // For desktop/mobile
          final filePath = result.files.first.path;
          if (filePath != null) {
            final file = File(filePath);
            fileContent = await file.readAsString();
          } else {
            throw Exception('Failed to get file path');
          }
        }

        setState(() {
          _statusMessage = 'Validating backup file...';
        });

        // Parse and validate JSON
        final backupData = jsonDecode(fileContent) as Map<String, dynamic>;
        
        // Validate backup structure
        if (!_validateBackupStructure(backupData)) {
          throw Exception('Invalid backup file format');
        }

        // Show confirmation dialog
        final confirmed = await _showRestoreConfirmationDialog(backupData);
        if (!confirmed) {
          setState(() {
            _isRestoring = false;
            _statusMessage = 'Restore cancelled';
          });
          return;
        }

        setState(() {
          _statusMessage = 'Restoring data...';
        });

        // Restore data
        final restoreResult = await _apiService.restoreFullBackup(backupData);
        
        if (restoreResult != null && restoreResult['success'] == true) {
          setState(() {
            _statusMessage = 'Data restored successfully!';
          });
          
          // Log activity
          await UserActivityService().logActivity(
            'Restore Backup',
            'Successfully restored data from backup file: ${result.files.first.name}',
            target: 'System Restore',
          );

          _showRestoreSuccessDialog(result.files.first.name ?? 'backup file');
        } else {
          throw Exception(restoreResult?['message'] ?? 'Restore failed');
        }

      } else {
        setState(() {
          _statusMessage = 'No file selected';
        });
      }

    } catch (e) {
      setState(() {
        _statusMessage = 'Restore failed: $e';
      });
    } finally {
      setState(() {
        _isRestoring = false;
      });
    }
  }

  bool _validateBackupStructure(Map<String, dynamic> backupData) {
    try {
      // Check if required keys exist
      if (!backupData.containsKey('backup_info') || !backupData.containsKey('data')) {
        return false;
      }

      final data = backupData['data'] as Map<String, dynamic>;
      
      // Check if data contains expected arrays
      return data.containsKey('machinery') && 
             data.containsKey('rice_varieties') && 
             data.containsKey('users');
    } catch (e) {
      return false;
    }
  }

  Future<bool> _showRestoreConfirmationDialog(Map<String, dynamic> backupData) async {
    final backupInfo = backupData['backup_info'] as Map<String, dynamic>;
    final totalRecords = backupInfo['total_records'] as Map<String, dynamic>;

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 600, 
          height: 650, // Increased from 500 to 650 to fit all content
          constraints: const BoxConstraints(maxWidth: 650),
          decoration: const BoxDecoration(
            color: ThemeColor.white2,
          ),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Confirm Data Restore',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 26,
                color: ThemeColor.primaryColor, // Changed from primaryColor to secondaryColor
              ),
            ),
            content: Column( // Removed SingleChildScrollView
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ WARNING: This will replace all current data!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ThemeColor.red,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Backup Information:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Created: ${backupInfo['created_at']}',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                Text(
                  'Version: ${backupInfo['version']}',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Data to be restored:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Machinery: ${totalRecords['machinery']} records',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                Text(
                  '• Rice Varieties: ${totalRecords['rice_varieties']} records',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                Text(
                  '• Users: ${totalRecords['users']} records',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This action cannot be undone!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ThemeColor.red,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'All existing data will be permanently replaced.',
                        style: TextStyle(
                          color: ThemeColor.red,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: ThemeColor.primaryColor,
                    fontSize: 24,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text(
                  'Restore Data',
                  style: TextStyle(
                    color: ThemeColor.red,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ) ?? false;
  }

  void _showRestoreSuccessDialog(String filename) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 450,
          height: 425, // Increased from 400 to 500
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: const BoxDecoration(
            color: ThemeColor.white2,
          ),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Restore Complete',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 26,
                color: ThemeColor.primaryColor,
              ),
            ),
            content: SingleChildScrollView( // Add ScrollView to handle overflow
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your data has been successfully restored!',
                    style: TextStyle(
                      fontSize: 18, // Reduced from 20 to 18
                      color: ThemeColor.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced from 16 to 12
                  Text(
                    'Source: $filename',
                    style: const TextStyle(
                      fontSize: 16, // Reduced from 18 to 16
                      color: ThemeColor.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced from 16 to 12
                  Container(
                    padding: const EdgeInsets.all(10), // Reduced from 12 to 10
                    decoration: BoxDecoration(
                      color: ThemeColor.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: ThemeColor.green, size: 20), // Reduced from 24 to 20
                        SizedBox(width: 8), // Reduced from 12 to 8
                        Expanded(
                          child: Text(
                            'All data has been restored from the backup file.',
                            style: TextStyle(
                              color: ThemeColor.green,
                              fontSize: 14, // Reduced from 16 to 14
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: ThemeColor.primaryColor,
                    fontSize: 22, // Reduced from 24 to 22
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
                          ? ThemeColor.red.withOpacity(0.1)
                          : _statusMessage.contains('successfully')
                            ? ThemeColor.green.withOpacity(0.1)
                            : _statusMessage.contains('No file selected')
                              ? ThemeColor.red.withOpacity(0.1)
                              : ThemeColor.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _statusMessage.contains('failed') 
                            ? ThemeColor.red 
                            : _statusMessage.contains('successfully')
                              ? ThemeColor.green
                              : _statusMessage.contains('No file selected')
                                ? ThemeColor.red
                                : ThemeColor.green,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // Responsive card layout with size limits
              LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;
                  double scaleFactor = (screenWidth / 1200).clamp(0.7, 0.9); // Updated scaling factor

                  // Updated card dimensions
                  double cardWidth = 380 * scaleFactor; // Updated to match system standard
                  double cardHeight = 380 * scaleFactor; // Updated to match system standard
                  double iconSize = 180 * scaleFactor; // Updated to match system standard
                  double fontSize = 22 * scaleFactor; // Updated to match system standard
                  double spacing = 35 * scaleFactor; // Updated to match system standard

                  // Ensure cards don't get too big or too small with updated limits
                  cardWidth = cardWidth.clamp(300.0, 380.0); // Updated constraints
                  cardHeight = cardHeight.clamp(300.0, 380.0); // Updated constraints
                  iconSize = iconSize.clamp(140.0, 180.0); // Updated constraints
                  fontSize = fontSize.clamp(18.0, 22.0); // Updated constraints
                  spacing = spacing.clamp(25.0, 35.0); // Updated constraints

                  return Center(
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.center,
                      children: [
                        // Backup Data Button
                        GestureDetector(
                          onTap: (_isBackingUp || _isRestoring) ? null : _backupData,
                          child: Container(
                            width: cardWidth,
                            height: cardHeight,
                            decoration: BoxDecoration(
                              color: (_isBackingUp || _isRestoring)
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
                                  Icon(
                                    Icons.settings_backup_restore,
                                    size: iconSize,
                                    color: ThemeColor.secondaryColor,
                                  ),
                                const SizedBox(height: 20),
                                Text(
                                  _isBackingUp ? "Backing Up..." : "Back Up Data",
                                  style: TextStyle(fontSize: fontSize),
                                ),
                                if (!_isBackingUp)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                                    child: Text(
                                      "Create backup and save to archives",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Restore Data Button
                        GestureDetector(
                          onTap: (_isBackingUp || _isRestoring) ? null : _uploadAndRestoreBackup,
                          child: Container(
                            width: cardWidth,
                            height: cardHeight,
                            decoration: BoxDecoration(
                              color: (_isBackingUp || _isRestoring)
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
                                if (_isRestoring)
                                  const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      ThemeColor.primaryColor,
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.restore,
                                    size: iconSize,
                                    color: ThemeColor.secondaryColor,
                                  ),
                                const SizedBox(height: 20),
                                Text(
                                  _isRestoring ? "Restoring..." : "Restore Data",
                                  style: TextStyle(fontSize: fontSize),
                                ),
                                if (!_isRestoring)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                                    child: Text(
                                      "Upload and restore from backup file",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Archives Button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ArchivesPage(),
                              ),
                            );
                          },
                          child: Container(
                            width: cardWidth,
                            height: cardHeight,
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.archive_outlined,
                                  size: iconSize,
                                  color: ThemeColor.secondaryColor,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Archives",
                                  style: TextStyle(fontSize: fontSize),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                                  child: Text(
                                    "View and manage backup archives",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
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
            ],
          ),
        ),
      ),
    );
  }
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
      _showBackupSuccessDialog(filename, backupData);

    } catch (e) {
      setState(() {
        _isBackingUp = false;
        _statusMessage = 'Backup failed: $e';
      });
    }
  }

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

  void _showBackupSuccessDialog(String filename, Map<String, dynamic> backupData) {
    final backupInfo = backupData['backup_info'] as Map<String, dynamic>;
    final totalRecords = backupInfo['total_records'] as Map<String, dynamic>;
    final totalCount = totalRecords.values.fold(0, (sum, count) => sum + (count as int));
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 500,
          height: 450,
          constraints: const BoxConstraints(maxWidth: 550),
          decoration: const BoxDecoration(
            color: ThemeColor.white2,
          ),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Backup Complete',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 26,
                color: ThemeColor.primaryColor,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeColor.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Successfully backed up $totalCount records',
                            style: const TextStyle(
                              color: ThemeColor.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Backup Details:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'File: $filename',
                    style: const TextStyle(fontSize: 16, color: ThemeColor.primaryColor),
                  ),
                  Text(
                    'Created: ${backupInfo['created_at']}',
                    style: const TextStyle(fontSize: 16, color: ThemeColor.primaryColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Machinery: ${totalRecords['machinery']} records',
                    style: const TextStyle(fontSize: 16, color: ThemeColor.primaryColor),
                  ),
                  Text(
                    '• Rice Varieties: ${totalRecords['rice_varieties']} records',
                    style: const TextStyle(fontSize: 16, color: ThemeColor.primaryColor),
                  ),
                  Text(
                    '• Users: ${totalRecords['users']} records',
                    style: const TextStyle(fontSize: 16, color: ThemeColor.primaryColor),
                  ),
                  const SizedBox(height: 16),
                  if (kIsWeb)
                    const Text(
                      'The backup file has been downloaded to your Downloads folder.',
                      style: TextStyle(fontSize: 14, color: ThemeColor.grey),
                    )
                  else
                    const Text(
                      'The backup data was also displayed for manual saving.',
                      style: TextStyle(fontSize: 14, color: ThemeColor.grey),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: ThemeColor.primaryColor,
                    fontSize: 24,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArchivesPage(),
                    ),
                  );
                },
                child: const Text(
                  'View Archives',
                  style: TextStyle(
                    color: ThemeColor.primaryColor,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}