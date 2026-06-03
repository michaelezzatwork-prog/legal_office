// ════════════════════════════════════════
// clients_screen.dart
// ════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.push('/clients/add'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('إضافة موكل'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    minimumSize: Size.zero,
                  ),
                ),
                Text('الموكلين والعملاء',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp,
                    fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
              ],
            ),
          ),
          Expanded(
            child: clientsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold)),
              error: (_, __) => const Center(
                child: Text('تعذّر التحميل',
                  style: TextStyle(color: AppColors.textSecondary))),
              data: (clients) {
                if (clients.isEmpty) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.people_outline,
                        color: AppColors.textMuted, size: 60.sp),
                      SizedBox(height: 12.h),
                      Text('لا يوجد موكلون مسجلون',
                        style: TextStyle(color: AppColors.textSecondary,
                          fontSize: 14.sp, fontFamily: 'Cairo')),
                    ]),
                  );
                }
                return RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: () => ref.refresh(clientsProvider.future),
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                    itemCount: clients.length,
                    itemBuilder: (_, i) => _ClientCard(client: clients[i]),
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

class _ClientCard extends StatelessWidget {
  final ClientModel client;
  const _ClientCard({required this.client});

  String get _typeLabel {
    switch (client.type) {
      case 'company': return 'شركة';
      case 'group': return 'مجموعة';
      default: return 'فرد';
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 10.h),
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatusBadge(
              label: client.status == 'active' ? 'نشط' : 'غير نشط',
              color: client.status == 'active' ? AppColors.success : AppColors.textMuted,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(client.name,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 15.sp,
                    fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                Text(_typeLabel,
                  style: TextStyle(color: AppColors.textSecondary,
                    fontSize: 12.sp, fontFamily: 'Cairo')),
              ],
            ),
            Container(
              width: 44.w, height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.person_outline, color: AppColors.gold, size: 22.sp),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Divider(color: AppColors.cardBorder, height: 1.h),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (client.phone != null)
              Row(children: [
                Icon(Icons.phone_outlined, color: AppColors.textMuted, size: 14.sp),
                SizedBox(width: 4.w),
                Text(client.phone!,
                  style: TextStyle(color: AppColors.textSecondary,
                    fontSize: 12.sp, fontFamily: 'Cairo')),
              ]),
            if (client.email != null)
              Text(client.email!,
                style: TextStyle(color: AppColors.gold,
                  fontSize: 12.sp, fontFamily: 'Cairo')),
          ],
        ),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(label,
      style: TextStyle(color: color, fontSize: 11.sp,
        fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
  );
}

// ════════════════════════════════════════
// invoices_screen.dart
// ════════════════════════════════════════
class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.push('/invoices/add'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('إنشاء فاتورة'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    minimumSize: Size.zero,
                  ),
                ),
                Text('الفواتير والمدفوعات',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp,
                    fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
              ],
            ),
          ),
          Expanded(
            child: invoicesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold)),
              error: (_, __) => const Center(
                child: Text('تعذّر التحميل',
                  style: TextStyle(color: AppColors.textSecondary))),
              data: (invoices) {
                final notifier = ref.read(invoicesProvider.notifier);
                final collected = notifier.getTotalCollected(invoices);
                final pending = notifier.getTotalPending(invoices);
                final total = collected + pending;

                return RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: () => ref.refresh(invoicesProvider.future),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                    children: [
                      // Summary Cards
                      Row(children: [
                        Expanded(child: _SummaryMini(
                          label: 'محصل',
                          value: '${(collected / 1000).toStringAsFixed(0)}،٠٠٠',
                          color: AppColors.success)),
                        SizedBox(width: 8.w),
                        Expanded(child: _SummaryMini(
                          label: 'معلق',
                          value: '${(pending / 1000).toStringAsFixed(0)}،٠٠٠',
                          color: AppColors.danger)),
                        SizedBox(width: 8.w),
                        Expanded(child: _SummaryMini(
                          label: 'الإجمالي',
                          value: '${(total / 1000).toStringAsFixed(0)}،٠٠٠',
                          color: AppColors.gold)),
                      ]),
                      SizedBox(height: 16.h),
                      // Progress bar
                      _CollectionBar(rate: total > 0 ? collected / total : 0),
                      SizedBox(height: 16.h),
                      // Invoices list
                      ...invoices.map((inv) => _InvoiceCard(invoice: inv)),
                    ],
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

class _SummaryMini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryMini({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Text(value,
          style: TextStyle(color: color, fontSize: 15.sp,
            fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
        Text('ج.م',
          style: TextStyle(color: color.withOpacity(0.7),
            fontSize: 10.sp, fontFamily: 'Cairo')),
        SizedBox(height: 2.h),
        Text(label,
          style: TextStyle(color: AppColors.textSecondary,
            fontSize: 11.sp, fontFamily: 'Cairo')),
      ],
    ),
  );
}

class _CollectionBar extends StatelessWidget {
  final double rate;
  const _CollectionBar({required this.rate});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${(rate * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: AppColors.success, fontSize: 14.sp,
                fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
            Text('نسبة التحصيل',
              style: TextStyle(color: AppColors.textSecondary,
                fontSize: 13.sp, fontFamily: 'Cairo')),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: rate.clamp(0.0, 1.0),
            backgroundColor: AppColors.cardBorder,
            valueColor: const AlwaysStoppedAnimation(AppColors.success),
            minHeight: 8.h,
          ),
        ),
      ],
    ),
  );
}

