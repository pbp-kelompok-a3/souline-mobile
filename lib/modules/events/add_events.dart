import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/event_model.dart';
import '../../shared/models/studio_entry.dart';

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
  final _descCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController(); // <- untuk URL image opsional

  Studio? _selectedStudio;
  StudioEntry? _studioEntry;

  bool _loading = false;
  String authToken = '';

  String joinBase(String path) {
    final base = AppConstants.baseUrl;
    if (base.endsWith('/')) return '$base$path';
    return '$base/$path';
  }

  @override
  void initState() {
    super.initState();
    _loadToken();
    _fetchStudios();
    if (widget.editEvent != null) {
      _nameCtrl.text = widget.editEvent!.name;
      _dateCtrl.text =
          widget.editEvent!.date.toIso8601String().substring(0, 10);
      _descCtrl.text = widget.editEvent!.description;
      _imageUrlCtrl.text = widget.editEvent!.poster; // ambil URL jika ada
    }
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token') ?? '';
  }

  Future<void> _fetchStudios() async {
    try {
      final candidates = [
        joinBase('studio/json/'),
        joinBase('studios/json/'),
      ];

      http.Response resp;
      bool got = false;
      Exception? lastEx;
      for (final u in candidates) {
        try {
          final uri = Uri.parse(u);
          final headers = <String, String>{'Accept': 'application/json'};
          if (authToken.isNotEmpty) headers['Authorization'] = 'Token $authToken';
          resp = await http.get(uri, headers: headers);
          if (resp.statusCode == 200) {
            final ct = resp.headers['content-type'] ?? '';
            if (!ct.contains('application/json') && !ct.contains('text/json')) {
              throw Exception(
                  'Unexpected content-type: $ct (body starts: ${resp.body.substring(0, resp.body.length > 80 ? 80 : resp.body.length)})');
            }
            final data = studioEntryFromJson(resp.body);
            if (!mounted) return;
            setState(() => _studioEntry = data);
            got = true;
            break;
          } else {
            lastEx = Exception('Status ${resp.statusCode} from $u');
          }
        } catch (e) {
          lastEx = Exception('Error fetching $u: $e');
          continue;
        }
      }

      if (!got) {
        throw lastEx ?? Exception('Failed to fetch studios');
      }

      if (widget.editEvent != null && _studioEntry != null) {
        Studio? pick;
        for (var city in _studioEntry!.cities) {
          for (var studio in city.studios) {
            if (widget.editEvent!.location == studio.namaStudio) {
              pick = studio;
              break;
            }
          }
          if (pick != null) break;
        }
        if (pick != null && mounted) setState(() => _selectedStudio = pick);
      }
    } catch (e) {
      final msg = e.toString();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error fetching studios: $msg')));
      }
    }
  }

  Future<void> _pickDate() async {
    DateTime initialDate = widget.editEvent?.date ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) _dateCtrl.text = date.toIso8601String().substring(0, 10);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a studio')));
      return;
    }

    setState(() => _loading = true);

    try {
      final uri = widget.editEvent == null
          ? Uri.parse(joinBase('events/api/create/'))
          : Uri.parse(joinBase('events/api/${widget.editEvent!.id}/edit/'));

      final request = http.MultipartRequest('POST', uri);
      request.fields['name'] = _nameCtrl.text.trim();
      request.fields['date'] = _dateCtrl.text.trim();
      request.fields['description'] = _descCtrl.text.trim();
      request.fields['location'] = _selectedStudio!.namaStudio;

      if (_imageUrlCtrl.text.trim().isNotEmpty) {
        request.fields['poster_url'] = _imageUrlCtrl.text.trim();
      }

      if (authToken.isNotEmpty) {
        request.headers['Authorization'] = 'Token $authToken';
      }
      request.headers['Accept'] = 'application/json';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      final success = widget.editEvent == null
          ? response.statusCode == 201
          : response.statusCode == 200;

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editEvent == null ? 'Event added' : 'Event updated'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.statusCode} — ${response.body}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dateCtrl.dispose();
    _descCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editEvent != null;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
          title: Text(isEdit ? 'Edit Event' : 'Add Event'),
          backgroundColor: AppColors.cream),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _imageUrlCtrl,
                decoration: const InputDecoration(
                    labelText: 'Image URL (optional)',
                    hintText: 'Enter poster URL'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateCtrl,
                decoration: const InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: _pickDate,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _studioEntry == null
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Studio>(
                      initialValue: _selectedStudio,
                      decoration: const InputDecoration(labelText: 'Location'),
                      items: _studioEntry!.cities
                          .expand((city) => city.studios)
                          .map((studio) => DropdownMenuItem(
                                value: studio,
                                child: Text(studio.namaStudio),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedStudio = val),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(isEdit ? 'Save' : 'Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
