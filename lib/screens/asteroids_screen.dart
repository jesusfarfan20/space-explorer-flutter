import 'package:flutter/material.dart';
import '../models/space_models.dart';
import '../services/space_service.dart';

class AsteroidsScreen extends StatefulWidget {
  const AsteroidsScreen({super.key});
  @override
  State<AsteroidsScreen> createState() => _AsteroidsScreenState();
}

class _AsteroidsScreenState extends State<AsteroidsScreen> {
  late Future<List<NearEarthObject>> _asteroidsFuture;

  @override
  void initState() {
    super.initState();
    _asteroidsFuture = SpaceService().fetchNearEarthObjects();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NearEarthObject>>(
      future: _asteroidsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No se pudieron cargar los asteroides. ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        }
        final asteroids = snapshot.data ?? [];
        if (asteroids.isEmpty) {
          return const Center(child: Text('No hay asteroides cercanos hoy.', style: TextStyle(color: Colors.white70)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: asteroids.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final a = asteroids[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF12172B),
                borderRadius: BorderRadius.circular(12),
                border: a.isHazardous ? Border.all(color: const Color(0xFFE05C5C), width: 1.5) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(a.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
                      if (a.isHazardous)
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFE05C5C), size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Diámetro: ${a.diameterMinKm.toStringAsFixed(2)} - ${a.diameterMaxKm.toStringAsFixed(2)} km', style: const TextStyle(color: Color(0xFF8B93A6), fontSize: 13)),
                  Text('Distancia: ${(a.missDistanceKm / 1000).toStringAsFixed(0)} mil km', style: const TextStyle(color: Color(0xFF8B93A6), fontSize: 13)),
                  Text('Velocidad: ${a.velocityKmH.toStringAsFixed(0)} km/h', style: const TextStyle(color: Color(0xFF8B93A6), fontSize: 13)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
