# OneApp Integration Technical Guide

This technical guide provides detailed information for developers integrating the Member Staff module into the OneApp.

## Technical Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        OneApp (Parent)                       │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │             │    │             │    │                 │  │
│  │   Auth      │    │  Navigation │    │  Core Services  │  │
│  │   Service   │    │  Service    │    │                 │  │
│  │             │    │             │    │                 │  │
│  └──────┬──────┘    └──────┬──────┘    └────────┬────────┘  │
│         │                  │                    │           │
│         └──────────────────┼────────────────────┘           │
│                            │                                │
│                    ┌───────▼───────┐                        │
│                    │               │                        │
│                    │  Module       │                        │
│                    │  Registry     │                        │
│                    │               │                        │
│                    └───────┬───────┘                        │
│                            │                                │
└────────────────────────────┼────────────────────────────────┘
                             │
                  ┌──────────▼──────────┐
                  │                     │
                  │   Member Staff      │
                  │   Module            │
                  │                     │
                  └─────────┬───────────┘
                            │
                  ┌─────────▼───────────┐
                  │                     │
                  │   Member Staff      │
                  │   API               │
                  │                     │
                  └─────────────────────┘
```

### Data Flow Diagram

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│             │      │             │      │             │
│  OneApp     │ JWT  │  Member     │ HTTP │  Member     │
│  Auth       ├─────►│  Staff      ├─────►│  Staff      │
│  Service    │ Token│  Module     │ API  │  API        │
│             │      │             │      │             │
└─────────────┘      └──────┬──────┘      └─────────────┘
                            │
                            │ User
                            │ Interaction
                            ▼
                     ┌─────────────┐
                     │             │
                     │  OneApp     │
                     │  UI         │
                     │             │
                     └─────────────┘
```

## Code Integration

### 1. Module Registration

The Member Staff module needs to be registered with the OneApp's module registry. This allows the OneApp to manage the module's lifecycle and navigation.

```dart
// In your OneApp's module registry
class ModuleRegistry {
  static final Map<String, ModuleBuilder> _modules = {};

  static void registerModule(String name, ModuleBuilder builder) {
    _modules[name] = builder;
  }

  static Widget? buildModule(String name, BuildContext context) {
    final builder = _modules[name];
    return builder?.call(context);
  }
}

// Register the Member Staff module
void registerMemberStaffModule() {
  ModuleRegistry.registerModule('member_staff', (context) {
    return const MemberStaffModule(
      baseUrl: ApiConfig.memberStaffApiUrl,
    );
  });
}
```

### 2. Authentication Integration

The Member Staff module needs to access the OneApp's authentication token. Implement a bridge between the OneApp's authentication service and the Member Staff module's TokenManager.

```dart
// In your OneApp's authentication service
class AuthBridge {
  static Future<void> syncTokenWithMemberStaffModule() async {
    final token = await OneAppAuthService.getToken();
    await TokenManager.saveAuthToken(token);
    
    // Set up a listener for token changes
    OneAppAuthService.addTokenChangeListener((newToken) {
      TokenManager.saveAuthToken(newToken);
    });
  }
}
```

### 3. API Gateway Configuration

Configure your API gateway to route Member Staff API requests to the correct backend.

```javascript
// Example API gateway configuration (Express.js)
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();

// Proxy Member Staff API requests
app.use('/api/member-staff', createProxyMiddleware({
  target: 'https://member-staff-api.example.com',
  changeOrigin: true,
  pathRewrite: {
    '^/api/member-staff': '/api', // Rewrite path
  },
  onProxyReq: (proxyReq, req, res) => {
    // Forward authentication headers
    if (req.headers.authorization) {
      proxyReq.setHeader('Authorization', req.headers.authorization);
    }
  },
}));

app.listen(3000);
```

### 4. Deep Linking Implementation

Implement deep linking to specific screens within the Member Staff module.

```dart
// In your OneApp's route handler
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');
    
    // Handle Member Staff module deep links
    if (uri.path.startsWith('/member-staff')) {
      // Extract parameters
      final params = uri.queryParameters;
      
      // Determine which screen to show
      if (uri.path == '/member-staff/verify') {
        return MaterialPageRoute(
          builder: (context) => MemberStaffModule(
            baseUrl: ApiConfig.memberStaffApiUrl,
            initialRoute: 'verify',
            params: params,
          ),
        );
      } else if (uri.path == '/member-staff/schedule') {
        return MaterialPageRoute(
          builder: (context) => MemberStaffModule(
            baseUrl: ApiConfig.memberStaffApiUrl,
            initialRoute: 'schedule',
            params: params,
          ),
        );
      }
      
      // Default to main screen
      return MaterialPageRoute(
        builder: (context) => MemberStaffModule(
          baseUrl: ApiConfig.memberStaffApiUrl,
        ),
      );
    }
    
    // Handle other routes
    // ...
  }
}
```

