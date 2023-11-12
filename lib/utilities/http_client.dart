import 'dart:async';

import 'mutliplatform/base_http_client_factory.dart';
import 'mutliplatform/cookie_service_factory.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';


class HTTPClient {
  static final env = dotenv.env;
  final String baseUrl;
  final http.Client _client = getCustomClient();
  final Duration timeoutDuration;
  static final Map<String, String> _headers = {
    'accept': 'application/json',
  };

  static String? _accessCookie;
  static String? _csrfCookie;
  static String? _identity;
  static List<String>? _roles;

  // Authed user details
  static String? username;
  static String? email;


  HTTPClient(String url)
        : baseUrl = '${env['APP_API_URL']}/${url.startsWith("/") ? url.substring(1) : url}',
        timeoutDuration = Duration(milliseconds: int.parse(env['APP_API_TIMEOUT_MS'] ?? '3000')) {

    if (_accessCookie != null) {
      _setAccessCookie(_accessCookie!);
    }

    if (_csrfCookie != null) {
      _setCSRFCookie(_csrfCookie!);
    } else {
      String? csrfCookie = getCSRFCookie();
      if (csrfCookie != null && csrfCookie.isNotEmpty) {
        _setCSRFCookie(csrfCookie);
      }
    }
  }

  void _setAccessCookie(String cookie) {
    _accessCookie = cookie;
    _headers['cookie'] = cookie;
  }

  void _setCSRFCookie(String cookie) {
    _csrfCookie = cookie;
    _headers['X-CSRF-TOKEN'] = cookie;
  }

  static void deAuthenticate() {
    _accessCookie = null;
    _csrfCookie = null;
    _identity = null;
    _roles = null;

    username = null;
    email = null;

    _headers.remove('cookie');
    _headers.remove('X-CSRF-TOKEN');
  }

  static bool isAuthenticated() {
    // If there is a cookie set for the application or an identity cookie present in
    // the browser cookies

    if (_accessCookie != null) {
      return true;
    }

    if (_identity != null) {
      return true;
    }

    // Lazy load for web browsers
    return _setIdentityData(getIdentityCookie());
  }

  static bool _setIdentityData(Map<String, dynamic>? identityData){
    if (identityData != null) {
      _identity = identityData['_id'];
      _roles = identityData['roles'];

      username = identityData['username'];
      email = identityData['email'];

      return true;
    }

    return false;
  }

  static bool isAdminAuthenticated() {
    return (isAuthenticated() && (_roles!.contains("admin") || _roles!.contains("Admin")));
  }

  static String? getIdentity() {
    return _identity;
  }

  static String? getUsername() {
    return username;
  }

  static String? getEmail() {
    return email;
  }

  static String getRoles() {
    return _roles.toString();
  }

  Future<void> login(String username, String password, Function? onSuccess, Function? onError) async {
    await post(
      body: {
        'username': username,
        'password': password,
      },
      onSuccess: (response) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          onSuccess?.call(response);
        } else {
          onError?.call(response);
        }
      },
      onError: (response) {
        onError?.call(response);
      }
    );
  }

  Future<void> logout(Function? onSuccess, Function? onError) async {
    await delete(
      onSuccess: (response) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          deAuthenticate();
          onSuccess?.call(response);
        } else {
          onError?.call(response);
        }
      },
      onError: (response) {
        deAuthenticate();
        onError?.call(response);
      }
    );
  }

  Future<void> _requestWrapper(Function requestFunc, {Function? onSuccess, Function? onError}) async {
    try {
      var response = await requestFunc().timeout(timeoutDuration);
      _handleResponse(response, onSuccess, onError);
    } catch (e) {
      int code = 500;
      String message = 'An unexpected error occurred';
      String details = '$e';

      if (e is http.ClientException) {
        message = 'Failed to connect to server [$baseUrl]';
        code = 400;
      } else if (e is TimeoutException) {
        message = 'Request timed out';
        code = 408;
      }

      onError?.call(http.Response(jsonEncode({'error': message, 'traceback': details}), code));
    }
  }

  void _handleResponse(http.Response response, Function? onSuccess, Function? onError) {
    if (response.statusCode == 401) {
      // Invalidate the cookie and set authenticated to false for 401 Unauthorized response
      deAuthenticate();
    } else {
      _updateCookie(response);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (onSuccess != null) onSuccess(response);
    } else {
      if (onError != null) onError(response);
    }
  }

  void _updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    String? accessTokenCookie = parseCookieToken(rawCookie);
    if (accessTokenCookie != null && accessTokenCookie.isNotEmpty) {
      _setAccessCookie(accessTokenCookie);
      _setIdentityData(parseIdentityAndRole(rawCookie));

      String? csrfTokenCookie = parseCookieToken(rawCookie, cookieName: "csrf_access_token");
      if (csrfTokenCookie != null && csrfTokenCookie.isNotEmpty) {
        _setCSRFCookie(csrfTokenCookie.split("=")[1]);
      }
    }
  }

  Map<String, String> setJSONContentTypeHeader(Map<String, dynamic>? body) {
    if (body != null) {
      Map<String, String> headers = Map<String, String>.from(_headers);
      headers['content-type'] = 'application/json';

      return headers;
    }

    return _headers;
  }


  Future<void> get({Map<String, String>? queryParams, Function? onSuccess, Function? onError}) {
    return _requestWrapper(() {
      var uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      return _client.get(uri, headers: _headers);
    }, onSuccess: onSuccess, onError: onError);
  }

  Future<void> post({Map<String, dynamic>? body, Function? onSuccess, Function? onError}) {
    return _requestWrapper(() {
      return _client.post(
        Uri.parse(baseUrl),
        headers: setJSONContentTypeHeader(body),
        body: json.encode(body),
      );
    }, onSuccess: onSuccess, onError: onError);
  }

  Future<void> put({Map<String, dynamic>? body, Function? onSuccess, Function? onError}) {
    return _requestWrapper(() {
      return _client.put(
        Uri.parse(baseUrl),
        headers: setJSONContentTypeHeader(body),
        body: json.encode(body),
      );
    }, onSuccess: onSuccess, onError: onError);
  }

  Future<void> patch({Map<String, dynamic>? body, Function? onSuccess, Function? onError}) {
    return _requestWrapper(() {
      return _client.patch(
        Uri.parse(baseUrl),
        headers: setJSONContentTypeHeader(body),
        body: json.encode(body),
      );
    }, onSuccess: onSuccess, onError: onError);
  }

  Future<void> delete({Map<String, String>? queryParams, Function? onSuccess, Function? onError}) {
    return _requestWrapper(() {
      var uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      return _client.delete(uri, headers: _headers);
    }, onSuccess: onSuccess, onError: onError);
  }
}
