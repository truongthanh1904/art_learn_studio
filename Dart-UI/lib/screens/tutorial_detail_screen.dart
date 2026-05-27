import 'package:flutter/material.dart';

import '../models/tutorial.dart';
import '../services/content_service.dart';

/// Màn hình chi tiết bài hướng dẫn.
class TutorialDetailScreen extends StatefulWidget {
  final Tutorial tutorial;

  const TutorialDetailScreen({
    super.key,
    required this.tutorial,
  });

  @override
  State<TutorialDetailScreen> createState() => _TutorialDetailScreenState();
}

class _TutorialDetailScreenState extends State<TutorialDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Tutorial _tutorial;

  final TextEditingController _reviewController = TextEditingController();

  List<TutorialReview> _reviews = [];
  int _reviewRating = 5;

  @override
  void initState() {
    super.initState();
    _tutorial = widget.tutorial;
    _tabController = TabController(length: 3, vsync: this);
    _loadTutorialDetail();
    _loadReviews();
  }

  /// Tải chi tiết bài hướng dẫn từ backend.
  Future<void> _loadTutorialDetail() async {
    final detail = await ContentService.fetchTutorialDetail(_tutorial.id);

    if (!mounted || detail == null) return;

    setState(() {
      _tutorial = detail;
    });
  }

  /// Tải danh sách đánh giá từ backend.
  Future<void> _loadReviews() async {
    final reviews = await ContentService.fetchTutorialReviews(_tutorial.id);

    if (!mounted) return;

    setState(() {
      _reviews = reviews;
      _recalculateAggregates();
    });
  }

  /// Tính lại số lượng đánh giá và điểm trung bình.
  void _recalculateAggregates() {
    final count = _reviews.length;
    _tutorial.reviewCount = count;

    if (count == 0) {
      _tutorial.averageRating = 0;
      return;
    }

    final sum = _reviews.fold<double>(
      0,
      (total, review) => total + review.rating,
    );

    _tutorial.averageRating = sum / count;
  }

  /// Gửi đánh giá bài hướng dẫn.
  Future<void> _addReview() async {
    await ContentService.postTutorialReview(
      tutorialId: _tutorial.id,
      rating: _reviewRating,
      comment: _reviewController.text.trim(),
    );

    _reviewController.clear();
    _loadReviews();
  }

  /// Lưu hoặc bỏ lưu bài hướng dẫn yêu thích.
  Future<void> _toggleFavorite() async {
    final next = !_tutorial.isSaved;

    setState(() {
      _tutorial.isSaved = next;
    });

    await ContentService.setTutorialFavorite(
      tutorialId: _tutorial.id,
      favorite: next,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final difficulty = _tutorial.difficultyLevel ?? 'Chưa phân loại';

    return Scaffold(
      appBar: AppBar(
        title: Text(_tutorial.title),
        actions: [
          IconButton(
            icon: Icon(
              _tutorial.isSaved ? Icons.bookmark : Icons.bookmark_border,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mô tả'),
            Tab(text: 'Bước làm'),
            Tab(text: 'Đánh giá'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildHeader(difficulty),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDescriptionTab(),
                _buildStepsTab(),
                _buildReviewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String difficulty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tutorial.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text('${_tutorial.category} • $difficulty'),
          const SizedBox(height: 6),
          Text(
            '${_tutorial.stepCount} bước • ${_tutorial.averageRating.toStringAsFixed(1)}★ (${_tutorial.reviewCount} đánh giá)',
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(_tutorial.description),
        const SizedBox(height: 18),
        Text(
          'Vật liệu',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        ..._tutorial.materials.map(
          (material) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle_outline),
            title: Text(material.name),
          ),
        ),
      ],
    );
  }

  Widget _buildStepsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tutorial.steps.length,
      itemBuilder: (context, index) {
        final step = _tutorial.steps[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(child: Text('${step.stepOrder}')),
            title: Text(step.title),
            subtitle: Text(step.content),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButton<int>(
          value: _reviewRating,
          items: [1, 2, 3, 4, 5]
              .map(
                (rating) => DropdownMenuItem(
                  value: rating,
                  child: Text('$rating sao'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _reviewRating = value);
            }
          },
        ),
        TextField(
          controller: _reviewController,
          decoration: const InputDecoration(
            hintText: 'Nhập nhận xét...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: _addReview,
          child: const Text('Gửi đánh giá'),
        ),
        const Divider(height: 32),
        if (_reviews.isEmpty)
          const Text('Chưa có đánh giá.')
        else
          ..._reviews.map(
            (review) => ListTile(
              leading: const Icon(Icons.star),
              title: Text('${review.rating} sao - ${review.userName}'),
              subtitle: Text(review.comment ?? ''),
            ),
          ),
      ],
    );
  }
}