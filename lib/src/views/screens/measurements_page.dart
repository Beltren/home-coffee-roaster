import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/gadget.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this import for the chart

class MeasurementsPage extends StatefulWidget {
  final int temperatureLevels;
  final List<Measurement> existingMeasurements;

  const MeasurementsPage({
    Key? key,
    required this.temperatureLevels,
    required this.existingMeasurements,
  }) : super(key: key);

  @override
  _MeasurementsPageState createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage> {
  late List<Measurement> measurements;
  int _currentSlide = 0;
  int _currentLevelIndex = 0;
  Stopwatch _stopwatch = Stopwatch();
  bool _isTimerRunning = false;
  Timer? _timer;

  TextEditingController _levelNumberController = TextEditingController();
  TextEditingController _realTempController = TextEditingController();

  double _coolDownTime = 0.0;
  bool _coolDownMeasured = false;

  @override
  void initState() {
    super.initState();
    measurements = widget.existingMeasurements.isNotEmpty
        ? widget.existingMeasurements
        : List.generate(widget.temperatureLevels, (index) {
            return Measurement(
              level: index + 1,
              realTemperature: 0.0,
              heatUpTime: 0.0,
              coolDownTime: 0.0,
            );
          });
  }

  void _nextSlide() {
    setState(() {
      _currentSlide++;
    });
  }

  void _startTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // Updates the UI every second
      });
    });
    setState(() {
      _isTimerRunning = true;
    });
  }

  void _stopTimer() {
    _stopwatch.stop();
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isTimerRunning = false;
    });
    double timeInMinutes = _stopwatch.elapsed.inSeconds / 60;
    if (_currentSlide == 2) {
      // Heat-up time
      measurements[_currentLevelIndex].heatUpTime = timeInMinutes;
    } else if (_currentSlide == 5) {
      // Cool-down time
      _coolDownTime = timeInMinutes;
      _coolDownMeasured = true;
    }
  }

  void _resetTimer() {
    _stopwatch.reset();
    setState(() {
      // Update UI after reset
    });
  }

  void _saveLevelData() {
    measurements[_currentLevelIndex].level =
        int.tryParse(_levelNumberController.text) ?? (_currentLevelIndex + 1);
    measurements[_currentLevelIndex].realTemperature =
        double.tryParse(_realTempController.text) ?? 0.0;
    _levelNumberController.clear();
    _realTempController.clear();
  }

  void _nextLevel() {
    _saveLevelData();
    _stopwatch.reset();
    if (_currentLevelIndex < measurements.length - 1) {
      _currentLevelIndex++;
      _currentSlide = 1; // Reset to level start slide
      setState(() {
        // Update UI for the new level
      });
    } else {
      // Proceed to cool-down measurement
      _currentSlide = 4;
      setState(() {
        // Update UI
      });
    }
  }

  Widget _buildSlide() {
    switch (_currentSlide) {
      case 0:
        return _buildRoomTemperatureSlide();
      case 1:
        return _buildLevelNumberSlide();
      case 2:
        return _buildTimerSlide();
      case 3:
        return _buildRealTemperatureSlide();
      case 4:
        return _buildCoolDownStartSlide();
      case 5:
        return _buildCoolDownTimerSlide();
      case 6:
        return _buildGraphSlide();
      default:
        return const Center(child: Text('Error: Invalid slide'));
    }
  }

  Widget _buildRoomTemperatureSlide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Please check that the oven is at room temperature.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _nextSlide,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelNumberSlide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Level ${_currentLevelIndex + 1}: What's the number on your level?",
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _levelNumberController,
              decoration: const InputDecoration(
                labelText: 'Level Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _nextSlide,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerSlide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Please turn on your gadget and click Start to begin timing how long it takes for the temperature to stabilize.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Time: ${(_stopwatch.elapsed.inSeconds / 60).toStringAsFixed(2)} min',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_isTimerRunning) {
                      _stopTimer();
                    } else if (_stopwatch.elapsed.inMilliseconds > 0) {
                      _resetTimer();
                    } else {
                      _startTimer();
                    }
                  },
                  child: Text(_isTimerRunning
                      ? 'Stop'
                      : (_stopwatch.elapsed.inMilliseconds > 0 ? 'Repeat' : 'Start')),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _nextSlide,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTemperatureSlide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Please enter the real temperature at this level.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _realTempController,
              decoration: const InputDecoration(
                labelText: 'Real Temperature (°C)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _nextLevel,
              child: _currentLevelIndex < measurements.length - 1
                  ? const Text('Next Level')
                  : const Text('Proceed to Cool-Down'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoolDownStartSlide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Now, we will measure the cool-down time from the highest level to the first level.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Please set your gadget to the highest level, let it reach the temperature, and then reduce it to the first level.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _nextSlide,
              child: const Text('Start Cool-Down Measurement'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoolDownTimerSlide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Click Start to begin timing how long it takes for the temperature to cool down from the highest level to the first level.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Time: ${(_stopwatch.elapsed.inSeconds / 60).toStringAsFixed(2)} min',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_isTimerRunning) {
                      _stopTimer();
                    } else if (_stopwatch.elapsed.inMilliseconds > 0) {
                      _resetTimer();
                    } else {
                      _startTimer();
                    }
                  },
                  child: Text(_isTimerRunning
                      ? 'Stop'
                      : (_stopwatch.elapsed.inMilliseconds > 0 ? 'Repeat' : 'Start')),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_coolDownMeasured) {
                      _nextSlide();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please measure the cool-down time first.')),
                      );
                    }
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphSlide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Measurement Results',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    // Real Temperature vs Level
                    LineChartBarData(
                      spots: measurements
                          .map((m) => FlSpot(m.level.toDouble(), m.realTemperature))
                          .toList(),
                      isCurved: true,
                      color: const Color.fromARGB(255, 255, 0, 102),
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Heat-Up Time vs Level
                    LineChartBarData(
                      spots: measurements
                          .map((m) => FlSpot(m.level.toDouble(), m.heatUpTime))
                          .toList(),
                      isCurved: true,
                      color: const Color.fromARGB(255, 51, 51, 204),
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Cool-Down Time (single point)
                    if (_coolDownTime > 0)
                      LineChartBarData(
                        spots: [FlSpot(0, _coolDownTime)],
                        isCurved: false,
                        color: const Color.fromARGB(255, 0, 255, 153),
                        barWidth: 2,
                        dotData: FlDotData(show: true),
                      ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minY: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, measurements);
              },
              child: const Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _stopwatch.reset();
    _levelNumberController.dispose();
    _realTempController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurement Guide'),
      ),
      body: _buildSlide(),
    );
  }
}