class _InvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;
  const _InvoiceCard({required this.invoice});

  Color get _statusColor {
    switch (invoice.status) {
      case 'paid': return AppColors.success;
      case 'partial': return AppColors.warning;
      case 'cancelled': return AppColors.textMuted;
      default: return AppColors.danger;
    }
  }

  String get _statusLabel {
    switch (invoice.status) {
      case 'paid': return 'محصل';
      case 'partial': return 'جزئي';
      case 'cancelled': return 'ملغي';
      default: return 'معلق';
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 10.h),
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatusBadge(label: _statusLabel, color: _statusColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(invoice.invoiceNumber,
                  style: TextStyle(color: AppColors.textMuted,
                    fontSize: 11.sp, fontFamily: 'Cairo')),
                Text(invoice.clientName,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp,
                    fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
              ],
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (invoice.dueDate != null)
              Text(invoice.dueDate!.toString().split(' ')[0],
                style: TextStyle(color: AppColors.textSecondary,
                  fontSize: 12.sp, fontFamily: 'Cairo')),
            Text('${invoice.amount.toStringAsFixed(0)} ج.م',
              style: TextStyle(color: AppColors.gold, fontSize: 16.sp,
                fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
          ],
        ),
        if (invoice.status == 'partial') ...[
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(3.r),
            child: LinearProgressIndicator(
              value: invoice.collectionRate / 100,
              backgroundColor: AppColors.cardBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.warning),
              minHeight: 5.h,
            ),
          ),
        ],
      ],
    ),
  );
}

