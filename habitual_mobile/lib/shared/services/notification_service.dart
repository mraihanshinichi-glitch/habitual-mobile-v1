import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      
      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      _initialized = true;
      print('DEBUG NotificationService: Initialized successfully');
    } catch (e) {
      print('DEBUG NotificationService: Initialization error: $e');
      _initialized = false;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('DEBUG NotificationService: Notification tapped: ${response.payload}');
    // Handle notification tap here
  }

  Future<bool> requestPermissions() async {
    try {
      // Request Android 13+ notification permission
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        print('DEBUG NotificationService: Android notification permission: $granted');
        
        // Request exact alarm permission for Android 12+
        final exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();
        print('DEBUG NotificationService: Exact alarm permission: $exactAlarmGranted');
        
        return granted ?? false;
      }
      
      // Request iOS permissions
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        print('DEBUG NotificationService: iOS notification permission: $granted');
        return granted ?? false;
      }
      
      return true;
    } catch (e) {
      print('DEBUG NotificationService: Permission request error: $e');
      return false;
    }
  }

  Future<void> scheduleDailyHabitReminder({
    required int habitId,
    required String habitTitle,
    required int hour,
    required int minute,
  }) async {
    await initialize();
    
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      
      // If the scheduled time is in the past, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      
      try {
        await _notifications.zonedSchedule(
          habitId,
          'Pengingat Kebiasaan',
          'Waktunya untuk: $habitTitle',
          scheduledDate,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'habit_reminders',
              'Pengingat Kebiasaan',
              channelDescription: 'Notifikasi pengingat untuk kebiasaan harian',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
        );
      } catch (e) {
        print('DEBUG NotificationService: exact notification failed, falling back to inexact. Error: $e');
        await _notifications.zonedSchedule(
          habitId,
          'Pengingat Kebiasaan',
          'Waktunya untuk: $habitTitle',
          scheduledDate,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'habit_reminders',
              'Pengingat Kebiasaan',
              channelDescription: 'Notifikasi pengingat untuk kebiasaan harian',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
        );
      }
      
      print('DEBUG NotificationService: Scheduled daily reminder for "$habitTitle" at $hour:$minute');
    } catch (e) {
      print('DEBUG NotificationService: Error scheduling daily reminder: $e');
    }
  }

  Future<void> showStreakNotification({
    required int streak,
    required String message,
  }) async {
    await initialize();
    
    try {
      await _notifications.show(
        999, // Special ID for streak notifications
        '🔥 Streak Milestone!',
        message,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'streak_notifications',
            'Notifikasi Streak',
            channelDescription: 'Notifikasi pencapaian streak',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      
      print('DEBUG NotificationService: Showed streak notification: $message');
    } catch (e) {
      print('DEBUG NotificationService: Error showing streak notification: $e');
    }
  }

  Future<void> showStreakResetNotification() async {
    await initialize();
    
    try {
      await _notifications.show(
        998, // Special ID for streak reset
        '💔 Streak Reset',
        'Streak Anda telah direset. Jangan menyerah, mulai lagi hari ini!',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'streak_notifications',
            'Notifikasi Streak',
            channelDescription: 'Notifikasi pencapaian streak',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      
      print('DEBUG NotificationService: Showed streak reset notification');
    } catch (e) {
      print('DEBUG NotificationService: Error showing streak reset notification: $e');
    }
  }

  Future<void> cancelHabitNotification(int habitId) async {
    try {
      await _notifications.cancel(habitId);
      print('DEBUG NotificationService: Cancelled notification for habit $habitId');
    } catch (e) {
      print('DEBUG NotificationService: Error cancelling notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('DEBUG NotificationService: Cancelled all notifications');
    } catch (e) {
      print('DEBUG NotificationService: Error cancelling all notifications: $e');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      print('DEBUG NotificationService: Error getting pending notifications: $e');
      return [];
    }
  }

  Future<void> showTestNotification() async {
    await initialize();
    
    try {
      final now = DateTime.now();
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      print('DEBUG NotificationService: Test notification sent at $timeStr');
    } catch (e) {
      print('DEBUG NotificationService: Error showing test notification: $e');
    }
  }
}
