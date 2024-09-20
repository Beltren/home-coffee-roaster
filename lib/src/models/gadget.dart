class Gadget {
  String name;
  String description;
  int temperatureLevels;
  List<Measurement> measurements;

  Gadget({
    required this.name,
    required this.description,
    required this.temperatureLevels,
    required this.measurements,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'temperatureLevels': temperatureLevels,
      'measurements': measurements.map((m) => m.toJson()).toList(),
    };
  }

  factory Gadget.fromJson(Map<String, dynamic> json) {
    return Gadget(
      name: json['name'],
      description: json['description'],
      temperatureLevels: json['temperatureLevels'],
      measurements: (json['measurements'] as List)
          .map((item) => Measurement.fromJson(item))
          .toList(),
    );
  }
}

class Measurement {
  int level;
  double realTemperature;
  double heatUpTime;
  double coolDownTime;

  Measurement({
    required this.level,
    required this.realTemperature,
    required this.heatUpTime,
    required this.coolDownTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'realTemperature': realTemperature,
      'heatUpTime': heatUpTime,
      'coolDownTime': coolDownTime,
    };
  }

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      level: json['level'],
      realTemperature: json['realTemperature'],
      heatUpTime: json['heatUpTime'],
      coolDownTime: json['coolDownTime'],
    );
  }
}
