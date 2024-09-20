import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io'; // Add this import
import '../../models/gadget.dart';
import 'measurements_page.dart';

class EditGadgetPage extends StatefulWidget {
  final File gadgetFile;

  const EditGadgetPage({Key? key, required this.gadgetFile}) : super(key: key);

  @override
  _EditGadgetPageState createState() => _EditGadgetPageState();
}

class _EditGadgetPageState extends State<EditGadgetPage> {
  final _formKey = GlobalKey<FormState>();
  late String _gadgetName;
  late String _gadgetDescription;
  late int _temperatureLevels;
  List<Measurement> _measurements = [];
  bool _isLoading = true;

  Future<void> _loadGadget() async {
    try {
      final content = await widget.gadgetFile.readAsString();
      final jsonData = jsonDecode(content);
      final gadget = Gadget.fromJson(jsonData);

      setState(() {
        _gadgetName = gadget.name;
        _gadgetDescription = gadget.description;
        _temperatureLevels = gadget.temperatureLevels;
        _measurements = gadget.measurements;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading gadget: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGadget() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedGadget = Gadget(
        name: _gadgetName,
        description: _gadgetDescription,
        temperatureLevels: _temperatureLevels,
        measurements: _measurements,
      );

      await widget.gadgetFile.writeAsString(jsonEncode(updatedGadget.toJson()));

      Navigator.pop(context);
    }
  }

  Future<void> _collectMeasurements() async {
    final result = await Navigator.push<List<Measurement>>(
      context,
      MaterialPageRoute(
        builder: (context) => MeasurementsPage(
          temperatureLevels: _temperatureLevels,
          existingMeasurements: _measurements,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _measurements = result;
      });
    }
  }

  Future<void> _deleteGadget() async {
    await widget.gadgetFile.delete();
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _loadGadget();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Gadget'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Gadget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteGadget,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _gadgetName,
                decoration: const InputDecoration(labelText: 'Gadget Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a gadget name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _gadgetName = value!;
                },
              ),
              TextFormField(
                initialValue: _gadgetDescription,
                decoration: const InputDecoration(labelText: 'Gadget Description'),
                maxLines: 3,
                onSaved: (value) {
                  _gadgetDescription = value!;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _temperatureLevels,
                decoration: const InputDecoration(labelText: 'Temperature Levels'),
                items: List.generate(7, (index) {
                  int value = index + 4;
                  return DropdownMenuItem(
                    value: value,
                    child: Text('$value Levels'),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _temperatureLevels = value!;
                  });
                },
                onSaved: (value) {
                  _temperatureLevels = value!;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _collectMeasurements,
                child: const Text('Collect Measurements'),
              ),
              if (_measurements.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text('Measurements Collected: ${_measurements.length}'),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveGadget,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
