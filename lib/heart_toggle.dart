library heart_toggle;

import 'package:flutter/material.dart';

/// Properties for the heart toggle widget.
class HeartToggleProps {
  // Heart Properties
  final Color activeFillColor;
  final Color activeStrokeColor;
  final Color passiveFillColor;
  final Color passiveStrokeColor;
  final double size;
  final double? strokeWidth;
  final double? heartElevation;
  final Color heartShadowColor;

  // Toggle ball properties
  final double ballElevation;
  final Color ballColor;
  final Color ballShadowColor;

  // Toggle properties
  final ValueChanged<bool>? onChanged;
  final Duration duration;
  final VoidCallback? onTap;
  final bool isActive;

  /// Properties of the heart toggle widget with their default values and description.
  ///
  /// `isActive`: Whether the heart is active or not.
  ///
  /// `onTap`: *null* : Function to be called when the heart is toggled.
  ///
  /// `activeFillColor`: *const Color(0xfffe8da5)* : Color of the heart when it is active.
  ///
  /// `activeStrokeColor`: *const Color(0xffe75776)* : Color of the stroke when the heart is active.
  ///
  /// `passiveFillColor`: *Colors.white54* : Color of the heart when it is inactive.
  ///
  /// `passiveStrokeColor`: *Colors.grey* : Color of the stroke when the heart is inactive.
  ///
  /// `size`: *40.0* : Size of the heart.
  ///
  /// `strokeWidth`: *2.0* : Width of the stroke. (40 / 20)
  ///
  /// `ballElevation`: *4.0* : Elevation of the ball.
  ///
  /// `ballColor`: *Colors.white* : Color of the ball.
  ///
  /// `heartElevation`: *null* : Elevation of the heart.
  ///
  /// `heartShadowColor`: *Colors.grey* : Color of the shadow of the heart.
  ///
  /// `ballShadowColor`: *Colors.grey* : Color of the shadow of the ball.
  ///
  /// `duration`: *const Duration(milliseconds: 300)* : Duration of the animation.
  ///
  /// `onChanged`: Function to be called when the heart is toggled. This function is called with a bool parameter.
  const HeartToggleProps({
    this.isActive = false,
    this.activeFillColor = const Color(0xfffe8da5),
    this.activeStrokeColor = const Color(0xffe75776),
    this.passiveFillColor = Colors.white54,
    this.passiveStrokeColor = Colors.grey,
    this.size = 40,
    this.strokeWidth,
    this.ballElevation = 4.0,
    this.onTap,
    this.onChanged,
    this.ballColor = Colors.white,
    this.heartElevation,
    this.heartShadowColor = Colors.grey,
    this.ballShadowColor = Colors.grey,
    this.duration = const Duration(milliseconds: 300),
  });
}

/// Heart toggle widget.
class HeartToggle extends StatefulWidget {
  final HeartToggleProps props;

  /// Heart toggle widget.
  ///
  /// [props] : Properties of the heart toggle widget.
  const HeartToggle({Key? key, this.props = const HeartToggleProps()})
      : super(key: key);

  @override
  _HeartToggleState createState() => _HeartToggleState();
}

