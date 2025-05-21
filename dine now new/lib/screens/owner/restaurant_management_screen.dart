import 'package:cached_network_image/cached_network_image.dart';
import 'package:dine_now/models/restaurant_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import ConsumerWidget/Ref if needed
import 'package:dine_now/providers/auth_provider.dart'; // Import for logout
import 'package:dine_now/screens/profile/profile_screen.dart'; // Import profile screen
// Import tab screens
import 'tabs/manage_menu_tab.dart';
import 'tabs/manage_staff_tab.dart';
import 'tabs/manage_timings_tab.dart';
import 'tabs/restaurant_details_tab.dart';
import 'tabs/manage_bookings_tab.dart';
import 'tabs/orders_tab.dart'; // <-- Import the new Orders tab
import 'tabs/reports_tab.dart'; // <-- Import the new Reports tab
import 'tabs/dashboard_tab.dart'; // <-- Import the new Dashboard tab

// StateProvider to manage requested tab navigation from child tabs
final requestedTabIndexProvider = StateProvider<int?>((ref) => null);

class RestaurantManagementScreen extends StatefulWidget {
  final RestaurantModel restaurant;
  final String userRole; // Add userRole parameter

  const RestaurantManagementScreen({
    super.key,
    required this.restaurant,
    required this.userRole,
  });

  @override
  State<RestaurantManagementScreen> createState() =>
      _RestaurantManagementScreenState();
}

class _RestaurantManagementScreenState extends State<RestaurantManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Map<String, dynamic>> _visibleTabs;

  // Define ALL possible tabs
  static final List<Map<String, dynamic>> _allTabs = [
    {
      'id': 'dashboard',
      'icon': Icons.dashboard_outlined,
      'text': 'Dashboard',
      'widgetBuilder': (RestaurantModel r) => DashboardTab(restaurantId: r.id),
    },
    {
      'id': 'details',
      'icon': Icons.info_outline,
      'text': 'Details',
      'widgetBuilder':
          (RestaurantModel r) => RestaurantDetailsTab(restaurant: r),
    },
    {
      'id': 'timings',
      'icon': Icons.schedule,
      'text': 'Timings',
      'widgetBuilder':
          (RestaurantModel r) => ManageTimingsTab(restaurantId: r.id),
    },
    {
      'id': 'staff',
      'icon': Icons.group,
      'text': 'Staff',
      'widgetBuilder':
          (RestaurantModel r) => ManageStaffTab(restaurantId: r.id),
    },
    {
      'id': 'menu',
      'icon': Icons.menu_book,
      'text': 'Menu',
      'widgetBuilder': (RestaurantModel r) => ManageMenuTab(restaurantId: r.id),
    },
    {
      'id': 'bookings',
      'icon': Icons.book_online,
      'text': 'Bookings',
      'widgetBuilder':
          (RestaurantModel r) => ManageBookingsTab(restaurantId: r.id),
    },
    {
      'id': 'orders',
      'icon': Icons.receipt_long,
      'text': 'Orders',
      'widgetBuilder': (RestaurantModel r) => OrdersTab(restaurantId: r.id),
    },
    {
      'id': 'reports',
      'icon': Icons.bar_chart,
      'text': 'Reports',
      'widgetBuilder': (RestaurantModel r) => ReportsTab(restaurantId: r.id),
    },
  ];

  @override
  void initState() {
    super.initState();
    // Filter tabs based on user role
    if (widget.userRole == 'owner') {
      // Owner sees all tabs (Dashboard is first)
      _visibleTabs = _allTabs;
    } else if (widget.userRole == 'staff' || widget.userRole == 'chef') {
      // Staff/Chef see Menu, Bookings, and Orders ONLY (No Dashboard)
      _visibleTabs =
          _allTabs
              .where(
                (tab) =>
                    tab['id'] == 'menu' ||
                    tab['id'] == 'bookings' ||
                    tab['id'] == 'orders',
              )
              .toList();
    } else {
      _visibleTabs = []; // No tabs for other roles (or show error)
    }

    // Initialize TabController with the correct length
    _tabController = TabController(length: _visibleTabs.length, vsync: this);
    // No need to set initial index, defaults to 0 (Dashboard for owner)
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Handle case where no tabs are visible (e.g., unexpected role)
    if (_visibleTabs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.restaurant.name)),
        body: const Center(
          child: Text('You do not have permission to manage this section.'),
        ),
      );
    }

    // Use Consumer to access ref for logout/profile AND listen for tab changes
    return Consumer(
      builder: (context, ref, child) {
        // Listen to the requested tab index provider
        ref.listen<int?>(requestedTabIndexProvider, (previous, next) {
          if (next != null && next >= 0 && next < _tabController.length) {
            _tabController.animateTo(next);
            // Reset the provider state after handling navigation
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(requestedTabIndexProvider.notifier).state = null;
            });
          }
        });

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (
              BuildContext context,
              bool innerBoxIsScrolled,
            ) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 220.0,
                  floating: false,
                  pinned: true,
                  stretch: true,
                  title: Text(
                    widget.restaurant.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: colorScheme.primary,
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    // Profile Button (Only for owners)
                    if (widget.userRole == 'owner')
                      IconButton(
                        icon: const Icon(Icons.account_circle),
                        tooltip: 'My Profile',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                    // Conditional Logout Button (only for staff/chef on this screen)
                    if (widget.userRole == 'staff' || widget.userRole == 'chef')
                      IconButton(
                        icon: const Icon(Icons.logout),
                        tooltip: 'Logout',
                        onPressed:
                            () => ref.read(authServiceProvider).signOut(),
                      ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.zero,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.restaurant.imageUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) =>
                                  Container(color: Colors.grey[300]),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.restaurant,
                                  color: Colors.grey[600],
                                  size: 60,
                                ),
                              ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.7, 1.0],
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.2),
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 60.0,
                          left: 16.0,
                          right: 16.0,
                          child: Text(
                            widget.restaurant.name,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 6.0,
                                  color: Colors.black.withOpacity(0.7),
                                  offset: const Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    stretchModes: const [StretchMode.zoomBackground],
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    isScrollable: _visibleTabs.length > 4,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.8),
                    indicatorColor: colorScheme.secondary,
                    indicatorWeight: 3.0,
                    tabs:
                        _visibleTabs.map((tab) {
                          return Tab(
                            icon: Icon(tab['icon']),
                            text: tab['text'],
                          );
                        }).toList(),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children:
                  _visibleTabs.map<Widget>((tab) {
                    final builder =
                        tab['widgetBuilder']
                            as Widget Function(RestaurantModel);
                    return builder(widget.restaurant);
                  }).toList(),
            ),
          ),
        );
      },
    );
  }
}
