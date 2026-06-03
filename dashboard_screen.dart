import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/stat_card.dart';
import '../widgets/case_card.dart';
import '../widgets/session_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final casesAsync = ref.watch(casesProvider);
    final sessionsAsync = ref.watch(sessionsProvider);
    final templatesAsync = ref.watch(documentTemplatesProvider);

    final today = DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RefreshIndicator(
        color: AppColors.gold,
        backgroundColor: AppColors.cardBackground,
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(casesProvider);
          ref.invalidate(sessionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Welcome Card ──────────────────────────
              _WelcomeCard(today: today),
              SizedBox(height: 16.h),

              // ── Stats Cards ───────────────────────────
              statsAsync.when(
                loading: () => _StatsShimmer(),
                error: (_, __) => _StatsShimmer(),
                data: (stats) => Column(
                  children: [
                    StatCard(
                      icon: Icons.work_outline,
                      iconBg: AppColors.gold.withOpacity(0.15),
                      gradient: const LinearGradient(
                        colors: [AppColors.gold, AppColors.goldLight],
                      ),
                      title: 'القضايا المتداولة والنشطة',
                      value: stats.activeCases.toString(),
                      sub: 'من إجمالي ${stats.totalCases} قضية مسجلة',
                      linkLabel: 'عرض ملف القضايا',
                      onLinkTap: () => context.go('/cases'),
                    ),
                    SizedBox(height: 12.h),
                    StatCard(
                      icon: Icons.people_outline,
                      iconBg: AppColors.warning.withOpacity(0.15),
                      gradient: LinearGradient(
                        colors: [AppColors.warning, Colors.amber.shade300],
                      ),
                      title: 'الموكلون المقيدون',
                      value: stats.totalClients.toString(),
                      sub: 'أفراد ومؤسسات استثمارية',
                      linkLabel: 'إدارة الملاءة والموكلين',
                      onLinkTap: () => context.go('/clients'),
                    ),
                    SizedBox(height: 12.h),
                    StatCard(
                      icon: Icons.trending_up,
                      iconBg: AppColors.success.withOpacity(0.15),
                      gradient: const LinearGradient(
                        colors: [AppColors.success, Color(0xFF30D090)],
                      ),
                      title: 'الأتعاب المحصلة',
                      value: _formatMoney(stats.collectedFees),
                      sub: 'بنسبة تحصيل ${stats.collectionRate.toStringAsFixed(0)}%',
                      linkLabel: 'تقرير الفواتير',
                      onLinkTap: () => context.go('/invoices'),
                    ),
                    SizedBox(height: 12.h),
                    StatCard(
                      icon: Icons.attach_money,
                      iconBg: AppColors.danger.withOpacity(0.15),
                      gradient: const LinearGradient(
                        colors: [AppColors.danger, Color(0xFFFF6080)],
                      ),
                      title: 'المستحقات المعلقة',
                      value: _formatMoney(stats.pendingFees),
                      valueColor: AppColors.danger,
                      sub: 'مطالبات قيد الانتظار',
                      linkLabel: 'تحصيل الأتعاب المتأخرة',
                      onLinkTap: () => context.go('/invoices'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // ── Sessions Preview ──────────────────────
              sessionsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (sessions) {
                  final notifier = ref.read(sessionsProvider.notifier);
                  final upcoming = notifier.getUpcoming(sessions).take(3).toList();
                  if (upcoming.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: [
                      _SectionHeader(
                        icon: Icons.calendar_month_outlined,
                        title: 'أجندة الجلسات القضائية واللقاءات الوشيكة',
                        linkLabel: 'فتح الأجندة الكاملة',
                        onLinkTap: () => context.go('/sessions'),
                      ),
                      SizedBox(height: 10.h),
                      ...upcoming.map((s) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: SessionCard(session: s),
                      )),
                      SizedBox(height: 12.h),
                    ],
                  );
                },
              ),

              // ── Document Templates ────────────────────
              templatesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (templates) => Column(
                  children: [
                    _SectionHeader(
                      icon: Icons.description_outlined,
                      title: 'نماذج عقود جاهزة وصيغ توكيلات سريعة',
                      linkLabel: '',
                      onLinkTap: () {},
                    ),
                    SizedBox(height: 4.h),
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Text(
                        'قوالب صاغها مستشارو المكتب جاهزة للتخصيص الفوري والتحميل القانوني الداخلي.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    ...templates.map((doc) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: _DocumentTemplateItem(doc: doc),
                    )),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),

              // ── Recent Cases ──────────────────────────
              casesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (cases) {
                  final recent = cases.take(3).toList();
                  if (recent.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: [
                      _SectionHeader(
                        icon: Icons.work_outline,
                        title: 'أحدث القضايا المفتوحة',
                        linkLabel: 'كافة القضايا',
                        onLinkTap: () => context.go('/cases'),
                      ),
                      SizedBox(height: 10.h),
                      ...recent.map((c) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: CaseCard(caseModel: c),
                      )),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMoney(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}م';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}،٠٠٠';
    return amount.toStringAsFixed(0);
  }
}

// ── Welcome Card ─────────────────────────────────────────
class _WelcomeCard extends StatelessWidget {
  final String today;
  const _WelcomeCard({required this.today});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(18.w),
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(18.r),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('بوابة الإدارة الشاملة للمستشار القانوني',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 12.sp, fontFamily: 'Cairo')),
              SizedBox(width: 8.w),
              Container(width: 8.w, height: 8.w,
                decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        Text('أهلاً بك حضرة المستشار في\nمكتبك الاقتراضي الذكي',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 22.sp,
            fontWeight: FontWeight.w800, fontFamily: 'Cairo', height: 1.4),
          textAlign: TextAlign.right),
        SizedBox(height: 10.h),
        RichText(
          textAlign: TextAlign.right,
          text: TextSpan(
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp,
              fontFamily: 'Cairo', height: 1.7),
            children: [
              const TextSpan(text: 'تاريخ اليوم: '),
              TextSpan(text: today,
                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600)),
              const TextSpan(text: '. المنصة جاهزة لمراقبة شؤون القضايا وجدول الجلسات والمطالبات المالية لموكليك بكل دقة وموثوقية ممتدة.'),
            ],
          ),
        ),
      ],
    ),
  );
}

// ── Section Header ────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String linkLabel;
  final VoidCallback onLinkTap;

  const _SectionHeader({
    required this.icon, required this.title,
    required this.linkLabel, required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(18.r),
        topLeft: Radius.circular(18.r),
      ),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (linkLabel.isNotEmpty)
          GestureDetector(
            onTap: onLinkTap,
            child: Text(linkLabel,
              style: TextStyle(color: AppColors.gold, fontSize: 13.sp,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.gold, fontFamily: 'Cairo')),
          ),
        Row(
          children: [
            Text(title,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 15.sp,
                fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
            SizedBox(width: 8.w),
            Icon(icon, color: AppColors.gold, size: 20.sp),
          ],
        ),
      ],
    ),
  );
}

// ── Document Template Item ────────────────────────────────
class _DocumentTemplateItem extends StatelessWidget {
  final DocumentModel doc;
  const _DocumentTemplateItem({required this.doc});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Row(
      children: [
        Container(
          width: 42.w, height: 42.w,
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.description_outlined, color: AppColors.gold, size: 22.sp),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(doc.title,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp,
                fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
            if (doc.description != null)
              Text(doc.description!,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp, fontFamily: 'Cairo')),
          ],
        ),
      ],
    ),
  );
}

// ── Stats Shimmer ─────────────────────────────────────────
class _StatsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(4, (_) => Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18.r),
        ),
      ),
    )),
  );
}
