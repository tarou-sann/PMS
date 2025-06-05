// Create frontend/pms_frontend/lib/pages/archives.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/archive_service.dart';
import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';
import 'backup.dart';
import 'package:web/web.dart' as web;

class ArchivesPage extends StatefulWidget {
  const ArchivesPage({super.key});

  @override
  State<ArchivesPage> createState() => _ArchivesPageState();
}

class _ArchivesPageState extends State<ArchivesPage> {
  final ArchiveService _archiveService = ArchiveService();
  List<ArchiveItem> _archives = [];
  bool _isLoading = true;
  String _statusMessage = '';
  String _storageSize = '';

  @override
  void initState() {
    super.initState();
    _loadArchives();
    _cleanExpiredArchives();
  }

  Future<void> _loadArchives() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final archives = await _archiveService.getArchives();
      final storageSize = await _archiveService.getStorageSize();
      
      setState(() {
        _archives = archives;
        _storageSize = storageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error loading archives: $e';
      });
    }
  }

  Future<void> _cleanExpiredArchives() async {
    try {
      final deletedCount = await _archiveService.cleanExpiredArchives();
      if (deletedCount > 0) {
        setState(() {
          _statusMessage = 'Cleaned $deletedCount expired archives';
        });
        _loadArchives(); // Reload the list
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning expired archives: $e');
      }
    }
  }

  Future<void> _deleteArchive(ArchiveItem archive) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Archive'),
        content: Text('Are you sure you want to delete "${archive.filename}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _archiveService.deleteArchive(archive);
      if (success) {
        setState(() {
          _statusMessage = 'Archive deleted successfully';
        });
        _loadArchives();
      } else {
        setState(() {
          _statusMessage = 'Failed to delete archive';
        });
      }
    }
  }

  Future<void> _downloadArchive(ArchiveItem archive) async {
    try {
      final content = await _archiveService.getArchiveContent(archive);
      if (content != null) {
        if (kIsWeb) {
          _downloadFileWeb(content, archive.filename);
        } else {
          _showContentDialog(content, archive.filename);
        }
      } else {
        setState(() {
          _statusMessage = 'Archive content not found';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error downloading archive: $e';
      });
    }
  }

  // Update the _downloadFileWeb method in your archive.dart file:
  void _downloadFileWeb(String content, String filename) {
    try {
      // Use a simpler data URL approach that works without deprecated APIs
      final encodedContent = Uri.encodeComponent(content);
      final dataUrl = 'data:application/json;charset=utf-8,$encodedContent';
      
      // Try to trigger download using modern web APIs
      if (kIsWeb) {
        try {
          // Use package:web if available
          final link = web.HTMLAnchorElement()
            ..href = dataUrl
            ..download = filename
            ..style.display = 'none';
          
          web.document.body?.appendChild(link);
          link.click();
          web.document.body?.removeChild(link);
        } catch (e) {
          // Fallback: show content in dialog
          _showContentDialog(content, filename);
        }
      } else {
        _showContentDialog(content, filename);
      }
    } catch (e) {
      // Final fallback: show data in dialog
      _showContentDialog(content, filename);
    }
  }

  void _showContentDialog(String content, String filename) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Archive Content - $filename'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              content,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BackUpNav(),
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
                  'Backup Archives',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: ThemeColor.secondaryColor,
                  ),
                ),
                const Spacer(),
                // Storage info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ThemeColor.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Storage: $_storageSize',
                    style: const TextStyle(
                      color: ThemeColor.secondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Status message
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('Error') || _statusMessage.contains('Failed')
                      ? ThemeColor.red.withOpacity(0.1)
                      : ThemeColor.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('Error') || _statusMessage.contains('Failed')
                        ? ThemeColor.red.withOpacity(0.1)
                      : ThemeColor.green.withOpacity(0.1),
                  ),
                ),
              ),

            // Archives info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Archives are automatically deleted after 30 days. Total archives: ${_archives.length}',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                  TextButton(
                    onPressed: _cleanExpiredArchives,
                    child: const Text('Clean Expired'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Archives list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _archives.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.archive_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No archives found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create a backup to see archives here',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _archives.length,
                          itemBuilder: (context, index) {
                            final archive = _archives[index];
                            final isExpired = archive.isExpired;
                            final daysUntilExpiry = 30 - DateTime.now().difference(archive.createdAt).inDays;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: Icon(
                                  Icons.archive,
                                  color: isExpired ? Colors.red : ThemeColor.secondaryColor,
                                ),
                                title: Text(
                                  archive.filename,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: isExpired ? Colors.red : null,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Created: ${archive.createdAt.toString().split('.')[0]}'),
                                    Text(
                                      isExpired 
                                          ? 'Expired'
                                          : 'Expires in $daysUntilExpiry days',
                                      style: TextStyle(
                                        color: isExpired 
                                            ? Colors.red 
                                            : daysUntilExpiry <= 7 
                                                ? Colors.orange 
                                                : ThemeColor.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (archive.metadata['total_records'] != null)
                                      Text(
                                        'Records: ${archive.metadata['total_records']}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => _downloadArchive(archive),
                                      icon: const Icon(Icons.download),
                                      tooltip: 'Download',
                                    ),
                                    IconButton(
                                      onPressed: () => _deleteArchive(archive),
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Delete',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}