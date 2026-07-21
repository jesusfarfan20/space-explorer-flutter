import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as io_client;
import '../config/api_keys.dart';
import '../models/space_models.dart';

class SpaceService {
  Future<Apod> fetchApod() async {
    final url = 'https://api.nasa.gov/planetary/apod?api_key=${ApiKeys.nasaApiKey}';
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('No se pudo cargar la imagen astronómica del día.');
    }
    return Apod.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> fetchIssPosition() async {
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return host == 'api.wheretheiss.at';
      };
    final client = io_client.IOClient(httpClient);
    try {
      final response = await client
          .get(Uri.parse('https://api.wheretheiss.at/v1/satellites/25544'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw Exception('No se pudo cargar la posición de la ISS.');
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

  Future<List<Astronaut>> fetchAstronauts() async {
    final response = await http
        .get(Uri.parse('http://api.open-notify.org/astros.json'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('No se pudo cargar la lista de astronautas.');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final people = data['people'] as List<dynamic>? ?? [];
    return people.map((e) => Astronaut.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<LaunchEvent>> fetchUpcomingLaunches() async {
    final response = await http
        .get(Uri.parse('https://ll.thespacedevs.com/2.2.0/launch/upcoming/?limit=10'))
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los próximos lanzamientos.');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>? ?? [];
    return results.map((e) => LaunchEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<NearEarthObject>> fetchNearEarthObjects() async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final url = 'https://api.nasa.gov/neo/rest/v1/feed?start_date=$dateStr&end_date=$dateStr&api_key=${ApiKeys.nasaApiKey}';
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los asteroides cercanos.');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final nearEarthObjects = data['near_earth_objects'] as Map<String, dynamic>? ?? {};
    final todayList = nearEarthObjects[dateStr] as List<dynamic>? ?? [];
    return todayList.map((e) => NearEarthObject.fromJson(e as Map<String, dynamic>)).toList();
  }
}
