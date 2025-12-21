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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.pop(context),
                      color: AppColors.darkBlue,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isEdit ? 'Edit Event' : 'Add Events',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Post Image / URL Input
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final url = await _showImageUrlDialog();
                      if (url != null) {
                        setState(() {
                          _imageUrlCtrl.text = url;
                        });
                      }
                    },
                    child: Container(
                      width: 200,
                      height: 260,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBEBEB),
                        borderRadius: BorderRadius.circular(20),
                        image: _imageUrlCtrl.text.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(_imageUrlCtrl.text),
                                fit: BoxFit.cover,
                                onError: (_, __) {},
                              )
                            : null,
                      ),
                      child: _imageUrlCtrl.text.isEmpty
                          ? const Center(
                              child: Icon(
                                Icons.add,
                                size: 48,
                                color: AppColors.lightBlue,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                if (_imageUrlCtrl.text.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: Text(
                        "Tap to add image URL",
                        style: TextStyle(
                          color: AppColors.textMuted.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Name
                _buildLabel('Name'),
                _buildTextField(
                  controller: _nameCtrl,
                  hint: 'Enter Event Name',
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Date
                _buildLabel('Date'),
                _buildTextField(
                  controller: _dateCtrl,
                  hint: 'DD/MM/YY',
                  readOnly: true,
                  onTap: _pickDate,
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.darkBlue,
                    size: 20,
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Location
                _buildLabel('Location'),
                _studioEntry == null
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: LinearProgressIndicator(),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<Studio>(
                            value: _selectedStudio,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.darkBlue,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                            hint: const Text(
                              'Enter Location',
                              style: TextStyle(color: Color(0xFFAAAAAA)),
                            ),
                            isExpanded: true,
                            items: _studioEntry!.cities
                                .expand((city) => city.studios)
                                .map(
                                  (studio) => DropdownMenuItem(
                                    value: studio,
                                    child: Text(
                                      studio.namaStudio,
                                      style: const TextStyle(
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedStudio = val),
                            validator: (val) => val == null ? 'Required' : null,
                          ),
                        ),
                      ),
                const SizedBox(height: 16),

                // Description
                _buildLabel('Description'),
                _buildTextField(
                  controller: _descCtrl,
                  hint: 'Write description about the event...',
                  maxLines: 4,
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isEdit ? 'Save Changes' : 'Create Event',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBlue,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Future<String?> _showImageUrlDialog() async {
    final ctrl = TextEditingController(text: _imageUrlCtrl.text);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Image URL'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}
