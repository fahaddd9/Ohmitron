import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/presentation/providers/auth_provider.dart';

/// Premium Splash Screen.
/// Animation sequence:
///   0ms    — logo slides up + fades in (700ms, easeOutQuart)
///   600ms  — shimmer sweep across logo (500ms)
///   750ms  — subtitle types itself in letter by letter (700ms)
///   2300ms — navigate to /serial-entry
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {

  // ── Logo: slide-up + fade ──────────────────────────────────────────────────
  late final AnimationController _logoController;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;

  // ── Shimmer: diagonal light sweep across logo ──────────────────────────────
  late final AnimationController _shimmerController;

  // ── Subtitle: typewriter reveal ────────────────────────────────────────────
  late final AnimationController _textController;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    // Logo slides up 28px while fading in — 700ms
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutQuart),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _logoController, curve: Curves.easeOutQuart));

    // Shimmer sweeps once from left → right — 500ms
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Typewriter text reveal — 700ms
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _runSequence();

    ref.read(authProvider.future).ignore();
    _navTimer = Timer(const Duration(milliseconds: 2300), () {
      if (mounted) context.go('/serial-entry');
    });
  }

  Future<void> _runSequence() async {
    // Step 1: logo enters
    await _logoController.forward();
    // Step 2: shimmer fires immediately as logo lands
    _shimmerController.forward();
    // Step 3: subtitle starts slightly after shimmer begins
    await Future.delayed(const Duration(milliseconds: 150));
    _textController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _shimmerController.dispose();
    _textController.dispose();
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ── Logo with shimmer ─────────────────────────────────────────
              SlideTransition(
                position: _logoSlide,
                child: FadeTransition(
                  opacity: _logoFade,
                  child: AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) => _ShimmerMask(
                      progress: _shimmerController.value,
                      child: child!,
                    ),
                    child: SvgPicture.asset(
                      'assets/images/ohmitron_logo.svg',
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.space24),

              // ── Typewriter subtitle ───────────────────────────────────────
              _TypewriterText(
                text: 'POWER MONITOR',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.darkGrey,
                  letterSpacing: 4.5,
                  fontWeight: FontWeight.w400,
                ),
                controller: _textController,
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer: a diagonal light band that sweeps left → right once across the logo.
// Uses ShaderMask + blendMode srcATop so only painted pixels catch the shine.
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerMask extends StatelessWidget {
  final double progress; // 0 → 1
  final Widget child;

  const _ShimmerMask({required this.progress, required this.child});

  @override
  Widget build(BuildContext context) {
    // Outside active range — no shader overhead
    if (progress < 0.01 || progress > 0.99) return child;

    // Centre of the band moves from x = -2.0 to x = +2.0
    final cx = -2.0 + progress * 4.0;

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment(cx - 0.55, -1.0),
          end: Alignment(cx + 0.55, 1.0),
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.65),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.25, 0.5, 0.75],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Typewriter: reveals text character by character as controller progresses.
// Fades the whole text block in so first character doesn't pop abruptly.
// ─────────────────────────────────────────────────────────────────────────────

class _TypewriterText extends AnimatedWidget {
  final String text;
  final TextStyle style;

  const _TypewriterText({
    required this.text,
    required this.style,
    required AnimationController controller,
  }) : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final t = (listenable as AnimationController).value;
    final visible = (text.length * t).ceil().clamp(0, text.length);
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Text(text.substring(0, visible), style: style),
    );
  }
}
