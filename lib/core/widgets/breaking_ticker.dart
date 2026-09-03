import 'dart:async';
import 'package:flutter/material.dart';

class BreakingTicker extends StatefulWidget {
  const BreakingTicker({super.key});

  @override
  State<BreakingTicker> createState() => _BreakingTickerState();
}

class _BreakingTickerState extends State<BreakingTicker> with SingleTickerProviderStateMixin {
  final List<String> _breakingNews = [
    "🔴 عاجل: مجلس الوزراء يعقد جلسته الأسبوعية برئاسة ولي العهد",
    "🔴 عاجل: ارتفاع أسعار النفط بعد قرارات أوبك+",
    "🔴 عاجل: المملكة تسجل نموًا اقتصاديًا بنسبة 6.4% في الربع الثالث",
    "🔴 عاجل: الهلال يتصدر دوري روشن بعد فوز كبير",
  ];

  int _currentIndex = 0;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _breakingNews.length;
        });
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x4D7F1D1D) : const Color(0xFFFEF2F2),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0x66991B1B) : const Color(0xFFFEE2E2),
          ),
        ),
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFFB91C1C) : const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'عاجل',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  _breakingNews[_currentIndex],
                  key: ValueKey<int>(_currentIndex),
                  style: TextStyle(
                    color: isDark ? const Color(0xFFFECACA) : const Color(0xFF991B1B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
