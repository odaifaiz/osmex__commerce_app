import 'dart:convert';

/// JSON serialization utilities for the caching system.
///
/// Provides helper methods for serializing and deserializing
/// JSON data for caching purposes.
class JsonUtils {
  JsonUtils._();

  /// Encodes an object to JSON string.
  ///
  /// Handles various types including:
  /// - Map
  /// - List
  /// - String
  /// - num
  /// - bool
  /// - null
  static String encode(dynamic data) {
    return jsonEncode(data);
  }

  /// Decodes a JSON string to dynamic object.
  ///
  /// Returns a Map or List depending on the JSON content.
  static dynamic decode(String jsonString) {
    return jsonDecode(jsonString);
  }

  /// Safely encodes data, returning null on failure.
  static String? tryEncode(dynamic data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      return null;
    }
  }

  /// Safely decodes JSON, returning null on failure.
  static dynamic tryDecode(String jsonString) {
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }

  /// Checks if a string is valid JSON.
  static bool isValidJson(String jsonString) {
    try {
      jsonDecode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Pretty prints JSON for debugging.
  static String prettyPrint(dynamic data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Creates a JSON map with metadata for caching.
  static Map<String, dynamic> createCachePayload({
    required dynamic data,
    required String resourceKey,
    DateTime? cachedAt,
    DateTime? expiresAt,
    String? version,
  }) {
    return {
      'resourceKey': resourceKey,
      'data': data,
      'cachedAt': cachedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String() ?? 
          DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      'version': version ?? '1.0',
    };
  }
}

/// Extension on String for JSON operations.
extension JsonStringExtension on String {
  /// Returns true if this string is valid JSON.
  bool get isValidJson => JsonUtils.isValidJson(this);

  /// Attempts to decode this JSON string.
  dynamic get asJson => JsonUtils.tryDecode(this);

  /// Returns a pretty-printed version of this JSON string.
  String get prettyPrint {
    try {
      return JsonUtils.prettyPrint(jsonDecode(this));
    } catch (e) {
      return this;
    }
  }
}

/// Extension on dynamic for JSON operations.
extension JsonExtension on dynamic {
  /// Encodes this object to JSON string.
  String get asJsonString => JsonUtils.encode(this);
}
