import 'package:flutter/material.dart';
import './shared/widgets/left_drawer.dart';
import './shared/widgets/navigation_bar.dart';
import 'modules/studio/studio_page.dart';
import 'modules/sportswear/sportswear_page.dart';
import 'modules/resources/resources_page.dart';
import 'modules/user/user_page.dart';
import 'modules/timeline/timeline_page.dart';
import 'modules/events/events_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Souline'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      drawer: const LeftDrawer(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Welcome to Souline',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your yoga and pilates companion',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.only(bottom: 100),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildModuleCard(
                        context,
                        'Studio',
                        Icons.fitness_center,
                        Colors.purple,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StudioPage()),
                        ),
                      ),
                      _buildModuleCard(
                        context,
                        'Sportswear',
                        Icons.shopping_bag,
                        Colors.blue,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SportswearPage(),
                          ),
                        ),
                      ),
                      _buildModuleCard(
                        context,
                        'Resources',
                        Icons.video_library,
                        Colors.green,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ResourcesPage(),
                          ),
                        ),
                      ),
                      _buildModuleCard(
                        context,
                        'Profile',
                        Icons.person,
                        Colors.orange,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UserPage()),
                        ),
                      ),
                      _buildModuleCard(
                        context,
                        'Timeline',
                        Icons.timeline,
                        Colors.teal,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TimelinePage(),
                          ),
                        ),
                      ),
                      _buildModuleCard(
                        context,
                        'Events',
                        Icons.event,
                        Colors.red,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EventsPage()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingNavigationBar(currentIndex: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
