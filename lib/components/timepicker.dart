import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTimePicker extends StatefulWidget {
  const CustomTimePicker({super.key});
  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late int hour;
  late int minute;
  late String period;
  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    hour = now.hour > 12 ? now.hour - 12 : now.hour;
    minute = now.minute;
    period = now.hour >= 12 ? "PM" : "AM";
  }

  void incrementHour() {
    setState(() {
      if (hour == 12) {
        hour = 1;
      } else {
        hour++;
      }
    });
  }

  void decrementHour() {
    setState(() {
      if (hour == 1) {
        hour = 12;
      } else {
        hour--;
      }
    });
  }

  void incrementMinute() {
    setState(() {
      if (minute == 59) {
        minute = 0;
        incrementHour();
      } else {
        minute++;
      }
    });
  }

  void decrementMinute() {
    setState(() {
      if (minute == 0) {
        minute = 59;
        decrementHour();
      } else {
        minute--;
      }
    });
  }

  void togglePeriod() {
    setState(() {
      period = period == "AM" ? "PM" : "AM";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hour Up Button
            Column(
              children: [
                IconButton(
                  onPressed: incrementHour,
                  icon: const Icon(CupertinoIcons.chevron_up),
                ),
                Text(
                  hour.toString().padLeft(2, '0'),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: decrementHour,
                  icon: const Icon(CupertinoIcons.chevron_down),
                ),
              ],
            ),
            // Separator
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                ":",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            // Minute Up Button
            Column(
              children: [
                IconButton(
                  onPressed: incrementMinute,
                  icon: const Icon(CupertinoIcons.chevron_up),
                ),
                Text(
                  minute.toString().padLeft(2, '0'),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: decrementMinute,
                  icon: const Icon(CupertinoIcons.chevron_down),
                ),
              ],
            ),
            // Period Up Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  IconButton(
                    onPressed: togglePeriod,
                    icon: const Icon(CupertinoIcons.chevron_up),
                  ),
                  Text(
                    period,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: togglePeriod,
                    icon: const Icon(CupertinoIcons.chevron_down),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
