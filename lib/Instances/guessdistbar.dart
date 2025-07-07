import 'package:flutter/material.dart';

class GuessDistributionBar extends StatelessWidget {
  final List<int> guessCounts;

  const GuessDistributionBar({super.key, required this.guessCounts});

  @override
  Widget build(BuildContext context) {
    final maxCount = guessCounts.any((e) => e > 0)
        ? guessCounts.reduce((a, b) => a > b ? a : b)
        : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(6, (index) {
        final count = guessCounts[index];
        final hasValue = count > 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '${index + 1}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double barWidth = hasValue
                        ? (count / maxCount) * constraints.maxWidth
                        : 4;

                    return Stack(
                      children: [
                        Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: barWidth,
                          height: 24,
                          decoration: BoxDecoration(
                            color: hasValue
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: hasValue
                                ? [
                                    BoxShadow(
                                      color: const Color.fromRGBO(0, 0, 0, 0.1),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text(
                  '$count',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
