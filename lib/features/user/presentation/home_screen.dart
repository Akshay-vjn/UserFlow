import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:userflow/core/services/connectivity_service.dart';
import 'package:userflow/features/user/domain/user_model.dart';
import 'package:userflow/features/user/presentation/user_provider.dart';
import 'package:userflow/features/auth/presentation/auth_provider.dart';
import 'package:userflow/l10n/app_localizations.dart';
import 'package:userflow/app.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  List<User> _filterUsers(List<User> users) {
    if (_searchQuery.isEmpty) return users;
    return users.where((user) {
      final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
      final email = user.email.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return fullName.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usersAsync = ref.watch(userListProvider);
    final connectivityAsync = ref.watch(connectivityStatusProvider);

    ref.listen<bool>(
      connectivityStatusProvider.select((state) => state.asData?.value ?? true),
      (previous, next) {
        if (previous == false && next == true) {
          ref.read(userListProvider.notifier).refresh();
        }
      },
    );

    return connectivityAsync.when(
      data: (isConnected) {
        if (!isConnected) {
          return Scaffold(
            backgroundColor: theme.colorScheme.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => ref.read(userListProvider.notifier).refresh(),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                final metrics = notification.metrics;
                if (metrics.extentAfter < 400) {
                  final notifier = ref.read(userListProvider.notifier);
                  final hasMore = notifier.hasMore;
                  if (hasMore && !_isSearching && !_loadingMore) {
                    setState(() => _loadingMore = true);
                    notifier.fetchNextPage().whenComplete(() {
                      if (mounted) setState(() => _loadingMore = false);
                    });
                  }
                }
                return false;
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        AppLocalizations.of(context)!.homeTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.people,
                            size: 48,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(_isSearching ? Icons.close : Icons.search),
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                              _searchQuery = '';
                            }
                          });
                        },
                        tooltip: _isSearching ? 'Close search' : 'Search',
                      ),
                      IconButton(
                        icon: const Icon(Icons.person),
                        tooltip: 'Profile',
                        onPressed: () => context.push('/profile'),
                      ),
                    ],
                  ),
                  if (_isSearching)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: theme.colorScheme.surface,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search users...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                    ),
                  usersAsync.when(
                    data: (users) {
                      final filteredUsers = _filterUsers(users);
                      final showLoadMore = ref.read(userListProvider.notifier).hasMore;

                      if (filteredUsers.isEmpty && _searchQuery.isNotEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No users found for "$_searchQuery"',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try a different search term',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (filteredUsers.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!.noUsersAvailable,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the + button to add your first user',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final isFooter = showLoadMore && index == filteredUsers.length;
                              if (isFooter) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: _loadingMore
                                        ? const CircularProgressIndicator()
                                        : const SizedBox.shrink(),
                                  ),
                                );
                              }
                              final user = filteredUsers[index];
                              return _UserCard(user: user, index: index);
                            },
                            childCount: filteredUsers.length + (showLoadMore ? 1 : 0),
                          ),
                        ),
                      );
                    },
                    loading: () => SliverFillRemaining(
                      child: Center(
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
                              'Loading users...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    error: (e, _) => SliverFillRemaining(
                      child: Center(
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
                              AppLocalizations.of(context)!.errorLoadingUsers,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$e',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => ref.read(userListProvider.notifier).refresh(),
                              icon: const Icon(Icons.refresh),
                              label: Text(AppLocalizations.of(context)!.retryButton),
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
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: ScaleTransition(
            scale: _fabAnimation,
            child: FloatingActionButton.extended(
              onPressed: isConnected ? () => context.push('/create-user') : null,
              icon: const Icon(Icons.add),
              label: const Text('Add User'),
              backgroundColor: isConnected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.3),
              foregroundColor: isConnected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withOpacity(0.5),
              tooltip: isConnected ? 'Add User' : 'Add User (Offline - Not Available)',
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking connectivity...'),
            ],
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Connection Error'),
              const SizedBox(height: 8),
              Text('$error'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(connectivityStatusProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends ConsumerStatefulWidget {
  final User user;
  final int index;

  const _UserCard({required this.user, required this.index});

  @override
  ConsumerState<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends ConsumerState<_UserCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connectivityAsync = ref.watch(connectivityStatusProvider);

    return connectivityAsync.when(
      data: (isConnected) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildUserCard(theme, isOffline: !isConnected),
          ),
        );
      },
      loading: () => _buildUserCard(theme, isLoading: true),
      error: (error, stack) => _buildUserCard(theme, hasError: true),
    );
  }

  Widget _buildUserCard(ThemeData theme, {bool isOffline = false, bool isLoading = false, bool hasError = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shadowColor: theme.colorScheme.primary.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isOffline
              ? null
              : () => context.push(
                    '/user-detail/${widget.user.id ?? 0}',
                    extra: widget.user,
                  ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.2),
                        theme.colorScheme.secondary.withOpacity(0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      widget.user.avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 30,
                          color: theme.colorScheme.primary,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.user.firstName} ${widget.user.lastName}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isOffline
                              ? theme.colorScheme.onSurface.withOpacity(0.5)
                              : theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.user.email,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'ID: ${widget.user.id ?? 'N/A'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isOffline) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.wifi_off,
                                    size: 12,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Offline',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isOffline
                      ? theme.colorScheme.onSurface.withOpacity(0.2)
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
