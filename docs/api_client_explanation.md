# شرح ملف api_client.dart

## نظرة عامة

هذا الملف ينفذ طبقة عميل HTTP باستخدام مكتبة Dio للتعامل مع خادم API في تطبيق Flutter.

---

##的目的

يوفر:
- واجهة مجردة (Interface) لعمليات HTTP
- تنفيذ فعلي باستخدام Dio
- معالجة متقدمة للأخطاء
- إدارة timeout والاتصال
- تسجيل الطلبات والاستجابات

---

## الواجهة: IApiClient

واجهة مجردة تعرف контракт لعمليات HTTP الأساسية. تسمح بتغيير تطبيق HTTP (Dio, http package, etc.) دون تغيير كود العميل.

### العمليات المحددة:

```dart
abstract class IApiClient {
  // GET - قراءة بيانات
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Duration? timeout,
  );

  // POST - إرسال بيانات جديدة
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Duration? timeout,
  );

  // PUT - تحديث بيانات موجودة
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Duration? timeout,
  );

  // DELETE - حذف بيانات
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Duration? timeout,
  );

  // PATCH - تحديث جزئي
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Duration? timeout,
  );
}
```

---

## الكلاس: DioApiClient

تنفيذ الواجهة باستخدام مكتبة Dio.

### الخصائص:

```dart
class DioApiClient implements IApiClient {
  late final Dio _dio;           // كائن Dio الداخلي
  final String baseUrl;          // عنوان API الأساسي
  final Map<String, String> defaultHeaders; // الترويسات الافتراضية
}
```

### المُنشئ (Constructor):

```dart
DioApiClient({
  required this.baseUrl,
  Map<String, String>? defaultHeaders,
})
```

- **baseUrl**: مطلوب - عنوان API الأساسي
- **defaultHeaders**: اختياري - ترويسات تُضاف لكل الطلبات

---

## إنشاء كائن Dio

```dart
Dio _createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: NetworkConstants.defaultTimeout,
      receiveTimeout: NetworkConstants.defaultTimeout,
      sendTimeout: NetworkConstants.defaultTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...defaultHeaders,
      },
    ),
  );
  // إضافة interceptors للتسجيل والمعالجة
  return dio;
}
```

**إعدادات BaseOptions:**
- `baseUrl`: عنوان API الأساسي
- `connectTimeout`: مهلة الاتصال (30 ثانية افتراضياً)
- `receiveTimeout`: مهلة استلام البيانات
- `sendTimeout`: مهلة إرسال البيانات
- `headers`: ترويسات HTTP الافتراضية

---

## الـ Interceptors

```dart
dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) {
      _logRequest(options);
      handler.next(options);
    },
    onResponse: (response, handler) {
      _logResponse(response);
      handler.next(response);
    },
    onError: (error, handler) {
      _logError(error);
      handler.next(error);
    },
  ),
);
```

### أنواع الـ Interceptors:
1. **onRequest**: يُستدعى قبل إرسال الطلب
2. **onResponse**: يُستدعى عندReceive الاستجابة
3. **onError**: يُستدعى عند حدوث خطأ

---

## تنفيذ عمليات HTTP

### مثال: GET

```dart
@override
Future<ApiResponse<T>> get<T>(
  String path, {
  Map<String, dynamic>? queryParameters,
  Map<String, dynamic>? headers,
  Duration? timeout,
}) async {
  return _request<T>(
    method: 'GET',
    path: path,
    queryParameters: queryParameters,
    headers: headers,
    timeout: timeout,
  );
}
```

جميع العمليات (get, post, put, delete, patch) تستخدم نفس الدالة `_request`.

---

## دالة الطلب الأساسية: _request

