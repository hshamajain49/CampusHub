import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _ambientController;
  late final AnimationController _entranceController;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _loaderFade;

  late final List<_FloatingIcon> _floatingIcons;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _logoFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _titleFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
          ),
        );

    _taglineFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 0.9, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.55, 0.9, curve: Curves.easeOutCubic),
          ),
        );

    _loaderFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
    );

    _floatingIcons = _buildFloatingIcons();
    _particles = _buildParticles();

    _entranceController.forward();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  List<_FloatingIcon> _buildFloatingIcons() {
    const icons = [
      Icons.school_rounded, // graduation cap
      Icons.menu_book_rounded, // open book
      Icons.account_balance_rounded, // campus building
      Icons.edit_outlined, // pencil
      Icons.lightbulb_outline_rounded, // idea
      Icons.workspace_premium_outlined, // diploma/medal
      Icons.auto_stories_rounded, // stacked books
    ];
    const positions = [
      Offset(0.10, 0.12),
      Offset(0.80, 0.10),
      Offset(0.85, 0.32),
      Offset(0.08, 0.34),
      Offset(0.15, 0.68),
      Offset(0.82, 0.62),
      Offset(0.50, 0.08),
    ];
    final rnd = math.Random(7); // fixed seed — consistent, non-jarring layout
    return List.generate(icons.length, (i) {
      return _FloatingIcon(
        icon: icons[i],
        left: positions[i].dx,
        top: positions[i].dy,
        size: 22 + rnd.nextDouble() * 12,
        floatSpeed: 0.5 + rnd.nextDouble() * 0.6,
        floatAmplitude: 10 + rnd.nextDouble() * 8,
        rotateSpeed: 0.3 + rnd.nextDouble() * 0.4,
        rotateAmplitude: 0.06 + rnd.nextDouble() * 0.05,
        phase: rnd.nextDouble() * 2 * math.pi,
        opacity: 0.10 + rnd.nextDouble() * 0.08,
      );
    });
  }

  List<_Particle> _buildParticles() {
    final rnd = math.Random(21);
    return List.generate(22, (_) {
      return _Particle(
        x: rnd.nextDouble(),
        startY: rnd.nextDouble(),
        size: 1.5 + rnd.nextDouble() * 2.5,
        speed: 0.4 + rnd.nextDouble() * 0.8,
        driftAmplitude: 0.02 + rnd.nextDouble() * 0.03,
        phase: rnd.nextDouble() * 2 * math.pi,
        opacity: 0.12 + rnd.nextDouble() * 0.22,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _AnimatedGradientBackground(controller: _ambientController),
              _ParticleField(
                controller: _ambientController,
                particles: _particles,
              ),
              ..._floatingIcons.map(
                (item) => _FloatingIconWidget(
                  controller: _ambientController,
                  item: item,
                  constraints: constraints,
                ),
              ),
              _WaveLayer(controller: _ambientController),
              _CenterContent(
                logoFade: _logoFade,
                logoScale: _logoScale,
                titleFade: _titleFade,
                titleSlide: _titleSlide,
                taglineFade: _taglineFade,
                taglineSlide: _taglineSlide,
                loaderFade: _loaderFade,
                ambientController: _ambientController,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// Background gradient — slowly drifting light source, never static.
// ============================================================================

class _AnimatedGradientBackground extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedGradientBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value * 2 * math.pi;
        final dx = math.cos(t * 0.15) * 0.6;
        final dy = math.sin(t * 0.15) * 0.6;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(dx, -0.6 + dy * 0.3),
              radius: 1.4,
              colors: [
                AppColors.primary.withValues(alpha: 0.07),
                AppColors.background,
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// Rising particle field
// ============================================================================

class _Particle {
  final double x, startY, size, speed, driftAmplitude, phase, opacity;
  const _Particle({
    required this.x,
    required this.startY,
    required this.size,
    required this.speed,
    required this.driftAmplitude,
    required this.phase,
    required this.opacity,
  });
}

class _ParticleField extends StatelessWidget {
  final AnimationController controller;
  final List<_Particle> particles;
  const _ParticleField({required this.controller, required this.particles});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlesPainter(
            t: controller.value,
            particles: particles,
            color: AppColors.primary,
          ),
        );
      },
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final double t;
  final List<_Particle> particles;
  final Color color;
  _ParticlesPainter({
    required this.t,
    required this.particles,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      // Rises from startY toward the top, then wraps back to the bottom.
      var progress = (p.startY - t * p.speed) % 1.0;
      if (progress < 0) progress += 1.0;
      final y = progress * size.height;
      final x =
          (p.x + math.sin(t * 2 * math.pi + p.phase) * p.driftAmplitude) *
          size.width;
      paint.color = color.withValues(alpha: p.opacity);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) =>
      oldDelegate.t != t;
}

// ============================================================================
// Floating academic iconography
// ============================================================================

class _FloatingIcon {
  final IconData icon;
  final double left,
      top,
      size,
      floatSpeed,
      floatAmplitude,
      rotateSpeed,
      rotateAmplitude,
      phase,
      opacity;
  const _FloatingIcon({
    required this.icon,
    required this.left,
    required this.top,
    required this.size,
    required this.floatSpeed,
    required this.floatAmplitude,
    required this.rotateSpeed,
    required this.rotateAmplitude,
    required this.phase,
    required this.opacity,
  });
}

class _FloatingIconWidget extends StatelessWidget {
  final AnimationController controller;
  final _FloatingIcon item;
  final BoxConstraints constraints;
  const _FloatingIconWidget({
    required this.controller,
    required this.item,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final dy =
            math.sin(t * 2 * math.pi * item.floatSpeed + item.phase) *
            item.floatAmplitude;
        final angle =
            math.sin(t * 2 * math.pi * item.rotateSpeed + item.phase) *
            item.rotateAmplitude;
        return Positioned(
          left: constraints.maxWidth * item.left,
          top: constraints.maxHeight * item.top + dy,
          child: Transform.rotate(
            angle: angle,
            child: Icon(
              item.icon,
              size: item.size,
              color: AppColors.primary.withValues(alpha: item.opacity),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// Layered waves anchored to the bottom
// ============================================================================

class _WaveLayer extends StatelessWidget {
  final AnimationController controller;
  const _WaveLayer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: _WavePainter(
                t: t,
                color: AppColors.primary.withValues(alpha: 0.05),
                amplitude: 14,
                frequency: 1.4,
                speed: 0.35,
                phaseOffset: 0,
                verticalPosition: 0.90,
              ),
            ),
            CustomPaint(
              size: Size.infinite,
              painter: _WavePainter(
                t: t,
                color: AppColors.secondary.withValues(alpha: 0.07),
                amplitude: 18,
                frequency: 1.1,
                speed: 0.5,
                phaseOffset: math.pi / 3,
                verticalPosition: 0.94,
              ),
            ),
            CustomPaint(
              size: Size.infinite,
              painter: _WavePainter(
                t: t,
                color: AppColors.primary.withValues(alpha: 0.10),
                amplitude: 10,
                frequency: 1.8,
                speed: 0.7,
                phaseOffset: math.pi / 1.5,
                verticalPosition: 0.97,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double t, amplitude, frequency, speed, phaseOffset, verticalPosition;
  final Color color;
  _WavePainter({
    required this.t,
    required this.color,
    required this.amplitude,
    required this.frequency,
    required this.speed,
    required this.phaseOffset,
    required this.verticalPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    final baseY = size.height * verticalPosition;
    final phase = t * 2 * math.pi * speed + phaseOffset;

    path.moveTo(0, size.height);
    path.lineTo(0, baseY);
    for (double x = 0; x <= size.width; x += 6) {
      final y =
          baseY +
          math.sin((x / size.width) * frequency * 2 * math.pi + phase) *
              amplitude;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => oldDelegate.t != t;
}

// ============================================================================
// Center content — glow ring, logo, staggered title/tagline, loader
// ============================================================================

class _CenterContent extends StatelessWidget {
  final Animation<double> logoFade;
  final Animation<double> logoScale;
  final Animation<double> titleFade;
  final Animation<Offset> titleSlide;
  final Animation<double> taglineFade;
  final Animation<Offset> taglineSlide;
  final Animation<double> loaderFade;
  final AnimationController ambientController;

  const _CenterContent({
    required this.logoFade,
    required this.logoScale,
    required this.titleFade,
    required this.titleSlide,
    required this.taglineFade,
    required this.taglineSlide,
    required this.loaderFade,
    required this.ambientController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([logoFade, ambientController]),
          builder: (context, child) {
            final glowT = ambientController.value * 2 * math.pi;
            final pulse = 0.5 + math.sin(glowT * 0.5) * 0.5; // 0..1
            return Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing glow ring behind the logo
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: 0.10 + pulse * 0.08,
                        ),
                        blurRadius: 40 + pulse * 20,
                        spreadRadius: 4 + pulse * 6,
                      ),
                    ],
                  ),
                ),
                Opacity(
                  opacity: logoFade.value,
                  child: Transform.scale(scale: logoScale.value, child: child),
                ),
              ],
            );
          },
          child: const AppLogo(size: 96),
        ),
        const SizedBox(height: 24),
        // FadeTransition(
        //   opacity: titleFade,
        //   child: SlideTransition(
        //     position: titleSlide,
        //     child: Text(
        //       'CampusHub',
        //       style: AppTextStyles.h1.copyWith(letterSpacing: 0.5),
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 8),
        // FadeTransition(
        //   opacity: taglineFade,
        //   child: SlideTransition(
        //     position: taglineSlide,
        //     child: Text(
        //       'Your Campus, Simplified',
        //       style: AppTextStyles.bodySecondary.copyWith(letterSpacing: 0.3),
        //     ),
        //   ),
        // ),
        const SizedBox(height: 56),
        FadeTransition(
          opacity: loaderFade,
          child: _PulsingDots(controller: ambientController),
        ),
      ],
    );
  }
}

class _PulsingDots extends StatelessWidget {
  final AnimationController controller;
  const _PulsingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value * 2 * math.pi;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = i * (math.pi / 2.2);
            final scale = 0.6 + (0.5 + math.sin(t * 3 + phase) * 0.5) * 0.4;
            final opacity = 0.35 + (0.5 + math.sin(t * 3 + phase) * 0.5) * 0.5;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: opacity),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
