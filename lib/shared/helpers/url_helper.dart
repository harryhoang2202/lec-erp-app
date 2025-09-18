import 'package:flutter/foundation.dart';

import '../constants/url_constants.dart';

/// Helper class for safe URL parsing and formatting
class UrlHelper {
  /// Safely parses a URL string and returns a Uri object
  /// Returns null if the URL is invalid
  static Uri? parseUrl(String url) {
    try {
      String formattedUrl = _formatUrl(url);
      final Uri uri = Uri.parse(formattedUrl);

      // Validate the parsed URI
      if (!uri.hasScheme || !uri.hasAuthority || uri.host.isEmpty) {
        return null;
      }

      // Additional validation for host format
      if (!_isValidHost(uri.host)) {
        return null;
      }

      return uri;
    } catch (e) {
      debugPrint('Error parsing URL: $e');
      return null;
    }
  }

  /// Validates host format
  static bool _isValidHost(String host) {
    // Check if host contains valid characters and format
    if (host.isEmpty) return false;

    // Check for valid domain format (at least one dot and valid characters)
    if (!host.contains('.') || host.startsWith('.') || host.endsWith('.')) {
      return false;
    }

    // Check for valid characters (letters, numbers, dots, hyphens)
    final RegExp validHostRegex = RegExp(r'^[a-zA-Z0-9.-]+$');
    if (!validHostRegex.hasMatch(host)) {
      return false;
    }

    // Check for consecutive dots or hyphens
    if (host.contains('..') ||
        host.contains('--') ||
        host.contains('.-') ||
        host.contains('-.')) {
      return false;
    }

    return true;
  }

  /// Formats URL to ensure it has proper protocol and format
  static String _formatUrl(String url) {
    String formattedUrl = url.trim();

    // Add protocol if missing
    if (!formattedUrl.startsWith('http://') &&
        !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }

    // Remove trailing slash
    if (formattedUrl.endsWith('/')) {
      formattedUrl = formattedUrl.substring(0, formattedUrl.length - 1);
    }

    return formattedUrl;
  }

  /// Validates if a URL string is valid
  static bool isValidUrl(String url) {
    return parseUrl(url) != null;
  }

  /// Extracts host from URL string
  static String? extractHost(String url) {
    final Uri? uri = parseUrl(url);
    return uri?.host;
  }

  /// Extracts scheme from URL string
  static String? extractScheme(String url) {
    final Uri? uri = parseUrl(url);
    return uri?.scheme;
  }

  /// Creates a safe URL string from components
  static String createUrl({
    required String host,
    String scheme = 'https',
    String path = '',
    Map<String, String>? queryParameters,
  }) {
    try {
      final Uri uri = Uri(
        scheme: scheme,
        host: host,
        path: path,
        queryParameters: queryParameters,
      );
      return uri.toString();
    } catch (e) {
      debugPrint('Error creating URL: $e');
      return '';
    }
  }

  /// Safely joins URL parts
  static String joinUrl(String baseUrl, String path) {
    try {
      final Uri? baseUri = parseUrl(baseUrl);
      if (baseUri == null) {
        return '$baseUrl/$path';
      }
      final Uri joinedUri = baseUri.resolve(path);
      return joinedUri.toString();
    } catch (e) {
      debugPrint('Error joining URLs: $e');
      return '$baseUrl/$path';
    }
  }

  /// Validates and formats ERP URL
  static String? formatErpUrl(String url) {
    try {
      final Uri? uri = parseUrl(url);
      if (uri == null) return null;

      // Ensure it's a valid ERP URL (has host)
      if (uri.host.isEmpty) return null;

      return uri.toString();
    } catch (e) {
      debugPrint('Error formatting ERP URL: $e');
      return null;
    }
  }

  /// Check if the URL points to a previewable file
  static bool isPreviewFile(String url) {
    return UrlConstants.previewFileExtensions.any(
      (extension) => url.toLowerCase().endsWith(extension),
    );
  }

  /// Check if the URL points to a downloadable file
  static bool isDownloadFile(String url) {
    return UrlConstants.downloadFileExtensions.any(
      (extension) => url.toLowerCase().endsWith(extension),
    );
  }

  static bool isExternalUrl(String url, String erpUrl) {
    final Uri? uri = parseUrl(url);
    if (uri == null) return false;
    if ([
      'http',
      'https',
      'file',
      'chrome',
      'data',
      'javascript',
    ].contains(uri.scheme)) {
      if (uri.host == erpUrl) {
        return false;
      } else {
        return true;
      }
    }

    return true;
  }
}
