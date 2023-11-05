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

    Map<String, dynamic> identityMap = {};

    // Split the string into parts using the '|' delimiter
    List<String> keyValuePairs = parsedValue.split('|');

    // Iterate over the key-value pairs
    for (String pair in keyValuePairs) {
      // Split the pair into key and value using the '=' delimiter
      List<String> keyAndValue = pair.split('=');
      
      // Check if we have exactly two elements: a key and a value
      if (keyAndValue.length == 2) {
        String key = keyAndValue[0];
        String value = keyAndValue[1];

        // Check if the key is 'roles', if so split the value by ','
        if (key == 'roles') {
          identityMap[key] = value.split(',');
        } else {
          identityMap[key] = value;
        }
      }
    }

    return identityMap;
  }

  return null;
}

Map<String, dynamic>? getIdentityCookie() {
  return null;
}

String? getCSRFCookie() {
  return null;
}
