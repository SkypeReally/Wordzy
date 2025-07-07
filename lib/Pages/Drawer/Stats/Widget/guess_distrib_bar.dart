import 'package:flutter/material.dart';

class GuessDistributionChart extends StatelessWidget {
  final List<int> distribution;

  const GuessDistributionChart({super.key, required this.distribution});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = distribution.fold<int>(0, (prev, e) => e > prev ? e : prev);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxBarWidth =
            constraints.maxWidth - 40; // 20 for label + padding

        return Column(
          children: List.generate(distribution.length, (i) {
            final value = distribution[i];
            final barWidth = max > 0 ? (value / max) * maxBarWidth : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text("${i + 1}", style: theme.textTheme.bodyMedium),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    children: [
                      Container(
                        height: 24,
                        width: maxBarWidth,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                            0.5,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 24,
                        width: barWidth,
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      if (value > 0)
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "$value",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
