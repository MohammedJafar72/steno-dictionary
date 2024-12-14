import 'package:flutter/material.dart';
import 'package:steno_dictionary/common_methods.dart';
import 'package:steno_dictionary/reusable_widgets/sd_outline_image_frame.dart';
import '../database/database_helper.dart';
import '../reusable_widgets/sd_elevated_button.dart';
import '../reusable_widgets/sd_textfield.dart';

class AddOutline extends StatefulWidget {
  const AddOutline({super.key});

  @override
  State<AddOutline> createState() => _AddOutlineState();
}

class _AddOutlineState extends State<AddOutline> {
  final TextEditingController _txtController = TextEditingController();
  String? _capturedImagePath;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _txtController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _txtController.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _isButtonEnabled = _txtController.text.isNotEmpty && _capturedImagePath != null;
    });
  }

  Future<void> _openCamera() async {
    final capturedImagePath = await openCamera(context);

    // If an image was captured, update the state
    if (capturedImagePath is String) {
      setState(() {
        _capturedImagePath = capturedImagePath;

        // for enabling and disabling the save button
        _validateInput(); // Update button state after capturing the image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Outline'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text Field with Camera Icon
            SdTextField(
              controller: _txtController,
              suffixIcon: IconButton(
                icon: const Icon(Icons.camera_alt_rounded, size: 30, color: Colors.white),
                onPressed: _openCamera,
              ),
              contentPadding: const EdgeInsets.all(10.0),
              prefixIcon: null,
              hintText: "Add English word or phrase...",
            ),
            const SizedBox(height: 16),
            OutlineImageFrame(capturedImagePath: _capturedImagePath),
            // Dotted Border to Display Image
            // DottedBorder(
            //   color: Colors.white54,
            //   strokeWidth: 3,
            //   dashPattern: const [
            //     6
            //   ],
            //   borderType: BorderType.RRect,
            //   radius: const Radius.circular(5),
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: SizedBox(
            //       height: MediaQuery.of(context).size.width * 9 / 16,
            //       width: MediaQuery.of(context).size.width,
            //       child: _capturedImagePath == null
            //           ? const Center(
            //               child: Opacity(
            //                 opacity: 0.5,
            //                 child: Text(
            //                   'Click the camera icon to capture an image',
            //                   textAlign: TextAlign.center,
            //                   style: TextStyle(
            //                     fontStyle: FontStyle.italic,
            //                     fontSize: 17,
            //                     color: Colors.white,
            //                   ),
            //                 ),
            //               ),
            //             )
            //           : ClipRRect(
            //               borderRadius: BorderRadius.circular(5),
            //               child: Image.file(
            //                 File(_capturedImagePath!), // Display captured image
            //                 fit: BoxFit.cover,
            //               ),
            //             ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: SdElevatedButton(
                    backgroundColor: Colors.blueAccent,
                    text: 'Retake',
                    icon: Icons.refresh,
                    onPressed: () {
                      if (_capturedImagePath != null) {
                        setState(() => _capturedImagePath = null);
                        _openCamera();
                      } else {
                        showSnackBar(context, '');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10), // Space between the buttons
                Expanded(
                  child: SdElevatedButton(
                    backgroundColor: Colors.redAccent,
                    text: 'Delete',
                    icon: Icons.delete_outline_rounded,
                    onPressed: () async {
                      // Check if there is any image in the frame
                      if (_capturedImagePath != null) {
                        bool? result = await showConfirmationDialog(context);
                        if (result == true) {
                          setState(() => _capturedImagePath = null);
                          _validateInput(); // Update button state after deleting the image
                        }
                      } else {
                        showSnackBar(context, '');
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SdElevatedButton(
              onPressed: _isButtonEnabled
                  ? () async {
                      var result = await DatabaseHelper.instance.saveImage(context, _capturedImagePath, _txtController);

                      if (result == true) {
                        showSnackBar(context, "Data saved successfully in the box.");
                        Navigator.pop(context);
                      }
                    }
                  : null,
              backgroundColor: _isButtonEnabled ? Colors.green : Colors.grey,
              text: 'Save',
              icon: Icons.check_circle_outline_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
