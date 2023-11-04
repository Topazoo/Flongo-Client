import 'package:http/browser_client.dart';

// Used by Flutter Web
// Use credentials to allow Cookie management
BrowserClient getCustomClient() => BrowserClient()..withCredentials=true;
