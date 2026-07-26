import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

Widget _buildStyledAmountHint({
  required String hint,
  required String symbol,
  required bool isSuffix,
  required TextStyle amountStyle,
  required TextStyle currencyStyle,
}) {
  final spans = isSuffix
      ? <InlineSpan>[
          TextSpan(text: hint, style: amountStyle),
          TextSpan(text: '\u202F', style: currencyStyle),
          TextSpan(text: symbol, style: currencyStyle),
        ]
      : <InlineSpan>[
          TextSpan(text: symbol, style: currencyStyle),
          TextSpan(text: hint, style: amountStyle),
        ];

  return Text.rich(
    TextSpan(children: spans),
    textAlign: TextAlign.center,
    overflow: TextOverflow.visible,
  );
}

class _CurrencyAmountInputFormatter extends TextInputFormatter {
  _CurrencyAmountInputFormatter({
    required this.symbol,
    required this.isSuffix,
  });

  final String symbol;
  final bool isSuffix;
  final NumberFormat _groupFormatter = NumberFormat.decimalPattern('en_US');

  String _clean(String input) {
    var cleaned = input
        .replaceAll('\u00A0', '')
        .replaceAll('\u202F', '')
        .replaceAll(' ', '')
        .replaceAll(',', '')
        .replaceAll(symbol, '');
    cleaned = cleaned.replaceAll(RegExp(r'[^0-9.]'), '');

    final firstDot = cleaned.indexOf('.');
    if (firstDot != -1) {
      final before = cleaned.substring(0, firstDot);
      final fraction = cleaned.substring(firstDot + 1).replaceAll('.', '');
      final after = fraction.length > 2 ? fraction.substring(0, 2) : fraction;
      cleaned = '$before.$after';
    }

    if (cleaned.startsWith('.')) {
      cleaned = '0$cleaned';
    }

    return cleaned;
  }

  String _formatNumeric(String cleaned) {
    if (cleaned.isEmpty) return '';

    final hasDot = cleaned.contains('.');
    final trailingDot = hasDot && cleaned.endsWith('.');
    final parts = cleaned.split('.');
    var intPart = parts.first;
    final decimalPart = hasDot && parts.length > 1 ? parts[1] : '';

    intPart = intPart.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (intPart.isEmpty) intPart = '0';

    if (intPart.length > 15) {
      intPart = intPart.substring(0, 15);
    }

    final grouped = _groupFormatter.format(int.parse(intPart));
    if (!hasDot) return grouped;
    if (trailingDot) return '$grouped.';
    return '$grouped.$decimalPart';
  }

  String _decorate(String numeric) {
    if (numeric.isEmpty) return '';
    return isSuffix ? '$numeric\u202F$symbol' : '$symbol$numeric';
  }

  int _selectionOffset(String formatted, String numeric) {
    return isSuffix ? numeric.length : formatted.length;
  }

  String formatString(String raw) {
    final cleaned = _clean(raw);
    final numeric = _formatNumeric(cleaned);
    return _decorate(numeric);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = _clean(newValue.text);
    if (cleaned.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final hasDot = cleaned.contains('.');
    final parts = cleaned.split('.');
    var testIntPart = parts.first;
    testIntPart = testIntPart.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (testIntPart.length > 15) {
      return oldValue;
    }

    final numeric = _formatNumeric(cleaned);
    final formatted = _decorate(numeric);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _selectionOffset(formatted, numeric),
      ),
      composing: TextRange.empty,
    );
  }
}

/// Amount controller that renders currency symbol with a smaller/softer style.
class AmountTextEditingController extends TextEditingController {
  AmountTextEditingController({super.text});

  TextStyle? _currencyStyle;

