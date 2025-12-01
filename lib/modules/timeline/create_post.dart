import 'package:flutter/material.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => CreatePostPageState();
}

class CreatePostPageState extends State<CreatePostPage> {

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xfff9f4e8),
        body: Column(
          children: [
            _header(context),
            
        ],
      ),
    );
  }
}

Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff5e7fa3), Color(0xff8ecae6)],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const Text('Create Post',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
              const SizedBox(width: 48)
            ],
          ),  
        ],
      ),
    );
  }