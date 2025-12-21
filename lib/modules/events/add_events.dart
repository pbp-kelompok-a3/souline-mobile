import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/event_model.dart';
import '../../shared/models/studio_entry.dart';
import '../studio/studio_service.dart';
import 'events_service.dart';

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
  final _imageUrlCtrl = TextEditingController();

  Studio? _selectedStudio;
  StudioEntry? _studioEntry;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchStudios());
    if (widget.editEvent != null) {
      _nameCtrl.text = widget.editEvent!.name;
      _dateCtrl.text = widget.editEvent!.date.toIso8601String().substring(
        0,
        10,
      );
      _descCtrl.text = widget.editEvent!.description;
      _imageUrlCtrl.text = widget.editEvent!.poster;
    }
  }

  Future<void> _fetchStudios() async {
    try {
      final request = context.read<CookieRequest>();
      final service = StudioService(request);
      final entry = await service.fetchStudios();

      if (!mounted) return;
      setState(() => _studioEntry = entry);

      // Pre-select studio if editing
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
        if (pick != null) setState(() => _selectedStudio = pick);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching studios: $e')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a studio')));
      return;
    }

    setState(() => _loading = true);

    try {
      final request = context.read<CookieRequest>();
      final service = EventService(request, AppConstants.baseUrl);

      bool success;
      if (widget.editEvent == null) {
        // Create new event
        success = await service.createEvent(
          name: _nameCtrl.text.trim(),
          date: _dateCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          location: _selectedStudio!.namaStudio,
          posterUrl: _imageUrlCtrl.text.trim().isNotEmpty
              ? _imageUrlCtrl.text.trim()
              : null,
        );
      } else {
        // Update existing event
        success = await service.updateEvent(
          eventId: widget.editEvent!.id,
          name: _nameCtrl.text.trim(),
          date: _dateCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          location: _selectedStudio!.namaStudio,
          posterUrl: _imageUrlCtrl.text.trim().isNotEmpty
              ? _imageUrlCtrl.text.trim()
              : null,
        );
      }

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save event')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
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
        backgroundColor: AppColors.cream,
      ),
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
                  hintText: 'Enter poster URL',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateCtrl,
                decoration: const InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: _pickDate,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _studioEntry == null
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Studio>(
                      value: _selectedStudio,
                      decoration: const InputDecoration(labelText: 'Location'),
                      items: _studioEntry!.cities
                          .expand((city) => city.studios)
                          .map(
                            (studio) => DropdownMenuItem(
                              value: studio,
                              child: Text(studio.namaStudio),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _selectedStudio = val),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(isEdit ? 'Save' : 'Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
