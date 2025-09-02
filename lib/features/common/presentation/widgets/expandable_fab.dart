import 'package:flutter/material.dart';

class ExpandableFab extends StatefulWidget {
  final List<ActionButton> children;

  const ExpandableFab({super.key, required this.children});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with TickerProviderStateMixin {
  bool _isExpanded = false;

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    _expandAnimation = CurvedAnimation(parent: _animationController, curve: const Cubic(0.2, 0.0, 0.0, 1.0));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _animationController, curve: const Cubic(0.4, 0.0, 0.2, 1.0)));
    _widthAnimation = Tween<double>(
      begin: 56.0,
      end: 56.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: const Cubic(0.2, 0.0, 0.0, 1.0)));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_expandAnimation.value > 0)
                  ...widget.children.asMap().entries.map((entry) {
                    final index = entry.key;
                    final actionButton = entry.value;

                    return AnimatedContainer(
                      duration: Duration(milliseconds: 150 + (index * 50)),
                      curve: const Cubic(0.2, 0.0, 0.0, 1.0),
                      transform: Matrix4.identity()
                        ..translateByDouble(
                          (1 - _expandAnimation.value) * 60, // Deslizar desde la derecha
                          (1 - _expandAnimation.value) * 20, // Leve movimiento vertical
                          0.0,
                          1.0,
                        )
                        ..scaleByDouble(_expandAnimation.value, _expandAnimation.value, _expandAnimation.value, 1.0),
                      child: Opacity(
                        opacity: _expandAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: _buildActionButton(actionButton, colorScheme, textTheme),
                        ),
                      ),
                    );
                  }),
                if (_expandAnimation.value > 0) SizedBox(height: 8 * _expandAnimation.value),
              ],
            );
          },
        ),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: SizedBox(
                width: _widthAnimation.value,
                height: 56,
                child: Material(
                  elevation: _isExpanded ? 2 : 6,
                  borderRadius: BorderRadius.circular(_isExpanded ? 1000 : 16),
                  color: _isExpanded ? colorScheme.primary : colorScheme.primaryContainer,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(1000),
                    onTap: _toggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: const Cubic(0.2, 0.0, 0.0, 1.0),
                      width: _widthAnimation.value,
                      height: 56,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(_isExpanded ? 1000 : 16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isExpanded ? Icons.close : Icons.edit,
                            size: _isExpanded ? 20 : 24,
                            color: _isExpanded ? colorScheme.onPrimary : colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(ActionButton actionButton, ColorScheme colorScheme, TextTheme textTheme) {
    return Material(
      borderRadius: BorderRadius.circular(1000),
      color: colorScheme.primaryContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(1000),
        onTap: () {
          if (actionButton.onPressed != null) {
            actionButton.onPressed!();
          }
          // Cerrar con un ligero delay para mejor UX
          Future.delayed(const Duration(milliseconds: 100), () => _toggle());
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: const Cubic(0.4, 0.0, 0.2, 1.0),
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8.0,
            children: [
              Icon(
                actionButton.icon,
                size: 24,
                fill: 1,
                weight: 400,
                grade: 0,
                opticalSize: 24,
                color: colorScheme.onPrimaryContainer,
              ),
              Text(actionButton.label, style: textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimaryContainer)),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionButton {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const ActionButton({required this.icon, required this.label, this.onPressed});
}
