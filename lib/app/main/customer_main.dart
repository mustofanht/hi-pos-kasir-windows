import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/presentation/views/modules/customer_page.dart';

class CustomerMain extends StatelessWidget {
  const CustomerMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    logger.safeLog('Customer Main');

    return const MaterialApp(
      title: 'Jaya Propertiy',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
      onGenerateRoute: generateRoute,
      initialRoute: 'presentation',
    );
  }
}

Route<dynamic> generateRoute(RouteSettings settings) {
  logger.safeLog('Route To : ${settings.name}');

  switch (settings.name) {
    case 'presentation':
      return MaterialPageRoute(builder: (_) => const CustomerPage());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}
