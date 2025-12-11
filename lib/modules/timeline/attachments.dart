import 'package:flutter/material.dart';

class AttachmentSelectorPage extends StatefulWidget {
  final String type;
  const AttachmentSelectorPage({super.key, required this.type});

  @override
  State<AttachmentSelectorPage> createState() => _AttachmentSelectorPageState();
}

class _AttachmentSelectorPageState extends State<AttachmentSelectorPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> dummyList = [
    {'id': 1, 'name': 'Item One'},
    {'id': 2, 'name': 'Item Two'},
    {'id': 3, 'name': 'Item Three'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select ${widget.type}"),
        backgroundColor: const Color(0xff8ecae6),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView(
              children: dummyList
                  .where((e) => e['name']
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase()))
                  .map(
                    (e) => ListTile(
                      title: Text(e['name']),
                      onTap: () => Navigator.pop(context, e),
                    ),
                  )
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}
