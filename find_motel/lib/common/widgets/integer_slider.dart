import 'package:flutter/material.dart';
import 'package:find_motel/theme/app_colors.dart';

/// Builds a label to display for the given [value].
typedef IntLabelBuilder = String Function(double value);

/// A slider constrained to integer values using the same visual style and
/// API philosophy as [IntegerRangeSlider].
///
/// Example:
/// ```dart
/// IntegerSlider(
///   minValue: 0,
///   maxValue: 10,
///   initialValue: 3,
///   onChanged: (v) => print('selected: $v'),
/// )
/// ```
class IntegerSlider extends StatefulWidget {
  /// Minimum integer value of the slider.
  final int minValue;

  /// Maximum integer value of the slider.
  final int maxValue;

  /// The initial selected integer value.
  final int initialValue;

  /// Callback that is fired whenever the user selects a new value.
  final ValueChanged<int>? onChanged;

  /// Custom label builder. If null, the current integer value is shown.
  final IntLabelBuilder? labelBuilder;

  /// Color of the active part of the track.
  final Color? activeColor;

  /// Color of the inactive part of the track.
  final Color? inactiveColor;

  const IntegerSlider({
    super.key,
    this.minValue = 0,
    this.maxValue = 10,
    this.initialValue = 0,
    this.onChanged,
    this.labelBuilder,
    this.activeColor,
    this.inactiveColor,
  }) : assert(maxValue >= minValue, 'maxValue must be >= minValue');

  @override
  State<IntegerSlider> createState() => _IntegerSliderState();
}

class _IntegerSliderState extends State<IntegerSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    // Ensure initialValue within bounds.
    _currentValue = widget.initialValue
        .clamp(widget.minValue, widget.maxValue)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _currentValue,
      min: widget.minValue.toDouble(),
      max: widget.maxValue.toDouble(),
      divisions: widget.maxValue - widget.minValue,
      label: widget.labelBuilder != null
          ? widget.labelBuilder!(_currentValue)
          : _currentValue.round().toString(),
      onChanged: (double newValue) {
        // Round to nearest integer.
        final int intVal = newValue.round();
        setState(() {
          _currentValue = intVal.toDouble();
        });
        widget.onChanged?.call(intVal);
      },
      activeColor: widget.activeColor ?? AppColors.highlight,
      inactiveColor: widget.inactiveColor ?? AppColors.elementSecondary,
    );
  }
}