class _HeartToggleState extends State<HeartToggle>
    with TickerProviderStateMixin {
  bool _toggled = false;
  late AnimationController _controller;
  late Animation<Color?> _fillAnim;
  late Animation<Color?> _strokeAnim;
  late Animation<double> _toggleXAnim;
  late Animation<double> _toggleYAnim;
  late AnimationController _toggleYCntrllr;
  late Color _beginFillColor;
  late Color _beginStrokeColor;
  late Color _endFillColor;
  late Color _endStrokeColor;
  late double _beginXPos;
  late double _endXPos;

  @override
  void initState() {
    super.initState();
    _initFields();
    _initAnimations();
  }

  void _initFields() {
    _toggled = widget.props.isActive;
    _beginFillColor =
        _toggled ? widget.props.activeFillColor : widget.props.passiveFillColor;
    _beginStrokeColor = _toggled
        ? widget.props.activeStrokeColor
        : widget.props.passiveStrokeColor;
    _endFillColor =
        _toggled ? widget.props.passiveFillColor : widget.props.activeFillColor;
    _endStrokeColor = _toggled
        ? widget.props.passiveStrokeColor
        : widget.props.activeStrokeColor;
    _beginXPos = _toggled ? 0.725 : 0.288;
    _endXPos = _toggled ? 0.288 : 0.725;
  }

  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.props.duration,
    );
    _toggleYCntrllr = AnimationController(
      vsync: this,
      duration:
          Duration(milliseconds: widget.props.duration.inMilliseconds ~/ 2),
    );
    _fillAnim = ColorTween(
      begin: _beginFillColor,
      end: _endFillColor,
    ).animate(_controller)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    _strokeAnim = ColorTween(
      begin: _beginStrokeColor,
      end: _endStrokeColor,
    ).animate(_controller);
    _toggleXAnim = Tween<double>(
      begin: _beginXPos,
      end: _endXPos,
    ).animate(_controller);

    _toggleYAnim = Tween<double>(
      begin: .426,
      end: .580,
    ).animate(_toggleYCntrllr)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _toggleYCntrllr.reverse();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _toggleYCntrllr.dispose();
    super.dispose();
  }

  double get _strokeWidth => widget.props.strokeWidth ?? widget.props.size / 20;

  void _onTap() {
    if (!_controller.isAnimating && !_toggleYCntrllr.isAnimating) {
      _toggled = !_toggled;
      if (widget.props.onTap != null) widget.props.onTap!();
      if (widget.props.onChanged != null) widget.props.onChanged!(_toggled);
      if (mounted)
        setState(() {
          if (_toggled) {
            _controller.forward();
            _toggleYCntrllr.forward();
          } else {
            _controller.reverse();
            _toggleYCntrllr.forward();
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: SizedBox(
        height: widget.props.size,
        width: widget.props.size * 1.5,
        child: CustomPaint(
          foregroundPainter: _ToggleBallPainter(
            xOffset: _toggleXAnim.value,
            yOffset: _toggleYAnim.value,
            elevation: widget.props.ballElevation,
            shadowColor: widget.props.ballShadowColor,
            ballColor: widget.props.ballColor,
          ),
          isComplex: true,
          painter: _HeartShapePainter(
            fillColor: _fillAnim.value ?? Colors.white,
            strokeWidth: _strokeWidth,
            strokeColor: _strokeAnim.value ?? Colors.grey,
            shadowColor: widget.props.heartShadowColor,
            elevation: widget.props.heartElevation,
          ),
        ),
      ),
    );
  }
}

class _ToggleBallPainter extends CustomPainter {
  final double xOffset;
  final double yOffset;
  final double? elevation;
  final Color shadowColor;
  final Color ballColor;
  _ToggleBallPainter({
    required this.xOffset,
    required this.yOffset,
    required this.shadowColor,
    required this.ballColor,
    this.elevation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ballColor
      ..style = PaintingStyle.fill;
    final h = size.height;
    final w = size.width;
    final center = Offset(w * xOffset, h * yOffset);
    final radius = size.width / 3.9;
    final path = Path()..addOval(ovalRectFrom(center, radius));
    if (elevation != null) {
      canvas.drawShadow(path, shadowColor, elevation!, false);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ToggleBallPainter oldDelegate) {
    return oldDelegate.xOffset != xOffset || oldDelegate.yOffset != yOffset;
  }

  Rect ovalRectFrom(Offset center, double radius) {
    return Rect.fromCircle(center: center, radius: radius);
  }
}

class _HeartShapePainter extends CustomPainter {
  final Color strokeColor;
  final Color fillColor;
  final double strokeWidth;
  final double? elevation;
  final Color shadowColor;
  _HeartShapePainter({
    required this.strokeColor,
    required this.fillColor,
    required this.strokeWidth,
    this.elevation,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    final y = size.height;
    final x = size.width;
    final path = Path();
    path
      ..moveTo(0.723 * x, 0.02 * y)
      ..cubicTo(0.876 * x, 0.02 * y, x, 0.201 * y, x, 0.422 * y)
      ..cubicTo(x, 0.753 * y, 0.66 * x, y, 0.507 * x, y)
      ..cubicTo(0.354 * x, y, 0.015 * x, 0.754 * y, 0.015 * x, 0.422 * y)
      ..cubicTo(0.015 * x, 0.201 * y, 0.139 * x, 0.02 * y, 0.292 * x, 0.02 * y)
      ..cubicTo(0.379 * x, 0.02 * y, 0.456 * x, 0.08 * y, 0.507 * x, 0.17 * y)
      ..cubicTo(0.558 * x, 0.08 * y, 0.636 * x, 0.02 * y, 0.723 * x, 0.02 * y);
    if (elevation != null) {
      canvas.drawShadow(path, shadowColor, elevation!, false);
    }
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(_HeartShapePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }

  @override
  bool shouldRebuildSemantics(_HeartShapePainter oldDelegate) => false;
}
