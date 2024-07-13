import 'package:flutter/material.dart';
import 'package:phone_mart/activity/order_activity.dart';
import 'package:phone_mart/style/font_style.dart';

class OrderTabbar extends StatefulWidget {
  const OrderTabbar({super.key});

  @override
  State<OrderTabbar> createState() => _OrderTabbarState();
}

class _OrderTabbarState extends State<OrderTabbar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Widget> tabs = [
    const OrderActivity(isSeller: false),
    const OrderActivity(isSeller: true),
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Order Saya'),
                Tab(text: 'Order Masuk'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: tabs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
