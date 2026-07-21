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
  final Set<String> _expanded = {};

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
        final hazardousCount = asteroids.where((a) => a.isHazardous).length;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('${asteroids.length} asteroides cercanos hoy', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            if (hazardousCount > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A1F1F),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE05C5C)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFE05C5C)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$hazardousCount marcado(s) como potencialmente peligroso(s)',
                        style: const TextStyle(color: Color(0xFFE05C5C), fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...asteroids.map((a) {
              final isExpanded = _expanded.contains(a.name);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF12172B),
                  borderRadius: BorderRadius.circular(12),
                  border: a.isHazardous ? Border.all(color: const Color(0xFFE05C5C), width: 1.5) : null,
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expanded.remove(a.name);
                      } else {
                        _expanded.add(a.name);
                      }
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(a.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
                          if (a.isHazardous) const Icon(Icons.warning_amber_rounded, color: Color(0xFFE05C5C), size: 20),
                          Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white38),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Diámetro estimado: ${a.diameterMinKm.toStringAsFixed(2)} - ${a.diameterMaxKm.toStringAsFixed(2)} km', style: const TextStyle(color: Color(0xFF8B93A6), fontSize: 13)),
                      Text('Distancia de paso: ${(a.missDistanceKm / 1000).toStringAsFixed(0)} mil km', style: const TextStyle(color: Color(0xFF8B93A6), fontSize: 13)),
                      Text('Velocidad relativa: ${a.velocityKmH.toStringAsFixed(0)} km/h', style: const TextStyle(color: Color(0xFF8B93A6), fontSize: 13)),
                      if (isExpanded) ...[
                        const SizedBox(height: 10),
                        const Divider(color: Color(0xFF2A3050), height: 1),
                        const SizedBox(height: 10),
                        Text('Fecha de aproximación: ${a.closeApproachDate}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        Text('Magnitud absoluta: ${a.absoluteMagnitude.toStringAsFixed(1)} H', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        Text('Cuerpo que orbita: ${a.orbitingBody}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        if (a.isHazardous) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFF3A1F1F), borderRadius: BorderRadius.circular(8)),
                            child: const Text(
                              '¿Por qué está marcado como peligroso?\nLa NASA clasifica un asteroide como "potencialmente peligroso" cuando cumple dos condiciones: mide más de 140 metros de diámetro Y su órbita lo acerca a menos de 7.5 millones de km de la Tierra. Esto no significa que vaya a impactar, solo que su tamaño y cercanía ameritan seguimiento constante.',
                              style: TextStyle(color: Color(0xFFE0A0A0), fontSize: 12.5, height: 1.4),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