// ════════════════════════════════════════
// documents_screen.dart
// ════════════════════════════════════════
class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_outlined, size: 18),
                  label: const Text('رفع مستند'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    minimumSize: Size.zero,
                  ),
                ),
                Text('الأرشيف والمستندات',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp,
                    fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
              ],
            ),
          ),
          Expanded(
            child: docsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold)),
              error: (_, __) => const Center(
                child: Text('تعذّر التحميل',
                  style: TextStyle(color: AppColors.textSecondary))),
              data: (docs) {
                if (docs.isEmpty) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.folder_open_outlined,
                        color: AppColors.textMuted, size: 60.sp),
                      SizedBox(height: 12.h),
                      Text('الأرشيف فارغ',
                        style: TextStyle(color: AppColors.textSecondary,
                          fontSize: 14.sp, fontFamily: 'Cairo')),
                    ]),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                  itemCount: docs.length,
                  itemBuilder: (_, i) => _DocCard(doc: docs[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  final DocumentModel doc;
  const _DocCard({required this.doc});

  IconData get _icon {
    switch (doc.type) {
      case 'نموذج': return Icons.description_outlined;
      case 'مذكرة': return Icons.edit_note;
      case 'تقرير': return Icons.analytics_outlined;
      case 'عقد': return Icons.handshake_outlined;
      case 'توكيل': return Icons.assignment_outlined;
      default: return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 10.h),
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.gold.withOpacity(0.4)),
          ),
          child: Text(doc.type,
            style: TextStyle(color: AppColors.gold, fontSize: 11.sp,
              fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
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
                style: TextStyle(color: AppColors.textSecondary,
                  fontSize: 12.sp, fontFamily: 'Cairo')),
          ],
        ),
        SizedBox(width: 12.w),
        Container(
          width: 42.w, height: 42.w,
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(_icon, color: AppColors.gold, size: 22.sp),
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════
// ADD CASE SCREEN
// ════════════════════════════════════════
class AddCaseScreen extends ConsumerStatefulWidget {
  const AddCaseScreen({super.key});
  @override
  ConsumerState<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends ConsumerState<AddCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caseNumberCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(text: DateTime.now().year.toString());
  final _courtCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _clientNameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _type = 'مدني';
  bool _loading = false;

  final _types = ['مدني', 'عمالية', 'جنائي', 'تجاري', 'إداري'];

  @override
  void dispose() {
    _caseNumberCtrl.dispose(); _yearCtrl.dispose(); _courtCtrl.dispose();
    _titleCtrl.dispose(); _clientNameCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(casesProvider.notifier).addCase({
        'caseNumber': _caseNumberCtrl.text.trim(),
        'year': int.parse(_yearCtrl.text.trim()),
        'court': _courtCtrl.text.trim(),
        'title': _titleCtrl.text.trim(),
        'type': _type,
        'clientName': _clientNameCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة القضية بنجاح ✓'),
            backgroundColor: AppColors.success));
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'),
          backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إضافة قضية جديدة'),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? SizedBox(width: 20.w, height: 20.w,
                    child: const CircularProgressIndicator(
                      color: AppColors.gold, strokeWidth: 2))
                : Text('حفظ',
                    style: TextStyle(color: AppColors.gold, fontSize: 16.sp,
                      fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _FormField(ctrl: _caseNumberCtrl, label: 'رقم القضية',
                hint: 'مثال: ٤٥٦٢', icon: Icons.numbers,
                validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              SizedBox(height: 12.h),
              Row(children: [
                Expanded(child: _FormField(ctrl: _yearCtrl, label: 'السنة',
                  hint: '2026', icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'مطلوب' : null)),
                SizedBox(width: 12.w),
                Expanded(child: _DropdownField(
                  label: 'نوع القضية',
                  value: _type,
                  items: _types,
                  onChanged: (v) => setState(() => _type = v!),
                )),
              ]),
              SizedBox(height: 12.h),
              _FormField(ctrl: _courtCtrl, label: 'المحكمة',
                hint: 'مثال: كلي شمال القاهرة', icon: Icons.account_balance,
                validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              SizedBox(height: 12.h),
              _FormField(ctrl: _titleCtrl, label: 'موضوع القضية',
                hint: 'أدخل وصفاً مختصراً للقضية', icon: Icons.subject,
                maxLines: 2, validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              SizedBox(height: 12.h),
              _FormField(ctrl: _clientNameCtrl, label: 'اسم الموكل',
                hint: 'الاسم الكامل للموكل', icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              SizedBox(height: 12.h),
              _FormField(ctrl: _notesCtrl, label: 'ملاحظات',
                hint: 'ملاحظات إضافية (اختياري)', icon: Icons.notes,
                maxLines: 3),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('حفظ القضية'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ════════════════════════════════════════
// ADD SESSION SCREEN
// ════════════════════════════════════════
class AddSessionScreen extends ConsumerStatefulWidget {
  const AddSessionScreen({super.key});
  @override
  ConsumerState<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends ConsumerState<AddSessionScreen> {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _clientCtrl = TextEditingController();
  String _type = 'جلسة محاكمة';
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  bool _loading = false;

  final _types = ['جلسة محاكمة', 'استشارة عميل', 'اجتماع داخلي'];

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context, initialDate: _date,
      firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.gold,
            onPrimary: Colors.black, surface: AppColors.cardBackground)),
        child: child!));
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context, initialTime: _time,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.gold,
            onPrimary: Colors.black, surface: AppColors.cardBackground)),
        child: child!));
    if (t != null) setState(() => _time = t);
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      final dt = DateTime(_date.year, _date.month, _date.day);
      await ref.read(sessionsProvider.notifier).addSession({
        'type': _type,
        'title': _titleCtrl.text.trim(),
        'clientName': _clientCtrl.text.trim(),
        'sessionDate': dt.toIso8601String(),
        'startTime': _time.format(context),
        'location': _locationCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة الموعد بنجاح ✓'),
            backgroundColor: AppColors.success));
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'),
          backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إضافة موعد'),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close), onPressed: () => context.pop()),
        actions: [
          TextButton(
            onPressed: _loading ? null : _submit,
            child: Text('حفظ',
              style: TextStyle(color: AppColors.gold, fontSize: 16.sp,
                fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(children: [
          _DropdownField(label: 'نوع الموعد', value: _type,
            items: _types, onChanged: (v) => setState(() => _type = v!)),
          SizedBox(height: 12.h),
          _FormField(ctrl: _titleCtrl, label: 'عنوان الموعد',
            hint: 'وصف مختصر للموعد', icon: Icons.title, maxLines: 2),
          SizedBox(height: 12.h),
          _FormField(ctrl: _clientCtrl, label: 'اسم العميل',
            hint: 'اسم الموكل أو العميل', icon: Icons.person_outline),
          SizedBox(height: 12.h),
          Row(children: [
            Expanded(child: _TapField(
              label: 'التاريخ',
              value: '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
              icon: Icons.calendar_today,
              onTap: _pickDate,
            )),
            SizedBox(width: 12.w),
            Expanded(child: _TapField(
              label: 'الوقت',
              value: _time.format(context),
              icon: Icons.access_time,
              onTap: _pickTime,
            )),
          ]),
          SizedBox(height: 12.h),
          _FormField(ctrl: _locationCtrl, label: 'المكان',
            hint: 'مثال: محكمة شمال القاهرة', icon: Icons.location_on_outlined),
          SizedBox(height: 12.h),
          _FormField(ctrl: _notesCtrl, label: 'ملاحظات',
            hint: 'تفاصيل إضافية', icon: Icons.notes, maxLines: 3),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: const Text('حفظ الموعد'),
          ),
        ]),
      ),
    ),
  );

  @override
  void dispose() {
    _titleCtrl.dispose(); _locationCtrl.dispose();
    _notesCtrl.dispose(); _clientCtrl.dispose();
    super.dispose();
  }
}

// ════════════════════════════════════════
// ADD CLIENT SCREEN
// ════════════════════════════════════════
class AddClientScreen extends ConsumerStatefulWidget {
  const AddClientScreen({super.key});
  @override
  ConsumerState<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends ConsumerState<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _type = 'individual';
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(clientsProvider.notifier).addClient({
        'name': _nameCtrl.text.trim(),
        'type': _type,
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'nationalId': _idCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة الموكل بنجاح ✓'),
            backgroundColor: AppColors.success));
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إضافة موكل'),
        backgroundColor: AppColors.background,
        leading: IconButton(icon: const Icon(Icons.close),
          onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(children: [
            _DropdownField(label: 'نوع الموكل', value: _type,
              items: ['individual', 'company', 'group'],
              labels: ['فرد', 'شركة', 'مجموعة'],
              onChanged: (v) => setState(() => _type = v!)),
            SizedBox(height: 12.h),
            _FormField(ctrl: _nameCtrl, label: 'الاسم الكامل',
              hint: 'اسم الموكل أو الشركة', icon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? 'مطلوب' : null),
            SizedBox(height: 12.h),
            _FormField(ctrl: _phoneCtrl, label: 'رقم الهاتف',
              hint: '01xxxxxxxxx', icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone),
            SizedBox(height: 12.h),
            _FormField(ctrl: _emailCtrl, label: 'البريد الإلكتروني',
              hint: 'example@email.com', icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress),
            SizedBox(height: 12.h),
            _FormField(ctrl: _idCtrl, label: 'الرقم القومي / رقم السجل',
              hint: 'اختياري', icon: Icons.badge_outlined),
            SizedBox(height: 12.h),
            _FormField(ctrl: _addressCtrl, label: 'العنوان',
              hint: 'العنوان التفصيلي', icon: Icons.location_on_outlined,
              maxLines: 2),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: const Text('حفظ الموكل'),
            ),
          ]),
        ),
      ),
    ),
  );

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose();
    _idCtrl.dispose(); _addressCtrl.dispose();
    super.dispose();
  }
}

