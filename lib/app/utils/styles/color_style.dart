part of 'theme_style.dart';

class AppColorStyle {
  final Color primary = const Color.fromRGBO(97, 47, 245, 1);
  final Color primaryLight = Color.fromRGBO(137, 87, 255, 1);
  final Color primaryDark = const Color.fromRGBO(57, 7, 205, 1);
  final Color white = const Color(0xFFFFFFFF);
  final Color zircon = const Color(0xFFF2F9FE);
  final Color black = const Color(0xFF0A222D);
  final Color hawkes_blue = const Color(0xFFD2E5F9);
  final Color cloud_blue = const Color(0xFFC8E3FF);
  final Color dark_blue = Color.fromARGB(255, 29, 61, 120);
  final Color blue = Color.fromARGB(255, 77, 79, 188);
  final Color green = const Color(0xFF42AD43);
  final Color lime = const Color.fromRGBO(211, 242, 97, 1);
  final Color yellow = const Color(0xFFFFC300);
  final Color red = const Color(0xFFCE2F21);
  final Color grey = const Color(0xFF849096);
  final Color lightGrey = const Color.fromRGBO(239, 237, 243, 1);
  final Color transparent = Colors.transparent;
  final Color disabled = const Color(0xFF849096).withOpacity(0.1);
  final Color background = const Color.fromRGBO(250, 250, 250, 1);
  final Color creamy = const Color.fromRGBO(255, 242, 232, 1);

  // get color checkbox
  Color checkboxColor({
    required Set<MaterialState> states,
    required Color c,
  }) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
      MaterialState.selected
    };
    if (states.any(interactiveStates.contains)) {
      return c;
    }
    return colorStyle.blue;
  }
}

AppColorStyle colorStyle = new AppColorStyle();
