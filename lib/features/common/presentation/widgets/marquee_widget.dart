import 'package:flutter/material.dart';

class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final Axis direction;
  final Duration animationDuration;
  final Duration reverseDuration;
  final Duration pauseDuration;

  const MarqueeWidget({
    super.key,
    required this.child,
    this.direction = Axis.horizontal,
    this.animationDuration = const Duration(seconds: 4),
    this.reverseDuration = const Duration(seconds: 4),
    this.pauseDuration = const Duration(milliseconds: 800),
  });

  @override
  State<MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  late ScrollController _controller;
  bool _needsScrolling = false;

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback(_checkIfScrollingNeeded);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _checkIfScrollingNeeded(_) {
    if (!_controller.hasClients) return;

    // Verificar si el contenido excede el ancho disponible
    if (_controller.position.maxScrollExtent > 0) {
      setState(() => _needsScrolling = true);
      _startScrolling();
    }
  }

  void _startScrolling() async {
    if (!mounted || !_controller.hasClients || !_needsScrolling) return;

    while (mounted && _controller.hasClients && _needsScrolling) {
      await Future.delayed(widget.pauseDuration);

      if (!mounted || !_controller.hasClients) break;

      await _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: widget.animationDuration,
        curve: Curves.easeInOut,
      );

      if (!mounted || !_controller.hasClients) break;

      await Future.delayed(widget.pauseDuration);

      if (!mounted || !_controller.hasClients) break;

      await _controller.animateTo(0.0, duration: widget.reverseDuration, curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: widget.direction,
      physics: NeverScrollableScrollPhysics(),
      child: widget.child,
    );
  }
}
