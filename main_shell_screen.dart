import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';

class MainShellScreen extends StatelessWidget {
  final Widget child;
  const MainShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context, location),
      body: child,
      bottomNavigationBar: _buildBottomNav(context, location),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    backgroundColor: AppColors.background,
    elevation: 0,
    toolbarHeight: 64,
    leading: Builder(
      builder: (ctx) => IconButton(
        icon: const Icon(Icons.menu, color: AppColors.textPrimary),
        onPressed: () => Scaffold.of(ctx).openDrawer(),
      ),
    ),
    title: const Column(children: [
      Text('مكتب المستشار القانوني المتكامل',
        style: TextStyle(color: AppColors.textPrimary, fontSize: 15,
          fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
      Text('بوابة الإدارة القضائية والتحكيم',
        style: TextStyle(color: AppColors.gold, fontSize: 11, fontFamily: 'Cairo')),
    ]),
    actions: [
      // ══ LOGO → أجندة الجلسات ══
      GestureDetector(
        onTap: () => context.go('/sessions'),
        child: Tooltip(
          message: 'أجندة الجلسات',
          child: Container(
            margin: const EdgeInsets.only(left: 12),
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(
                color: AppColors.gold.withOpacity(0.35),
                blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: const Icon(Icons.balance, color: Colors.black, size: 24),
          ),
        ),
      ),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(
        height: 1,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gold, AppColors.cardBorder, AppColors.cardBorder])),
      ),
    ),
  );

  Widget _buildDrawer(BuildContext context, String location) => Drawer(
    backgroundColor: AppColors.background,
    width: MediaQuery.of(context).size.width * 0.75,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))),
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.cardBorder))),
          child: Row(children: [
            GestureDetector(
              onTap: () { Navigator.of(context).pop(); context.go('/sessions'); },
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.balance, color: Colors.black, size: 24),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('مكتب المستشار القانوني',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 13,
                  fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
              Text('بوابة الإدارة القضائية',
                style: TextStyle(color: AppColors.gold, fontSize: 11, fontFamily: 'Cairo')),
            ])),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
              onPressed: () => Navigator.of(context).pop()),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 8, bottom: 8, top: 4),
                child: Text('لوحات الإدارة والتحليل',
                  style: TextStyle(color: AppColors.textMuted,
                    fontSize: 11, fontFamily: 'Cairo')),
              ),
              ..._navItems.map((item) => _DrawerItem(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                route: item['route'] as String,
                isActive: location == item['route'],
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(item['route'] as String);
                },
              )),
            ],
          ),
        ),
      ]),
    ),
  );

  Widget _buildBottomNav(BuildContext context, String location) => Container(
    decoration: const BoxDecoration(
      color: AppColors.cardBackground,
      border: Border(top: BorderSide(color: AppColors.cardBorder))),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _bottomNavItems.map((item) {
            final isActive = location == item['route'];
            return GestureDetector(
              onTap: () => context.go(item['route'] as String),
              behavior: HitTestBehavior.opaque,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(item['icon'] as IconData,
                  color: isActive ? AppColors.gold : AppColors.textMuted, size: 24),
                const SizedBox(height: 4),
                Text(item['label'] as String,
                  style: TextStyle(
                    color: isActive ? AppColors.gold : AppColors.textMuted,
                    fontSize: 10, fontFamily: 'Cairo')),
                if (isActive)
                  Container(margin: const EdgeInsets.only(top: 3),
                    width: 4, height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.gold, shape: BoxShape.circle)),
              ]),
            );
          }).toList(),
        ),
      ),
    ),
  );

  static const _navItems = [
    {'icon': Icons.dashboard_outlined, 'label': 'لوحة التحكم الرئيسية', 'route': '/dashboard'},
    {'icon': Icons.work_outline, 'label': 'إدارة السجل القضائي', 'route': '/cases'},
    {'icon': Icons.people_outline, 'label': 'الموكلين والعملاء', 'route': '/clients'},
    {'icon': Icons.calendar_month_outlined, 'label': 'الأجندة والجلسات', 'route': '/sessions'},
    {'icon': Icons.attach_money, 'label': 'الفواتير والمدفوعات', 'route': '/invoices'},
    {'icon': Icons.folder_outlined, 'label': 'الأرشيف والمستندات', 'route': '/documents'},
  ];

  static const _bottomNavItems = [
    {'icon': Icons.folder_outlined, 'label': 'المستندات', 'route': '/documents'},
    {'icon': Icons.attach_money, 'label': 'الفواتير', 'route': '/invoices'},
    {'icon': Icons.calendar_month_outlined, 'label': 'الجلسات', 'route': '/sessions'},
    {'icon': Icons.work_outline, 'label': 'القضايا', 'route': '/cases'},
    {'icon': Icons.dashboard_outlined, 'label': 'الرئيسية', 'route': '/dashboard'},
  ];
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final VoidCallback onTap;
  const _DrawerItem({required this.icon, required this.label,
    required this.route, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isActive ? AppColors.cardSurface : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isActive ? Border.all(color: AppColors.cardBorder) : null,
      ),
      child: Row(children: [
        Icon(icon,
          color: isActive ? AppColors.gold : AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label,
          style: TextStyle(
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 14, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            fontFamily: 'Cairo'))),
        if (isActive)
          Container(width: 4, height: 4,
            decoration: const BoxDecoration(
              color: AppColors.gold, shape: BoxShape.circle)),
      ]),
    ),
  );
}
