import 'package:flutter/material.dart';

typedef RangeLabelsBuilder = RangeLabels Function(RangeValues values);

class IntegerRangeSlider extends StatefulWidget {
  final int minValue; // Giá trị số nguyên tối thiểu của slider
  final int maxValue; // Giá trị số nguyên tối đa của slider
  final RangeValues initialRange; // Khoảng giá trị số nguyên ban đầu
  final ValueChanged<RangeValues>? onChanged; // Callback khi giá trị thay đổi
  final RangeLabelsBuilder? labelsBuilder;
  final Color? activeColor;
  final Color? inactiveColor;
  final int minRangeDifference;

  const IntegerRangeSlider({
    super.key,
    this.minValue = 0,
    this.maxValue = 10, // Mặc định từ 0 đến 100
    this.initialRange = const RangeValues(0, 3), // Mặc định từ 0 đến 50
    this.labelsBuilder,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.minRangeDifference = 1,
  });

  @override
  State<IntegerRangeSlider> createState() => _IntegerRangeSliderState();
}

class _IntegerRangeSliderState extends State<IntegerRangeSlider> {
  late RangeValues _currentRangeValues;

  @override
  void initState() {
    super.initState();
    // Đảm bảo giá trị ban đầu nằm trong phạm vi min/max
    double start = widget.initialRange.start.clamp(
      widget.minValue.toDouble(),
      widget.maxValue.toDouble(),
    );
    double end = widget.initialRange.end.clamp(
      widget.minValue.toDouble(),
      widget.maxValue.toDouble(),
    );

    // Nếu khoảng cách ban đầu nhỏ hơn minRangeDifference, điều chỉnh
    if (end - start < widget.minRangeDifference) {
      if (start + widget.minRangeDifference <= widget.maxValue) {
        end = start + widget.minRangeDifference;
      } else {
        start =
            widget.maxValue.toDouble() - widget.minRangeDifference.toDouble();
      }
    }
    _currentRangeValues = RangeValues(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return RangeSlider(
      values: _currentRangeValues,
      min: widget.minValue.toDouble(), // RangeSlider nhận double cho min/max
      max: widget.maxValue.toDouble(),
      // divisions: Số lượng khoảng trống giữa các điểm.
      // Để đảm bảo chỉ chọn được số nguyên, divisions = (maxValue - minValue)
      divisions: widget.maxValue - widget.minValue,
      labels: widget.labelsBuilder != null
          ? widget.labelsBuilder!(
              _currentRangeValues,
            ) // Gọi callback từ bên ngoài
          : RangeLabels(
              _currentRangeValues.start.round().toString(),
              _currentRangeValues.end.round().toString(),
            ),
      onChanged: (RangeValues newValues) {
        double newStart = newValues.start;
        double newEnd = newValues.end;

        // Đảm bảo khoảng cách tối thiểu giữa start và end
        if ((newEnd - newStart).round() < widget.minRangeDifference) {
          if (newValues.start < _currentRangeValues.start) {
            // Nếu kéo thumb trái
            newStart = newEnd - widget.minRangeDifference.toDouble();
            if (newStart < widget.minValue) {
              // Ngăn chặn vượt quá minValue
              newStart = widget.minValue.toDouble();
              newEnd = newStart + widget.minRangeDifference.toDouble();
            }
          } else {
            // Nếu kéo thumb phải
            newEnd = newStart + widget.minRangeDifference.toDouble();
            if (newEnd > widget.maxValue) {
              // Ngăn chặn vượt quá maxValue
              newEnd = widget.maxValue.toDouble();
              newStart = newEnd - widget.minRangeDifference.toDouble();
            }
          }
        }

        setState(() {
          // Cập nhật giá trị đã được điều chỉnh và làm tròn
          _currentRangeValues = RangeValues(
            newStart.roundToDouble(),
            newEnd.roundToDouble(),
          );
        });
        widget.onChanged?.call(_currentRangeValues);
      },
      activeColor: widget.activeColor ?? Color(0xFFFFD47A),
      inactiveColor: widget.inactiveColor ?? Color(0xFFEBEBEB),
    );
  }
}

// --- Cách sử dụng ví dụ ---
/*
Để sử dụng, bạn có thể đặt nó vào bất kỳ widget nào khác, ví dụ:
void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Integer Range Slider Demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Slider mặc định (0-100, ban đầu 0-50):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const IntegerRangeSlider(),
              const SizedBox(height: 30),
              const Text(
                'Slider tùy chỉnh (10-50, ban đầu 15-30):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              IntegerRangeSlider(
                minValue: 10,
                maxValue: 50,
                initialRange: const RangeValues(15, 30),
                onChanged: (values) {
                  // Bạn có thể làm gì đó với các giá trị đã chọn ở đây
                  print('Khoảng giá trị mới: ${values.start.round()} - ${values.end.round()}');
                },
              ),
            ],
          ),
        ),
      ),
    ),
  ));
}
*/
