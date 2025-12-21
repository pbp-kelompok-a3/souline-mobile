import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../modules/user/login.dart';
import '../../modules/user/user_page.dart';
import '../../home_page.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer({super.key});

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  String _username = 'Guest';
  String _location = 'Location not set';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      if (request.loggedIn) {
        _loadProfile(request);
      }
    });
  }

  Future<void> _loadProfile(CookieRequest request) async {
    setState(() => _isLoading = true);
    try {
      final response = await request.get(
        '${AppConstants.baseUrl}users/get-profile-flutter/',
      );

      if (mounted && response['status'] == true) {
        setState(() {
          _username = response['username'];
          _location = response['kota'] ?? 'Location not set';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // Reset to generic if logged out
    if (!request.loggedIn && _username != 'Guest') {
      _username = 'Guest';
      _location = 'Location not set';
    }

    return Drawer(
      child: Container(
        color: AppColors.cream,
        child: Column(
          children: [
            // Drawer Header
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                children: [
                  _buildHeader(context, request.loggedIn),
                  const SizedBox(height: 20),
                  Divider(color: AppColors.darkBlue.withValues(alpha: 0.5)),
                  const SizedBox(height: 10),

                  // Navigation Items
                  _buildListTile(
                    context,
                    icon: Icons.home_outlined,
                    title: 'Home',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () {
                      if (request.loggedIn) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserPage(),
                          ),
                        ).then((_) {
                          // Refresh profile in case it changed
                          _loadProfile(request);
                        });
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      }
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.bookmark_border,
                    title: 'Bookmarks',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to Bookmarks Page
                    },
                  ),
                ],
              ),
            ),

            // Auth Section
            Padding(
              padding: const EdgeInsets.only(
                bottom: 24.0,
                left: 24.0,
                right: 24.0,
              ),
              child: _buildAuthTile(context, request),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLoggedIn) {
    return Container(
      color: AppColors.cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.darkBlue,
            child: Icon(
              isLoggedIn ? Icons.person : Icons.person_outline,
              size: 40,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else ...[
            Text(
              isLoggedIn ? _username : 'Guest',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 4),
            if (isLoggedIn)
              Text(
                _location,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.darkBlue, size: 30),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.darkBlue,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildAuthTile(BuildContext context, CookieRequest request) {
    if (request.loggedIn) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.logout, color: Colors.red, size: 30),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ),
        ),
        onTap: () async {
          final response = await request.logout(
            '${AppConstants.baseUrl}auth/logout/',
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message']),
                backgroundColor: AppColors.darkBlue,
              ),
            );
            Navigator.pop(context);
          }
        },
      );
    } else {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.login, color: AppColors.darkBlue, size: 30),
        title: const Text(
          'Login',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlue,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
      );
    }
  }
}
