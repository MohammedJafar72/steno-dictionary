import 'package:flutter/material.dart';
import 'package:steno_dictionary/reusable_widgets/sd_outline_image_frame.dart';

class ViewOutline extends StatelessWidget {
  const ViewOutline({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String imgPath = args['imgPath'];
    final String text = args['text'] ?? 'No text yet';
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Outline'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 45.0,
                decoration: const BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
                child: Center(
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlineImageFrame(capturedImagePath: imgPath, placeholderText: 'There is no image available to be displayed :\'('),
            ],
          ),
        ),
      ),
    );
  }
}
