import 'package:flutter/material.dart';

class MonthlySpendingChart extends StatelessWidget {
  const MonthlySpendingChart({required this.values, super.key});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final maximum =
        values.fold<int>(0, (max, value) => value > max ? value : max);
    return Container(
      height: 190,
      padding: const EdgeInsets.fromLTRB(17, 17, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily spending',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var index = 0; index < values.length; index++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: maximum == 0
                                    ? 0.02
                                    : (values[index] / maximum).clamp(0.02, 1),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: values[index] == 0
                                        ? const Color(0xFFE5E5E5)
                                        : Colors.black,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            index == 0 || (index + 1) % 5 == 0
                                ? '${index + 1}'
                                : '',
                            style: const TextStyle(
                              color: Color(0xFF8A8A8A),
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
