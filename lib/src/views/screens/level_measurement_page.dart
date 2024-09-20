import 'package:flutter/material.dart';
import '../../models/gadget.dart';

class LevelMeasurementPage extends StatefulWidget {
  final Measurement measurement;

  const LevelMeasurementPage({
    Key? key,
    required this.measurement,
  }) : super(key: key);

  @override
  _LevelMeasurementPageState createState() => _LevelMeasurementPageState();
}

class _LevelMeasurementPageState extends State<LevelMeasurementPage> {
  final _formKey = GlobalKey<FormState>();
  late double realTemperature;
  late double heatUpTime;
  late double coolDownTime;

  @override
  void initState() {
    super.initState();
    realTemperature = widget.measurement.realTemperature;
    heatUpTime = widget.measurement.heatUpTime;
    coolDownTime = widget.measurement.coolDownTime;
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.measurement.realTemperature = realTemperature;
      widget.measurement.heatUpTime = heatUpTime;
      widget.measurement.coolDownTime = coolDownTime;
      Navigator.pop(context);
    }
  }

  Future<void> _startTimer(String type) async {
    Stopwatch stopwatch = Stopwatch();
    bool isRunning = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('$type Timer'),
            content: Text(
              'Time: ${(stopwatch.elapsed.inSeconds / 60).toStringAsFixed(2)} min',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (!isRunning) {
                    stopwatch.start();
                    setState(() {
                      isRunning = true;
                    });
                  } else {
                    stopwatch.stop();
                    setState(() {
                      isRunning = false;
                    });
                  }
                },
                child: Text(isRunning ? 'Stop' : 'Start'),
              ),
              TextButton(
                onPressed: () {
                  stopwatch.reset();
                  setState(() {});
                },
                child: const Text('Reset'),
              ),
              TextButton(
                onPressed: () {
                  double timeInMinutes = stopwatch.elapsed.inSeconds / 60;
                  if (type == 'Heat-Up') {
                    setState(() {
                      heatUpTime = timeInMinutes;
                    });
                  } else {
                    setState(() {
                      coolDownTime = timeInMinutes;
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.measurement.level} Measurement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Set your gadget to Level ${widget.measurement.level} and perform measurements.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: realTemperature > 0 ? realTemperature.toString() : '',
                decoration: const InputDecoration(
                  labelText: 'Real Temperature (°C)',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the real temperature';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  realTemperature = double.parse(value!);
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Heat-Up Time'),
                subtitle: Text(heatUpTime > 0
                    ? '${heatUpTime.toStringAsFixed(2)} min'
                    : 'Not measured'),
                trailing: ElevatedButton(
                  onPressed: () {
                    _startTimer('Heat-Up');
                  },
                  child: const Text('Measure'),
                ),
              ),
              ListTile(
                title: const Text('Cool-Down Time'),
                subtitle: Text(coolDownTime > 0
                    ? '${coolDownTime.toStringAsFixed(2)} min'
                    : 'Not measured'),
                trailing: ElevatedButton(
                  onPressed: () {
                    _startTimer('Cool-Down');
                  },
                  child: const Text('Measure'),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save Measurement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
