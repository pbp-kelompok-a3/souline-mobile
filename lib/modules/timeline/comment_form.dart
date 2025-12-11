import 'package:flutter/material.dart';

class CommentFormPage extends StatefulWidget {
  const CommentFormPage({super.key});

  @override
  State<CommentFormPage> createState() => CommentFormPageState();
}

class CommentFormPageState extends State<CommentFormPage> {

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xfff9f4e8),
        body: Column(
          children: [
            _header(context),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Write a reply',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Icon(
                      Icons.image,
                      size: 100,
                      color: Colors.grey[300],
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _header(BuildContext context) {
    return Container(
          height: 160,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7EB3DE), Color(0xFF446178)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // ⬅️ aksi kembali
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Spacer(),
              Text(
                'Add Comment',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.send_rounded),
                color: Colors.white,
                iconSize: 24,
                onPressed: () => {  
                  // Aksi untuk mengirim post
                },
              )
            ],
          ),
        );
  }