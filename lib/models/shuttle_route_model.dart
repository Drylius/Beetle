import 'package:beetle/models/campus_model.dart';

class ShuttleRoute {
  final String id;
  final Campus originCampus;
  final Campus destinationCampus;

  ShuttleRoute({
    required this.id,
    required this.originCampus,
    required this.destinationCampus,
  });

  factory ShuttleRoute.empty() {
    return ShuttleRoute(
      id: '',
      originCampus: Campus(id: '', name: ''),
      destinationCampus: Campus(id: '', name: ''),
    );
  }

  factory ShuttleRoute.fromJson(Map<String, dynamic> json) {
    return ShuttleRoute(
      id: json['id'] ?? '',
      originCampus: json['originCampus'] is Map<String, dynamic>
          ? Campus.fromJson(json['originCampus'])
          : json['originCampus'], // handle both object or nested map
      destinationCampus: json['destinationCampus'] is Map<String, dynamic>
          ? Campus.fromJson(json['destinationCampus'])
          : json['destinationCampus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originCampus': originCampus.toJson(),
      'destinationCampus': destinationCampus.toJson(),
    };
  }
}
