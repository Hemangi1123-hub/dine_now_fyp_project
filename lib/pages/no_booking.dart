import 'package:flutter/material.dart';

class NoOrder extends StatelessWidget {
  const NoOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child:
              Text('Cannot place order without booking table for today first')),
    );
  }
}
