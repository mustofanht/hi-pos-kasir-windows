import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';

class CustomLoadMoreButton extends StatelessWidget {
  final Function onPressed;
  final bool isLoading;
  final double? bottom;

  const CustomLoadMoreButton({
    Key? key,
    required this.onPressed,
    required this.isLoading,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottom ?? layoutStyle.defaultMargin,
      left: MediaQuery.of(context).size.width * 32 / 100,
      child: Container(
        height: layoutStyle.blockVertical * 5.5,
        width: layoutStyle.blockHorizontal * 35,
        decoration: BoxDecoration(
          color: colorStyle.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: colorStyle.black.withOpacity(0.05),
              offset: const Offset(0, 1),
            ),
            BoxShadow(
              blurRadius: 8,
              color: colorStyle.black.withOpacity(0.05),
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: isLoading
            ? TextButton(
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: layoutStyle.blockVertical * 2,
                      height: layoutStyle.blockVertical * 2,
                      child: CircularProgressIndicator.adaptive(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorStyle.blue),
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(
                      width: layoutStyle.defaultMargin / 2,
                    ),
                    Text(
                      'Loading...',
                      style: textStyle.blueText.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              )
            : TextButton(
                onPressed: () {
                  onPressed();
                },
                child: Text(
                  'Show More',
                  style: textStyle.blueText.copyWith(fontSize: 12),
                ),
              ),
      ),
    );
  }
}
