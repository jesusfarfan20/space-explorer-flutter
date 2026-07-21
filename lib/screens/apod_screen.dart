import 'package:flutter/material.dart';
import '../models/space_models.dart';
import '../services/space_service.dart';

class ApodScreen extends StatefulWidget {
  const ApodScreen({super.key});
  @override
  State<ApodScreen> createState() => _ApodScreenState();
}

class _ApodScreenState extends State<ApodScreen> {
  late Future<Apod> _apodFuture;

  @override
  void initState() {
    super.initState();
    _apodFuture = SpaceService().fetchApod();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Apod>(
      future: _apodFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No se pudo cargar la imagen del día. ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        }
        final apod = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (apod.mediaType == 'image')
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    apod.url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()));
                    },
                    errorBuilder: (context, error, stack) => const SizedBox(
                      height: 220,
                      child: Center(child: Icon(Icons.broken_image, color: Colors.white38, size: 48)),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(apod.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(apod.date, style: const TextStyle(color: Color(0xFF8B93A6), fontSize: 13)),
              const SizedBox(height: 12),
              Text(apod.explanation, style: const TextStyle(color: Colors.white70, height: 1.5)),
            ],
          ),
        );
      },
    );
  }
}
