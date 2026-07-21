import 'package:flutter/material.dart';
import '../models/space_models.dart';
import '../services/space_service.dart';

class AstronautsScreen extends StatefulWidget {
  const AstronautsScreen({super.key});
  @override
  State<AstronautsScreen> createState() => _AstronautsScreenState();
}

class _AstronautsScreenState extends State<AstronautsScreen> {
  late Future<List<Astronaut>> _astronautsFuture;

  @override
  void initState() {
    super.initState();
    _astronautsFuture = _loadAstronauts();
  }

  Future<List<Astronaut>> _loadAstronauts() async {
    final astronauts = await SpaceService().fetchAstronauts();
    for (final astronaut in astronauts) {
      await SpaceService().enrichAstronautWithWikipedia(astronaut);
    }
    return astronauts;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Astronaut>>(
      future: _astronautsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No se pudo cargar la lista de astronautas. ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        }
        final astronauts = snapshot.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('${astronauts.length} personas en el espacio ahora', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...astronauts.map((a) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF12172B), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFF3E4A7A),
                            backgroundImage: a.photoUrl != null ? NetworkImage(a.photoUrl!) : null,
                            child: a.photoUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('Nave: ${a.craft}', style: const TextStyle(color: Color(0xFF8B93A6), fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (a.bio != null && a.bio!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Divider(color: Color(0xFF2A3050), height: 1),
                        const SizedBox(height: 10),
                        Text(a.bio!, style: const TextStyle(color: Colors.white70, height: 1.4, fontSize: 13)),
                      ],
                    ],
                  ),
                )),
          ],
        );
      },
    );
  }
}
