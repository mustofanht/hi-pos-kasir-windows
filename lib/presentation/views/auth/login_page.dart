import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/auth/login_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends GetView<LoginPageController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    // title builder
    Widget titleBuilder() {
      return Column(
        children: [
          SizedBox(
            width: layoutStyle.blockHorizontal * 15,
            height: layoutStyle.blockHorizontal * 15,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: layoutStyle.defaultMargin / 2,
            ),
            child: Image.asset(
              assetsConstant.imgLogo,
              width: layoutStyle.blockHorizontal * 10,
              height: layoutStyle.blockHorizontal * 10,
              fit: BoxFit.contain,
            ),
          ),
        ],
      );
    }
    // end builder

    // form login builder
    Widget formLogin(LoginPageController controller) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTextBox(
            height: layoutStyle.blockVertical * 6.5,
            margin: EdgeInsets.symmetric(
              vertical: layoutStyle.defaultMargin / 2,
              horizontal: layoutStyle.defaultMargin,
            ),
            obscureText: false,
            border: Border.all(
              color: colorStyle.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(
              layoutStyle.defaultMargin / 2,
            ),
            controller: controller.inpUsername,
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: layoutStyle.blockVertical * 1.5,
                horizontal: layoutStyle.blockHorizontal * 2,
              ),
              prefix: SizedBox(
                width: layoutStyle.defaultMargin / 2,
              ),
              prefixIconConstraints: BoxConstraints(
                maxWidth: layoutStyle.blockHorizontal * 6.5,
                maxHeight: layoutStyle.blockHorizontal * 6.5,
              ),
              hintText: 'Username',
              hintStyle: textStyle.greyText,
              border: InputBorder.none,
            ),
          ),
          CustomTextBox(
            height: layoutStyle.blockVertical * 6.5,
            margin: EdgeInsets.symmetric(
              vertical: layoutStyle.defaultMargin / 2,
              horizontal: layoutStyle.defaultMargin,
            ),
            obscureText: !controller.showPassword.value,
            border: Border.all(
              color: colorStyle.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(
              layoutStyle.defaultMargin / 2,
            ),
            controller: controller.inpPassword,
            decoration: InputDecoration(
              isCollapsed: true,
              prefix: SizedBox(
                width: layoutStyle.defaultMargin / 2,
              ),
              prefixIconConstraints: BoxConstraints(
                maxWidth: layoutStyle.blockHorizontal * 6.5,
                maxHeight: layoutStyle.blockHorizontal * 6.5,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.showPassword.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  controller.doShowPassword();
                },
              ),
              suffix: SizedBox(
                width: layoutStyle.defaultMargin / 2,
              ),
              hintText: 'Password',
              hintStyle: textStyle.greyText,
              border: InputBorder.none,
            ),
          ),
          CustomButton(
            margin: EdgeInsets.symmetric(
              vertical: layoutStyle.defaultMargin / 2,
              horizontal: layoutStyle.defaultMargin,
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              controller.isLoading.value ? null : controller.doLogin();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith(
                (states) => colorStyle.blue,
              ),
              overlayColor: MaterialStateProperty.resolveWith(
                (states) => colorStyle.black.withOpacity(0.1),
              ),
              shape: MaterialStateProperty.resolveWith(
                (states) => RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    layoutStyle.defaultMargin / 2,
                  ),
                ),
              ),
            ),
            label: controller.isLoading.value
                ? loading.buttonLoading()
                : Text(
                    'Login',
                    style: textStyle.whiteText,
                  ),
            height: layoutStyle.blockVertical * 6.5,
          ),
        ],
      );
    }
    // end builder

    // end builder
    return GetX(
      init: controller,
      tag: 'LoginPage',
      initState: (state) {},
      builder: (context) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: (context.isProcessing.value)
              ? loading.simpleLoading()
              : Container(
                  width: layoutStyle.screenWidth,
                  height: layoutStyle.screenHeight,
                  decoration: const BoxDecoration(),
                  padding: EdgeInsets.symmetric(
                    horizontal: layoutStyle.screenWidth / 3,
                  ),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: layoutStyle.screenHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            titleBuilder(),
                            formLogin(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
