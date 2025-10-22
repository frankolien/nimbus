import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:web3dart/web3dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../configs/env_config.dart';

// External dependencies
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final web3ClientProvider = Provider<Web3Client>((ref) {
  return Web3Client(
    EnvConfig.polygonRpcUrl,
    http.Client(),
  );
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Initialize SharedPreferences
final sharedPreferencesFutureProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});
