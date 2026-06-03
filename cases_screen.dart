import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/cards.dart';

// ════════════════════════════════════════
// CASES SCREEN
// ════════════════════════════════════════
class CasesScreen extends ConsumerStatefulWidget {
  const CasesScreen({super.key});
  @override
  ConsumerState<CasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends ConsumerState<CasesScreen> {
  String _filter = 'الكل';
  final _filters = ['الكل', 'مدني', 'عمالية', 'جنائي', 'تجاري', 'إداري'];

  @override
  Widget build(BuildContext context) {
    final casesAsync = ref.watch(casesProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          // ── Toolbar ────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.push('/cases/add'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('إضافة قضية'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    minimumSize: Size.zero,
                  ),
                ),
                Text('إدارة السجل القضائي',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp,
                    fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
              ],
            ),
          ),
          // ── Filters ────────────────────────────
          SizedBox(height: 12.h),
          SizedBox(
            height: 38.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _filters.length,
              itemBuilder: (_, i) {
                final f = _filters[i];
                final active = f == _filter;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    margin: EdgeInsets.only(left: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: active ? AppColors.gold : AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: active ? AppColors.gold : AppColors.cardBorder),
                    ),
                    child: Text(f,
                      style: TextStyle(
                        color: active ? Colors.black : AppColors.textSecondary,
                        fontSize: 13.sp, fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo')),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12.h),
          // ── List ───────────────────────────────
          Expanded(
            child: casesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(
                color: AppColors.gold)),
              error: (e, _) => _EmptyState(
                icon: Icons.error_outline,
                title: 'تعذّر تحميل القضايا',
                sub: 'تحقق من الاتصال بالإنترنت',
                onRetry: () => ref.invalidate(casesProvider),
              ),
              data: (cases) {
                final filtered = _filter == 'الكل'
                    ? cases
                    : cases.where((c) => c.type.contains(_filter)).toList();
                if (filtered.isEmpty) {
                  return _EmptyState(
                    icon: Icons.work_off_outlined,
                    title: 'لا توجد قضايا',
                    sub: 'اضغط "إضافة قضية" لإنشاء قضية جديدة',
                  );
                }
                return RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: () => ref.refresh(casesProvider.future),
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: CaseCard(caseModel: filtered[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════
// CASE DETAIL SCREEN
// ════════════════════════════════════════
class CaseDetailScreen extends ConsumerWidget {
  final String caseId;
  const CaseDetailScreen({super.key, required this.caseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casesAsync = ref.watch(casesProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('تفاصيل القضية'),
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pop(),
          ),
        ),
        body: casesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold)),
          error: (_, __) => const Center(
            child: Text('خطأ في تحميل البيانات',
              style: TextStyle(color: AppColors.textSecondary))),
          data: (cases) {
            final c = cases.where((x) => x.id == caseId).firstOrNull;
            if (c == null) {
              return const Center(
                child: Text('القضية غير موجودة',
                  style: TextStyle(color: AppColors.textSecondary)));
            }
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _DetailCard(children: [
                    _DetailRow(label: 'رقم القضية', value: c.caseNumber),
                    _DetailRow(label: 'السنة', value: c.year.toString()),
                    _DetailRow(label: 'المحكمة', value: c.court),
                    _DetailRow(label: 'النوع', value: c.type),
                    _DetailRow(label: 'الحالة',
                      value: c.status == 'active' ? 'نشطة' : 'مغلقة',
                      valueColor: c.status == 'active' ? AppColors.success : AppColors.danger),
                  ]),
                  SizedBox(height: 12.h),
                  _DetailCard(title: 'موضوع القضية', children: [
                    Text(c.title,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 15.sp,
                        fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
                  ]),
                  SizedBox(height: 12.h),
                  _DetailCard(title: 'بيانات الموكل', children: [
                    _DetailRow(label: 'الاسم', value: c.clientName),
                  ]),
                  if (c.nextSession != null) ...[
                    SizedBox(height: 12.h),
                    _DetailCard(title: 'الجلسة القادمة', children: [
                      _DetailRow(label: 'التاريخ',
                        value: c.nextSession!.toString().split(' ')[0]),
                    ]),
                  ],
                  if (c.notes != null && c.notes!.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _DetailCard(title: 'ملاحظات', children: [
                      Text(c.notes!,
                        style: TextStyle(color: AppColors.textSecondary,
                          fontSize: 13.sp, fontFamily: 'Cairo', height: 1.6)),
                    ]),
                  ],
                  SizedBox(height: 80.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const _DetailCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (title != null) ...[
          Text(title!,
            style: TextStyle(color: AppColors.gold, fontSize: 14.sp,
              fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          Divider(color: AppColors.cardBorder, height: 20.h),
        ],
        ...children,
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 14.sp, fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
        Text(label,
          style: TextStyle(color: AppColors.textSecondary,
            fontSize: 13.sp, fontFamily: 'Cairo')),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback? onRetry;

  const _EmptyState({
    required this.icon, required this.title,
    required this.sub, this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.textMuted, size: 60.sp),
        SizedBox(height: 16.h),
        Text(title,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp,
            fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
        SizedBox(height: 6.h),
        Text(sub,
          style: TextStyle(color: AppColors.textSecondary,
            fontSize: 13.sp, fontFamily: 'Cairo')),
        if (onRetry != null) ...[
          SizedBox(height: 20.h),
          ElevatedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ],
    ),
  );
}
