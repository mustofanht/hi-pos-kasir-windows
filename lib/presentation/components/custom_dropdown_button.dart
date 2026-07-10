import 'package:flutter/material.dart';

import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';

class CustomDropdownButton<T> extends StatelessWidget {
  final T? value;
  final Function(T?)? onChanged;
  final List<DropdownMenuItem<T>>? items;
  final Text? label;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Widget? hint;
  final double width;
  final double height;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final bool? isLoading;
  final bool? isMandatory;

  const CustomDropdownButton({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.items,
    this.label,
    this.border,
    this.boxShadow,
    this.hint,
    this.width = double.infinity,
    required this.height,
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.isLoading = false,
    this.isMandatory = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label != null
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: layoutStyle.defaultMargin / 2,
                  ),
                  // child: label,
                  child: Row(
                    children: [
                      label ?? const Text(''),
                      isMandatory!
                          ? Text(
                              '*',
                              style: textStyle.redText,
                            )
                          : const Text('')
                    ],
                  ),
                )
              : Container(),
          isLoading!
              ? Center(
                  child: SizedBox(
                    width: height,
                    height: height,
                    child: loading.simpleLoading(),
                  ),
                )
              : Container(
                  height: height,
                  padding: EdgeInsets.symmetric(
                    horizontal: layoutStyle.defaultMargin / 2,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor ?? colorStyle.white,
                    borderRadius: BorderRadius.circular(10),
                    border: border,
                    boxShadow: boxShadow,
                  ),
                  child: Center(
                    child: DropdownButton<T>(
                      hint: hint,
                      value: value,
                      icon: const Icon(
                        Icons.arrow_drop_down_rounded,
                      ),
                      onChanged: onChanged,
                      isExpanded: true,
                      elevation: 3,
                      borderRadius: BorderRadius.circular(
                        layoutStyle.defaultMargin / 2,
                      ),
                      underline: const SizedBox(),
                      style: textStyle.blackText,
                      items: items,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
