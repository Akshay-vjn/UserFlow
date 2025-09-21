import 'package:userflow/core/network/api_client.dart';
import '../domain/user_model.dart';

class UserRepository {
  final ApiClient _apiClient;
  UserRepository(this._apiClient);

  Future<List<User>> getUsers(int page) async {
    final response = await _apiClient.get('/users', query: {'page': page.toString()});
    final List<dynamic> usersJson = response['data'] as List<dynamic>;
    return usersJson.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<User> getUser(int id) async {
    final response = await _apiClient.get('/users/$id');
    return User.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<User> createUser(User user) async {
    final response = await _apiClient.post('/users', {
      'name': '${user.firstName} ${user.lastName}',
      'job': 'leader',
    });
    final idStr = response['id']?.toString();
    final id = idStr == null ? null : int.tryParse(idStr);
    return User(
      id: id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      avatar: user.avatar,
    );
  }

  Future<User> updateUser(User user, {String job = 'zion resident'}) async {
    await _apiClient.put('/users/${user.id}', {
      'name': '${user.firstName} ${user.lastName}',
      'job': job,
    });
    return user;
  }

  Future<void> deleteUser(int id) async {
    await _apiClient.delete('/users/$id');
  }

}
