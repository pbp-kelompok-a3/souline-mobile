import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import 'events_page.dart';

class AddEventPage extends StatefulWidget {
  final EventModel? editEvent;
  const AddEventPage({super.key, this.editEvent});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String authToken = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editEvent != null) {
      _nameCtrl.text = widget.editEvent!.name;
      // set date as YYYY-MM-DD
      _dateCtrl.text = widget.editEvent!.date.toIso8601String().substring(0, 10);
      _locationCtrl.text = widget.editEvent!.location;
      _descCtrl.text = widget.editEvent!.description;
    }
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token') ?? '';
  }

  String joinBase(String path) {
    final base = AppConstants.baseUrl;
    if (base.endsWith('/')) return '$base$path';
    return '$base/$path';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final name = _nameCtrl.text.trim();
    final date = _dateCtrl.text.trim(); // expect YYYY-MM-DD
    final desc = _descCtrl.text.trim();
    final location = _locationCtrl.text.trim();

    final headers = {'Content-Type': 'application/json'};
    if (authToken.isNotEmpty) headers['Authorization'] = 'Token $authToken';

    try {
      if (widget.editEvent == null) {
        final url = joinBase('events/api/create/');
        final resp = await http.post(Uri.parse(url), headers: headers, body: jsonEncode({
          'name': name,
          'date': date,
          'description': desc,
          'location': location,
        }));

        if (resp.statusCode == 201) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Create failed: ${resp.statusCode}')));
        }
      } else {
        final url = joinBase('events/api/${widget.editEvent!.id}/edit/');
        final resp = await http.put(Uri.parse(url), headers: headers, body: jsonEncode({
          'name': name,
          'date': date,
          'description': desc,
          'location': location,
        }));

        if (resp.statusCode == 200) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: ${resp.statusCode}')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dateCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editEvent != null;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: Text(isEdit ? 'Edit Event' : 'Add Event'), backgroundColor: AppColors.cream),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // poster placeholder
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Icon(Icons.add_a_photo_outlined, size: 36, color: Colors.grey)),
              ),
              const SizedBox(height: 20),
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _dateCtrl, decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _locationCtrl, decoration: const InputDecoration(labelText: 'Location')),
              const SizedBox(height: 12),
              TextFormField(controller: _descCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _loading ? null : _submit, child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(isEdit ? 'Save' : 'Add Event')),
            ],
          ),
        ),
      ),
    );
  }
}
