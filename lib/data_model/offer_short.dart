import 'package:active_ecommerce_cms_demo_app/app_config.dart';

class OfferShort {
  const OfferShort({
    this.id,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.videoUrl,
    this.webUrl,
  });

  final String? id;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String? webUrl;

  factory OfferShort.fromJson(Map<String, dynamic> json) {
    final video = _asMap(json['video']) ?? _asMap(json['media']);
    final thumbnail = _asMap(json['thumbnail']) ?? _asMap(json['image']);

    return OfferShort(
      id: _asString(json['id']),
      title: _firstString(json, const ['title', 'name', 'caption']),
      description: _firstString(
        json,
        const ['description', 'short_description', 'excerpt'],
      ),
      thumbnailUrl: _normaliseUrl(
        _firstString(json, const [
              'thumbnail_url',
              'thumbnail',
              'cover',
              'image',
              'photo',
            ]) ??
            _firstString(thumbnail, const ['url', 'path', 'src']),
      ),
      videoUrl: _normaliseUrl(
        _firstString(json, const [
              'video_url',
              'video_link',
              'video',
              'media_url',
            ]) ??
            _firstString(video, const ['url', 'path', 'src']),
      ),
      webUrl: _normaliseUrl(
        _firstString(json, const ['web_url', 'share_url', 'link', 'url']),
      ),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    return value is Map<String, dynamic> ? value : null;
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is num) return value.toString();
    return null;
  }

  static String? _firstString(
    Map<String, dynamic>? json,
    List<String> keys,
  ) {
    if (json == null) return null;
    for (final key in keys) {
      final value = _asString(json[key]);
      if (value != null) return value;
    }
    return null;
  }

  static String? _normaliseUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) return value;

    return '${AppConfig.RAW_BASE_URL}/${value.replaceFirst(RegExp(r'^/+'), '')}';
  }
}
