import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/event_model.dart';
import 'add_events.dart'; // <-- tambahkan import ini

class EventDetailPage extends StatefulWidget {
  final EventModel event;
  final String baseUrl;
  final String currentUsername;

  const EventDetailPage({
    super.key,
    required this.event,
    required this.baseUrl,
    this.currentUsername = '',
  });

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _isDeleting = false;
  String _authToken = '';

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token') ?? '';
    } catch (_) {
      _authToken = '';
    }
  }

  String buildPosterUrl(String path) {
    if (path.startsWith('http')) return path;
    final base = widget.baseUrl;
    if (base.endsWith('/')) return '$base$path';
    return '$base/$path';
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete event?'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    final url = _joinBase('events/api/${widget.event.id}/delete/');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_authToken.isNotEmpty) headers['Authorization'] = 'Token $_authToken';

    final resp = await http.delete(Uri.parse(url), headers: headers);
    setState(() => _isDeleting = false);

    if (!mounted) return;

    if (resp.statusCode == 200) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event deleted')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Delete failed: ${resp.statusCode}')));
    }
  }

  String _joinBase(String path) {
    final base = widget.baseUrl;
    if (base.endsWith('/')) return '$base$path';
    return '$base/$path';
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.currentUsername.isNotEmpty && widget.currentUsername == widget.event.createdBy;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Event Detail'),
        backgroundColor: AppColors.cream,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (widget.event.poster.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                buildPosterUrl(widget.event.poster),
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(widget.event.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(DateFormat("dd MMMM yyyy", "en_US").format(widget.event.date)),
          const SizedBox(height: 20),
          const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(child: SingleChildScrollView(child: Text(widget.event.description))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (isOwner)
              ElevatedButton(
                onPressed: () {
                  final navigator = Navigator.of(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddEventPage(editEvent: widget.event)),
                  ).then((val) {
                    if (val == true && navigator.mounted) navigator.pop(true);
                  });
                },
                child: const Text('Edit'),
              ),
            const SizedBox(width: 8),
            if (isOwner)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _isDeleting ? null : _deleteEvent,
                child: _isDeleting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Delete'),
              ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.textDark),
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ])
        ]),
      ),
    );
  }
}
