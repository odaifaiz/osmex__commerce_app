# شرح ملف json_utils.dart

## نظرة عامة

هذا الملف يوفر أدوات مساعدة للتعامل مع بيانات JSON لنظام التخزين المؤقت (Offline Caching) في تطبيق Flutter.

---

## الاستيرادات (Imports)

```dart
import 'dart:convert';
import 'package:hive/hive.dart';
```

- **`dart:convert`**: مكتبة Dart الأساسية للتعامل مع JSON
- **`package:hive/hive.dart`**: مكتبة للتخزين المحلي السريع

---

## الكلاس الرئيسي: JsonUtils

فئة utiliti static توفر دوال مساعدة للتعامل مع JSON.

### الدوال المتاحة:

#### 1. `encode(dynamic data) -> String`
تحويل أي كائن إلى نص JSON.
- **المعاملات**: أي نوع من البيانات (Map, List, String, num, bool, null)
- **المثال**:
  ```dart
  String json = JsonUtils.encode({'name': 'Ahmed', 'age': 25});
  // النتيجة: '{"name":"Ahmed","age":25}'
  ```

#### 2. `decode(String jsonString) -> dynamic`
تحويل نص JSON إلى كائن Dart.
- **المعاملات**: نص JSON
- **المثال**:
  ```dart
  dynamic data = JsonUtils.decode('{"name":"Ahmed"}');
  // النتيجة: {name: Ahmed}
  ```

#### 3. `tryEncode(dynamic data) -> String?`
نفس `encode` ولكن ترجع `null` في حالة الخطأ بدلاً من رمي استثناء.
- **المثال**:
  ```dart
  String? result = JsonUtils.tryEncode(data);
  if (result == null) {
    print('فشل في التحويل');
  }
  ```

#### 4. `tryDecode(String jsonString) -> dynamic?`
نفس `decode` مع معالجة آمنة للخطأ.
- **المثال**:
  ```dart
  dynamic? data = JsonUtils.tryDecode('not valid json');
  // ترجع null بدلاً من خطأ
  ```

#### 5. `isValidJson(String jsonString) -> bool`
التحقق مما إذا كان النص JSON صالحاً.
- **المثال**:
  ```dart
  bool valid = JsonUtils.isValidJson('{"key": "value"}'); // true
  bool invalid = JsonUtils.isValidJson('not json'); // false
  ```

#### 6. `prettyPrint(dynamic data) -> String`
تنسيق JSON بشكل جميل وقابل للقراءة (مع مسافات بادئة).
- **المثال**:
  ```dart
  String formatted = JsonUtils.prettyPrint({'a': 1, 'b': 2});
  /*
  النتيجة:
  {
    "a": 1,
    "b": 2
  }
  */
  ```

#### 7. `createCachePayload(...) -> Map<String, dynamic>`
إنشاء هيكل بيانات التخزين المؤقت مع metadata.
- **المعاملات**:
  - `data`: البيانات المطلوبة للتخزين
  - `resourceKey`: مفتاح فريد للموارد
  - `cachedAt`: وقت التخزين (اختياري)
  - `expiresAt`: وقت الانتهاء (اختياري)
  - `version`: إصدار البيانات (اختياري)

---

## الـ Extensions

### 1. JsonStringExtension (على String)
إضافة دوال على نوع String:

```dart
extension JsonStringExtension on String {
  bool get isValidJson;      // التحقق من صحة JSON
  dynamic get asJson;        // فك ترميز JSON
  String get prettyPrint;    // تنسيق جميل
}
```

**المثال:**
```dart
String text = '{"name": "Ali"}';
print(text.isValidJson); // true
print(text.asJson);      // {name: Ali}
```

### 2. JsonExtension (على dynamic)
إضافة دالة لتحويل أي كائن إلى JSON:

```dart
extension JsonExtension on dynamic {
  String get asJsonString;
}
```

**المثال:**
```dart
Map data = {'x': 10};
String json = data.asJsonString; // '{"x":10}'
```

---

## محولات الأنواع (Type Adapters)

### 1. DateTimeAdapter
محول لتخزين كائنات DateTime في Hive.

```dart
class DateTimeAdapter extends TypeAdapter<DateTime> {
  @override
  final int typeId = 0;

  @override
  DateTime read(BinaryReader reader) {
    final milliseconds = reader.readInt();
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  @override
  void write(BinaryWriter writer, DateTime obj) {
    writer.writeInt(obj.millisecondsSinceEpoch);
  }
}
```

**آلية العمل:**
- تحويل DateTime إلى milliseconds عند الكتابة
- تحويل milliseconds إلى DateTime عند القراءة
- `typeId = 0`: معرف فريد لهذا المحول

### 2. DurationAdapter
محول لتخزين كائنات Duration في Hive.

```dart
class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final int typeId = 1;
  // نفس آلية DateTimeAdapter
}
```

---

## هيكل بيانات التخزين المؤقت

الهيكل الذي ينشئه `createCachePayload()`:

```json
{
  "resourceKey": "users_list",
  "data": { ... },
  "cachedAt": "2024-01-15T10:30:00Z",
  "expiresAt": "2024-01-16T10:30:00Z",
  "version": "1.0"
}
```

- **resourceKey**: مفتاح فريد لتعريف البيانات
- **data**: البيانات الفعلية المخزنة
- **cachedAt**: وقت التخزين
- **expiresAt**: وقت انتهاء الصلاحية (افتراضياً 24 ساعة)
- **version**: إصدار تنسيق البيانات

---

## ملخص الاستخدام

هذا الملف يوفر الأساس للتعامل مع:
1. **تحويل البيانات إلى/from JSON** للتخزين المؤقت
2. **معالجة آمنة للخطأ** باستخدام tryEncode/tryDecode
3. **التحقق من صحة JSON** قبل المعالجة
4. **تنسيق البيانات** للتصحيح والتطوير
5. **تخزين البيانات المعقدة** (DateTime, Duration) في Hive