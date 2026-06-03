import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/cards.dart';

class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});
  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _typeFilter = 'الكل';
  final _types = ['الكل', 'جلسة محاكمة', 'استشارة عميل', 'اجتماع داخلي'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          // ── Header ─────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.push('/sessions/add'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('إضافة موعد'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    minimumSize: Size.zero,
                  ),
                ),
                Text('الأجندة والجلسات',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp,
                    fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
              ],
            ),
          ),

          // ── Status Tabs ────────────────────────
          SizedBox(height: 12.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.gold,
              indicatorWeight: 2,
              labelColor: AppColors.gold,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp,
                fontWeight: FontWeight.w700),
              unselectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp),
              tabs: const [
                Tab(text: 'الوشيكة'),
                Tab(text: 'المكتملة'),
                Tab(text: 'الكل'),
              ],
            ),
          ),

          // ── Type Filter ────────────────────────
          SizedBox(height: 10.h),
          SizedBox(
            height: 36.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _types.length,
              itemBuilder: (_, i) {
                final t = _types[i];
                final active = t == _typeFilter;
                return GestureDetector(
                  onTap: () => setState(() => _typeFilter = t),
                  child: Container(
                    margin: EdgeInsets.only(left: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: active ? AppColors.gold.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: active ? AppColors.gold : AppColors.cardBorder),
                    ),
                    child: Text(t,
                      style: TextStyle(
                        color: active ? AppColors.gold : AppColors.textSecondary,
                        fontSize: 12.sp, fontFamily: 'Cairo')),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10.h),

          // ── Content ────────────────────────────
          Expanded(
            child: sessionsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold)),
              error: (_, __) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                      color: AppColors.textMuted, size: 48.sp),
                    SizedBox(height: 12.h),
                    Text('تعذّر التحميل',
                      style: TextStyle(color: AppColors.textSecondary,
                        fontSize: 14.sp, fontFamily: 'Cairo')),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(sessionsProvider),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
              data: (sessions) {
                final now = DateTime.now();
                final upcoming = sessions.where((s) =>
                  s.sessionDate.isAfter(now) && s.status == 'upcoming').toList()
                  ..sort((a, b) => a.sessionDate.compareTo(b.sessionDate));
                final completed = sessions.where((s) =>
                  s.status == 'completed' || s.sessionDate.isBefore(now)).toList()
                  ..sort((a, b) => b.sessionDate.compareTo(a.sessionDate));

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _SessionList(sessions: _applyTypeFilter(upcoming), isUpcoming: true),
                    _SessionList(sessions: _applyTypeFilter(completed)),
                    _SessionList(sessions: _applyTypeFilter(sessions)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<SessionModel> _applyTypeFilter(List<SessionModel> list) {
    if (_typeFilter == 'الكل') return list;
    return list.where((s) => s.type == _typeFilter).toList();
  }
}

class _SessionList extends StatelessWidget {
  final List<SessionModel> sessions;
  final bool isUpcoming;

  const _SessionList({required this.sessions, this.isUpcoming = false});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, color: AppColors.textMuted, size: 60.sp),
            SizedBox(height: 12.h),
            Text('لا توجد جلسات',
              style: TextStyle(color: AppColors.textSecondary,
                fontSize: 14.sp, fontFamily: 'Cairo')),
          ],
        ),
      );
    }

    // Group by date
    final grouped = <String, List<SessionModel>>{};
    for (final s in sessions) {
      final key = '${s.sessionDate.year}-${s.sessionDate.month}-${s.sessionDate.day}';
      grouped.putIfAbsent(key, () => []).add(s);
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
      children: grouped.entries.map((entry) {
        final date = entry.value.first.sessionDate;
        final months = ['', 'يناير', 'فبراير', 'مارس', 'إبريل', 'مايو', 'يونيو',
          'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
        final label = '${date.day} ${months[date.month]} ${date.year}';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(label,
                    style: TextStyle(color: AppColors.gold, fontSize: 13.sp,
                      fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                  SizedBox(width: 8.w),
                  Icon(Icons.calendar_today, color: AppColors.gold, size: 14.sp),
                ],
              ),
            ),
            ...entry.value.map((s) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: SessionCard(session: s),
            )),
          ],
        );
      }).toList(),
    );
  }
}
