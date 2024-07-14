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
              fit: BoxFit.fill,
            ),
            // child: Text(
            //   'Sign In',
            //   textAlign: TextAlign.center,
            //   style: textStyle.blackText.copyWith(
            //     fontSize: fontSize.title,
            //     fontWeight: fontWeight.bold,
            //   ),
            // ),
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
          // Padding(
          //   padding: EdgeInsets.symmetric(
          //     horizontal: layoutStyle.defaultMargin,
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Row(
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         mainAxisAlignment: MainAxisAlignment.start,
          //         children: [
          //           Checkbox(
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(5),
          //             ),
          //             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //             visualDensity: VisualDensity.compact,
          //             value: controller.isSaved.value,
          //             checkColor: colorStyle.white,
          //             fillColor: MaterialStateProperty.resolveWith(
          //               (states) => colorStyle.checkboxColor(
          //                 states: states,
          //                 c: colorStyle.blue,
          //               ),
          //             ),
          //             onChanged: (bool? value) {
          //               controller.isSaved.value = value!;
          //             },
          //           ),
          //           Text(
          //             'Remember me',
          //             style: textStyle.blackText.copyWith(
          //                 fontWeight: fontWeight.medium,
          //                 fontSize: fontSize.small),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
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
          // Padding(
          //   padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
          //   child: InkWell(
          //     onTap: () {},
          //     child: Text(
          //       'Forgot password?',
          //       style: textStyle.blueText.copyWith(
          //           fontWeight: fontWeight.medium, fontSize: fontSize.small),
          //     ),
          //   ),
          // ),
        ],
      );
    }
    // end builder

    // footer builder
    // Widget footerBuilder(LoginPageController controller) {
    //   return Column(
    //     children: [
    //       Text(
    //         'Don\'t have account?',
    //         style: textStyle.greyText,
    //       ),
    //       InkWell(
    //         onTap: () {},
    //         child: Text(
    //           'Register',
    //           style: textStyle.blueText.copyWith(
    //             fontWeight: fontWeight.medium,
    //             fontSize: fontSize.title,
    //           ),
    //         ),
    //       ),
    //       SizedBox(
    //         height: layoutStyle.defaultMargin,
    //       ),
    //     ],
    //   );
    // }

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
                    horizontal: layoutStyle.defaultMargin * 20,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: layoutStyle.screenHeight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    titleBuilder(),
                                    formLogin(context),
                                  ],
                                ),
                              ),
                              // footerBuilder(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
