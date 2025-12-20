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
  bool _isLoading = true; 
  String? _errorMessage;

  List<Product> brands = [];
  // List<Resource> videos = []; 

  @override
  void initState() {
    super.initState();
    _loadData(); 
  }

  Future<void> _loadData() async {
    try {
      if (widget.type == 'Sportswear') {
        final fetchedBrands = await fetchBrands();
        if (mounted) {
          setState(() {
            brands = fetchedBrands;
            _isLoading = false;
          });
        }
      } 
      // else if (widget.type == 'Resource') {
      //   final fetchedVideos = await fetchVideos();
      //   if (mounted) {
      //     setState(() {
      //       videos = fetchedVideos;
      //       _isLoading = false;
      //     });
      //   }
      // }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<List<Product>> fetchBrands() async {
    final response = await http.get(Uri.parse('${AppConstants.baseUrl}sportswear/api/list/'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load brands. Status: ${response.statusCode}');
    }
  }

  // Future<List<Product>> fetchVideos() async {
  //   final response = await http.get(Uri.parse('${AppConstants.baseUrl}resources/api/list/'));

  //   if (response.statusCode == 200) {
  //     final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
  //     return jsonList.map((json) => Resource.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Failed to load resources. Status: ${response.statusCode}');
  //   }
  // }

  List<dynamic> get _filteredData {
    final query = _searchQuery.toLowerCase();

    if (widget.type == 'Sportswear') {
      if (query.isEmpty) return brands;
      
      return brands.where((b) => 
        (b.name).toLowerCase().contains(query)
      ).toList();
    } 
    // else if (widget.type == 'Resource') {
    //   if (query.isEmpty) return videos;
      
    //   return videos.where((v) => 
    //     (v.name).toLowerCase().contains(query)
    //   ).toList();
    // }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select ${widget.type}", style: TextStyle(fontSize: 18)),
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
                hintText: "Search...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _errorMessage != null
                ? Center(child: Text("Error: $_errorMessage"))
                : ListView.builder(
                    padding: EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: _filteredData.length,
                    itemBuilder: (context, index) {
                      final Product obj = _filteredData[index]; 
                      return Padding(
                        padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context, {
                              "id": obj.id,
                              "name": obj.name, 
                              "thumbnail": obj.thumbnail,
                              "type": widget.type
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.textLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Image.network(
                                  obj.thumbnail,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_,__,___) => Icon(Icons.broken_image),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        obj.name,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        widget.type,
                                        style: TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
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