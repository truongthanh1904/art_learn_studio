import 'package:flutter/material.dart';

import '../models/tutorial.dart';

/// Widget hiển thị tóm tắt một bài hướng dẫn.
class TutorialCard extends StatelessWidget {
  final Tutorial tutorial;
  final VoidCallback onTap;

  const TutorialCard({
    super.key,
    required this.tutorial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final difficulty = tutorial.difficultyLevel ?? 'Chưa phân loại';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                child: Text(
                  tutorial.title.isNotEmpty ? tutorial.title[0] : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutorial.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text('${tutorial.category} • $difficulty'),
                    const SizedBox(height: 6),
                    Text(
                      tutorial.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${tutorial.stepCount} bước • ${tutorial.averageRating.toStringAsFixed(1)}★',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}