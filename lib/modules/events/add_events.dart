import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AddEventPage extends StatelessWidget {
  const AddEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text("Add Event"),
        backgroundColor: AppColors.cream,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.add, size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Name"),
            const TextField(decoration: InputDecoration(hintText: "Enter name")),
            const SizedBox(height: 16),
            const Text("Date"),
            const TextField(decoration: InputDecoration(hintText: "DD/MM/YYYY")),
            const SizedBox(height: 16),
            const Text("Location"),
            const TextField(decoration: InputDecoration(hintText: "Enter location")),
            const SizedBox(height: 16),
            const Text("Description"),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(hintText: "Write description..."),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.teal,
        child: const Icon(Icons.check, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
