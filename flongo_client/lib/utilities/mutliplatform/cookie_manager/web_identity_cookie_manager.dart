import 'dart:html';
import 'package:flongo_client/utilities/mutliplatform/cookie_manager/mobile_identity_cookie_manager.dart';
export 'package:flongo_client/utilities/mutliplatform/cookie_manager/mobile_identity_cookie_manager.dart' show parseIdentityAndRole;
export 'package:flongo_client/utilities/mutliplatform/cookie_manager/mobile_identity_cookie_manager.dart' show parseCookieToken;

Map<String, dynamic>? getIdentityCookie() {
  if (document.cookie!.contains('identity_cookie=')) {
    return parseIdentityAndRole(document.cookie);
  }

  return null;
}

String? getCSRFCookie() {
  if (document.cookie!.contains('csrf_access_token=')) {
    return parseCookieToken(document.cookie, cookieName: "csrf_access_token")?.split("=")[1];
  }

  return null;
}
