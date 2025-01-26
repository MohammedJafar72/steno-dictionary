import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:steno_dictionary/reusable_widgets/okbtn_dialogue.dart';
import 'package:steno_dictionary/reusable_widgets/sd_textfield.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController txtController = TextEditingController();
  String searchQuery = ''; // Track the current search query

  @override
  void initState() {
    super.initState();
    txtController.addListener(() {
      setState(() {
        searchQuery = txtController.text.trim().toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => Navigator.pushNamed(context, '/addOutline'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: SdTextField(
                        controller: txtController,
                        hintText: 'Search for outline...',
                        suffixIcon: const Icon(Icons.sort_by_alpha_outlined, color: Colors.white),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/openSettings'),
                    icon: const Icon(Icons.settings_rounded, size: 30),
                  )
                ],
              ),
            ),
            Expanded(child: _buildValueListenableBuilder()),
          ],
        ),
      ),
    );
  }

  Widget _buildValueListenableBuilder() {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('sdData').listenable(),
      builder: (context, sdData, _) {
        if (sdData.isEmpty) {
          return Center(child: _noDataFoundContainer(true));
        }

        final entries = sdData.values.toList();
        // Filter entries based on the search query
        final filteredEntries = entries.where((entry) => (entry['text'] ?? '').toString().toLowerCase().contains(searchQuery)).toList();

        if (filteredEntries.isEmpty) {
          return Center(child: _noDataFoundContainer(false));
        }

        return ListView.builder(
          itemCount: filteredEntries.length,
          itemBuilder: (context, index) {
            final entry = filteredEntries[index];
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 6.0),
                  title: Text(entry['text'] ?? 'No Title'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                    onPressed: () => _confirmAndDeleteEntry(entry, context),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/viewOutline',
                      arguments: {
                        'imgPath': entry['imagePath'],
                        'text': entry['text'],
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Widget blocks
Column _noDataFoundContainer(bool isEmpty) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Opacity(
        opacity: 0.5,
        child: Image.asset(
          'assets/images/no-data-found-white.png',
          height: 90,
        ),
      ),
      const SizedBox(height: 8),
      Opacity(
        opacity: 0.5,
        child: Text(
          isEmpty ? 'Try adding some data by clicking on the \'plus\' icon below.' : 'No results found. Try searching for another term.',
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 19,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );
}

void _confirmAndDeleteEntry(Map entry, BuildContext context) async {
  await showOkDialog(
    context: context,
    title: 'Delete Entry',
    message: 'Are you sure you want to delete this entry? This will also delete it from the backup location and JSON backup file.',
    onOkPressed: () async {
      final box = Hive.box('sdData');
      final entryKey = box.keys.firstWhere((key) => box.get(key) == entry);

      // Delete from local Hive database
      await box.delete(entryKey);

      // Delete local image file
      if (entry['imagePath'] != null) {
        final imageFile = File(entry['imagePath']);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }

      try {
        // Get backup directory and JSON file path
        final paths = await getBackupDirectoryAndJsonFile();
        final String backupDirectory = paths['backupDirectory']!;
        final String jsonFilePath = paths['jsonFilePath']!;

        // Delete the image from the backup directory
        final String backupImagePath = '$backupDirectory/${entry['imagePath']?.split('/').last}';
        final backupImageFile = File(backupImagePath);
        if (await backupImageFile.exists()) {
          await backupImageFile.delete();
        }

        // Update the JSON file by removing the entry
        await _removeEntryFromJsonFile(jsonFilePath, entry);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete entry from backup. Error: $e')),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry deleted successfully from all locations!')),
      );
    },
    onCancelPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete operation canceled.')),
      );
    },
  );
}

/// Helper to get the backup image path
Future<String> getBackupImagePath(String? localImagePath) async {
  if (localImagePath == null) {
    throw Exception('Local image path is null');
  }

  // Replace the local image directory with the backup directory
  // Example: If images are stored in '/data/user/0/com.example.steno_dictionary/images',
  // replace it with the backup directory path
  final String backupDirectory = await getBackupDirectoryPath();
  final fileName = localImagePath.split('/').last;
  return '$backupDirectory/$fileName';
}

/// Mock implementation of backup directory path
Future<Map<String, String>> getBackupDirectoryAndJsonFile() async {
  // Open directory picker to select the backup directory
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory == null) {
    throw Exception("Backup directory selection was canceled.");
  }

  // Validate if the directory contains the `.json` file
  final String jsonFilePath = '$selectedDirectory/Data_Backup.json';
  final File jsonFile = File(jsonFilePath);

  if (!await jsonFile.exists()) {
    throw Exception("Backup JSON file not found in the selected directory.");
  }

  return {
    "backupDirectory": selectedDirectory,
    "jsonFilePath": jsonFilePath,
  };
}

/// Helper to remove an entry from the JSON backup file
Future<void> _removeEntryFromJsonFile(String backupJsonPath, Map entry) async {
  final File jsonFile = File(backupJsonPath);

  if (await jsonFile.exists()) {
    final String jsonContent = await jsonFile.readAsString();

    // Decode JSON and remove the specific entry
    final Map<String, dynamic> jsonData = jsonDecode(jsonContent);
    final String entryKey = jsonData.keys.firstWhere(
      (key) => jsonData[key]['text'] == entry['text'] && jsonData[key]['imagePath'] == entry['imagePath'],
      orElse: () => '',
    );

    if (entryKey.isNotEmpty) {
      jsonData.remove(entryKey);

      // Write updated JSON back to the file
      await jsonFile.writeAsString(jsonEncode(jsonData));
    }
  }
}

/// Mock implementation of backup directory path
Future<String> getBackupDirectoryPath() async {
  // Replace with the logic for your actual backup directory
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
  return selectedDirectory!;
}
