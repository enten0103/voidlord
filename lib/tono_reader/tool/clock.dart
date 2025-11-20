import 'dart:async';

import 'package:flutter/material.dart';

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  var time = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Text(
      "${time.hour}:${time.minute}",
      style: TextStyle(
        fontSize: 16,
        color: Color(0xFF999999),
      ),
    );
  }

  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        setState(() {
          time = DateTime.now();
        });
      }
    });
    super.initState();
  }
}
