import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';

class QiblaCompass extends StatefulWidget {
  const QiblaCompass({super.key});

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass> {
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await FlutterQiblah.checkLocationStatus();
    if (status.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
    }
    
    final finalStatus = await FlutterQiblah.checkLocationStatus();
    if (mounted) {
      setState(() {
        _hasPermission = finalStatus.status == LocationPermission.always || 
                         finalStatus.status == LocationPermission.whileInUse;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF006C35))),
      );
    }

    if (!_hasPermission) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("يرجى تفعيل الموقع لتحديد القبلة"),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _checkPermission,
                child: const Text("طلب الإذن"),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator(color: Color(0xFF006C35))),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text("خطأ: ${snapshot.error}"));
        }

        final qiblahDirection = snapshot.data!;
        // The angle needed to point the Kaaba icon (which is at the top of our stack)
        // towards Kaaba relative to the device's current heading.
        final angle = qiblahDirection.qiblah * (math.pi / 180) * -1;

        return _buildCompassUI(context, angle, qiblahDirection.offset);
      },
    );
  }

  Widget _buildCompassUI(BuildContext context, double angle, double offset) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saudiGreen = const Color(0xFF006C35);

    return Container(
      width: 220,
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFF1F1F1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: saudiGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "بوصلة القبلة",
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Container(
                    width: 176,
                    height: 176,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                        width: 4,
                      ),
                    ),
                  ),
                  // Inner ring
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF4B5563) : const Color(0xFFF3F4F6),
                        width: 2,
                      ),
                    ),
                  ),
                  // Directions
                  _buildDirectionText("ش", Alignment.topCenter),
                  _buildDirectionText("ج", Alignment.bottomCenter),
                  _buildDirectionText("غ", Alignment.centerLeft),
                  _buildDirectionText("ق", Alignment.centerRight),
                  
                  // The moving needle - layered design matching React project
                  Transform.rotate(
                    angle: angle,
                    child: SizedBox(
                      width: 128,
                      height: 128,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 0,
                            child: Column(
                              children: [
                                const Text("🕋", style: TextStyle(fontSize: 24)),
                                Container(
                                  width: 2,
                                  height: 48,
                                  color: saudiGreen,
                                ),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "اتجاه القبلة: ${offset.toStringAsFixed(0)}°",
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionText(String text, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}
