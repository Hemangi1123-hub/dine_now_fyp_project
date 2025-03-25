import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:hotel_management/pages/Admin/adminSignIn.dart';
import 'package:hotel_management/pages/Chefs/chefsSignIn.dart';
import 'package:hotel_management/pages/Owner/ownerSignIn.dart';
import 'package:hotel_management/pages/home_page.dart';

class HiddenDrawer extends StatefulWidget {
  const HiddenDrawer({super.key});

  @override
  State<HiddenDrawer> createState() => _HiddenDrawerState();
}

class _HiddenDrawerState extends State<HiddenDrawer> {
  List<ScreenHiddenDrawer> _pages = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _pages = [
      
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: "Admin",
          baseStyle: TextStyle(color: Colors.white, fontSize: 20.0),
          colorLineSelected: Colors.orange,
          selectedStyle: TextStyle(color: Colors.orange),
        ),
        AdminSignIn(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: "Chefs",
          baseStyle: TextStyle(color: Colors.white, fontSize: 20.0),
          colorLineSelected: Colors.orange,
          selectedStyle: TextStyle(color: Colors.orange),
        ),
        Chefssignin(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: "Owner",
          baseStyle: TextStyle(color: Colors.white, fontSize: 20.0),
          colorLineSelected: Colors.orange,
          selectedStyle: TextStyle(color: Colors.orange),
        ),
        Ownersignin(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
      backgroundColorMenu: Colors.deepPurple,
      screens: _pages,
      initPositionSelected: 0,
    );
  }
}
