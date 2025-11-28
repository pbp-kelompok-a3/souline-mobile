import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/studio_entry.dart';

class StudioFormPage extends StatefulWidget {
  final Studio? studio; // null for create, non-null for edit

  const StudioFormPage({super.key, this.studio});

  @override
  State<StudioFormPage> createState() => _StudioFormPageState();
}

class _StudioFormPageState extends State<StudioFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _thumbnailController;
  late TextEditingController _areaController;
  late TextEditingController _alamatController;
  late TextEditingController _gmapsController;
  late TextEditingController _teleponController;

  UserKota _selectedKota = UserKota.JAKARTA;
  double _rating = 5.0; // Default rating

  bool get _isEditing => widget.studio != null;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing values if editing
    _namaController = TextEditingController(
      text: widget.studio?.namaStudio ?? '',
    );
    _thumbnailController = TextEditingController(
      text: widget.studio?.thumbnail ?? '',
    );
    _areaController = TextEditingController(text: widget.studio?.area ?? '');
    _alamatController = TextEditingController(
      text: widget.studio?.alamat ?? '',
    );
    _gmapsController = TextEditingController(
      text: widget.studio?.gmapsLink ?? '',
    );
    _teleponController = TextEditingController(
      text: widget.studio?.nomorTelepon ?? '',
    );

    if (widget.studio != null) {
      _selectedKota = widget.studio!.kota;
      _rating = widget.studio!.rating;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _thumbnailController.dispose();
    _areaController.dispose();
    _alamatController.dispose();
    _gmapsController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement API call for create/edit

      // For now, just show success and go back
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Studio updated successfully'
                : 'Studio created successfully',
          ),
          backgroundColor: AppColors.darkBlue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Studio' : 'Add New Studio',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Studio Name
              _buildSectionLabel('Studio Name'),
              _buildTextField(
                controller: _namaController,
                hintText: 'Enter studio name',
                prefixIcon: Icons.fitness_center,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter studio name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Thumbnail URL
              _buildSectionLabel('Thumbnail URL'),
              _buildTextField(
                controller: _thumbnailController,
                hintText: 'Enter image URL',
                prefixIcon: Icons.image,
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter thumbnail URL';
                  }
                  if (!Uri.tryParse(value)!.isAbsolute) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),

              // Preview thumbnail if URL is provided
              if (_thumbnailController.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _thumbnailController.text,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 40,
                              color: AppColors.textMuted,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Invalid image URL',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // City (Kota)
              _buildSectionLabel('City'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.teal.withOpacity(0.3)),
                ),
                child: DropdownButtonFormField<UserKota>(
                  value: _selectedKota,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.location_city,
                      color: AppColors.darkBlue,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  dropdownColor: Colors.white,
                  items: UserKota.values.map((UserKota city) {
                    return DropdownMenuItem<UserKota>(
                      value: city,
                      child: Text(userKotaValues.reverse[city] ?? ''),
                    );
                  }).toList(),
                  onChanged: (UserKota? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedKota = newValue;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Area
              _buildSectionLabel('Area'),
              _buildTextField(
                controller: _areaController,
                hintText: 'Enter area (e.g., Kemang, Sudirman)',
                prefixIcon: Icons.place,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter area';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Full Address
              _buildSectionLabel('Full Address'),
              _buildTextField(
                controller: _alamatController,
                hintText: 'Enter complete address',
                prefixIcon: Icons.home,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Phone Number
              _buildSectionLabel('Phone Number'),
              _buildTextField(
                controller: _teleponController,
                hintText: 'Enter phone number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Rating
              _buildSectionLabel('Rating'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.teal.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const Text(
                          ' / 5.0',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const Spacer(),
                        // Star rating display
                        Row(
                          children: List.generate(5, (index) {
                            final starValue = index + 1;
                            // Round rating to nearest 0.5 for star display
                            final roundedRating = (_rating * 2).round() / 2;
                            if (roundedRating >= starValue) {
                              return const Icon(
                                Icons.star,
                                size: 20,
                                color: AppColors.orange,
                              );
                            } else if (roundedRating >= starValue - 0.5) {
                              return const Icon(
                                Icons.star_half,
                                size: 20,
                                color: AppColors.orange,
                              );
                            } else {
                              return Icon(
                                Icons.star_border,
                                size: 20,
                                color: AppColors.orange.withOpacity(0.5),
                              );
                            }
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.orange,
                        inactiveTrackColor: AppColors.orange.withOpacity(0.2),
                        thumbColor: AppColors.orange,
                        overlayColor: AppColors.orange.withOpacity(0.2),
                        valueIndicatorColor: AppColors.orange,
                        valueIndicatorTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Slider(
                        value: _rating,
                        min: 0.0,
                        max: 5.0,
                        divisions: 50,
                        label: _rating.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            _rating = value;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          '5.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Google Maps Link
              _buildSectionLabel('Google Maps Link'),
              _buildTextField(
                controller: _gmapsController,
                hintText: 'Enter Google Maps URL',
                prefixIcon: Icons.map,
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Google Maps link';
                  }
                  if (!Uri.tryParse(value)!.isAbsolute) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Update Studio' : 'Create Studio',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkBlue,
                    side: const BorderSide(color: AppColors.darkBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.darkBlue,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: (value) {
        // Trigger rebuild for thumbnail preview
        if (controller == _thumbnailController) {
          setState(() {});
        }
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(prefixIcon, color: AppColors.darkBlue),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.teal.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.teal.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.teal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
