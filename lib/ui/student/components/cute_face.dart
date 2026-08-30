import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/model/student_gender.dart';
import 'cute_face_kind.dart';
import 'cute_face_painters.dart';

class CuteFace extends StatefulWidget {
  const CuteFace({
    super.key,
    this.size = 52,
    this.kind = CuteFaceKind.bunny,
    this.animate = true,
  });

  final double size;
  final CuteFaceKind kind;
  final bool animate;

  @override
  State<CuteFace> createState() => _CuteFaceState();
}

class _CuteFaceState extends State<CuteFace> with TickerProviderStateMixin {
  late final AnimationController _blink;
  late final AnimationController _bob;
  Timer? _blinkWait;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.animate) {
      _bob.repeat(reverse: true);
      _scheduleBlink();
    }
  }

  @override
  void didUpdateWidget(CuteFace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _bob.repeat(reverse: true);
        _scheduleBlink();
      } else {
        _blinkWait?.cancel();
        _bob.stop();
        _blink.value = 0;
      }
    }
  }

  void _scheduleBlink() {
    _blinkWait?.cancel();
    if (!widget.animate) return;
    final wait = 1800 + math.Random().nextInt(2200);
    _blinkWait = Timer(Duration(milliseconds: wait), () async {
      if (!mounted || !widget.animate) return;
      await _blink.forward();
      await _blink.reverse();
      _scheduleBlink();
    });
  }

  @override
  void dispose() {
    _blinkWait?.cancel();
    _blink.dispose();
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_blink, _bob]),
      builder: (context, child) {
        final lift = widget.animate ? (_bob.value - 0.5) * 3 : 0.0;
        return Transform.translate(offset: Offset(0, lift), child: child);
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _blink,
          builder: (context, _) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: widget.kind.fill,
                shape: BoxShape.circle,
              ),
              child: CustomPaint(
                painter: CuteFacePainter(
                  kind: widget.kind,
                  blink: _blink.value,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CyclingCuteFace extends StatefulWidget {
  const CyclingCuteFace({super.key, this.size = 52, this.gender});

  final double size;
  final StudentGender? gender;

  @override
  State<CyclingCuteFace> createState() => _CyclingCuteFaceState();
}

class _CyclingCuteFaceState extends State<CyclingCuteFace> {
  late CuteFaceKind _kind;
  Timer? _cycle;

  List<CuteFaceKind> get _pool {
    final gender = widget.gender;
    if (gender == null) return CuteFaceKind.values;
    return CuteFaceKind.poolFor(gender);
  }

  @override
  void initState() {
    super.initState();
    _kind = _pool.first;
    _cycle = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() => _advance());
    });
  }

  @override
  void didUpdateWidget(CyclingCuteFace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gender != widget.gender) {
      setState(() => _kind = _pool.first);
    }
  }

  void _advance() {
    final pool = _pool;
    final index = pool.indexOf(_kind);
    _kind = pool[((index < 0 ? 0 : index) + 1) % pool.length];
  }

  @override
  void dispose() {
    _cycle?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: CuteFace(key: ValueKey(_kind), size: widget.size, kind: _kind),
    );
  }
}
