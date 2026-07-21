import 'package:flutter/material.dart';
import 'screens/apod_screen.dart';
import 'screens/iss_screen.dart';
import 'screens/astronauts_screen.dart';
import 'screens/launches_screen.dart';
import 'screens/asteroids_screen.dart';
import 'widgets/starfield_background.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E1A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E4A7A),
          brightness: Brightness.dark,
          primary: const Color(0xFF6C7BC7),
          secondary: const Color(0xFFE0A93E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F1424),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF0F1424)),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    ApodScreen(),
    IssScreen(),
    AstronautsScreen(),
    LaunchesScreen(),
    AsteroidsScreen(),
  ];

  static const List<String> _titles = <String>[
    'Imagen del día',
    'Estación Espacial',
    'Astronautas',
    'Lanzamientos',
    'Asteroides',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Space Explorer'),
            Text(_titles[_selectedIndex], style: const TextStyle(fontSize: 12, color: Color(0xFFE0A93E))),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF3E4A7A)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.rocket_launch, size: 44, color: Color(0xFFE0A93E)),
                  SizedBox(height: 8),
                  Text('Space Explorer', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Datos del espacio en vivo', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            _buildDrawerItem(Icons.image_outlined, 'Imagen del día', 0),
            _buildDrawerItem(Icons.satellite_alt, 'ISS en vivo', 1),
            _buildDrawerItem(Icons.person_outline, 'Astronautas', 2),
            _buildDrawerItem(Icons.rocket_launch_outlined, 'Lanzamientos', 3),
            _buildDrawerItem(Icons.public, 'Asteroides', 4),
          ],
        ),
      ),
      body: StarfieldBackground(child: _screens[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.image_outlined), label: 'APOD'),
          NavigationDestination(icon: Icon(Icons.satellite_alt), label: 'ISS'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Astros'),
          NavigationDestination(icon: Icon(Icons.rocket_launch_outlined), label: 'Lanz.'),
          NavigationDestination(icon: Icon(Icons.public), label: 'Aster.'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFFE0A93E) : Colors.white70),
      title: Text(label, style: TextStyle(color: isSelected ? const Color(0xFFE0A93E) : Colors.white)),
      selected: isSelected,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }
}