```dart
Future<ApiResponse<T>> _request<T>({
  required String method,
  required String path,
  dynamic data,
  Map<String, dynamic>? queryParameters,
  Map<String, dynamic>? headers,
  Duration? timeout,
}) async {
  try {
    final options = Options(
      method: method,
      headers: headers,
      sendTimeout: timeout ?? NetworkConstants.defaultTimeout,
      receiveTimeout: timeout ?? NetworkConstants.defaultTimeout,
    );

    final response = await _dio.request<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );

    return ApiResponse<T>.fromHttpResponse(...);
  } on DioException catch (e) {
    throw _handleDioError(e, path);
  } catch (e) {
    throw NetworkException(...);
  }
}
```

**الخطوات:**
1. إنشاء خيارات الطلب
2. تنفيذ الطلب عبر Dio
3. تحويل الاستجابة لـ ApiResponse
4. معالجة أخطاء Dio
5. معالجة الأخطاء العامة

---

## معالجة الأخطاء

### دالة _handleDioError

تحول أخطاء Dio إلى استثناءات مخصصة في التطبيق:

```dart
NetworkException _handleDioError(DioException error, String path) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return TimeoutException(...);

    case DioExceptionType.connectionError:
      return const NetworkException(msg: 'No internet connection');

    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode ?? 0;
      if (statusCode >= 500) {
        return ServerUnavailableException(...);
      }
      return ServerException(...);

    case DioExceptionType.cancel:
      return NetworkException(msg: 'Request cancelled');

    case DioExceptionType.unknown:
    default:
      return NetworkException(msg: error.message ?? 'Unknown network error');
  }
}
```

### أنواع الأخطاء:

| نوع الخطأ | الوصف | الاستثناء |
|-----------|-------|-----------|
| connectionTimeout | انتهاء مهلة الاتصال | TimeoutException |
| sendTimeout | انتهاء مهلة الإرسال | TimeoutException |
| receiveTimeout | انتهاء مهلة الاستلام | TimeoutException |
| connectionError | خطأ في الاتصال | NetworkException |
| badResponse | استجابة خطأ (4xx/5xx) | ServerException |
| cancel | إلغاء الطلب | NetworkException |
| unknown | خطأ غير معروف | NetworkException |

---

## استخراج رسالة الخطأ

```dart
String _extractErrorMessage(Response<dynamic>? response) {
  if (response?.data is Map) {
    final data = response!.data as Map;
    return data['message'] as String? ??
        data['error'] as String? ??
        'Server error';
  }
  return 'Server error';
}
```

تحاول استخراج رسالة الخطأ من:
1. حقل `message` في الاستجابة
2. حقل `error` في الاستجابة
3. رسالة افتراضية

---

## دوال التسجيل

```dart
void _logRequest(RequestOptions options) {
  print('[API] ${options.method} ${options.path}');
}

void _logResponse(Response<dynamic> response) {
  print('[API] Response ${response.statusCode}');
}

void _logError(DioException error) {
  print('[API] Error: ${error.message}');
}
```

---

## إدارة التوكن

```dart
void setAuthToken(String token) {
  _dio.options.headers['Authorization'] = 'Bearer $token';
}

void clearAuthToken() {
  _dio.options.headers.remove('Authorization');
}
```

---

## إغلاق العميل

```dart
void close() {
  _dio.close();
}
```

يُستدعى عند الانتهاء من استخدام العميل لتحرير الموارد.

---

## ملخص تدفق الطلب

```
1. استدعاء get/post/put/delete/patch
   ↓
2. استدعاء _request
   ↓
3. إنشاء Options مع timeout
   ↓
4. تنفيذ الطلب عبر Dio
   ↓
5. إذا نجح → تحويل لـ ApiResponse
   ↓
6. إذا فشل → _handleDioError → استثناء مخصص
   ↓
7. إرجاع النتيجة أو رمي الاستثناء
```

---

## مثال الاستخدام

```dart
// إنشاء العميل
final client = DioApiClient(
  baseUrl: 'https://api.example.com',
  defaultHeaders: {'Authorization': 'Bearer token'},
);

// طلب GET
final response = await client.get<List<User>>('/users');

// طلب POST
final newUser = await client.post<User>('/users', data: user.toJson());

// تحديث التوكن
client.setAuthToken('new_token');

// إغلاق العميل
client.close();
```