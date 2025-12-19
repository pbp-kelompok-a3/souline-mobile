import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'modules/studio/studio_page.dart';
import 'modules/sportswear/sportswear_page.dart';
import 'modules/resources/resources_page.dart';
import 'modules/user/user_page.dart';
import 'modules/user/login.dart';
import 'modules/timeline/timeline_page.dart';
import 'modules/events/events_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _username;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final request = context.read<CookieRequest>();
    
    if (request.loggedIn) {
      try {
        final response = await request.get(
          'https://farrel-rifqi-souline.pbp.cs.ui.ac.id/users/get-profile-flutter/',
        );
        
        if (response['status'] == true) {
          setState(() {
            _username = response['username'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final request = context.read<CookieRequest>();
    
    try {
      final response = await request.logout(
        'https://farrel-rifqi-souline.pbp.cs.ui.ac.id/auth/logout/',
      );
      
      if (mounted) {
        setState(() {
          _username = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Logged out')),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Souline'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (request.loggedIn && _username != null)
            PopupMenuButton<String>(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      'Hello, $_username',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
              onSelected: (value) {
                if (value == 'profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserPage()),
                  ).then((_) => _checkLoginStatus());
                } else if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 20),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            )
          else
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ).then((_) => _checkLoginStatus());
              },
              icon: const Icon(Icons.login),
              label: const Text('Login'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
              ),
            ),
        ],
      ),
      body: Padding(
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
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildModuleCard(
                    context,
                    'Studio',
                    Icons.fitness_center,
                    Colors.purple,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudioPage())),
                  ),
                  _buildModuleCard(
                    context,
                    'Sportswear',
                    Icons.shopping_bag,
                    Colors.blue,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SportswearPage())),
                  ),
                  _buildModuleCard(
                    context,
                    'Resources',
                    Icons.video_library,
                    Colors.green,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResourcesPage())),
                  ),
                  _buildModuleCard(
                    context,
                    'Timeline',
                    Icons.timeline,
                    Colors.teal,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimelinePage())),
                  ),
                  _buildModuleCard(
                    context,
                    'Events',
                    Icons.event,
                    Colors.red,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventsPage())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}