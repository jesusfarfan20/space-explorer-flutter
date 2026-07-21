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
  String? bio;
  String? photoUrl;

  Astronaut({required this.name, required this.craft, this.bio, this.photoUrl});

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
  final String missionDescription;
  final String rocketName;
  final String padName;
  final String padLocation;

  LaunchEvent({
    required this.name,
    required this.net,
    required this.status,
    required this.provider,
    this.imageUrl,
    required this.missionDescription,
    required this.rocketName,
    required this.padName,
    required this.padLocation,
  });

  factory LaunchEvent.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as Map<String, dynamic>?;
    final provider = json['launch_service_provider'] as Map<String, dynamic>?;
    final mission = json['mission'] as Map<String, dynamic>?;
    final rocket = json['rocket'] as Map<String, dynamic>?;
    final rocketConfig = rocket?['configuration'] as Map<String, dynamic>?;
    final pad = json['pad'] as Map<String, dynamic>?;

    return LaunchEvent(
      name: json['name'] ?? '',
      net: json['net'] ?? '',
      status: status?['name']?.toString() ?? 'Desconocido',
      provider: provider?['name']?.toString() ?? '',
      imageUrl: json['image'] as String?,
      missionDescription: mission?['description']?.toString() ?? 'Sin descripción disponible.',
      rocketName: rocketConfig?['full_name']?.toString() ?? rocketConfig?['name']?.toString() ?? 'Desconocido',
      padName: pad?['name']?.toString() ?? '',
      padLocation: (pad?['location'] as Map<String, dynamic>?)?['name']?.toString() ?? '',
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
  final double absoluteMagnitude;
  final String closeApproachDate;
  final String orbitingBody;

  NearEarthObject({
    required this.name,
    required this.diameterMinKm,
    required this.diameterMaxKm,
    required this.isHazardous,
    required this.missDistanceKm,
    required this.velocityKmH,
    required this.absoluteMagnitude,
    required this.closeApproachDate,
    required this.orbitingBody,
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
      absoluteMagnitude: (json['absolute_magnitude_h'] as num?)?.toDouble() ?? 0,
      closeApproachDate: closeApproach['close_approach_date']?.toString() ?? '',
      orbitingBody: closeApproach['orbiting_body']?.toString() ?? 'Tierra',
    );
  }
}
