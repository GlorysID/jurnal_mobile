import 'package:isar/isar.dart';
import '../../core/utils/hash_util.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../database/isar_service.dart';
import '../models/user.dart';
import '../models/session.dart';

class AuthRepositoryImpl implements AuthRepository {
  final IsarService _isarService;

  AuthRepositoryImpl(this._isarService);

  @override
  Future<UserEntity?> login(String username, String password) async {
    final isar = await _isarService.db;
    final hashedPassword = HashUtil.hashPassword(password);

    final user = await isar.users
        .filter()
        .usernameEqualTo(username)
        .passwordHashEqualTo(hashedPassword)
        .findFirst();

    if (user != null) {
      await _saveSession(user.id);
      return UserEntity(
        id: user.id,
        username: user.username,
        createdAt: user.createdAt,
      );
    }
    return null;
  }

  @override
  Future<UserEntity> register(String username, String password) async {
    final isar = await _isarService.db;

    final existingUser = await isar.users
        .filter()
        .usernameEqualTo(username)
        .findFirst();
    if (existingUser != null) {
      throw Exception('Username already exists');
    }

    final hashedPassword = HashUtil.hashPassword(password);
    final newUser = User()
      ..username = username
      ..passwordHash = hashedPassword
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.users.put(newUser);
    });

    await _saveSession(newUser.id);

    return UserEntity(
      id: newUser.id,
      username: newUser.username,
      createdAt: newUser.createdAt,
    );
  }

  @override
  Future<UserEntity> updateProfile(int userId, String newUsername) async {
    final isar = await _isarService.db;
    final user = await isar.users.get(userId);
    if (user == null) throw Exception('User not found');

    if (user.username != newUsername) {
      final existingUser = await isar.users
          .filter()
          .usernameEqualTo(newUsername)
          .findFirst();
      if (existingUser != null) {
        throw Exception('Username already exists');
      }
    }

    user.username = newUsername;
    await isar.writeTxn(() async {
      await isar.users.put(user);
    });

    return UserEntity(
      id: user.id,
      username: user.username,
      createdAt: user.createdAt,
    );
  }

  @override
  Future<void> changePassword(
    int userId,
    String currentPassword,
    String newPassword,
  ) async {
    final isar = await _isarService.db;
    final user = await isar.users.get(userId);
    if (user == null) throw Exception('User not found');

    if (user.passwordHash != HashUtil.hashPassword(currentPassword)) {
      throw Exception('Current password is incorrect');
    }

    user.passwordHash = HashUtil.hashPassword(newPassword);
    await isar.writeTxn(() async {
      await isar.users.put(user);
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final isar = await _isarService.db;
    final session = await isar.sessions.get(1);

    if (session != null && session.currentUserId != null) {
      final user = await isar.users.get(session.currentUserId!);
      if (user != null) {
        return UserEntity(
          id: user.id,
          username: user.username,
          createdAt: user.createdAt,
        );
      }
    }
    return null;
  }

  @override
  Future<void> logout() async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      final session = await isar.sessions.get(1);
      if (session != null) {
        session.currentUserId = null;
        await isar.sessions.put(session);
      }
    });
  }

  Future<void> _saveSession(int userId) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      var session = await isar.sessions.get(1);
      session ??= Session()..id = 1;
      session.currentUserId = userId;
      await isar.sessions.put(session);
    });
  }
}
