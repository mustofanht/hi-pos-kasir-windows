import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';

class CustomEmptyData extends StatelessWidget {
  const CustomEmptyData({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetsConstant.imgEmptyBox,
              fit: BoxFit.fill,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return const Text('Img Not Found');
              },
            ),
            SizedBox(
              height: layoutStyle.defaultMargin,
            ),
            Text(
              'Data Empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize.title,
                fontWeight: fontWeight.bold,
              ),
            ),
            SizedBox(
              height: layoutStyle.defaultMargin,
            ),
          ],
        ),
      ),
    );
  }
}
