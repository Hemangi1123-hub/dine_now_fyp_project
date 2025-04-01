import 'package:flutter/material.dart';

class Services {
  String name;
  Icon icon;

  Services({required this.name, required this.icon});

  // Updated or removed the private getters based on use case
  String get _name => this.name; // If needed (optional)
  Icon get _icon => this.icon;   // If needed (optional)
}