## Technical Implementation Details

### 1. Token Management

The Member Staff module uses the `TokenManager` class to handle JWT tokens. This class needs to be integrated with the OneApp's authentication system.

```dart
// In the Member Staff module's TokenManager
class TokenManager {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'oneapp_auth_token';
  
  // Cache for decoded token
  static Map<String, dynamic>? _cachedDecodedToken;
  
  // Get the auth token from secure storage
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  // Save the auth token to secure storage
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    _cachedDecodedToken = null; // Clear cache when setting new token
  }
  
  // Get the decoded token
  static Future<Map<String, dynamic>?> getDecodedToken() async {
    if (_cachedDecodedToken != null) return _cachedDecodedToken;
    
    final token = await getAuthToken();
    if (token == null) return null;
    
    try {
      _cachedDecodedToken = JwtDecoder.decode(token);
      return _cachedDecodedToken;
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }
  
  // Get member context from token
  static Future<Map<String, dynamic>> getMemberContext() async {
    final decodedToken = await getDecodedToken();
    if (decodedToken == null) return {};
    
    return {
      'member_id': decodedToken['member_id'],
      'unit_id': decodedToken['unit_id'],
      'company_id': decodedToken['company_id'],
    };
  }
}
```

### 2. API Client Configuration

The Member Staff module's API client needs to be configured to work with the OneApp's API gateway.

```dart
// In the Member Staff module's ApiClient
class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  
  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();
  
  // Get headers for API requests, including auth token
  Future<Map<String, String>> _getHeaders() async {
    final authHeaders = await TokenManager.getAuthHeader();
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...authHeaders,
    };
  }
  
  // Enrich request body with member context
  Future<Map<String, dynamic>> _enrichRequestBody(Map<String, dynamic> body) async {
    final memberContext = await TokenManager.getMemberContext();
    
    // Only add context fields that aren't already in the body
    memberContext.forEach((key, value) {
      if (!body.containsKey(key)) {
        body[key] = value;
      }
    });
    
    return body;
  }
  
  // Make a GET request
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    // Implementation...
  }
  
  // Make a POST request
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    // Implementation...
  }
  
  // Make a PUT request
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    // Implementation...
  }
  
  // Make a DELETE request
  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? body}) async {
    // Implementation...
  }
}
```

### 3. Module Initialization

The Member Staff module needs to be initialized with the correct configuration when it's loaded by the OneApp.

```dart
// In the Member Staff module's entry point
class MemberStaffModule extends StatefulWidget {
  final String baseUrl;
  final String? initialRoute;
  final Map<String, String>? params;
  
  const MemberStaffModule({
    Key? key,
    required this.baseUrl,
    this.initialRoute,
    this.params,
  }) : super(key: key);
  
  @override
  State<MemberStaffModule> createState() => _MemberStaffModuleState();
}

class _MemberStaffModuleState extends State<MemberStaffModule> {
  late ApiClient _apiClient;
  late MemberStaffApi _memberStaffApi;
  late MemberStaffProvider _memberStaffProvider;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize API client
    _apiClient = ApiClient(baseUrl: widget.baseUrl);
    
    // Initialize Member Staff API
    _memberStaffApi = MemberStaffApi(apiClient: _apiClient);
    
    // Initialize provider
    _memberStaffProvider = MemberStaffProvider(api: _memberStaffApi);
    
    // Handle initial route if provided
    if (widget.initialRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleInitialRoute();
      });
    }
  }
  
  void _handleInitialRoute() {
    // Navigate to the initial route
    switch (widget.initialRoute) {
      case 'verify':
        // Navigate to verification screen
        break;
      case 'schedule':
        // Navigate to schedule screen
        break;
      default:
        // Default to main screen
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: _apiClient),
        Provider<MemberStaffApi>.value(value: _memberStaffApi),
        ChangeNotifierProvider<MemberStaffProvider>.value(value: _memberStaffProvider),
      ],
      child: MaterialApp(
        // Module configuration
        home: MobileVerificationScreen(),
        // Disable navigation bar and other OneApp UI elements
        builder: (context, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Member Staff'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: child,
          );
        },
      ),
    );
  }
}
```

## Performance Considerations

### 1. Lazy Loading

To improve the OneApp's startup time, implement lazy loading for the Member Staff module:

