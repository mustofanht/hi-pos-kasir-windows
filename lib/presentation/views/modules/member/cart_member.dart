import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';

class CartMember extends StatefulWidget {
  const CartMember({super.key});

  @override
  State<CartMember> createState() => _CartMemberState();
}

class _CartMemberState extends State<CartMember> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: layoutStyle.screenWidth / 4,
      decoration: BoxDecoration(
        color: colorStyle.white,
        border: Border(
          left: BorderSide(
            color: colorStyle.grey,
            width: 1,
          ),
        ),
      ),
    );
  }
}
