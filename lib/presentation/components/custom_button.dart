import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final EdgeInsetsGeometry margin;
  final Function onPressed;
  final ButtonStyle style;
  final MainAxisAlignment labelAlignment;
  final Widget label;
  final double width;
  final double height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final BoxConstraints? constraints;

  const CustomButton({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onPressed,
    required this.style,
    this.labelAlignment = MainAxisAlignment.center,
    required this.label,
    this.width = double.infinity,
    required this.height,
    this.prefixIcon,
    this.suffixIcon,
    this.constraints,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool loadingButton = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: widget.constraints,
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      child: ElevatedButton(
        onPressed: () async {
          // loadingButton = true;
          // setState(() {});
          widget.onPressed();
        },
        style: widget.style,
        child: loadingButton
            ? loading.buttonLoading()
            : Row(
                mainAxisAlignment: widget.labelAlignment,
                children: [
                  widget.prefixIcon ?? Container(),
                  widget.label,
                  widget.suffixIcon ?? Container(),
                ],
              ),
      ),
    );
  }
}
