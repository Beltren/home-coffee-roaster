import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class RoastingGadgetsPage extends StatefulWidget {
  const RoastingGadgetsPage({Key? key}) : super(key: key);

  @override
  _RoastingGadgetsPageState createState() => _RoastingGadgetsPageState();
}

class _RoastingGadgetsPageState extends State<RoastingGadgetsPage> {
  List<FileSystemEntity> gadgetFiles = [];
  Directory? gadgetsDirectory;

  @override
  void initState() {
    super.initState();
    _initializeGadgetsDirectory();
  }

  Future<void> _initializeGadgetsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = Directory('${directory.path}/gadgets');

    if (!(await path.exists())) {
      await path.create();
    }

    setState(() {
      gadgetsDirectory = path;
      gadgetFiles = path.listSync();
    });
  }

  void _refreshGadgetList() {
    if (gadgetsDirectory != null) {
      setState(() {
        gadgetFiles = gadgetsDirectory!.listSync();
      });
    }
  }

  Future<void> _deleteGadget(FileSystemEntity file) async {
    try {
      await file.delete();
      _refreshGadgetList();
    } catch (e) {
      // Handle the error if necessary
      print('Error deleting gadget: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roasting Gadgets'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/newGadget').then((_) {
                // Refresh the list when returning from the new gadget page
                _refreshGadgetList();
              });
            },
          ),
        ],
      ),
      body: gadgetsDirectory == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: gadgetFiles.length,
                    itemBuilder: (context, index) {
                      final file = gadgetFiles[index];
                      final fileName =
                          file.path.split('/').last.replaceAll('.txt', '');
                      return ListTile(
                        title: Text(
                          fileName,
                          style: const TextStyle(fontSize: 18),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/editGadget',
                                  arguments: file,
                                ).then((_) {
                                  // Refresh the list when returning
                                  _refreshGadgetList();
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                // Confirm deletion
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Gadget'),
                                    content: const Text(
                                        'Are you sure you want to delete this gadget?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  _deleteGadget(file);
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/editGadget',
                            arguments: file,
                          ).then((_) {
                            // Refresh the list when returning
                            _refreshGadgetList();
                          });
                        },
                      );
                    },
                  ),
                ),
                if (gadgetFiles.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No gadgets available. Tap the "+" button to add a new gadget.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
    );
  }
}
