import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class TakePicture extends StatefulWidget {
  const TakePicture({super.key});

  @override
  State<TakePicture> createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    // Initialize the camera controller
    _controller = CameraController(
      cameras.first, // Use the first available camera (usually rear camera)
      ResolutionPreset.high, // Use high resolution for capturing
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the camera controller to free resources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Take a Picture")),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Camera is initialized
            return Stack(
              children: [
                // Full-screen Camera Preview
                CameraPreview(_controller),

                // 16:9 Overlay Frame
                Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9, // The active frame is 16:9
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ), // White border to highlight active area
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),

                // Dimmed areas outside 16:9 active frame
                Positioned.fill(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                // Capture Button at the Bottom
                Positioned(
                  bottom: 40, // Position slightly above the screen bottom
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(80, 80),
                        shape: const CircleBorder(),
                        // Makes the button circular
                        padding: const EdgeInsets.all(16.0),
                        // Adjusts the size of the button
                        backgroundColor: Colors.white,
                        // White background
                        foregroundColor: Colors.black,
                        // Black icon color
                        elevation: 5, // Add slight shadow
                      ),
                      onPressed: () async {
                        try {
                          // Ensure the controller is initialized
                          await _initializeControllerFuture;

                          // Capture the image
                          final XFile image = await _controller.takePicture();

                          // Pass the captured image path back
                          Navigator.pop(context, image.path);
                        } catch (e) {
                          // Handle errors
                          print("Error capturing image: $e");
                        }
                      },
                      child: const Icon(
                        Icons.camera_alt,
                        size: 40, // Icon size
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Show a loading spinner while initializing the camera
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
