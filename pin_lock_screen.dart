import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../core/security/security_service.dart';
import '../core/theme/app_theme.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _isSettingPin = false;
  String _confirmPin = '';
  bool _confirmStep = false;
  bool _error = false;
  int _attempts = 0;
  bool _biometricAvailable = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).chain(
      CurveTween(curve: Curves.elasticIn),
    ).animate(_shakeController);

    _init();
  }

  Future<void> _init() async {
    final hasPin = await SecurityService.instance.hasPinSet();
    final biometric = await SecurityService.instance.isBiometricAvailable();
    final biometricEnabled = await SecurityService.instance.isBiometricEnabled();
    setState(() {
      _isSettingPin = !hasPin;
      _biometricAvailable = biometric && biometricEnabled;
    });

    if (biometric && biometricEnabled && hasPin) {
      await _tryBiometric();
    }
  }

  Future<void> _tryBiometric() async {
    final success = await SecurityService.instance.authenticateWithBiometrics();
    if (success && mounted) {
      _navigateToDashboard();
    }
  }

  void _onKeyPress(String key) {
    if (_pin.length >= 4) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pin += key;
      _error = false;
    });

    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 150), _processPin);
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _processPin() async {
    if (_isSettingPin) {
      if (!_confirmStep) {
        setState(() {
          _confirmPin = _pin;
          _pin = '';
          _confirmStep = true;
        });
      } else {
        if (_pin == _confirmPin) {
          await SecurityService.instance.savePin(_pin);
          if (mounted) _navigateToDashboard();
        } else {
          _showError();
          setState(() {
            _pin = '';
            _confirmStep = false;
            _confirmPin = '';
          });
        }
      }
    } else {
      final correct = await SecurityService.instance.verifyPin(_pin);
      if (correct) {
        await SecurityService.instance.saveSessionToken('session_${DateTime.now().millisecondsSinceEpoch}');
        if (mounted) _navigateToDashboard();
      } else {
        _attempts++;
        _showError();
        setState(() => _pin = '');
        if (_attempts >= 5) {
          // Lock for 30 seconds after 5 wrong attempts
          await Future.delayed(const Duration(seconds: 30));
          _attempts = 0;
        }
      }
    }
  }

  void _showError() {
    HapticFeedback.heavyImpact();
    setState(() => _error = true);
    _shakeController.forward(from: 0);
  }

  void _navigateToDashboard() => context.go('/dashboard');

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              const Spacer(),
              // Logo
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(Icons.balance, color: Colors.black, size: 42.sp),
              ),
              SizedBox(height: 20.h),
              Text(
                'مكتب المستشار القانوني',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Cairo',
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _isSettingPin
                    ? (_confirmStep ? 'أعد إدخال الرمز للتأكيد' : 'أنشئ رمز دخول مكون من 4 أرقام')
                    : 'أدخل رمز الدخول للمتابعة',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  fontFamily: 'Cairo',
                ),
              ),
              SizedBox(height: 48.h),

              // PIN dots
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(_shakeAnimation.value * (_shakeController.value < 0.5 ? 1 : -1), 0),
                  child: child,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.w),
                    width: 18.w,
                    height: 18.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _pin.length
                          ? (_error ? AppColors.danger : AppColors.gold)
                          : Colors.transparent,
                      border: Border.all(
                        color: _error ? AppColors.danger : AppColors.cardBorder,
                        width: 2,
                      ),
                    ),
                  )),
                ),
              ),

              if (_error)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Text(
                    'الرمز غير صحيح، حاول مرة أخرى',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 13.sp,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),

              const Spacer(),

              // Keypad
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 48.w),
                child: Column(
                  children: [
                    ...['123', '456', '789'].map((row) => Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: row.split('').map((k) => _KeyButton(
                          label: k,
                          onTap: () => _onKeyPress(k),
                        )).toList(),
                      ),
                    )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _biometricAvailable
                            ? _KeyButton(
                                icon: Icons.fingerprint,
                                onTap: _tryBiometric,
                                secondary: true,
                              )
                            : const SizedBox(width: 80),
                        _KeyButton(label: '0', onTap: () => _onKeyPress('0')),
                        _KeyButton(
                          icon: Icons.backspace_outlined,
                          onTap: _onDelete,
                          secondary: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool secondary;

  const _KeyButton({
    this.label,
    this.icon,
    required this.onTap,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75.w,
        height: 75.w,
        decoration: BoxDecoration(
          color: secondary ? Colors.transparent : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: secondary ? Colors.transparent : AppColors.cardBorder,
          ),
        ),
        child: Center(
          child: label != null
              ? Text(
                  label!,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                )
              : Icon(icon, color: AppColors.textSecondary, size: 26.sp),
        ),
      ),
    );
  }
}
