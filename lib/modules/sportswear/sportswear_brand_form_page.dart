import 'package:flutter/material.dart';

import 'package:souline_mobile/shared/models/sportswear_model.dart';
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'sportswear_service.dart';

class SportswearBrandFormPage extends StatefulWidget {
  final Product? brand;

  const SportswearBrandFormPage({super.key, this.brand});

  @override
  State<SportswearBrandFormPage> createState() => _SportswearBrandFormPageState();
}

class _SportswearBrandFormPageState extends State<SportswearBrandFormPage> {
  final _formKey = GlobalKey<FormState>();
  final SportswearService _service = SportswearService();

  // Menggunakan AppColors dari constants
  static const Color myBackgroundColor = AppColors.background;
  static const Color primaryBrandColor = AppColors.darkBlue;
  static const Color accentColor = AppColors.teal;
  static const Color ratingColor = AppColors.orange;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _thumbnailController;
  late TextEditingController _linkController;

  String? _selectedTag;
  final List<String> _categories = ['Yoga', 'Pilates'];

  double _rating = 5.0;
  bool get _isEditing => widget.brand != null;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.brand?.name ?? '');
    _descriptionController = TextEditingController(text: widget.brand?.description ?? '');
    _thumbnailController = TextEditingController(text: widget.brand?.thumbnail ?? '');
    _linkController = TextEditingController(text: widget.brand?.link ?? '');

    if (widget.brand != null && _categories.contains(widget.brand!.tag)) {
      _selectedTag = widget.brand!.tag;
    }

    if (widget.brand != null) {
      _rating = widget.brand!.rating;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      final dataToSend = Product(
        id: widget.brand?.id ?? 0,
        name: _nameController.text,
        description: _descriptionController.text,
        tag: _selectedTag ?? '',
        thumbnail: _thumbnailController.text,
        rating: _rating,
        link: _linkController.text,
        timelineReviews: widget.brand?.timelineReviews ?? [],
        adminNotes: widget.brand?.adminNotes,
      );

      try {
        if (_isEditing) {
          await _service.updateBrand(dataToSend);
        } else {
          await _service.createBrand(dataToSend);
        }

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Brand updated successfully!' : 'Brand added successfully!'),
              backgroundColor: primaryBrandColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Submission Failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: myBackgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Brand' : 'Add New Brand', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryBrandColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('Brand Name'),
              _buildTextField(controller: _nameController, hintText: 'Enter brand name', prefixIcon: Icons.local_offer,
                validator: (value) => value == null || value.isEmpty ? 'Please enter brand name' : null,
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Logo URL'),
              _buildTextField(controller: _thumbnailController, hintText: 'Enter logo image URL', prefixIcon: Icons.image, keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) { return 'Please enter logo image URL'; }
                  if (Uri.tryParse(value)?.isAbsolute != true) { return 'Please enter a valid URL'; }
                  return null;
                },
              ),
              if (_thumbnailController.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _thumbnailController.text, height: 100, width: 100, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100, width: 100, decoration: BoxDecoration(color: accentColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.broken_image, size: 30, color: Colors.grey),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              _buildSectionLabel('Official Store URL'),
              _buildTextField(controller: _linkController, hintText: 'Enter official store or website URL', prefixIcon: Icons.link, keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) { return 'Please enter the official store URL'; }
                  if (Uri.tryParse(value)?.isAbsolute != true) { return 'Please enter a valid URL'; }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Category Tag'),
              DropdownButtonFormField<String>(
                value: _selectedTag,
                isExpanded: true,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTag = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
                decoration: InputDecoration(
                  hintText: 'Select category',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.category, color: primaryBrandColor),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor.withOpacity(0.3))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor.withOpacity(0.3))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBrandColor, width: 2)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                dropdownColor: Colors.white,
                iconEnabledColor: primaryBrandColor,
                menuMaxHeight: 200,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Short Description'),
              _buildTextField(controller: _descriptionController, hintText: 'Enter description', prefixIcon: Icons.description, maxLines: 2,
                validator: (value) => value == null || value.isEmpty ? 'Please enter description' : null,
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Rating'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryBrandColor.withOpacity(0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: ratingColor, size: 24),
                        const SizedBox(width: 8),
                        Text(_rating.toStringAsFixed(1), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBrandColor)),
                        const Text(' / 5.0', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const Spacer(),
                        Row(children: List.generate(5, (index) {
                            final starValue = index + 1;
                            final roundedRating = (_rating * 2).round() / 2;
                            IconData icon;
                            if (roundedRating >= starValue) { icon = Icons.star; }
                            else if (roundedRating >= starValue - 0.5) { icon = Icons.star_half; }
                            else { icon = Icons.star_border; }
                            return Icon(icon, size: 20, color: ratingColor);
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: ratingColor, inactiveTrackColor: ratingColor.withOpacity(0.2),
                        thumbColor: ratingColor, overlayColor: ratingColor.withOpacity(0.2),
                        valueIndicatorColor: ratingColor, valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      child: Slider(
                        value: _rating, min: 0.0, max: 5.0, divisions: 50, label: _rating.toStringAsFixed(1),
                        onChanged: (value) { setState(() { _rating = value; }); },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryBrandColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) :
                                      Text(_isEditing ? 'Update Brand' : 'Add New Brand', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity, height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(foregroundColor: primaryBrandColor, side: const BorderSide(color: primaryBrandColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryBrandColor)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, required String hintText, required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text, int maxLines = 1, String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller, keyboardType: keyboardType, maxLines: maxLines, validator: validator,
      onChanged: (value) {
        if (controller == _thumbnailController || controller == _linkController) { setState(() {}); }
      },
      decoration: InputDecoration(
        hintText: hintText, hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(prefixIcon, color: primaryBrandColor), filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor.withOpacity(0.3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBrandColor, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}