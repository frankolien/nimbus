import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

/// Thrown when a request ultimately fails after exhausting retries.
class NetworkException implements Exception {
  NetworkException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => 'NetworkException($statusCode): $message';
}

/// A thin HTTP client that makes every request survivable: a hard timeout,
/// bounded retries with exponential backoff + jitter, and retry only on
/// transient failures (5xx, 429, timeouts, socket errors). Per the project
/// rule: "Network calls without timeout + retry don't exist."
class ResilientHttp {
  ResilientHttp({
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 300),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;
  final int maxRetries;
  final Duration baseDelay;
  final _rng = Random();

  Future<dynamic> getJson(Uri url, {Map<String, String>? headers}) {
    return _send(() => _client.get(url, headers: headers), url.host);
  }

  Future<dynamic> postJson(
    Uri url,
    Object body, {
    Map<String, String>? headers,
  }) {
    final merged = {'Content-Type': 'application/json', ...?headers};
    return _send(
      () => _client.post(url, headers: merged, body: jsonEncode(body)),
      url.host,
    );
  }

  Future<dynamic> _send(Future<http.Response> Function() request, String host) async {
    var attempt = 0;
    while (true) {
      try {
        final res = await request().timeout(timeout);
        if (res.statusCode >= 200 && res.statusCode < 300) {
          return res.body.isEmpty ? null : jsonDecode(res.body);
        }
        if (_retriableStatus(res.statusCode) && attempt < maxRetries) {
          attempt++;
          await _backoff(attempt);
          continue;
        }
        throw NetworkException('$host returned ${res.statusCode}',
            statusCode: res.statusCode);
      } on TimeoutException {
        if (attempt >= maxRetries) {
          throw NetworkException('$host timed out after $maxRetries retries');
        }
        attempt++;
        await _backoff(attempt);
      } on SocketException {
        if (attempt >= maxRetries) {
          throw NetworkException('$host unreachable');
        }
        attempt++;
        await _backoff(attempt);
      } on http.ClientException {
        if (attempt >= maxRetries) {
          throw NetworkException('$host connection failed');
        }
        attempt++;
        await _backoff(attempt);
      }
    }
  }

  bool _retriableStatus(int code) => code == 429 || (code >= 500 && code < 600);

  /// Exponential backoff with full jitter: delay in [0, base * 2^attempt).
  Future<void> _backoff(int attempt) {
    final ceiling = baseDelay.inMilliseconds * (1 << attempt);
    final ms = _rng.nextInt(ceiling.clamp(1, 8000));
    return Future.delayed(Duration(milliseconds: ms));
  }

  void close() => _client.close();
}
