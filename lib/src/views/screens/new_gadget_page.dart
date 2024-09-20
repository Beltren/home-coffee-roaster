import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io'; // Add this import
import 'package:path_provider/path_provider.dart';
import '../../models/gadget.dart';
import 'measurements_page.dart';

class NewGadgetPage extends StatefulWidget {
  const NewGadgetPage({Key? key}) : super(key: key);

  @override
  _NewGadgetPageState createState() => _NewGadgetPageState();
}

class _NewGadgetPageState extends State<NewGadgetPage> {
  final _formKey = GlobalKey<FormState>();
  String _gadgetName = '';
  String _gadgetDescription = '';
  int _temperatureLevels = 4;
  List<Measurement> _measurements = [];

  Future<void> _saveGadget() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newGadget = Gadget(
        name: _gadgetName,
        description: _gadgetDescription,
        temperatureLevels: _temperatureLevels,
        measurements: _measurements,
      );

      final directory = await getApplicationDocumentsDirectory();
      final path = Directory('${directory.path}/gadgets');

      if (!(await path.exists())) {
        await path.create(recursive: true);
      }

      final file = File('${path.path}/${_gadgetName.replaceAll(' ', '_')}.json');

      await file.writeAsString(jsonEncode(newGadget.toJson()));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Gadget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
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
                child: const Text('Save Gadget'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