// ════════════════════════════════════════
// ADD INVOICE SCREEN
// ════════════════════════════════════════
class AddInvoiceScreen extends ConsumerStatefulWidget {
  const AddInvoiceScreen({super.key});
  @override
  ConsumerState<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends ConsumerState<AddInvoiceScreen> {
  final _clientCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _dueDate;
  bool _loading = false;

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context, initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.gold,
            onPrimary: Colors.black, surface: AppColors.cardBackground)),
        child: child!));
    if (d != null) setState(() => _dueDate = d);
  }

  Future<void> _submit() async {
    if (_clientCtrl.text.isEmpty || _amountCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(invoicesProvider.notifier).addInvoice({
        'clientName': _clientCtrl.text.trim(),
        'amount': double.parse(_amountCtrl.text.trim()),
        'dueDate': _dueDate?.toIso8601String(),
        'notes': _notesCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء الفاتورة بنجاح ✓'),
            backgroundColor: AppColors.success));
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إنشاء فاتورة'),
        backgroundColor: AppColors.background,
        leading: IconButton(icon: const Icon(Icons.close),
          onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(children: [
          _FormField(ctrl: _clientCtrl, label: 'اسم الموكل',
            hint: 'اختر أو أدخل اسم الموكل', icon: Icons.person_outline),
          SizedBox(height: 12.h),
          _FormField(ctrl: _amountCtrl, label: 'المبلغ (ج.م)',
            hint: '0.00', icon: Icons.attach_money,
            keyboardType: TextInputType.number),
          SizedBox(height: 12.h),
          _TapField(
            label: 'تاريخ الاستحقاق',
            value: _dueDate != null
                ? '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'
                : 'اختر تاريخاً',
            icon: Icons.calendar_today,
            onTap: _pickDate,
          ),
          SizedBox(height: 12.h),
          _FormField(ctrl: _notesCtrl, label: 'ملاحظات',
            hint: 'تفاصيل الأتعاب', icon: Icons.notes, maxLines: 3),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: const Text('إنشاء الفاتورة'),
          ),
        ]),
      ),
    ),
  );

  @override
  void dispose() {
    _clientCtrl.dispose(); _amountCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }
}