```dart
// In your OneApp's module registry
class LazyModule extends StatefulWidget {
  final String moduleName;
  final Map<String, dynamic>? params;
  
  const LazyModule({
    Key? key,
    required this.moduleName,
    this.params,
  }) : super(key: key);
  
  @override
  State<LazyModule> createState() => _LazyModuleState();
}

class _LazyModuleState extends State<LazyModule> {
  late Future<Widget> _moduleFuture;
  
  @override
  void initState() {
    super.initState();
    _moduleFuture = _loadModule();
  }
  
  Future<Widget> _loadModule() async {
    // Simulate loading delay for demonstration
    await Future.delayed(Duration(milliseconds: 100));
    
    // Load the module
    return ModuleRegistry.buildModule(widget.moduleName, context) ?? 
        Container(child: Text('Module not found'));
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _moduleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error loading module: ${snapshot.error}'));
        }
        
        return snapshot.data ?? Container();
      },
    );
  }
}
```

### 2. Memory Management

Implement proper memory management to ensure the Member Staff module doesn't cause memory leaks:

```dart
// In the Member Staff module's entry point
@override
void dispose() {
  // Dispose of resources
  _memberStaffProvider.dispose();
  super.dispose();
}
```

### 3. API Caching

Implement API response caching to improve performance:

```dart
// In the Member Staff module's ApiClient
class ApiCache {
  static final Map<String, CacheEntry> _cache = {};
  
  static void set(String key, dynamic data, {Duration? expiry}) {
    final expiryTime = expiry != null ? DateTime.now().add(expiry) : null;
    _cache[key] = CacheEntry(data, expiryTime);
  }
  
  static dynamic get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    if (entry.expiryTime != null && DateTime.now().isAfter(entry.expiryTime!)) {
      _cache.remove(key);
      return null;
    }
    
    return entry.data;
  }
  
  static void clear() {
    _cache.clear();
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime? expiryTime;
  
  CacheEntry(this.data, this.expiryTime);
}
```

## Security Considerations

### 1. Token Storage

Ensure that JWT tokens are stored securely:

```dart
// In the Member Staff module's TokenManager
static Future<void> saveToken(String token) async {
  // Use secure storage with encryption
  await _secureStorage.write(
    key: _tokenKey,
    value: token,
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
}
```

### 2. API Communication

Ensure all API communication is secure:

```dart
// In the Member Staff module's ApiClient
Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
  final uri = Uri.https(baseUrl, endpoint, queryParams?.map(
    (key, value) => MapEntry(key, value.toString())
  ));
  
  // Rest of the implementation...
}
```

### 3. Input Validation

Implement proper input validation:

```dart
// In the Member Staff module's screens
String? validateMobile(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a mobile number';
  }
  
  if (value.length != 10) {
    return 'Please enter a valid 10-digit mobile number';
  }
  
  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
    return 'Please enter only digits';
  }
  
  return null;
}
```

## Error Handling

Implement proper error handling to ensure a good user experience:

```dart
// In the Member Staff module's ApiClient
Future<dynamic> _handleResponse(http.Response response) {
  if (response.statusCode >= 200 && response.statusCode < 300) {
    // Success
    return jsonDecode(response.body);
  } else if (response.statusCode == 401) {
    // Unauthorized - token expired or invalid
    throw ApiException(
      message: 'Unauthorized: Please log in again',
      statusCode: response.statusCode,
      isAuthError: true,
    );
  } else if (response.statusCode == 403) {
    // Forbidden - insufficient permissions
    throw ApiException(
      message: 'Forbidden: You do not have permission to access this resource',
      statusCode: response.statusCode,
    );
  } else {
    // Other errors
    String errorMessage = 'Unknown error';
    try {
      final errorData = jsonDecode(response.body);
      errorMessage = errorData['message'] ?? errorMessage;
    } catch (e) {
      // Ignore JSON parsing errors
    }
    
    throw ApiException(
      message: errorMessage,
      statusCode: response.statusCode,
    );
  }
}
```

## Monitoring and Analytics

Implement monitoring and analytics to track usage and errors:

```dart
// In the Member Staff module's ApiClient
Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
  final startTime = DateTime.now();
  
  try {
    final result = await _get(endpoint, queryParams: queryParams);
    
    // Log successful API call
    final duration = DateTime.now().difference(startTime);
    Analytics.logApiCall(
      endpoint: endpoint,
      method: 'GET',
      duration: duration,
      success: true,
    );
    
    return result;
  } catch (e) {
    // Log failed API call
    final duration = DateTime.now().difference(startTime);
    Analytics.logApiCall(
      endpoint: endpoint,
      method: 'GET',
      duration: duration,
      success: false,
      error: e.toString(),
    );
    
    rethrow;
  }
}
```

## Conclusion

This technical guide provides detailed information for integrating the Member Staff module into the OneApp. By following these guidelines, you can ensure a smooth integration with proper authentication, API communication, and user experience.

Remember to thoroughly test the integration before deploying to production, and to monitor the module's performance and usage after deployment.
