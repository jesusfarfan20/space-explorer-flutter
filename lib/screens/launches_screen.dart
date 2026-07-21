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
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Cargando y traduciendo lanzamientos...', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          );
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
              decoration: BoxDecoration(color: const Color(0xFF12172B), borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {},
                splashColor: const Color(0xFFE0A93E).withValues(alpha: 0.1),
                highlightColor: const Color(0xFFE0A93E).withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(launch.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(launch.provider, style: const TextStyle(color: Color(0xFF8B93A6), fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF3E4A7A), borderRadius: BorderRadius.circular(999)),
                    child: Text(launch.status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF2A3050), height: 1),
                  const SizedBox(height: 12),
                  _DetailRow(icon: Icons.rocket_launch, label: 'Cohete', value: launch.rocketName),
                  _DetailRow(icon: Icons.place_outlined, label: 'Plataforma', value: launch.padName),
                  _DetailRow(icon: Icons.public, label: 'Ubicación', value: launch.padLocation),
                  const SizedBox(height: 10),
                  Text(launch.missionDescription, style: const TextStyle(color: Colors.white70, height: 1.4, fontSize: 13)),
                ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: const Color(0xFFE0A93E)),
          const SizedBox(width: 6),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(color: Color(0xFF8B93A6), fontSize: 13)),
                  TextSpan(text: value, style: const TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
