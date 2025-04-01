import 'package:flutter/material.dart';

class Activities {
  String name;
  String description;
  Icon icon;

  Activities(
      {required this.name, required this.description, required this.icon});

  // Updated or removed the private getters based on use case
  String get _name => this.name; // If needed (optional)
  String get _description => this.description;
  Icon get _icon => this.icon; // If needed (optional)
}
