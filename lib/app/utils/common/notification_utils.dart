// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
// import 'package:jaya_propertiy/data/models/common/received_notification.dart';

// class NotificationUtil {
//   static const inboxPayload = "inbox";
//   static const MethodChannel platform =
//       MethodChannel('java_property.com/jaya_property');
//   static const String portName = 'notification_send_port';

//   String? selectedNotificationPayload;

//   static const String urlLaunchActionId = 'id_1';
//   static const String navigationActionId = 'id_3';
//   static const String darwinNotificationCategoryText = 'textCategory';
//   static const String darwinNotificationCategoryPlain = 'plainCategory';

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   final StreamController<ReceivedNotification>
//       didReceiveLocalNotificationStream =
//       StreamController<ReceivedNotification>.broadcast();

//   final StreamController<String?> selectNotificationStream =
//       StreamController<String?>.broadcast();

//   initializeNotification() async {
//     logger.safeLog('Initialize Notification');

//     final NotificationAppLaunchDetails? notificationAppLaunchDetails =
//         !kIsWeb && Platform.isLinux
//             ? null
//             : await flutterLocalNotificationsPlugin
//                 .getNotificationAppLaunchDetails();

//     if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
//       selectedNotificationPayload =
//           notificationAppLaunchDetails!.notificationResponse?.payload;
//     }

//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     final List<DarwinNotificationCategory> darwinNotificationCategories =
//         <DarwinNotificationCategory>[
//       DarwinNotificationCategory(
//         darwinNotificationCategoryText,
//         actions: <DarwinNotificationAction>[
//           DarwinNotificationAction.text(
//             'text_1',
//             'Action 1',
//             buttonTitle: 'Send',
//             placeholder: 'Placeholder',
//           ),
//         ],
//       ),
//       DarwinNotificationCategory(
//         darwinNotificationCategoryPlain,
//         actions: <DarwinNotificationAction>[
//           DarwinNotificationAction.plain('id_1', 'Action 1'),
//           DarwinNotificationAction.plain(
//             'id_2',
//             'Action 2 (destructive)',
//             options: <DarwinNotificationActionOption>{
//               DarwinNotificationActionOption.destructive,
//             },
//           ),
//           DarwinNotificationAction.plain(
//             navigationActionId,
//             'Action 3 (foreground)',
//             options: <DarwinNotificationActionOption>{
//               DarwinNotificationActionOption.foreground,
//             },
//           ),
//           DarwinNotificationAction.plain(
//             'id_4',
//             'Action 4 (auth required)',
//             options: <DarwinNotificationActionOption>{
//               DarwinNotificationActionOption.authenticationRequired,
//             },
//           ),
//         ],
//         options: <DarwinNotificationCategoryOption>{
//           DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
//         },
//       )
//     ];

//     /// Note: permissions aren't requested here just to demonstrate that can be
//     /// done later
//     final DarwinInitializationSettings initializationSettingsDarwin =
//         DarwinInitializationSettings(
//       requestAlertPermission: false,
//       requestBadgePermission: false,
//       requestSoundPermission: false,
//       onDidReceiveLocalNotification:
//           (int id, String? title, String? body, String? payload) async {
//         didReceiveLocalNotificationStream.add(
//           ReceivedNotification(
//             id: id,
//             title: title,
//             body: body,
//             payload: payload,
//           ),
//         );
//       },
//       notificationCategories: darwinNotificationCategories,
//     );
//     final LinuxInitializationSettings initializationSettingsLinux =
//         LinuxInitializationSettings(
//       defaultActionName: 'Open notification',
//       defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
//     );
//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsDarwin,
//       macOS: initializationSettingsDarwin,
//       linux: initializationSettingsLinux,
//     );
//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse:
//           (NotificationResponse notificationResponse) {
//         switch (notificationResponse.notificationResponseType) {
//           case NotificationResponseType.selectedNotification:
//             selectNotificationStream.add(notificationResponse.payload);
//             break;
//           case NotificationResponseType.selectedNotificationAction:
//             if (notificationResponse.actionId == navigationActionId) {
//               selectNotificationStream.add(notificationResponse.payload);
//             }
//             break;
//         }
//       },
//       onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
//     );
//   }

//   void requestPermissions() async {
//     if (Platform.isIOS || Platform.isMacOS) {
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               IOSFlutterLocalNotificationsPlugin>()
//           ?.requestPermissions(
//             alert: true,
//             badge: true,
//             sound: true,
//           );
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               MacOSFlutterLocalNotificationsPlugin>()
//           ?.requestPermissions(
//             alert: true,
//             badge: true,
//             sound: true,
//           );
//     } else if (Platform.isAndroid) {
//       // final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
//       flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>();
//     }
//   }

//   displayNotification(
//       ReceivedNotification receivedNotification, int nmbCount) async {
//     AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//       'FPChannelId',
//       'FP Channel name',
//       importance: Importance.max,
//       priority: Priority.high,
//       ticker: 'ticker',
//       channelShowBadge: false,
//       number: nmbCount,
//     );
//     DarwinNotificationDetails darwinNotificationDetails =
//         DarwinNotificationDetails(
//       categoryIdentifier: darwinNotificationCategoryText,
//       badgeNumber: nmbCount,
//     );

//     NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//       iOS: darwinNotificationDetails,
//       macOS: darwinNotificationDetails,
//     );
//     await flutterLocalNotificationsPlugin.show(
//       receivedNotification.id,
//       receivedNotification.title,
//       receivedNotification.body,
//       notificationDetails,
//       payload: receivedNotification.payload,
//     );
//   }
// }

// @pragma('vm:entry-point')
// void notificationTapBackground(NotificationResponse notificationResponse) {
//   // ignore: avoid_print
//   logger.safeLog(
//     'notification(${notificationResponse.id}) action tapped: '
//     '${notificationResponse.actionId} with'
//     ' payload: ${notificationResponse.payload}',
//   );
//   if (notificationResponse.input?.isNotEmpty ?? false) {
//     logger.safeLog(
//       'notification action tapped with input: ${notificationResponse.input}',
//     );
//   }
// }

// NotificationUtil notificationUtil = NotificationUtil();
