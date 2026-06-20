import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// An iOS-style slide-to-confirm control. Slides right to trigger [onConfirm].
/// When [confirmed] is true it locks in the done state.
class SlideToAction extends StatefulWidget {
  final bool confirmed;
  final String idleLabel;
  final String doneLabel;
  final Future<void> Function() onConfirm;

  const SlideToAction({
    super.key,
    required this.confirmed,
    required this.idleLabel,
    required this.doneLabel,
    required this.onConfirm,
  });

  @override
  State<SlideToAction> createState() => _SlideToActionState();
}

class _SlideToActionState extends State<SlideToAction>
    with SingleTickerProviderStateMixin {
  double _pos = 0;
  bool _done = false;
  bool _busy = false;
  late final AnimationController _snap;
  Animation<double> _snapAnim = const AlwaysStoppedAnimation(0);

  static const double _thumb = 56;

  @override
  void initState() {
    super.initState();
    _done = widget.confirmed;
    _snap = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _snap.addListener(() {
      if (!_done && mounted) setState(() => _pos = _snapAnim.value);
    });
  }

  @override
  void didUpdateWidget(covariant SlideToAction old) {
    super.didUpdateWidget(old);
    if (widget.confirmed && !_done) {
      setState(() => _done = true);
    }
  }

  @override
  void dispose() {
    _snap.dispose();
    super.dispose();
  }

  void _update(DragUpdateDetails d, double max) {
    if (_done || _busy) return;
    setState(() => _pos = (_pos + d.delta.dx).clamp(0.0, max));
  }

  Future<void> _end(double max) async {
    if (_done || _busy) return;
    if (_pos >= max * 0.75) {
      setState(() {
        _pos = max;
        _busy = true;
      });
      await widget.onConfirm();
      if (mounted) setState(() => _busy = false);
    } else {
      _snapAnim = Tween<double>(begin: _pos, end: 0)
          .animate(CurvedAnimation(parent: _snap, curve: Curves.easeOut));
      _snap.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final max = constraints.maxWidth - _thumb - 8;
        final progress = max > 0 ? (_pos / max).clamp(0.0, 1.0) : 0.0;

        return Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              colors: _done
                  ? [const Color(0xFF15803D), AppColors.success]
                  : [AppColors.primaryDark, AppColors.primary],
            ),
            boxShadow: [
              BoxShadow(
                color: (_done ? AppColors.success : AppColors.primary)
                    .withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned.fill(
                child: Center(
                  child: Opacity(
                    opacity: _done ? 1 : (1 - progress * 0.5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 40),
                        Text(
                          _done ? widget.doneLabel : widget.idleLabel,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!_done) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.keyboard_double_arrow_right_rounded,
                              color: Colors.white70, size: 20),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _done ? max : _pos + 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) => _update(d, max),
                  onHorizontalDragEnd: (_) => _end(max),
                  child: Container(
                    width: _thumb,
                    height: _thumb,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: _busy
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: AppColors.primary),
                          )
                        : Icon(
                            _done
                                ? Icons.check_rounded
                                : Icons.chevron_right_rounded,
                            color:
                                _done ? AppColors.success : AppColors.primary,
                            size: 28,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
