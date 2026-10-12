import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_logo.dart';

/// Shown while AuthStateCubit resolves the session (min. 2s).
///
/// The very first frame is identical to the native launch screen
/// (flutter_native_splash in pubspec.yaml): a [_logoSize] logo centred on
/// [AppColors.splashBackground]. Everything else animates in from there, so
/// the hand-off from native to Flutter is invisible.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

const double _logoSize = 112;
const double _logoLift = 52;

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _ambient;

  late final Animation<double> _backdrop;
  late final Animation<double> _lift;
  late final Animation<double> _wordmark;
  late final Animation<double> _tagline;
  late final Animation<double> _loader;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    CurvedAnimation interval(double begin, double end, Curve curve) =>
        CurvedAnimation(
          parent: _entrance,
          curve: Interval(begin, end, curve: curve),
        );

    _backdrop = interval(0.0, 0.55, Curves.easeOut);
    _lift = interval(0.18, 0.62, Curves.easeInOutCubic);
    _wordmark = interval(0.40, 0.80, Curves.easeOutCubic);
    _tagline = interval(0.52, 0.92, Curves.easeOutCubic);
    _loader = interval(0.75, 1.0, Curves.easeOut);

    _entrance.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
      _ambient.stop();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.splashBackground,
      ),
      child: Scaffold(
        backgroundColor: AppColors.splashBackground,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final center = Offset(size.width / 2, size.height / 2);

            return AnimatedBuilder(
              animation: Listenable.merge([_entrance, _ambient]),
              builder: (context, _) {
                final logoCenter = center.translate(
                  0,
                  -_logoLift * _lift.value,
                );
                final textTop = logoCenter.dy + _logoSize / 2 + 28;

                return Stack(
                  children: [
                    // Drifting brand-coloured glows.
                    Opacity(
                      opacity: _backdrop.value,
                      child: _AmbientGlows(t: _ambient.value, size: size),
                    ),

                    // "Hub" ripples radiating from the logo.
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _RipplePainter(
                          center: logoCenter,
                          t: _ambient.value,
                          opacity: _backdrop.value,
                        ),
                      ),
                    ),

                    // Logo.
                    Positioned(
                      left: logoCenter.dx - _logoSize / 2,
                      top: logoCenter.dy - _logoSize / 2,
                      child: const AppLogo(
                        size: _logoSize,
                        showWordmark: false,
                        onDark: true,
                      ),
                    ),

                    // Wordmark + tagline.
                    Positioned(
                      left: 24,
                      right: 24,
                      top: textTop,
                      child: Column(
                        children: [
                          _Reveal(
                            animation: _wordmark,
                            child: const AppWordmark(
                              onDark: true,
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _Reveal(
                            animation: _tagline,
                            child: Text(
                              'Your campus, simplified.',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white.withValues(alpha: 0.72),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Loader + footer.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SafeArea(
                        top: false,
                        child: Opacity(
                          opacity: _loader.value,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 28),
                            child: Column(
                              children: [
                                _PulsingDots(t: _ambient.value),
                                const SizedBox(height: 18),
                                Text(
                                  'Complaints  ·  Venues  ·  Suggestions',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.45),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Fades and slides its child up as [animation] goes 0 -> 1.
class _Reveal extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  const _Reveal({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: animation.value,
      child: Transform.translate(
        offset: Offset(0, 14 * (1 - animation.value)),
        child: child,
      ),
    );
  }
}

class _AmbientGlows extends StatelessWidget {
  final double t;
  final Size size;
  const _AmbientGlows({required this.t, required this.size});

  @override
  Widget build(BuildContext context) {
    final a = t * 2 * math.pi;
    final d = size.width * 1.3;
    return Stack(
      children: [
        Positioned(
          left: -d * 0.45 + math.cos(a) * 24,
          top: -d * 0.35 + math.sin(a) * 30,
          child: _Glow(
            diameter: d,
            color: const Color(0xFF2F55C8),
            alpha: 0.55,
          ),
        ),
        Positioned(
          right: -d * 0.5 + math.sin(a) * 28,
          bottom: -d * 0.4 + math.cos(a) * 22,
          child: _Glow(diameter: d, color: AppColors.secondary, alpha: 0.42),
        ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final double diameter;
  final Color color;
  final double alpha;
  const _Glow({
    required this.diameter,
    required this.color,
    required this.alpha,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Offset center;
  final double t;
  final double opacity;
  _RipplePainter({
    required this.center,
    required this.t,
    required this.opacity,
  });

  static const int _rings = 3;
  static const double _cyclesPerLoop = 4; // ripple speed within the 12s loop

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity == 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 0; i < _rings; i++) {
      final p = (t * _cyclesPerLoop + i / _rings) % 1.0;
      final radius = _logoSize * 0.62 + p * 130;
      final alpha = (1 - p) * 0.22 * opacity;
      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter old) =>
      old.t != t || old.center != center || old.opacity != opacity;
}

class _PulsingDots extends StatelessWidget {
  final double t;
  const _PulsingDots({required this.t});

  @override
  Widget build(BuildContext context) {
    final a = t * 2 * math.pi * 6;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final wave = 0.5 + math.sin(a - i * 0.9) * 0.5; // 0..1
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Transform.scale(
            scale: 0.7 + wave * 0.4,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.35 + wave * 0.55),
              ),
            ),
          ),
        );
      }),
    );
  }
}
