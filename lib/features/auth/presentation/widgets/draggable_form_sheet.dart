import 'dart:math' as math;

import 'package:flutter/material.dart';

class DraggableFormSheet extends StatefulWidget {
  /// Campos del formulario
  final List<Widget> formContent;

  /// Personalización del contenido del widget
  final String buttonLabel;
  final String bottomMessage;
  final String bottomButtonLabel;

  /// Tamaño inicial del BottomSheet.
  final double initialChildSize;

  /// Tamaño mínimo del BottomSheet.
  final double minChildSize;

  /// Tamaño máximo del BottomSheet.
  final double maxSheetHeightProportionCap;

  final Color? sheetBackgroundColor;
  final bool showDragHandle;

  final double topPaddingAboveForm;
  final double bottomPaddingBelowForm;

  const DraggableFormSheet({
    super.key,
    required this.formContent,
    required this.buttonLabel,
    required this.bottomMessage,
    required this.bottomButtonLabel,
    this.initialChildSize = 0.48,
    this.minChildSize = 0.48,
    this.maxSheetHeightProportionCap = 1.0,
    this.sheetBackgroundColor,
    this.showDragHandle = true,
    this.topPaddingAboveForm = 64.0,
    this.bottomPaddingBelowForm = 16.0,
  });

  @override
  State<DraggableFormSheet> createState() => _DraggableFormSheetState();
}

class _DraggableFormSheetState extends State<DraggableFormSheet> {
  final GlobalKey _formContentKey = GlobalKey();

  /// Tamaño calculado del BottomSheet.
  late double _calculatedMaxChildSize;

  /// Indica si el tamaño del BottomSheet ha cambiado y hay que recalcularlo.
  bool _isSheetSizeDirty = true;

  /// Controlador del DraggableScrollableSheet
  final DraggableScrollableController _draggableController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();

    _calculatedMaxChildSize = widget.maxSheetHeightProportionCap;

    _draggableController.addListener(() {});
  }

  @override
  void dispose() {
    _draggableController.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DraggableFormSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si algún parámetro relevante cambia, se marca para recalcular el tamaño
    if (widget.formContent != oldWidget.formContent ||
        widget.topPaddingAboveForm != oldWidget.topPaddingAboveForm ||
        widget.bottomPaddingBelowForm != oldWidget.bottomPaddingBelowForm) {
      _isSheetSizeDirty = true;
    }
    // Se actualiza el tamaño calculado si cualquiera de los límites cambia
    if (widget.maxSheetHeightProportionCap != oldWidget.maxSheetHeightProportionCap) {
      _calculatedMaxChildSize = math.min(_calculatedMaxChildSize, widget.maxSheetHeightProportionCap);
      _isSheetSizeDirty = true;
    }
    if (widget.minChildSize != oldWidget.minChildSize || widget.initialChildSize != oldWidget.initialChildSize) {
      _isSheetSizeDirty = true;
    }
  }

  /// Calcula el tamaño máximo del BottomSheet en función del contenido.
  void _calculateSheetSize(double availableHeightForSheet) {
    if (!_isSheetSizeDirty || !mounted) return;

    final RenderBox? formBox = _formContentKey.currentContext?.findRenderObject() as RenderBox?;

    if (formBox != null && availableHeightForSheet > 0) {
      double formHeight = formBox.size.height;

      // Se calcula el espacio adicional para el "drag handle" y paddings verticales dentro del sheet.
      double totalContentHeight = formHeight + widget.topPaddingAboveForm + widget.bottomPaddingBelowForm;

      double contentProportion = (totalContentHeight / availableHeightForSheet).clamp(0.0, 1.0);
      double newMax = contentProportion;

      // Se asegura que maxChildSize esté dentro de los límites definidos
      newMax = math.max(widget.minChildSize, newMax);
      newMax = math.max(widget.initialChildSize, newMax);
      newMax = math.min(newMax, widget.maxSheetHeightProportionCap);

      if ((_calculatedMaxChildSize - newMax).abs() > 0.01 || _isSheetSizeDirty) {
        setState(() => _calculatedMaxChildSize = newMax);
      }
      _isSheetSizeDirty = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Se usa LayoutBuilder para obtener la altura disponible para el DraggableScrollableSheet
    return LayoutBuilder(
      builder: (context, constraints) {
        // Se llama a _calculateSheetSize en el siguiente frame si es necesario
        if (_isSheetSizeDirty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _calculateSheetSize(constraints.maxHeight);
          });
        }

        return DraggableScrollableSheet(
          controller: _draggableController,
          initialChildSize: widget.initialChildSize,
          minChildSize: widget.minChildSize,
          // Se usa el valor calculado
          maxChildSize: _calculatedMaxChildSize,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
              ),
              child: Column(
                children: [
                  if (widget.showDragHandle)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: (details) {
                        final newPosition =
                            _draggableController.size - (details.primaryDelta! / MediaQuery.of(context).size.height);
                        if (widget.minChildSize <= newPosition && newPosition <= widget.maxSheetHeightProportionCap) {
                          _draggableController.jumpTo(newPosition);
                        }
                      },
                      onVerticalDragEnd: (details) {
                        // Se obtiene la velocidad del drag, de forma que, si es suficientemente alta, la hoja se mueve
                        final velocity = details.velocity.pixelsPerSecond.dy;

                        // Si la velocidad es positiva (hacia abajo) y la hoja no está en el mínimo, se mueve a esta
                        // posición mínima (cerrada)
                        if (velocity > 100 && _draggableController.size > widget.minChildSize) {
                          _draggableController.animateTo(
                            widget.minChildSize,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                        // Si la velocidad es negativa (hacia arriba) y la hoja no está en el máximo, se mueve a esta
                        // posición máxima (expandida)
                        else if (velocity < -100 && _draggableController.size < _calculatedMaxChildSize) {
                          _draggableController.animateTo(
                            _calculatedMaxChildSize,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                        // Si la velocidad es baja, la hoja se ajusta al punto de anclaje más cercano
                        else {
                          final initialSize = widget.initialChildSize;
                          final minSize = widget.minChildSize;
                          final maxSize = _calculatedMaxChildSize;
                          final currentSize = _draggableController.size;

                          // Se elige el punto de anclaje más cercano
                          double targetSize;
                          if (currentSize - minSize < initialSize - currentSize) {
                            targetSize = minSize;
                          } else if (maxSize - currentSize < currentSize - initialSize) {
                            targetSize = maxSize;
                          } else {
                            targetSize = initialSize;
                          }

                          _draggableController.animateTo(
                            targetSize,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 22.0),
                        child: Center(
                          child: Container(
                            width: 32,
                            height: 4,
                            decoration: BoxDecoration(
                              // Se calcula la opacidad (según el valor dado por el estándar) en la escala de 0 a 255
                              color: colorScheme.onSurfaceVariant.withAlpha((0.4 * 255).round()),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(16.0, widget.showDragHandle ? 4.0 : 32.0, 16.0, 16.0),
                      child: Column(
                        key: _formContentKey,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: widget.formContent,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
