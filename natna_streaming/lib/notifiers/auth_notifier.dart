import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_services.dart';
import '../utils/auth_utils.dart';
import '../utils/error_utils.dart';

final apiServiceProvider = Provider<AuthServices>((ref) => AuthServices());
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

class AuthState {
  final User? user;
  final String? token;
  final bool? isLoading;
  final String? error;
  final String? userId;

  AuthState({this.user, this.token, this.error, this.isLoading, this.userId});

  AuthState copyWith({
    User? user,
    String? token,
    String? error,
    bool? isLoading,
    String? userId,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isAuthenticated => token != null && userId != null;
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  final _authChangeController = StreamController<AuthState>.broadcast();

  @override
  Future<AuthState> build() async {
    final token = AuthUtils.getToken();
    final userId = AuthUtils.getUserId();
    final initialState = AuthState(
      token: token,
      userId: userId,
      user: null,
      error: null,
    );
    _authChangeController.add(initialState);
    return initialState;
  }

  void initialize(String token, String userId) {
    state = AsyncData(AuthState(token: token, userId: userId));
  }

  Future<void> signup(String fullName, String email, String password) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, error: null));
    try {
      final response = await ref
          .read(apiServiceProvider)
          .register(email, password, fullName);

      final user = User.fromJson(response["user"]);
      final token = response["token"];
      state = AsyncData(
        state.value!.copyWith(
          user: user,
          token: token,
          error: null,
          isLoading: false,
          userId: user.id,
        ),
      );
    } catch (err) {
      final errorMessage = ErrorUtils.parseAuthError(err.toString());

      state = AsyncData(
        state.value!.copyWith(isLoading: false, error: errorMessage),
      );
      // AsyncError(err, stack);
      throw errorMessage;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final response = await ref
          .read(apiServiceProvider)
          .login(email, password);

      final user = User.fromJson(response["user"]);
      final token = response["token"];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("jwt_token", token);
      await prefs.setString("userId", user.id);

      final loginState = AuthState(token: token, user: user, userId: user.id);

      state = AsyncData(loginState);
      _authChangeController.add(loginState);
    } catch (err, stack) {
      log("Error in notifier: $err");
      final errorMessage = ErrorUtils.parseAuthError(err.toString());
      state = AsyncError(errorMessage, stack);
      throw errorMessage;
    }
  }

  Future<bool> verifyPin(String pin) async {
    return ref.read(apiServiceProvider).verifyPin(pin);
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await AuthUtils.clearData();
      final logoutState = AuthState(
        token: null,
        userId: null,
        user: null,
        isLoading: false,
        error: null,
      );

      state = AsyncData(logoutState);
      _authChangeController.add(logoutState);
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  void cleanError() {
    state = AsyncData(state.value!.copyWith(error: null));
    _authChangeController.close();
  }

  Stream<AuthState> get authChanges => _authChangeController.stream;
}
