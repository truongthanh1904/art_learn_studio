import 'dart:async';

import 'package:flutter/material.dart';

import '../models/tutorial.dart';
import '../services/content_service.dart';
import '../widgets/tutorial_card.dart';
import 'tutorial_detail_screen.dart';

/// Màn hình danh sách bài hướng dẫn.
class TutorialsScreen extends StatefulWidget {
  const TutorialsScreen({super.key});

  @override
  State<TutorialsScreen> createState() => _TutorialsScreenState();
}

class _TutorialsScreenState extends State<TutorialsScreen> {
  List<Tutorial> _tutorials = [];
  String _selectedCategory = 'Tất cả';
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  final List<String> _categories = ['Tất cả', 'Vẽ', 'Thủ công'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  /// Tải danh sách bài hướng dẫn từ backend.
  Future<void> _loadData() async {
    final tutorials = await ContentService.fetchTutorials(
      query: _searchQuery,
      category: _selectedCategory,
    );

    if (!mounted) return;

    setState(() {
      _tutorials = tutorials;
    });
  }

  /// Xử lý thay đổi từ khóa tìm kiếm.
  void _onSearchChanged() {
    final value = _searchController.text;

    if (_searchQuery != value) {
      setState(() => _searchQuery = value);
    }

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _loadData();
    });
  }

  /// Mở màn hình chi tiết bài hướng dẫn.
  void _openTutorialDetail(Tutorial tutorial) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TutorialDetailScreen(tutorial: tutorial),
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          Expanded(
            child: _tutorials.isEmpty
                ? const Center(child: Text('Không có bài hướng dẫn.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tutorials.length,
                    itemBuilder: (context, index) {
                      return TutorialCard(
                        tutorial: _tutorials[index],
                        onTap: () => _openTutorialDetail(_tutorials[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Bài hướng dẫn',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  /// Tạo ô tìm kiếm bài hướng dẫn.
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bài hướng dẫn...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  /// Tạo bộ lọc danh mục.
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              selected: isSelected,
              label: Text(category),
              onSelected: (_) {
                setState(() => _selectedCategory = category);
                _loadData();
              },
            ),
          );
        },
      ),
    );
  }
}