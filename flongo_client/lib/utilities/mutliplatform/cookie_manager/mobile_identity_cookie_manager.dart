String? parseCookieToken(String? cookieHeader, {String cookieName='access_token_cookie'}) {
  if (cookieHeader != null) {
    int startIndex = cookieHeader.indexOf(cookieName);
    if (startIndex >= 0) {
      String fromCookie = cookieHeader.substring(startIndex);

      int endIndex = fromCookie.indexOf(";");
      return fromCookie.substring(0, endIndex);
    }
  }

  return null;
}

Map<String, dynamic>? parseIdentityAndRole(String? rawCookie) {
  String? rawIdAndRole = rawCookie?.split('identity_cookie=')[1].split(';')[0];
  if (rawIdAndRole != null && rawIdAndRole.isNotEmpty) {
    final parsedValue = (rawIdAndRole.startsWith('"') && rawIdAndRole.endsWith('"')) ?
      rawIdAndRole.substring(1, rawIdAndRole.length - 1) : rawIdAndRole;

    final parts = parsedValue.split('|');

    return {
      'identity':  parts[0],
      'roles': parts[1].split('=')[1].split(',')
    };
  }

  return null;
}

Map<String, dynamic>? getIdentityCookie() {
  return null;
}

String? getCSRFCookie() {
  return null;
}
