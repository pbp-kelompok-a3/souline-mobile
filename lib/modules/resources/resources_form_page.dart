import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/resources_entry.dart';

class ResourceFormPage extends StatefulWidget {
  final ResourcesEntry? initialResource; // null = ADD, ada = EDIT

  const ResourceFormPage({super.key, this.initialResource});

  @override
  State<ResourceFormPage> createState() => _ResourceFormPageState();
}

class _ResourceFormPageState extends State<ResourceFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleC;
  late final TextEditingController _descC;
  late final TextEditingController _youtubeUrlC;

  String _level = 'beginner';
  bool _isSubmitting = false;

  bool get isEdit => widget.initialResource != null;

  @override
  void initState() {
    super.initState();

    final r = widget.initialResource;
    _titleC = TextEditingController(text: r?.title ?? '');
    _descC = TextEditingController(text: r?.description ?? '');
    _youtubeUrlC = TextEditingController(text: r?.youtubeUrl ?? '');

    _level = (r?.level ?? 'beginner').toLowerCase();
    if (!['beginner', 'intermediate', 'advanced'].contains(_level)) {
      _level = 'beginner';
    }
  }

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    _youtubeUrlC.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    return null;
  }

  String? _youtubeValidator(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'YouTube link is required';

    // Accept: youtu.be/xxx | youtube.com/watch?v=xxx | youtube.com/embed/xxx
    final ok = value.contains('youtu.be/') ||
        value.contains('youtube.com/watch') ||
        value.contains('youtube.com/embed/');
    if (!ok) return 'Use a valid YouTube URL (watch / embed / youtu.be)';

    return null;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _isSubmitting = true);

    try {
      final payload = {
        "title": _titleC.text.trim(),
        "description": _descC.text.trim(),
        "youtube_url": _youtubeUrlC.text.trim(),
        "level": _level,
      };

      // TODO: panggil API ADD/EDIT kamu di sini
      // - Add: POST /resources/api/add/
      // - Edit: POST/PUT /resources/api/edit/<id>/

      if (!mounted) return;
      Navigator.pop(context, true); // return true biar page sebelumnya bisa refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isEdit ? 'Edit Resource' : 'Add Resource';

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            backgroundColor: AppColors.cream,
            elevation: 0,
            centerTitle: true,
            title: Text(
              title,
              style: const TextStyle(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w800,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // spacing top
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Label('Title'),
                          const SizedBox(height: 8),
                          _Input(
                            controller: _titleC,
                            hint: 'e.g. 30 MIN FULL BODY',
                            validator: _requiredValidator,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          const _Label('YouTube URL'),
                          const SizedBox(height: 8),
                          _Input(
                            controller: _youtubeUrlC,
                            hint: 'Paste watch / embed / youtu.be link',
                            validator: _youtubeValidator,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          const _Label('Level'),
                          const SizedBox(height: 8),
                          _LevelDropdown(
                            value: _level,
                            onChanged: (v) => setState(() => _level = v),
                          ),
                          const SizedBox(height: 16),

                          const _Label('Description'),
                          const SizedBox(height: 8),
                          _Input(
                            controller: _descC,
                            hint: 'Short description…',
                            validator: _requiredValidator,
                            maxLines: 5,
                            textInputAction: TextInputAction.newline,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF62C4D9),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                isEdit ? 'Save Changes' : 'Add Resource',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Tip: pakai link embed / watch / youtu.be. Jangan pakai tanda kutip.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================== UI pieces ======================

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.darkBlue,
        fontWeight: FontWeight.w800,
        fontSize: 13,
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;

  const _Input({
    required this.controller,
    required this.hint,
    required this.validator,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.darkBlue,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textMuted.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFFFF7EA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: const Color(0xFF62C4D9).withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: const Color(0xFF62C4D9).withOpacity(0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF62C4D9), width: 1.6),
        ),
      ),
    );
  }
}

class _LevelDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _LevelDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF62C4D9).withOpacity(0.35)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: const [
            DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
            DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
            DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
          ],
          onChanged: (v) {
            if (v == null) return;
            onChanged(v);
          },
        ),
      ),
    );
  }
}
