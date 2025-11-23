import 'package:flutter/material.dart';

class SportswearPage extends StatelessWidget {
  const SportswearPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sportswear'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 80, color: Colors.purple),
            SizedBox(height: 16),
            Text(
              'Sportswear Module',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Discover yoga and pilates gear'),
          ],
        ),
      ),
    );
  }
}