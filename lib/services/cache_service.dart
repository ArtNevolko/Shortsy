import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CacheService {
  static final CacheService _i = CacheService._();
  CacheService._();
  factory CacheService() => _i;

  Future<Directory> _dir() async {
    final base = await getTemporaryDirectory();
    final d = Directory('${base.path}/media_cache');
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  String _hash(String url) => sha1.convert(utf8.encode(url)).toString();

  Future<File> fileForUrl(String url, {String ext = 'bin'}) async {
    final d = await _dir();
    return File('${d.path}/${_hash(url)}.$ext');
  }

  Future<File?> prefetch(String url) async {
    try {
      final f = await fileForUrl(url, ext: 'mp4');
      if (await f.exists() && await f.length() > 0) return f;
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        await f.writeAsBytes(res.bodyBytes, flush: true);
        return f;
      }
    } catch (_) {}
    return null;
  }

  Future<File?> thumbnail(String url) async {
    try {
      final f = await fileForUrl(url, ext: 'jpg');
      if (await f.exists() && await f.length() > 0) return f;
      final bytes = await VideoThumbnail.thumbnailData(
        video: url,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 480,
        timeMs: 900,
        quality: 70,
      );
      if (bytes != null) {
        await f.writeAsBytes(bytes, flush: true);
        return f;
      }
    } catch (_) {}
    return null;
  }
}
