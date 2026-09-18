import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class NeuOtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  const NeuOtpInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<NeuOtpInput> createState() => NeuOtpInputState();
}

class NeuOtpInputState extends State<NeuOtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void clear() {
    for (var c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  void setOtp(String code) {
    if (code.length == widget.length) {
      for (int i = 0; i < widget.length; i++) {
        _controllers[i].text = code[i];
      }
      widget.onCompleted(code);
      setState(() {});
    }
  }

  String _getOtp() {
    return _controllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        final isFocused = _focusNodes[index].hasFocus;
        final hasValue = _controllers[index].text.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 48,
          height: 56,
          decoration: BoxDecoration(
            color: hasValue ? AppColors.surfaceLight : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isFocused
                  ? AppColors.primary
                  : (hasValue
                      ? AppColors.accent.withValues(alpha: 0.8)
                      : AppColors.divider),
              width: isFocused ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowDark.withValues(alpha: 0.9),
                offset: const Offset(3, 3),
                blurRadius: 5,
              ),
              BoxShadow(
                color: isFocused
                    ? AppColors.primary.withValues(alpha: 0.25)
                    : AppColors.shadowLight.withValues(alpha: 0.2),
                offset: const Offset(-2, -2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace &&
                    _controllers[index].text.isEmpty &&
                    index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
              },
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    if (index < widget.length - 1) {
                      _focusNodes[index + 1].requestFocus();
                    } else {
                      _focusNodes[index].unfocus();
                    }
                  } else {
                    if (index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                  }

                  final otp = _getOtp();
                  widget.onChanged?.call(otp);
                  if (otp.length == widget.length) {
                    widget.onCompleted(otp);
                  }
                  setState(() {});
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
