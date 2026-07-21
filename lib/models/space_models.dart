class Apod {
  final String title;
  final String explanation;
  final String url;
  final String date;
  final String mediaType;

  Apod({required this.title, required this.explanation, required this.url, required this.date, required this.mediaType});

  factory Apod.fromJson(Map<String, dynamic> json) {
    return Apod(
      title: json['title'] ?? 'Sin título',
      explanation: json['explanation'] ?? '',
      url: json['url'] ?? '',
      date: json['date'] ?? '',
      mediaType: json['media_type'] ?? 'image',
    );
  }
}

class Astronaut {
  final String name;
  final String craft;

  Astronaut({required this.name, required this.craft});

  factory Astronaut.fromJson(Map<String, dynamic> json) {
    return Astronaut(name: json['name'] ?? '', craft: json['craft'] ?? '');
  }
}

class LaunchEvent {
  final String name;
  final String net;
  final String status;
  final String provider;
  final String? imageUrl;

  LaunchEvent({required this.name, required this.net, required this.status, required this.provider, this.imageUrl});

  factory LaunchEvent.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as Map<String, dynamic>?;
    final provider = json['launch_service_provider'] as Map<String, dynamic>?;
    return LaunchEvent(
      name: json['name'] ?? '',
      net: json['net'] ?? '',
      status: status?['name']?.toString() ?? 'Desconocido',
      provider: provider?['name']?.toString() ?? '',
      imageUrl: json['image'] as String?,
    );
  }
}

class NearEarthObject {
  final String name;
  final double diameterMinKm;
  final double diameterMaxKm;
  final bool isHazardous;
  final double missDistanceKm;
  final double velocityKmH;

  NearEarthObject({
    required this.name,
    required this.diameterMinKm,
    required this.diameterMaxKm,
    required this.isHazardous,
    required this.missDistanceKm,
    required this.velocityKmH,
  });

  factory NearEarthObject.fromJson(Map<String, dynamic> json) {
    final diameter = json['estimated_diameter']?['kilometers'] as Map<String, dynamic>?;
    final closeApproach = (json['close_approach_data'] as List?)?.isNotEmpty == true
        ? json['close_approach_data'][0] as Map<String, dynamic>
        : <String, dynamic>{};
    final missDistance = closeApproach['miss_distance'] as Map<String, dynamic>?;
    final relativeVelocity = closeApproach['relative_velocity'] as Map<String, dynamic>?;

    return NearEarthObject(
      name: json['name'] ?? '',
      diameterMinKm: (diameter?['estimated_diameter_min'] as num?)?.toDouble() ?? 0,
      diameterMaxKm: (diameter?['estimated_diameter_max'] as num?)?.toDouble() ?? 0,
      isHazardous: json['is_potentially_hazardous_asteroid'] ?? false,
      missDistanceKm: double.tryParse(missDistance?['kilometers']?.toString() ?? '0') ?? 0,
      velocityKmH: double.tryParse(relativeVelocity?['kilometers_per_hour']?.toString() ?? '0') ?? 0,
    );
  }
}