  void setCurrencyStyle(TextStyle style) {
    _currencyStyle = style;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (style == null || _currencyStyle == null || value.text.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    if (withComposing &&
        value.isComposingRangeValid &&
        !value.composing.isCollapsed) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    final text = value.text;
    final prefixMatch = RegExp(r'^[^0-9]+').firstMatch(text);
    final suffixMatch = RegExp(r'[^0-9]+$').firstMatch(text);

    final hasPrefix =
        prefixMatch != null && prefixMatch.end > prefixMatch.start;
    final hasSuffix =
        suffixMatch != null && suffixMatch.end > suffixMatch.start;

    if (!hasPrefix && !hasSuffix) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    final spans = <InlineSpan>[];
    var middleStart = 0;
    var middleEnd = text.length;

    if (hasPrefix) {
      final prefix = text.substring(prefixMatch.start, prefixMatch.end);
      spans.add(TextSpan(text: prefix, style: _currencyStyle));
      middleStart = prefixMatch.end;
    }

    if (hasSuffix) {
      middleEnd = suffixMatch.start;
    }

    if (middleEnd > middleStart) {
      spans.add(
          TextSpan(text: text.substring(middleStart, middleEnd), style: style));
    }

    if (hasSuffix) {
      final suffix = text.substring(suffixMatch.start, suffixMatch.end);
      spans.add(TextSpan(text: suffix, style: _currencyStyle));
    }

    return TextSpan(style: style, children: spans);
  }
}

/// A text field for amount input with a subtle scale animation on text change.
class AnimatedAmountField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String hint;
  final double? fontSize;
  final double? height;
  final double? width;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final Map<String, String>? validator;

  const AnimatedAmountField({
    super.key,
    required this.controller,
    this.hint = '0.00',
    this.fontSize,
    this.height,
    this.width,
    this.fillColor,
    this.borderRadius,
    this.validator,
  });

  @override
  ConsumerState<AnimatedAmountField> createState() =>
      _AnimatedAmountFieldState();
}