// ════════════════════════════════════════
// SHARED FORM WIDGETS
// ════════════════════════════════════════
class _FormField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final IconData icon;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.ctrl, required this.label, required this.hint,
    required this.icon, this.maxLines, this.keyboardType, this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    maxLines: maxLines ?? 1,
    keyboardType: keyboardType,
    textAlign: TextAlign.right,
    validator: validator,
    style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo', fontSize: 14.sp),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20.sp),
    ),
  );
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final List<String>? labels;
  final void Function(String?) onChanged;

  const _DropdownField({
    required this.label, required this.value,
    required this.items, this.labels, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: value,
    onChanged: onChanged,
    isExpanded: true,
    dropdownColor: AppColors.cardBackground,
    style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo', fontSize: 14.sp),
    decoration: InputDecoration(labelText: label),
    items: items.asMap().entries.map((e) => DropdownMenuItem(
      value: e.value,
      child: Text(labels != null ? labels![e.key] : e.value,
        style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo', fontSize: 14.sp),
        textAlign: TextAlign.right),
    )).toList(),
  );
}

class _TapField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _TapField({
    required this.label, required this.value,
    required this.icon, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(label,
              style: TextStyle(color: AppColors.textSecondary,
                fontSize: 12.sp, fontFamily: 'Cairo')),
          ),
          Text(value,
            style: TextStyle(color: AppColors.textPrimary,
              fontSize: 13.sp, fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}
