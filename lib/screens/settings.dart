import 'package:flutter/material.dart';
import 'package:steno_dictionary/common_methods.dart';
import 'package:steno_dictionary/database/backup_helper.dart';
import 'package:steno_dictionary/database/deletion_helper.dart';
import 'package:steno_dictionary/database/restore_helper.dart';
import 'package:steno_dictionary/reusable_widgets/okbtn_dialogue.dart';

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
          bool isOkPressed = false;

          await showOkDialog(
            context: context,
            message: 'Simply go to the folder where you want to save your data.',
            title: 'Backup Data',
            onOkPressed: () {
              isOkPressed = true;
            },
            onCancelPressed: () {
              isOkPressed = false;
            },
          );

          if (isOkPressed) {
            setState(() => _isLoading = true);
            String isBackupDone = await BackupHelper.backupHelperInstance.backupHiveData(context);
            setState(() => _isLoading = false);
            showSnackBar(context, isBackupDone);
          } else {
            // Handle the Cancel action if needed
            showSnackBar(context, 'Backup canceled.');
          }
        }
      },
      {
        'icon': Icons.restore_rounded,
        'title': 'Restore Data',
        'onTap': () async {
          bool isOkPressed = false;

          await showOkDialog(
            context: context,
            message: 'Simply go to the folder where you saved your backup data earlier.',
            title: 'Restore Data',
            onOkPressed: () {
              isOkPressed = true;
            },
            onCancelPressed: () {
              isOkPressed = false;
            },
          );

          if (isOkPressed) {
            setState(() => _isLoading = true);
            String isRestoreDone = await RestoreHelper.backupHelperInstance.restoreHiveData(context);
            setState(() => _isLoading = false);
            showSnackBar(context, isRestoreDone);
          } else {
            // Handle the Cancel action if needed
            showSnackBar(context, 'Restoration canceled.');
          }
        },
      },
      {
        'icon': Icons.delete_outline_rounded,
        'title': 'Delete Data',
        //'onTap': null,
        'onTap': () async {
          bool isOkPressed = false;

          await showOkDialog(
            context: context,
            message: 'Are you sure? Data added by you will get deleted completely. Make sure to take backup.',
            title: 'Delete All Data',
            onOkPressed: () {
              isOkPressed = true;
            },
            onCancelPressed: () {
              isOkPressed = false;
            },
          );

          if (isOkPressed) {
            setState(() => _isLoading = true);
            String isDeleted = await DeletionHelper.deletionHelperInstance.deleteAllData();
            showSnackBar(context, isDeleted);
            setState(() => _isLoading = false);
          } else {
            showSnackBar(context, 'Delete canceled');
          }
        },
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
                    'StenoMate  [0.1.1]',
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
