import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as io_client;
import '../config/api_keys.dart';
import '../models/space_models.dart';

class SpaceService {
  Future<String> translateToSpanish(String text) async {
    if (text.trim().isEmpty) return text;
    try {
      final chunks = <String>[];
      for (var i = 0; i < text.length; i += 450) {
        chunks.add(text.substring(i, i + 450 > text.length ? text.length : i + 450));
      }
      final translatedChunks = <String>[];
      for (final chunk in chunks) {
        final url = 'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(chunk)}&langpair=en|es';
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final translated = data['responseData']?['translatedText']?.toString();
          translatedChunks.add(translated ?? chunk);
        } else {
          translatedChunks.add(chunk);
        }
      }
      return translatedChunks.join(' ');
    } catch (_) {
      return text;
    }
  }

  Future<Apod> fetchApod() async {
    final url = 'https://api.nasa.gov/planetary/apod?api_key=${ApiKeys.nasaApiKey}';
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('No se pudo cargar la imagen astronómica del día.');
    }
    final apod = Apod.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    final translatedExplanation = await translateToSpanish(apod.explanation);
    final translatedTitle = await translateToSpanish(apod.title);
    return Apod(
      title: translatedTitle,
      explanation: translatedExplanation,
      url: apod.url,
      date: apod.date,
      mediaType: apod.mediaType,
    );
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

  Future<void> enrichAstronautWithWikipedia(Astronaut astronaut) async {
    try {
      final nameForUrl = astronaut.name.replaceAll(' ', '_');
      final url = 'https://es.wikipedia.org/api/rest_v1/page/summary/$nameForUrl';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        astronaut.bio = data['extract']?.toString();
        astronaut.photoUrl = (data['thumbnail'] as Map<String, dynamic>?)?['source']?.toString();
      }
    } catch (_) {
      // Si falla, se queda sin biografía extra.
    }
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
    final launches = results.map((e) => LaunchEvent.fromJson(e as Map<String, dynamic>)).toList();

    final translatedLaunches = <LaunchEvent>[];
    for (final launch in launches) {
      final translatedDescription = await translateToSpanish(launch.missionDescription);
      translatedLaunches.add(LaunchEvent(
        name: launch.name,
        net: launch.net,
        status: launch.status,
        provider: launch.provider,
        imageUrl: launch.imageUrl,
        missionDescription: translatedDescription,
        rocketName: launch.rocketName,
        padName: launch.padName,
        padLocation: launch.padLocation,
      ));
    }
    return translatedLaunches;
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
