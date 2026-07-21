import 'package:flutter/material.dart';
import '../models/space_models.dart';
import '../services/space_service.dart';

class LaunchesScreen extends StatefulWidget {
  const LaunchesScreen({super.key});
  @override
  State<LaunchesScreen> createState() => _LaunchesScreenState();
}

class _LaunchesScreenState extends State<LaunchesScreen> {
  late Future<List<LaunchEvent>> _launchesFuture;

  @override
  void initState() {
    super.initState();
    _launchesFuture = SpaceService().fetchUpcomingLaunches();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LaunchEvent>>(
      future: _launchesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No se pudieron cargar los lanzamientos. ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        }
        final launches = snapshot.data ?? [];
        if (launches.isEmpty) {
          return const Center(child: Text('No hay lanzamientos próximos.', style: TextStyle(color: Colors.white70)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: launches.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final launch = launches[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF12172B), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(launch.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(launch.provider, style: const TextStyle(color: Color(0xFF8B93A6), fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF3E4A7A), borderRadius: BorderRadius.circular(999)),
                        child: Text(launch.status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
