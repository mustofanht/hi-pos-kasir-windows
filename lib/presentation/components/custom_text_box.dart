import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';

class CustomTextBox extends StatefulWidget {
  final Text? label;
  final double height;
  final double width;
  final Color? backgroundColor;
  final TextEditingController? controller;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry? padding;
  final bool obscureText;
  final TextStyle? style;
  final TextAlign textAlign;
  final BoxBorder? border;
  final InputDecoration decoration;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final List<BoxShadow>? boxShadow;
  final BorderRadiusGeometry borderRadius;
  final Function(String)? onChanged;
  final Function(String)? onSubmit;
  final int? maxLength;
  final int? maxLine;
  final bool? isDisabled;
  final bool? isReadonly;
  final bool? isMandatory;

  const CustomTextBox({
    Key? key,
    this.label,
    required this.height,
    this.width = double.infinity,
    this.backgroundColor,
    this.controller,
    this.margin = EdgeInsets.zero,
    this.padding,
    required this.obscureText,
    this.style,
    this.textAlign = TextAlign.left,
    this.border,
    required this.decoration,
    this.inputFormatters,
    this.keyboardType,
    this.boxShadow,
    this.borderRadius = BorderRadius.zero,
    this.onChanged,
    this.onSubmit,
    this.maxLine = 1,
    this.maxLength,
    this.isReadonly = false,
    this.isDisabled = false,
    this.isMandatory = false,
  }) : super(key: key);

  @override
  State<CustomTextBox> createState() => _CustomTextBoxState();
}

class _CustomTextBoxState extends State<CustomTextBox> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.label != null
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: layoutStyle.defaultMargin / 2,
                  ),
                  child: Row(
                    children: [
                      widget.label ?? const Text(''),
                      widget.isMandatory!
                          ? Text(
                              '*',
                              style: textStyle.redText,
                            )
                          : const Text('')
                    ],
                  ),
                )
              : Container(),
          Container(
            height: widget.height,
            width: layoutStyle.screenWidth,
            padding: widget.padding ??
                EdgeInsets.symmetric(
                  horizontal: layoutStyle.defaultMargin / 2,
                ),
            decoration: BoxDecoration(
              color: widget.isDisabled != null && widget.isDisabled!
                  ? colorStyle.grey.withOpacity(0.10)
                  : widget.backgroundColor ?? colorStyle.white,
              borderRadius: widget.borderRadius,
              border: widget.border,
              boxShadow: widget.boxShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller ?? _controller,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    inputFormatters: widget.inputFormatters,
                    textAlign: widget.textAlign,
                    maxLength: widget.maxLength,
                    style: widget.style ?? textStyle.blackText,
                    maxLines: widget.maxLine,
                    textAlignVertical: TextAlignVertical.center,
                    textDirection: TextDirection.ltr,
                    decoration: widget.decoration.copyWith(
                      counterText: "",
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    readOnly: widget.isReadonly ?? false,
                    enabled:
                        widget.isDisabled != null ? !widget.isDisabled! : true,
                    onSubmitted: widget.isDisabled! ? null : widget.onSubmit,
                    onChanged: widget.isDisabled! ? null : widget.onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
