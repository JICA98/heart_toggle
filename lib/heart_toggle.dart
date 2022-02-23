library heart_toggle;

import 'package:flutter/material.dart';

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
    this.duration = const Duration(milliseconds: 250),
  });
}

class HeartToggle extends StatefulWidget {
  final HeartToggleProps props;
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
    _beginXPos = _toggled ? 0.72 : 0.28;
    _endXPos = _toggled ? 0.28 : 0.72;
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
      begin: .423,
      end: .610,
    ).animate(_toggleYCntrllr)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _toggleYCntrllr.reverse();
        }
      });

    Future.doWhile(() async {
      if (_toggled) {
        _controller.forward();
        _toggleYCntrllr.forward();
      } else {
        _controller.reverse();
        _toggleYCntrllr.reverse();
      }
      return _toggled;
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
        width: widget.props.size * 1.4,
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
    final radius = size.width / 4.48;
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
    final h = size.height;
    final w = size.width;
    final path = Path();
    path
      ..moveTo(0.5 * w, 0.25 * h)
      ..cubicTo(w * 0.15, h * -.25, w * -.35, h * 0.6, w * 0.5, h)
      ..moveTo(0.5 * w, 0.25 * h)
      ..cubicTo(w * .85, h * -.25, w * 1.35, h * 0.6, w * 0.5, h);
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
