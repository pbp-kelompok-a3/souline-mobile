import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sportswear_detail_page.dart';
import 'sportswear_brand_form_page.dart';
import 'sportswear_model.dart';
import 'package:souline_mobile/shared/widgets/app_header.dart';
import 'package:souline_mobile/shared/widgets/navigation_bar.dart';

const Color primaryBrandColor = Color(0xFF5E8096);
const Color accentColor = Color(0xFF90B4C8);
const Color ratingColor = Color(0xFFFFCC00);
const Color scaffoldBgColor = Color(0xFFF5F5F5);

class SportswearService {
  static const String _baseUrl = 'http://localhost:8000/sportswear/api';

  Future<Map<String, String>> _getAuthHeaders() async {
    return {'Content-Type': 'application/json; charset=UTF-8'};
  }

  // READ/LIST
  Future<List<Product>> fetchBrands({String? tag, String? query}) async {
    String url = '$_baseUrl/list/';

    Map<String, String> params = {};
    if (tag != null && tag.toLowerCase() != 'all') {
      params['tag'] = tag;
    }
    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    }

    if (params.isNotEmpty) {
      url += '?' + Uri(queryParameters: params).query;
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load brands. Status: ${response.statusCode}');
    }
  }

  // CREATE
  Future<Product> createBrand(Product newBrand) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('$_baseUrl/create/');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(newBrand.toJson()),
    );

    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Validation Failed: ${errorBody['errors'] ?? 'Invalid data submitted'}');
    } else {
      throw Exception('Failed to create brand. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  // UPDATE
  Future<Product> updateBrand(Product existingBrand) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('$_baseUrl/update/${existingBrand.id}/');

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(existingBrand.toJson()),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Validation Failed: ${errorBody['errors'] ?? 'Invalid data submitted'}');
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to update brand. Status: ${response.statusCode}, Body: ${errorBody}');
    }
  }

  // DELETE
  Future<void> deleteBrand(int id) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('$_baseUrl/delete/$id/');

    final response = await http.delete(
      url,
      headers: headers,
    );

    // Menerima 200 (OK) atau 204 (No Content)
    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else {
      throw Exception('Failed to delete brand. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }
}

// WIDGET UTAMA

class SportswearPage extends StatefulWidget {
  const SportswearPage({super.key});

  @override
  State<SportswearPage> createState() => _SportswearPageState();
}

class _SportswearPageState extends State<SportswearPage> {
  final SportswearService _service = SportswearService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedTagFilter;

  late Future<List<Product>> _brandsFuture;
  final List<String> _availableTags = ['All', 'Yoga', 'Pilates'];

  final int _navigationIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  void _loadBrands() {
    setState(() {
      _brandsFuture = _service.fetchBrands(
        tag: _selectedTagFilter,
        query: _searchQuery,
      );
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _loadBrands();
    });
  }

  // Navigasi ke Form (Create/Edit)
  void _navigateToFormPage({Product? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SportswearBrandFormPage(brand: product)),
    );

    if (result == true) {
      _loadBrands();
    }
  }

  // Fungsi Filter Dialog
  void _showTagFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter by Category'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableTags.length,
              itemBuilder: (context, index) {
                final tag = _availableTags[index];
                return RadioListTile<String>(
                  title: Text(tag),
                  value: tag,
                  groupValue: _selectedTagFilter ?? 'All',
                  onChanged: (String? value) {
                    setState(() {
                      _selectedTagFilter = value;
                      Navigator.pop(context);
                      _loadBrands();
                    });
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,

      body: Stack(
        children: [
          // 1. Konten Utama: Column (Header + List Produk)
          Column(
            children: [
              // Menggunakan AppHeader
              AppHeader(
                title: 'Sportswear',
                onSearchChanged: _onSearchChanged,
                onFilterPressed: _showTagFilterDialog,
              ),

              const SizedBox(height: 40),

              Expanded(
                child: FutureBuilder<List<Product>>(
                  future: _brandsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: primaryBrandColor));
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text('Failed to load data: ${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text(_searchQuery.isEmpty && _selectedTagFilter == null ? 'No brands found.' : 'No results for search/filter.'));
                    }

                    final brands = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16.0, 10, 16.0, 120),
                      itemCount: brands.length,
                      itemBuilder: (context, index) {
                        final product = brands[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: _ProductCard(
                            product: product,
                            onTap: () async {
                              // Navigasi ke Detail Page dan tunggu hasilnya
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SportswearDetailPage(product: product)),
                              );
                              // Jika result == true, berarti ada perubahan (Edit/Delete), maka refresh list
                              if (result == true) { _loadBrands(); }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // 2. Navigation Bar Mengambang
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingNavigationBar(
              currentIndex: _navigationIndex,
            ),
          ),

          // 3. Floating Action Button
          Positioned(
            right: 25,
            bottom: 100,
            child: FloatingActionButton(
              onPressed: () => _navigateToFormPage(),
              backgroundColor: accentColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

}

// PRODUCT CARD WIDGET
class _ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;

  const _ProductCard({required this.product, this.onTap});

  @override
  State<_ProductCard> createState() => __ProductCardState();
}

class __ProductCardState extends State<_ProductCard> {
  bool _showReviews = false;
  static const Color reviewBgColor = Color(0xFFF0F0F0);

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final reviews = product.timelineReviews;

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductDetails(context, product),
            InkWell(
              onTap: () {
                setState(() {
                  _showReviews = !_showReviews;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: _showReviews ? reviewBgColor : Colors.white,
                  borderRadius: _showReviews ? const BorderRadius.vertical(bottom: Radius.circular(10)) : BorderRadius.zero,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Timeline Reviews', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        Icon(_showReviews ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey[600]),
                      ],
                    ),

                    if (_showReviews)
                      if (reviews.isEmpty)
                        const Padding(padding: EdgeInsets.all(8.0), child: Text('Belum ada ulasan.'))
                      else
                        ...reviews.map((review) => Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: _buildReviewItem(context, review: review),
                        )).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, Product product) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              product.thumbnail,
              width: 120,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 100,
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Icon(Icons.bookmark_border, color: Colors.grey),
                  ],
                ),
                Text(product.description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.star, color: ratingColor, size: 18),
                    const SizedBox(width: 4),
                    Text('Rating: ${product.rating.toStringAsFixed(1)}/5', style: const TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(product.tag, style: TextStyle(fontSize: 12, color: primaryBrandColor, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Lihat Detail >', style: TextStyle(color: primaryBrandColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, {required Review review}) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 18, backgroundColor: primaryBrandColor.withOpacity(0.3)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(review.location, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.reviewText, style: const TextStyle(fontSize: 14), maxLines: 4, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.search, size: 20, color: Colors.grey),
              Icon(Icons.favorite_border, size: 20, color: Colors.grey),
              Icon(Icons.share, size: 20, color: Colors.grey),
              Icon(Icons.bookmark_border, size: 20, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}