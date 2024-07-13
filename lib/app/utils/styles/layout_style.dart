part of 'theme_style.dart';

class LayoutStyle {
  double textScale = 0;
  double screenWidth = 0;
  double screenHeight = 0;
  double shortestSide = 0;
  double blockHorizontal = 0;
  double blockVertical = 0;
  double defaultMargin = 0;
  double statusBarHeight = 0;
  double safeAreaHorizontal = 0;
  double safeAreaVertical = 0;
  double safeBlockHorizontal = 0;
  double safeBlockVertical = 0;

  void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    textScale = mediaQuery.textScaleFactor;
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    shortestSide = mediaQuery.size.shortestSide;
    blockHorizontal = screenWidth / 100;
    blockVertical = screenHeight / 100;
    defaultMargin = 20;
    statusBarHeight = mediaQuery.padding.top;
    safeAreaHorizontal = mediaQuery.padding.left + mediaQuery.padding.right;
    safeAreaVertical = mediaQuery.padding.top + mediaQuery.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;
  }
}

LayoutStyle layoutStyle = new LayoutStyle();
