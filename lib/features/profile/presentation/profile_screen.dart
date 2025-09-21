import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userflow/features/auth/presentation/auth_provider.dart';
import 'package:userflow/core/database/database_helper.dart';
import 'package:userflow/l10n/app_localizations.dart';
import 'package:userflow/app.dart';
import 'package:userflow/core/services/notification_provider.dart';
import 'package:userflow/core/services/notification_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _loadLocalProfile() async {
    final googleAuth = await DatabaseHelper.instance.getGoogleAuth();
    if (googleAuth != null) {
      return {
        'name': googleAuth['display_name'],
        'email': googleAuth['email'],
        'avatar': googleAuth['photo_url'],
      };
    }
    return DatabaseHelper.instance.getLatestUser();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final locale = ref.watch(localeProvider);
    final fcmTokenAsync = ref.watch(fcmTokenProvider);
    final notificationPermissionAsync = ref.watch(notificationPermissionProvider);
    final notificationEnabled = ref.watch(notificationEnabledProvider);
    final toggleNotification = ref.read(toggleNotificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileTitle),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadLocalProfile(),
        builder: (context, snapshot) {
          final local = snapshot.data;
          String? name;
          String? email;
          String? avatar;

          if (local != null) {
            name = local['name'] as String?;
            email = local['email'] as String?;
            avatar = local['avatar'] as String?;
          } else if (authState is AuthAuthenticated) {
            if (authState.user != null) {
              name = authState.user!.displayName;
              email = authState.user!.email;
              avatar = authState.user!.photoUrl;
            } else if (authState.localData != null) {
              name = authState.localData!['display_name'] as String?;
              email = authState.localData!['email'] as String?;
              avatar = authState.localData!['photo_url'] as String?;
            }
          }

          if (name == null && email == null) {
            return Center(child: Text(AppLocalizations.of(context)!.notLoggedInLabel));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: (avatar != null && avatar.isNotEmpty)
                              ? NetworkImage(avatar)
                              : null,
                          child: (avatar == null || avatar.isEmpty)
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name ?? '',
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                email ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          leading: Icon(
                            notificationEnabled ? Icons.notifications : Icons.notifications_off,
                            color: notificationEnabled ? theme.colorScheme.primary : Colors.grey,
                          ),
                          title: const Text(' Notifications'),
                          subtitle: Text(
                            notificationEnabled ? 'App notifications enabled' : 'App notifications disabled',
                            style: TextStyle(
                              color: notificationEnabled ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Switch(
                            value: notificationEnabled,
                            onChanged: (value) {
                              toggleNotification();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    value 
                                      ? 'Notifications enabled' 
                                      : 'Notifications disabled',
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: value ? Colors.green : Colors.orange,
                                ),
                              );
                            },
                            activeColor: theme.colorScheme.primary,
                          ),
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.send),
                          title: const Text('Test Notification'),
                          subtitle: Text(
                            notificationEnabled 
                              ? 'Send a test notification' 
                              : 'Enable notifications to test',
                          ),
                          onTap: notificationEnabled ? () {
                            final notificationService = ref.read(notificationServiceProvider);
                            notificationService.showNotification(
                              title: 'Test Notification',
                              body: 'This is a test notification from UserFlow!',
                            );
                          } : null,
                          enabled: notificationEnabled,
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.token),
                          title: const Text('FCM Token'),
                          subtitle: fcmTokenAsync.when(
                            data: (token) => Text(
                              token != null ? 'Token: ${token.substring(0, 20)}...' : 'No token',
                              style: const TextStyle(fontSize: 12),
                            ),
                            loading: () => const Text('Loading...'),
                            error: (_, __) => const Text('Error getting token'),
                          ),
                          onTap: () {
                            fcmTokenAsync.whenData((token) {
                              if (token != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('FCM Token: $token'),
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: const Text('Language'),
                          subtitle: Text(locale?.languageCode == 'hi' ? 'हिन्दी' : 'English'),
                        ),
                        const Divider(height: 0),
                        RadioListTile<String>(
                          value: 'en',
                          groupValue: locale?.languageCode ?? 'en',
                          title: const Text('English'),
                          onChanged: (val) {
                            ref.read(localeProvider.notifier).state = const Locale('en');
                          },
                        ),
                        RadioListTile<String>(
                          value: 'hi',
                          groupValue: locale?.languageCode ?? 'en',
                          title: const Text('हिन्दी'),
                          onChanged: (val) {
                            ref.read(localeProvider.notifier).state = const Locale('hi');
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: () => ref.read(authProvider.notifier).signOut(),
                  icon: const Icon(Icons.logout),
                  label: Text(AppLocalizations.of(context)!.signOutButton),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
