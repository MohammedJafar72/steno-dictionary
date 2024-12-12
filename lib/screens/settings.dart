import 'package:flutter/material.dart';
import 'package:steno_dictionary/common_methods.dart';
import 'package:steno_dictionary/database/backup_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // List of settings options
    final List<Map<String, dynamic>> settingsOptions = [
      {
        'icon': Icons.backup_rounded,
        'title': 'Backup Data',
        'onTap': () async {
          setState(() => _isLoading = true);
          String isBackupDone = await BackupHelper.backupHelperInstance.backupHiveData(context);
          setState(() => _isLoading = false);
          showSnackBar(context, isBackupDone);
        }
      },
      {
        'icon': Icons.restore_rounded,
        'title': 'Restore Data',
        'onTap': null,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                  child: ListView.builder(
                    itemCount: settingsOptions.length,
                    itemBuilder: (context, index) {
                      final option = settingsOptions[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 3, left: 0, right: 0, top: 0),
                        child: ListTile(
                          onTap: option['onTap'],
                          tileColor: const Color.fromARGB(255, 29, 29, 29),
                          leading: Icon(
                            option['icon'],
                            color: Colors.blueAccent,
                            size: 28,
                          ),
                          title: Text(
                            option['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Opacity(
                opacity: 0.5,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 5, left: 0, right: 0, top: 0),
                  child: Text(
                    'StenoMate  [0.0.1]',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.blueAccent,
              ),
            ),
        ],
      ),
    );
  }
}
