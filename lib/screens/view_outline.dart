import 'package:flutter/material.dart';

class ViewOutline extends StatelessWidget {
  const ViewOutline({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Outline'),
        centerTitle: true,
      ),
        body: const Center(
          child: Text(
            'View Outline',
            style: TextStyle(fontSize: 20),
          ),
        ));
  }
}
