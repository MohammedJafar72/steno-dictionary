import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:steno_dictionary/reusable_widgets/sd_textfield.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    // code to fetch data from db. list of english words
  }

  final TextEditingController txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(''),
      //   actions: [
      //     IconButton(onPressed: () => Navigator.pushNamed(context, '/openSettings'), icon: const Icon(Icons.settings_rounded))
      //   ],
      // ),
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
        // Dynamically update dataCount based on box data
        if (sdData.isEmpty) {
          return Center(child: _noDataFoundContainer);
        }

        final entries = sdData.values.toList(); // Fetch all data from the box

        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  // Background color for each tile
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 6.0),
                  title: Text(entry['text'] ?? 'No Title'),
                  // trailing: IconButton(
                  //   icon: const Icon(Icons.delete, color: Colors.red),
                  //   onPressed: () {},
                  // ),
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
Column _noDataFoundContainer = Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Opacity(opacity: 0.5, child: Image.asset('assets/images/no-data-found-white.png', height: 90)),
    const SizedBox(height: 8),
    const Opacity(
      opacity: 0.5,
      child: Text(
        'Try adding some data by clicking on the \'plus\' icon below.',
        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 19, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    )
  ],
);
// ListView _listViewBuilder = ListView.builder(
//   itemCount: 0,
//   itemBuilder: (context, index) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 3.0),
//       // Adds spacing between tiles
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white10,
//           // Background color for each tile
//           borderRadius: BorderRadius.circular(5),
//         ),
//         child: ListTile(
//           contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 6.0),
//           // Inner padding for text
//           title: Text(
//             'Item $index',
//             style: const TextStyle(
//               color: Colors.white, // Text color
//               fontSize: 16,
//               fontWeight: FontWeight.bold, // Optional: Make the text bold
//             ),
//           ),
//           onTap: () {
//             // Handle tap (optional)
//           },
//         ),
//       ),
//     );
//   },
// );

// ValueListenableBuilder _valueListenableBuilder = ValueListenableBuilder<Box>(
//   valueListenable: Hive.box('sdData').listenable(),
//   builder: (context, box, _) {
//     // Update dataCount dynamically when data changes
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {
//         dataCount = box.length; // Update dataCount based on the box size
//       });
//     });

//     final entries = box.values.toList(); // Fetch all data from the box

//     // Display ListView with fetched data
//     return ListView.builder(
//       itemCount: entries.length,
//       itemBuilder: (context, index) {
//         final entry = entries[index];
//         return ListTile(
//           // leading: entry['imagePath'] != null
//           //     ? Image.file(
//           //         File(entry['imagePath']),
//           //         width: 50,
//           //         height: 50,
//           //         fit: BoxFit.cover,
//           //       )
//           //     : const Icon(Icons.image_not_supported),
//           title: Text(entry['text'] ?? 'No Title'),
//           subtitle: Text(entry['imagePath'] ?? 'No Image Path'),
//           trailing: IconButton(
//             icon: const Icon(Icons.delete, color: Colors.red),
//             onPressed: () => null,
//           ),
//           onTap: () {
//             null;
//           },
//         );
//       },
//     );
//   },
// );
