import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ContributionHeatmap extends StatelessWidget {
  const ContributionHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate dummy heatmap data for 7 months x 4 weeks roughly
    final random = Random();
    final List<Color> colors = [
      AppTheme.secondaryColor, // Empty/Very Low
      AppTheme.secondaryColor.withValues(alpha: 0.5), // Low
      AppTheme.accentColor.withValues(alpha: 0.3), // Medium
      AppTheme.accentColor.withValues(alpha: 0.7), // High
      AppTheme.accentColor, // Very High
    ];

    return Column(
      children: [
        // Months header (approximate)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Nov', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('Dec', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('Jan', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('Feb', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('Mar', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('Apr', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        // Grid
        SizedBox(
          height: 150,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 16, // columns
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 16 * 5, // 16 weeks, 5 days/week
            itemBuilder: (context, index) {
              // Random color from the palette
              final color = colors[random.nextInt(colors.length)];
              // Occasional white cells like the image
              final isWhite = random.nextDouble() > 0.95;

              return Container(
                decoration: BoxDecoration(
                  color: isWhite ? Colors.white : color,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'Less',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(width: 8),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors[0],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors[1],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors[2],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors[3],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors[4],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'More',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
