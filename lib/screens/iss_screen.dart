import 'dart:async';
import 'package:flutter/material.dart';
import '../services/space_service.dart';

class IssScreen extends StatefulWidget {
  const IssScreen({super.key});
  @override
  State<IssScreen> createState() => _IssScreenState();
}

class _IssScreenState extends State<IssScreen> {
  Map<String, dynamic>? _issData;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadIssPosition();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => _loadIssPosition());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadIssPosition() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await SpaceService().fetchIssPosition();
      if (!mounted) return;
      setState(() {
        _issData = data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _issData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null && _issData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
        ),
      );
    }

    final data = _issData ?? <String, dynamic>{};
    final latitude = (data['latitude'] as num?)?.toStringAsFixed(2) ?? 'N/A';
    final longitude = (data['longitude'] as num?)?.toStringAsFixed(2) ?? 'N/A';
    final altitude = (data['altitude'] as num?)?.toStringAsFixed(1) ?? 'N/A';
    final velocity = (data['velocity'] as num?)?.toStringAsFixed(0) ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estación Espacial Internacional', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _StatRow(label: 'Latitud', value: '$latitude°'),
          _StatRow(label: 'Longitud', value: '$longitude°'),
          _StatRow(label: 'Altitud', value: '$altitude km'),
          _StatRow(label: 'Velocidad', value: '$velocity km/h'),
          const SizedBox(height: 12),
          const Text('Actualiza cada 8 segundos', style: TextStyle(color: Color(0xFF8B93A6), fontSize: 13)),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF12172B), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF8B93A6))),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
