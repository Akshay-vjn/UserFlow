import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userflow/core/services/connectivity_service.dart';
import 'package:userflow/features/user/domain/user_model.dart';
import 'package:userflow/features/user/presentation/user_provider.dart';
import 'package:userflow/l10n/app_localizations.dart';

class CreateUserScreen extends ConsumerStatefulWidget {
  const CreateUserScreen({super.key});

  @override
  ConsumerState<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends ConsumerState<CreateUserScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _avatarController = TextEditingController();
  
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _avatarController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    return null;
  }

  String? _validateAvatar(String? value) {
    if (value != null && value.isNotEmpty) {
      final uri = Uri.tryParse(value);
      if (uri == null || !uri.isAbsolute) {
        return 'Please enter a valid URL';
      }
    }
    return null;
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
              title: Text(AppLocalizations.of(context)!.createUserTitle),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
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
                      'User creation is not available while offline. Please check your internet connection and try again.',
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
            title: Text(AppLocalizations.of(context)!.createUserTitle),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 0,
          ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shadowColor: theme.colorScheme.primary.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.1),
                                theme.colorScheme.secondary.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person_add,
                                size: 48,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Add New User',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Fill in the details below to create a new user',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        _buildTextField(
                          controller: _firstNameController,
                          label: AppLocalizations.of(context)!.firstNameLabel,
                          icon: Icons.person_outline,
                          validator: (value) => _validateName(value, 'First name'),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildTextField(
                          controller: _lastNameController,
                          label: AppLocalizations.of(context)!.lastNameLabel,
                          icon: Icons.person_outline,
                          validator: (value) => _validateName(value, 'Last name'),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildTextField(
                          controller: _emailController,
                          label: AppLocalizations.of(context)!.emailLabel,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildTextField(
                          controller: _avatarController,
                          label: 'Avatar URL (Optional)',
                          icon: Icons.image_outlined,
                          keyboardType: TextInputType.url,
                          validator: _validateAvatar,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : () async {
                              final isOnline = ref.read(connectivityStatusProvider).maybeWhen(
                                    data: (v) => v,
                                    orElse: () => false,
                                  );
                              if (!isOnline) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: const [
                                          Icon(Icons.wifi_off, color: Colors.white),
                                          SizedBox(width: 12),
                                          Text('You are offline. Connect to the internet to create a user.'),
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
                               
                               setState(() => _isLoading = true);
                               
                               final newUser = User(
                                 email: _emailController.text.trim(),
                                 firstName: _firstNameController.text.trim(),
                                 lastName: _lastNameController.text.trim(),
                                 avatar: _avatarController.text.trim().isNotEmpty 
                                     ? _avatarController.text.trim()
                                     : 'https://via.placeholder.com/150',
                               );

                               try {
                                 final createdUser = await repo.createUser(newUser);
                                 ref.read(userListProvider.notifier).addUser(createdUser);
                                 
                                 if (context.mounted) {
                                   Navigator.pop(context);
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(
                                       content: Row(
                                         children: [
                                           const Icon(Icons.check_circle, color: Colors.white),
                                           const SizedBox(width: 12),
                                           Text(AppLocalizations.of(context)!.userCreatedSuccess),
                                         ],
                                       ),
                                       backgroundColor: Colors.green,
                                       behavior: SnackBarBehavior.floating,
                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                     ),
                                   );
                                 }
                               } catch (e) {
                                 if (context.mounted) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(
                                       content: Row(
                                         children: [
                                           const Icon(Icons.error, color: Colors.white),
                                           const SizedBox(width: 12),
                                           Text('${AppLocalizations.of(context)!.errorCreatingUser}: $e'),
                                         ],
                                       ),
                                       backgroundColor: Colors.red,
                                       behavior: SnackBarBehavior.floating,
                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                     ),
                                   );
                                 }
                               } finally {
                                 if (mounted) {
                                   setState(() => _isLoading = false);
                                 }
                               }
                             },
                             icon: _isLoading
                                 ? SizedBox(
                                     width: 20,
                                     height: 20,
                                     child: CircularProgressIndicator(
                                       strokeWidth: 2,
                                       valueColor: AlwaysStoppedAnimation<Color>(
                                         theme.colorScheme.onPrimary,
                                       ),
                                     ),
                                   )
                                 : const Icon(Icons.add, size: 24),
                             label: Text(
                               _isLoading ? 'Creating...' : AppLocalizations.of(context)!.createButton,
                               style: theme.textTheme.titleMedium?.copyWith(
                                 fontWeight: FontWeight.w600,
                                 color: theme.colorScheme.onPrimary,
                               ),
                             ),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.transparent,
                               shadowColor: Colors.transparent,
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(16),
                               ),
                             ),
                           ),
                        )],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )));
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createUserTitle),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
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
          title: Text(AppLocalizations.of(context)!.createUserTitle),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}