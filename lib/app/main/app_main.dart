import 'package:jaya_propertiy/app/main/app_route.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/app/utils/translation/app_translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

class AppMain extends StatefulWidget {
  const AppMain({super.key});

  @override
  State<AppMain> createState() => _AppMainState();
}

class _AppMainState extends State<AppMain> {
  @override
  void initState() {
    logger.safeLog('APP MAIN');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Jaya Propertiy',
      debugShowCheckedModeBanner: false,
      getPages: AppRoute.pages,
      initialRoute: RouteName.splashPage,
      theme: theme.light(),
      // darkTheme: theme.dark(),
      translations: AppTranslation(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('id', 'ID'),
      fallbackLocale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
    );
  }
}