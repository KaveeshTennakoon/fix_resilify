import 'package:flutter/material.dart';
import 'package:duration_time_picker/duration_time_picker.dart'; // Import the correct package

class DurationPickerWidget extends StatefulWidget {
  final Duration duration;
  final void Function(Duration) onDurationChange;

  const DurationPickerWidget({
    super.key,
    required this.duration,
    required this.onDurationChange,
  });

  @override
  _DurationPickerWidgetState createState() => _DurationPickerWidgetState();
}

class _DurationPickerWidgetState extends State<DurationPickerWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 150,
      child: DurationTimePicker(
        onChange: (value) {
          widget.onDurationChange(value); // Calls function from parent widget
        },
        duration: widget.duration,
        circleColor: const Color.fromARGB(255, 179, 144, 206).withOpacity(0.5),
        progressColor: const Color.fromRGBO(138, 109, 198, 1),
        backgroundColor: const Color.fromARGB(255, 210, 200, 214).withOpacity(0.5),
      ),
    );
  }
}