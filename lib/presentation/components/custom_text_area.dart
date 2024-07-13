import 'package:flutter/material.dart';

import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';

class CustomTextArea extends StatefulWidget {
  final Text? label;
  final double width;
  final double? height;
  final int? maxLines;
  final TextEditingController? controller;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry? padding;
  final bool obscureText;
  final TextStyle? style;
  final TextAlign textAlign;
  final BoxBorder? border;
  final Color? backgroundColor;
  final InputDecoration decoration;
  final List<BoxShadow>? boxShadow;
  final BorderRadiusGeometry borderRadius;
  final Function(String)? onChanged;

  const CustomTextArea({
    Key? key,
    this.label,
    this.width = double.infinity,
    this.height,
    this.maxLines,
    this.controller,
    this.margin = EdgeInsets.zero,
    this.padding,
    required this.obscureText,
    this.style,
    this.textAlign = TextAlign.left,
    this.border,
    this.backgroundColor,
    required this.decoration,
    this.boxShadow,
    this.borderRadius = BorderRadius.zero,
    this.onChanged,
  }) : super(key: key);

  @override
  State<CustomTextArea> createState() => _CustomTextAreaState();
}

class _CustomTextAreaState extends State<CustomTextArea> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.label != null
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: layoutStyle.defaultMargin / 2,
                  ),
                  child: widget.label,
                )
              : Container(),
          Container(
            height: widget.height ?? layoutStyle.blockVertical * 15,
            width: layoutStyle.screenWidth,
            padding: widget.padding ??
                EdgeInsets.symmetric(
                  horizontal: layoutStyle.defaultMargin / 2,
                ),
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? colorStyle.white,
              borderRadius: widget.borderRadius,
              border: widget.border,
              boxShadow: widget.boxShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: widget.onChanged,
                    controller: widget.controller ?? _controller,
                    obscureText: widget.obscureText,
                    maxLines: widget.maxLines ?? 6,
                    keyboardType: TextInputType.multiline,
                    textAlign: widget.textAlign,
                    style: widget.style ?? textStyle.blackText,
                    decoration: widget.decoration,
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
