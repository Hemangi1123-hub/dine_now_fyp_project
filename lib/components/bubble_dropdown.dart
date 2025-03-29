import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:popup_menu/popup_menu.dart';

class CustomPopupMenu extends StatefulWidget {
  final List<String> menuItems;

  const CustomPopupMenu({super.key, required this.menuItems});

  @override
  State<CustomPopupMenu> createState() => _CustomPopupMenuState();
}

class _CustomPopupMenuState extends State<CustomPopupMenu> {
  late PopupMenu menu;
  String? selectedMenu;
  GlobalKey btnKey2 = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  void onClickMenu(MenuItemProvider item) {
    setState(() {
      selectedMenu = item.menuTitle;
    });
  }

  void onDismiss() {
    print('Menu is dismiss');
  }

  void onShow() {
    print('Menu is show');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: btnKey2,
      onTap: listMenu,
      child: PrimaryContainer(
        radius: 10,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(
                selectedMenu ?? 'Choose space',
                style: TextStyle(
                    fontSize: 14,
                    color: selectedMenu != null
                        ? Colors.white
                        : const Color(0xFF5E5E5E)),
              ),
              const Spacer(),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }

  void listMenu() {
    List<MenuItem> menuItems = widget.menuItems.map((item) {
      return MenuItem.forList(
          title: item,
          textStyle: const TextStyle(color: Colors.white, fontSize: 16));
    }).toList();

    PopupMenu menu = PopupMenu(
      context: context,
      config: const MenuConfig(
        type: MenuType.list,
        itemWidth: 330,
        itemHeight: 45,
        maxColumn: 1,
        backgroundColor: Colors.black,
      ),
      items: menuItems,
      onClickMenu: onClickMenu,
      onShow: onShow,
      onDismiss: onDismiss,
    );

    menu.show(widgetKey: btnKey2);
  }
}

class PrimaryContainer extends StatelessWidget {
  final Widget child;
  final double? radius;
  final Color? color;
  const PrimaryContainer({
    super.key,
    this.radius,
    this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 30),
        boxShadow: [
          BoxShadow(
            color: color ?? const Color(0XFF1E1E1E),
          ),
          const BoxShadow(
            offset: Offset(2, 2),
            blurRadius: 4,
            spreadRadius: 0,
            color: Colors.black,
            inset: true,
          ),
        ],
      ),
      child: child,
    );
  }
}
