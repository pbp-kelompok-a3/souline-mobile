import 'package:flutter/material.dart';
import '../../shared/models/sportswear_model.dart';
import 'sportswear_page.dart';

class SportswearBrandFormPage extends StatefulWidget {
  final Product? brand;

  const SportswearBrandFormPage({super.key, this.brand});

  @override
  State<SportswearBrandFormPage> createState() => _SportswearBrandFormPageState();
}

class _SportswearBrandFormPageState extends State<SportswearBrandFormPage> {
  final _formKey = GlobalKey<FormState>();
  final SportswearService _service = SportswearService();

  static const Color primaryBrandColor = Color(0xFF5E8096);
  static const Color accentColor = Color(0xFF90B4C8);
  static const Color ratingColor = Color(0xFFFFCC00);

  late TextEditingController _nameController;
  late TextEditingController _tagController;
  late TextEditingController _descriptionController;
  late TextEditingController _thumbnailController;
  late TextEditingController _linkController;

  double _rating = 5.0;
  bool get _isEditing => widget.brand != null;
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.brand?.name ?? '');
    _descriptionController = TextEditingController(text: widget.brand?.description ?? '');
    _tagController = TextEditingController(text: widget.brand?.tag ?? 'Yoga');
    _thumbnailController = TextEditingController(text: widget.brand?.thumbnail ?? '');
    _linkController = TextEditingController(text: widget.brand?.link ?? 'https://example.com');


    if (widget.brand != null) {
      _rating = widget.brand!.rating;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
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
        tag: _tagController.text,
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
              content: Text(_isEditing ? 'Brand updated successfully!' : 'New Brand created successfully!'),
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
      backgroundColor: Colors.grey[100],
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
              _buildTextField(controller: _nameController, hintText: 'Enter brand name (e.g., HappyFit)', prefixIcon: Icons.local_offer,
                validator: (value) => value == null || value.isEmpty ? 'Please enter brand name' : null,
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Logo URL'),
              _buildTextField(controller: _thumbnailController, hintText: 'Enter brand logo image URL', prefixIcon: Icons.image, keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) { return 'Please enter image URL'; }
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

              _buildSectionLabel('E-Commerce Link'),
              _buildTextField(controller: _linkController, hintText: 'Enter shop link', prefixIcon: Icons.link, keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) { return 'Please enter a link'; }
                  if (Uri.tryParse(value)?.isAbsolute != true) { return 'Please enter a valid URL'; }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Category Tag'),
              _buildTextField(controller: _tagController, hintText: 'e.g., Yoga, Pilates, Running', prefixIcon: Icons.category,
                validator: (value) => value == null || value.isEmpty ? 'Please enter category tag' : null,
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Short Description'),
              _buildTextField(controller: _descriptionController, hintText: 'Comfortable, Premium, Durable, etc.', prefixIcon: Icons.description, maxLines: 2,
                validator: (value) => value == null || value.isEmpty ? 'Please enter description' : null,
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Initial Rating'),
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
                                      Text(_isEditing ? 'Update Brand' : 'Create Brand', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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