import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userflow/core/services/connectivity_service.dart';

class NoNetworkScreen extends ConsumerWidget {
  const NoNetworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOnlineAsync = ref.watch(connectivityStatusProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final contentWidth = maxWidth > 480 ? 480.0 : maxWidth * 0.9;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.wifi_off,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'No network connection',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'No internet connection. Connect to the internet and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 24),

                      isOnlineAsync.when(
                        data: (isConnected) => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ref.refresh(connectivityStatusProvider);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: isConnected
                                  ? Colors.green
                                  : theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        error: (_, __) => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => ref.refresh(connectivityStatusProvider),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