class _AnimatedAmountFieldState extends ConsumerState<AnimatedAmountField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  String _previousText = '';

  _CurrencyAmountInputFormatter? _formatter;
  String? _formatterCurrencyCode;
  String _activeSymbol = '';
  bool _activeIsSuffix = false;
  String _activeSuffixToken = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.03)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.03, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_animationController);

    widget.controller.addListener(_onTextChanged);
    _previousText = widget.controller.text;
  }

  _CurrencyAmountInputFormatter _buildFormatter(String currencyCode) {
    final symbol = currencySymbolForCode(currencyCode);
    final isSuffix = isSuffixCurrency(currencyCode);
    return _CurrencyAmountInputFormatter(
      symbol: symbol,
      isSuffix: isSuffix,
    );
  }

  int _suffixBoundaryOffset(String text) {
    if (!_activeIsSuffix || _activeSymbol.isEmpty) return text.length;
    if (_activeSuffixToken.isNotEmpty && text.endsWith(_activeSuffixToken)) {
      return text.length - _activeSuffixToken.length;
    }
    if (text.endsWith(_activeSymbol)) {
      return text.length - _activeSymbol.length;
    }
    return text.length;
  }

  void _enforceCursorBeforeSuffix() {
    if (!_activeIsSuffix || _activeSymbol.isEmpty) return;
    final text = widget.controller.text;
    if (!text.endsWith(_activeSymbol) &&
        (_activeSuffixToken.isEmpty || !text.endsWith(_activeSuffixToken))) {
      return;
    }

    final maxOffset = _suffixBoundaryOffset(text);
    final selection = widget.controller.selection;
    if (selection.baseOffset <= maxOffset &&
        selection.extentOffset <= maxOffset) {
      return;
    }

    widget.controller.value = widget.controller.value.copyWith(
      selection: TextSelection.collapsed(offset: maxOffset),
      composing: TextRange.empty,
    );
  }

  void _reformatControllerText() {
    if (_formatter == null) return;
    final current = widget.controller.text.trim();
    if (current.isEmpty) return;

    final formatted = _formatter!.formatString(current);
    if (formatted == widget.controller.text) return;

    final selectionOffset = _activeIsSuffix
        ? _suffixBoundaryOffset(formatted).clamp(0, formatted.length)
        : formatted.length;

    widget.controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }

  TextInputFormatter _suffixCursorGuardFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      if (!_activeIsSuffix || _activeSymbol.isEmpty) return newValue;
      final text = newValue.text;
      if (!text.endsWith(_activeSymbol) &&
          (_activeSuffixToken.isEmpty || !text.endsWith(_activeSuffixToken))) {
        return newValue;
      }

      final maxOffset = _suffixBoundaryOffset(text).clamp(0, text.length);
      final selection = newValue.selection;
      final isAlreadyValid = selection.baseOffset >= 0 &&
          selection.extentOffset >= 0 &&
          selection.baseOffset <= maxOffset &&
          selection.extentOffset <= maxOffset;
      if (isAlreadyValid) return newValue;

      return newValue.copyWith(
        selection: TextSelection.collapsed(offset: maxOffset),
        composing: TextRange.empty,
      );
    });
  }

  void _syncFormatter(String currencyCode) {
    if (_formatterCurrencyCode == currencyCode && _formatter != null) return;

    _formatterCurrencyCode = currencyCode;
    _formatter = _buildFormatter(currencyCode);
    _activeSymbol = currencySymbolForCode(currencyCode);
    _activeIsSuffix = isSuffixCurrency(currencyCode);
    _activeSuffixToken = _activeIsSuffix ? '\u202F$_activeSymbol' : '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _reformatControllerText();
      _enforceCursorBeforeSuffix();
    });
  }

  void _onTextChanged() {
    _enforceCursorBeforeSuffix();
    if (widget.controller.text != _previousText) {
      _previousText = widget.controller.text;
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.fontSize ?? 25;
    final height = widget.height ?? 120;
    final width = widget.width ?? double.infinity;
    final fillColor =
        widget.fillColor ?? Theme.of(context).colorScheme.surfaceDim;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(12);
    final currencyCode =
        ref.watch(currencyControllerProvider).value?.code ?? 'MGA';
    final symbol = currencySymbolForCode(currencyCode);
    final isSuffix = isSuffixCurrency(currencyCode);
    final cursorColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final currencyColor = Theme.of(context).hintColor;
    final currencyFontSize = fontSize * 0.90;
    final hintColor = Theme.of(context).hintColor;
    final currencyStyle = TextStyle(
      fontSize: currencyFontSize,
      fontWeight: FontWeight.w500,
      color: currencyColor,
    );
    final amountHintStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: hintColor,
    );

    if (widget.controller is AmountTextEditingController) {
      (widget.controller as AmountTextEditingController)
          .setCurrencyStyle(currencyStyle);
    }

    _syncFormatter(currencyCode);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: borderRadius,
          ),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: TextField(
        controller: widget.controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        cursorColor: cursorColor,
        cursorWidth: 1.2,
        cursorHeight: fontSize * 1.3,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        inputFormatters: [_formatter!, _suffixCursorGuardFormatter()],
        decoration: InputDecoration(
          hint: _buildStyledAmountHint(
            hint: widget.hint,
            symbol: symbol,
            isSuffix: isSuffix,
            amountStyle: amountHintStyle,
            currencyStyle: currencyStyle.copyWith(color: hintColor),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }
}

/// A smaller animated amount field for subcategory cards.
class AnimatedSubcategoryAmountField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String hint;
  final double? fontSize;
  final Color? fillColor;
  final BorderRadius? borderRadius;

  const AnimatedSubcategoryAmountField({
    super.key,
    required this.controller,
    this.hint = '0.00',
    this.fontSize,
    this.fillColor,
    this.borderRadius,
  });

  @override
  ConsumerState<AnimatedSubcategoryAmountField> createState() =>
      _AnimatedSubcategoryAmountFieldState();
}

