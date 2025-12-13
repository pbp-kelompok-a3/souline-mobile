import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.purple),
            SizedBox(height: 16),
            Text(
              'User Profile Module',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Manage your account and preferences'),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _activeForm;
  final _formKeys = {
    'username': GlobalKey<FormState>(),
    'password': GlobalKey<FormState>(),
    'kota': GlobalKey<FormState>(),
    'delete': GlobalKey<FormState>(),
  };

  // Controllers for form inputs
  final _newUsernameController = TextEditingController();
  final _currentPasswordUsernameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPassword1Controller = TextEditingController();
  final _newPassword2Controller = TextEditingController();
  final _kotaController = TextEditingController();
  final _currentPasswordKotaController = TextEditingController();
  final _currentPasswordDeleteController = TextEditingController();

  // Mock user data - replace with actual data from your backend
  String username = "user123";
  String kota = "Jakarta";

  @override
  void dispose() {
    _newUsernameController.dispose();
    _currentPasswordUsernameController.dispose();
    _oldPasswordController.dispose();
    _newPassword1Controller.dispose();
    _newPassword2Controller.dispose();
    _kotaController.dispose();
    _currentPasswordKotaController.dispose();
    _currentPasswordDeleteController.dispose();
    super.dispose();
  }

  void _toggleForm(String formId) {
    setState(() {
      _activeForm = _activeForm == formId ? null : formId;
    });
  }

  void _handleUsernameChange() {
    if (_formKeys['username']!.currentState!.validate()) {
      // TODO: Implement API call to change username
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username changed successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _toggleForm('username');
    }
  }

  void _handlePasswordChange() {
    if (_formKeys['password']!.currentState!.validate()) {
      if (_newPassword1Controller.text != _newPassword2Controller.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // TODO: Implement API call to change password
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _toggleForm('password');
    }
  }

  void _handleKotaChange() {
    if (_formKeys['kota']!.currentState!.validate()) {
      // TODO: Implement API call to update kota
      setState(() {
        kota = _kotaController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kota updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _toggleForm('kota');
    }
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKeys['delete']!.currentState!.validate()) {
                  // TODO: Implement API call to delete account
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Return to previous screen
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, {bool isDanger = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDanger ? const Color(0xFFDC3545) : const Color(0xFF446178),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        elevation: 2,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  Widget _buildFormSection(
    String formId,
    String title,
    List<Widget> formFields,
    VoidCallback onSubmit,
    {bool isDanger = false}
  ) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: _activeForm == formId
          ? Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Form(
                key: _formKeys[formId],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...formFields,
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDanger ? const Color(0xFFDC3545) : const Color(0xFF446178),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator ?? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.all(50),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Navigation
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Color(0xFF446178)),
                        SizedBox(width: 5),
                        Text(
                          'Back to Main',
                          style: TextStyle(
                            color: Color(0xFF446178),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Title
                  const Text(
                    'Your Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Profile Info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('Username:', username),
                        const SizedBox(height: 10),
                        _buildInfoRow('Password:', '********'),
                        const SizedBox(height: 10),
                        _buildInfoRow('Kota:', kota.isEmpty ? 'Not set' : kota),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Action Buttons Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 3,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildActionButton('Change Username', () => _toggleForm('username')),
                      _buildActionButton('Change Password', () => _toggleForm('password')),
                      _buildActionButton('Change Kota', () => _toggleForm('kota')),
                      _buildActionButton('Delete Account', () => _toggleForm('delete'), isDanger: true),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Forms
                  _buildFormSection(
                    'username',
                    'Change Username',
                    [
                      _buildTextField(
                        label: 'New Username:',
                        controller: _newUsernameController,
                      ),
                      _buildTextField(
                        label: 'Current Password:',
                        controller: _currentPasswordUsernameController,
                        obscureText: true,
                      ),
                    ],
                    _handleUsernameChange,
                  ),

                  _buildFormSection(
                    'password',
                    'Change Password',
                    [
                      _buildTextField(
                        label: 'Current Password:',
                        controller: _oldPasswordController,
                        obscureText: true,
                      ),
                      _buildTextField(
                        label: 'New Password:',
                        controller: _newPassword1Controller,
                        obscureText: true,
                      ),
                      _buildTextField(
                        label: 'Confirm New Password:',
                        controller: _newPassword2Controller,
                        obscureText: true,
                      ),
                    ],
                    _handlePasswordChange,
                  ),

                  _buildFormSection(
                    'kota',
                    'Update Kota',
                    [
                      _buildTextField(
                        label: 'Kota:',
                        controller: _kotaController,
                      ),
                      _buildTextField(
                        label: 'Current Password:',
                        controller: _currentPasswordKotaController,
                        obscureText: true,
                      ),
                    ],
                    _handleKotaChange,
                  ),

                  _buildFormSection(
                    'delete',
                    'Confirm Account Deletion',
                    [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: Text(
                          'Warning: Deleting your account is permanent and cannot be undone.',
                          style: TextStyle(
                            color: Color(0xFFDC3545),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _buildTextField(
                        label: 'Current Password:',
                        controller: _currentPasswordDeleteController,
                        obscureText: true,
                      ),
                    ],
                    _handleDeleteAccount,
                    isDanger: true,
                  ),

                  // Logout Link
                  const SizedBox(height: 30),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement logout
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Color(0xFF446178),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }
}