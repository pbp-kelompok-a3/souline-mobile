import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/shared/models/sportswear_model.dart';

class AttachmentSelectorPage extends StatefulWidget {
  final String type;
  const AttachmentSelectorPage({super.key, required this.type});

  @override
  State<AttachmentSelectorPage> createState() => _AttachmentSelectorPageState();
}

class _AttachmentSelectorPageState extends State<AttachmentSelectorPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  late Future<List<Product>> _brandsFuture;

  Future<List<Product>> fetchBrands() async {
    final response = await http.get(Uri.parse('http://localhost:8000/sportswear/api/list/'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load brands. Status: ${response.statusCode}');
    }
  }

  // List<Map<String, dynamic>> dummySportswear = [
  //   {
  //     "id": 1,
  //     "name": "Lululemon",
  //     "description": "description",
  //     "tag": "Sportswear",
  //     "thumbnail":
  //         "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQAG1UDEIZtYdGiU3wGWfNJc2nHYp_xnthZRw&s",
  //     "rating": 4,
  //     "link": "https://shop.lululemon.com/",
  //     "timelineReviews": [],
  //   },
  //   {
  //     "id": 2,
  //     "name": "Lululemon",
  //     "description": "description",
  //     "tag": "Sportswear",
  //     "thumbnail":
  //         "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQAG1UDEIZtYdGiU3wGWfNJc2nHYp_xnthZRw&s",
  //     "rating": 4,
  //     "link": "https://shop.lululemon.com/",
  //     "timelineReviews": [],
  //   },
  //   {
  //     "id": 3,
  //     "name": "Lululemon",
  //     "description": "description",
  //     "tag": "Sportswear",
  //     "thumbnail":
  //         "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQAG1UDEIZtYdGiU3wGWfNJc2nHYp_xnthZRw&s",
  //     "rating": 4,
  //     "link": "https://shop.lululemon.com/",
  //     "timelineReviews": [],
  //   },
  // ];

  // List<Resource> videos = [];
  List<Product> brands = [];

  List<dynamic> get _filteredData {
    final query = _searchQuery.toLowerCase();

    if (widget.type == 'Resource') {
      // return query.isNotEmpty
      //     ? videos.where((v) =>
      //         v.name.toLowerCase().contains(query)
      //       ).toList()
      //     : videos; 
    }

    if (widget.type == 'Sportswear') {
      return query.isNotEmpty
          ? brands.where((b) =>
              b.name.toLowerCase().contains(query),
            ).toList()
          : brands; 
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _brandsFuture = fetchBrands(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select ${widget.type}", style: TextStyle(fontSize: 18),),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.cream,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.textLight,
                prefixIconColor: Colors.grey,
                hintText: "Search...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightBlue.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightBlue.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.lightBlue, width: 1),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                  // _brandsFuture = fetchBrands();
                });
              }
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 8, bottom: 100),
              itemCount: _filteredData.length,
              itemBuilder: (context, index) {
                final obj = _filteredData[index];
                return Padding(
                  padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context, obj);
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.textLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          )
                        ]
                      ),
                      child: Row(
                        children: [
                          Image.network(
                            obj['thumbnail'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 12),
                          Column(
                            children: [
                              Text(obj['name'], 
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                              ),
                              Text(obj['tag'] ?? obj['type'] ?? 'Attachment', 
                                style: TextStyle(fontSize: 14)
                              ),
                            ]
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