class _AnimatedSubcategoryAmountFieldState
    extends ConsumerState<AnimatedSubcategoryAmountField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  String _previousText = '';

  _CurrencyAmountInputFormatter? _formatter;
  String? _formatterCurrencyCode;
  String _activeSymbol = '';
  bool _activeIsSuffix = false;
  String _activeSuffixToken = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.04)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.04, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_animationController);

    widget.controller.addListener(_onTextChanged);
    _previousText = widget.controller.text;
  }

  _CurrencyAmountInputFormatter _buildFormatter(String currencyCode) {
    final symbol = currencySymbolForCode(currencyCode);
    final isSuffix = isSuffixCurrency(currencyCode);
    return _CurrencyAmountInputFormatter(
      symbol: symbol,
      isSuffix: isSuffix,
    );
  }

  int _suffixBoundaryOffset(String text) {
    if (!_activeIsSuffix || _activeSymbol.isEmpty) return text.length;
    if (_activeSuffixToken.isNotEmpty && text.endsWith(_activeSuffixToken)) {
      return text.length - _activeSuffixToken.length;
    }
    if (text.endsWith(_activeSymbol)) {
      return text.length - _activeSymbol.length;
    }
    return text.length;
  }

  void _enforceCursorBeforeSuffix() {
    if (!_activeIsSuffix || _activeSymbol.isEmpty) return;
    final text = widget.controller.text;
    if (!text.endsWith(_activeSymbol) &&
        (_activeSuffixToken.isEmpty || !text.endsWith(_activeSuffixToken))) {
      return;
    }

    final maxOffset = _suffixBoundaryOffset(text);
    final selection = widget.controller.selection;
    if (selection.baseOffset <= maxOffset &&
        selection.extentOffset <= maxOffset) {
      return;
    }

    widget.controller.value = widget.controller.value.copyWith(
      selection: TextSelection.collapsed(offset: maxOffset),
      composing: TextRange.empty,
    );
  }

  void _reformatControllerText() {
    if (_formatter == null) return;
    final current = widget.controller.text.trim();
    if (current.isEmpty) return;

    final formatted = _formatter!.formatString(current);
    if (formatted == widget.controller.text) return;

    final selectionOffset = _activeIsSuffix
        ? _suffixBoundaryOffset(formatted).clamp(0, formatted.length)
        : formatted.length;

    widget.controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }

  TextInputFormatter _suffixCursorGuardFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      if (!_activeIsSuffix || _activeSymbol.isEmpty) return newValue;
      final text = newValue.text;
      if (!text.endsWith(_activeSymbol) &&
          (_activeSuffixToken.isEmpty || !text.endsWith(_activeSuffixToken))) {
        return newValue;
      }

      final maxOffset = _suffixBoundaryOffset(text).clamp(0, text.length);
      final selection = newValue.selection;
      final isAlreadyValid = selection.baseOffset >= 0 &&
          selection.extentOffset >= 0 &&
          selection.baseOffset <= maxOffset &&
          selection.extentOffset <= maxOffset;
      if (isAlreadyValid) return newValue;

      return newValue.copyWith(
        selection: TextSelection.collapsed(offset: maxOffset),
        composing: TextRange.empty,
      );
    });
  }

  void _syncFormatter(String currencyCode) {
    if (_formatterCurrencyCode == currencyCode && _formatter != null) return;

    _formatterCurrencyCode = currencyCode;
    _formatter = _buildFormatter(currencyCode);
    _activeSymbol = currencySymbolForCode(currencyCode);
    _activeIsSuffix = isSuffixCurrency(currencyCode);
    _activeSuffixToken = _activeIsSuffix ? '\u202F$_activeSymbol' : '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _reformatControllerText();
      _enforceCursorBeforeSuffix();
    });
  }

  void _onTextChanged() {
    _enforceCursorBeforeSuffix();
    if (widget.controller.text != _previousText) {
      _previousText = widget.controller.text;
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.fontSize ?? 25;
    final fillColor = widget.fillColor ?? Theme.of(context).colorScheme.surface;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(12);
    final currencyCode =
        ref.watch(currencyControllerProvider).value?.code ?? 'MGA';
    final symbol = currencySymbolForCode(currencyCode);
    final isSuffix = isSuffixCurrency(currencyCode);
    final cursorColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final currencyColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final currencyFontSize = fontSize * 0.78;
    final hintColor = Theme.of(context).hintColor.withAlpha(80);
    final currencyStyle = TextStyle(
      fontSize: currencyFontSize,
      fontWeight: FontWeight.w500,
      color: currencyColor,
    );
    final amountHintStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: hintColor,
    );

    if (widget.controller is AmountTextEditingController) {
      (widget.controller as AmountTextEditingController)
          .setCurrencyStyle(currencyStyle);
    }

    _syncFormatter(currencyCode);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: TextField(
        controller: widget.controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        cursorColor: cursorColor,
        cursorWidth: 1.2,
        cursorHeight: fontSize * 1.25,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        inputFormatters: [_formatter!, _suffixCursorGuardFormatter()],
        decoration: InputDecoration(
          hint: _buildStyledAmountHint(
            hint: widget.hint,
            symbol: symbol,
            isSuffix: isSuffix,
            amountStyle: amountHintStyle,
            currencyStyle: currencyStyle.copyWith(color: hintColor),
          ),
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 11.2),
        ),
      ),
    );
  }
}
