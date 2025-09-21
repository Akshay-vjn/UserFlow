import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userflow/core/services/connectivity_service.dart';
import 'package:userflow/features/user/domain/user_model.dart';
import 'package:userflow/features/user/presentation/user_provider.dart';
import 'package:userflow/l10n/app_localizations.dart';

class EditUserScreen extends ConsumerStatefulWidget {
  final User user;
  const EditUserScreen({super.key, required this.user});

  @override
  ConsumerState<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends ConsumerState<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _avatar;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.user.firstName);
    _lastName = TextEditingController(text: widget.user.lastName);
    _email = TextEditingController(text: widget.user.email);
    _avatar = TextEditingController(text: widget.user.avatar);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _avatar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = ref.read(userRepositoryProvider);
    final connectivityAsync = ref.watch(connectivityStatusProvider);

    return connectivityAsync.when(
      data: (isConnected) {
        if (!isConnected) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.editUserTitle),
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
                      'User editing is not available while offline. Please check your internet connection and try again.',
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
            title: Text(AppLocalizations.of(context)!.editUserTitle),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _firstName,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.firstNameLabel),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lastName,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.lastNameLabel),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.emailLabel),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _avatar,
                    decoration: const InputDecoration(labelText: 'Avatar URL'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final isOnline = ref.read(connectivityStatusProvider).maybeWhen(
                        data: (v) => v,
                        orElse: () => false,
                      );
                      if (!isOnline) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.wifi_off, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('You are offline. Connect to the internet to save changes.'),
                                ],
                              ),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        return;
                      }

                      if (!_formKey.currentState!.validate()) return;

                      final updatedUser = User(
                        id: widget.user.id,
                        email: _email.text,
                        firstName: _firstName.text,
                        lastName: _lastName.text,
                        avatar: _avatar.text.isNotEmpty ? _avatar.text : widget.user.avatar,
                      );

                      await repo.updateUser(updatedUser);
                      ref.read(userListProvider.notifier).refresh();

                      if (context.mounted) Navigator.pop(context, updatedUser);
                    },
                    child: Text(AppLocalizations.of(context)!.saveButton),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.editUserTitle),
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
          title: Text(AppLocalizations.of(context)!.editUserTitle),
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
}
