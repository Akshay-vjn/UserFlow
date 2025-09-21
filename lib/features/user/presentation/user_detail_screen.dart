import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userflow/core/services/connectivity_service.dart';
import 'package:userflow/features/user/domain/user_model.dart';
import 'package:userflow/features/user/presentation/user_provider.dart';
import 'package:userflow/features/user/presentation/edit_user_screen.dart';
import 'package:userflow/l10n/app_localizations.dart';

class UserDetailScreen extends ConsumerWidget {
  final int userId;
  final User? initialUser;

  const UserDetailScreen({super.key, required this.userId, this.initialUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connectivityAsync = ref.watch(connectivityStatusProvider);

    return connectivityAsync.when(
      data: (isConnected) {
        if (!isConnected) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.userDetailTitle),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      size: 80,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Internet Connection',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'User details cannot be loaded while offline. Please check your internet connection and try again.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.userDetailTitle),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          body: _buildUserBody(context, ref, theme),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.userDetailTitle),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Checking connectivity...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.userDetailTitle),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Connection Error',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Unable to check internet connection',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(connectivityStatusProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserBody(BuildContext context, WidgetRef ref, ThemeData theme) {
    final hasLocalOnly = initialUser != null && (userId == 0 || initialUser!.id == null);
    if (hasLocalOnly) {
      return _buildUserContent(context, ref, theme, initialUser!);
    }

    if (initialUser != null) {
      final fetched = ref.watch(userDetailProvider(userId));
      return fetched.when(
        data: (user) => _buildUserContent(context, ref, theme, user),
        loading: () => _buildUserContent(context, ref, theme, initialUser!),
        error: (e, st) => _buildUserContent(context, ref, theme, initialUser!),
      );
    }

    final fetched = ref.watch(userDetailProvider(userId));
    return fetched.when(
      data: (user) => _buildUserContent(context, ref, theme, user),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('${AppLocalizations.of(context)!.errorLoadingUser}: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(userDetailProvider(userId)),
              child: Text(AppLocalizations.of(context)!.retryButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserContent(BuildContext context, WidgetRef ref, ThemeData theme, User user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ZoomableImage(imageUrl: user.avatar, radius: 50),
              ),
              const SizedBox(height: 16),
              Text(
                '${user.firstName} ${user.lastName}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final isOnline = ref.read(connectivityStatusProvider).maybeWhen(
                              data: (v) => v,
                              orElse: () => false,
                            );
                        if (!isOnline) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.wifi_off, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('You are offline. Connect to the internet to edit this user.'),
                                ],
                              ),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditUserScreen(user: user),
                          ),
                        ).then((updatedUser) {
                          if (updatedUser != null) {
                            ref.read(userListProvider.notifier).refresh();
                          }
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: Text(AppLocalizations.of(context)!.editUserTitle),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final isOnline = ref.read(connectivityStatusProvider).maybeWhen(
                              data: (v) => v,
                              orElse: () => false,
                            );
                        if (!isOnline) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.wifi_off, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('You are offline. Connect to the internet to delete this user.'),
                                ],
                              ),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(AppLocalizations.of(context)!.deleteUserDialogTitle),
                            content: Text(AppLocalizations.of(context)!.deleteUserDialogContent),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(AppLocalizations.of(context)!.cancelButton),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(AppLocalizations.of(context)!.deleteButton),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          try {
                            await ref.read(userRepositoryProvider).deleteUser(user.id!);
                            ref.read(userListProvider.notifier).removeUser(user.id!);
                            
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.userDeletedSuccess)),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${AppLocalizations.of(context)!.errorDeletingUser}: $e')),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: Text(AppLocalizations.of(context)!.deleteButton),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ZoomableImage extends StatelessWidget {
  final String imageUrl;
  final double radius; // optional if you want circular preview

  const ZoomableImage({
    super.key,
    required this.imageUrl,
    this.radius = 56,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showZoomImage(context, imageUrl),
      child: CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl),
      ),
    );
  }

  void _showZoomImage(BuildContext context, String url) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'image',
      barrierColor: Colors.transparent, // Blur handled below
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, animation, secondaryAnimation) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Stack(
            fit: StackFit.expand,
            children: [
              BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withOpacity(0.25)),
              ),
              InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 5.0,
                child: SizedBox.expand(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}