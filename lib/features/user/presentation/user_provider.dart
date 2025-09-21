import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userflow/core/network/api_client.dart';
import 'package:userflow/features/user/data/user_repository.dart';
import 'package:userflow/features/user/domain/user_model.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final userRepositoryProvider = Provider<UserRepository>(
        (ref) => UserRepository(ref.read(apiClientProvider)));

class UserListNotifier extends AutoDisposeAsyncNotifier<List<User>> {
  final List<User> _users = [];
  int _page = 1;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  Future<List<User>> build() async {
    return _fetch(reset: true);
  }

  Future<List<User>> _fetch({bool reset = false}) async {
    final repo = ref.read(userRepositoryProvider);

    if (reset) {
      _page = 1;
      _users.clear();
      _hasMore = true;
    }

    if (!_hasMore) return _users;

    try {
      final newUsers = await repo.getUsers(_page);
      if (newUsers.isEmpty) {
        _hasMore = false;
      } else {
        _users.addAll(newUsers);
        _page++;
      }
      state = AsyncData([..._users]);
      return _users;
    } catch (e, st) {
      state = AsyncError(e, st);
      return _users;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      await _fetch(reset: true);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> fetchNextPage() async {
    if (!_hasMore || state.isLoading) return;
    try {
      await _fetch();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void addUser(User user) {
    _users.insert(0, user);
    state = AsyncData([..._users]);
  }

  void updateUser(User user) {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      state = AsyncData([..._users]);
    }
  }

  void removeUser(int userId) {
    _users.removeWhere((u) => u.id == userId);
    state = AsyncData([..._users]);
  }
}

final userListProvider =
AutoDisposeAsyncNotifierProvider<UserListNotifier, List<User>>(UserListNotifier.new);

final userDetailProvider =
FutureProvider.autoDispose.family<User, int>((ref, userId) async {
  final repository = ref.read(userRepositoryProvider);
  return repository.getUser(userId);
});