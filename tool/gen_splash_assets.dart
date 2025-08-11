import 'dart:io';
import 'package:image/image.dart' as img;

// Генерация splash-ассетов: icon.png, icon_dark.png, brand.png, brand_dark.png
// Запуск: dart run gen_splash_assets.dart
void main() async {
  final outDir = Directory('assets/splash');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  const appName = 'Shortsy';

  await _genIcon('${outDir.path}/icon.png');
  await _genIcon('${outDir.path}/icon_dark.png');

  await _genBrand('${outDir.path}/brand.png', appName);
  await _genBrand('${outDir.path}/brand_dark.png', appName, dark: true);

  stdout.writeln('Генерация завершена: ${outDir.path}');
}

Future<void> _genIcon(String path) async {
  const size = 1024;
  final canvas = img.Image(width: size, height: size);

  // Прозрачный фон — фон задаёт сплэш (#000000)
  img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0));

  // Чёрный скруглённый квадрат по центру
  final pad = (size * 0.12).round();
  final corner = (size * 0.22).round();
  _fillRoundedRect(
    canvas,
    x1: pad,
    y1: pad,
    x2: size - pad,
    y2: size - pad,
    radius: corner,
    color: img.ColorRgb8(0, 0, 0),
  );

  // Буква 'S': рисуем на временном холсте, обрезаем по альфе и масштабируем
  final tmp = img.Image(width: 300, height: 300);
  img.fill(tmp, color: img.ColorRgba8(0, 0, 0, 0));
  img.drawString(tmp, 'S',
      font: img.arial48, x: 96, y: 126, color: img.ColorRgb8(255, 255, 255));

  final b = _contentBounds(tmp);
  final glyph =
      img.copyCrop(tmp, x: b.left, y: b.top, width: b.width, height: b.height);
  final scaled = img.copyResize(glyph,
      height: (size * 0.58).round(), interpolation: img.Interpolation.linear);

  final dx = ((size - scaled.width) / 2).round();
  final dy = ((size - scaled.height) / 2).round();
  img.compositeImage(canvas, scaled,
      dstX: dx, dstY: dy, blend: img.BlendMode.alpha);

  await File(path).writeAsBytes(img.encodePng(canvas));
}

Future<void> _genBrand(String path, String text, {bool dark = false}) async {
  const w = 1200, h = 256;
  final bg = img.Image(width: w, height: h);
  img.fill(bg, color: img.ColorRgb8(0, 0, 0));

  final color = img.ColorRgb8(255, 255, 255);

  // Приблизительное центрирование (arial48)
  const approxCharW = 28;
  const approxCharH = 48;
  final tw = text.length * approxCharW;
  final x = ((w - tw) / 2).round();
  final y = ((h - approxCharH) / 2).round();
  img.drawString(bg, text, font: img.arial48, x: x, y: y, color: color);

  await File(path).writeAsBytes(img.encodePng(bg));
}

class _Bounds {
  final int left;
  final int top;
  final int right;
  final int bottom;
  const _Bounds(this.left, this.top, this.right, this.bottom);
  int get width => right - left + 1;
  int get height => bottom - top + 1;
}

_Bounds _contentBounds(img.Image im) {
  int minX = im.width, minY = im.height, maxX = -1, maxY = -1;
  for (var y = 0; y < im.height; y++) {
    for (var x = 0; x < im.width; x++) {
      final p = im.getPixel(x, y);
      if (p.a > 0) {
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
    }
  }
  if (maxX < minX || maxY < minY) {
    return _Bounds(0, 0, im.width - 1, im.height - 1);
  }
  return _Bounds(minX, minY, maxX, maxY);
}

void _fillRoundedRect(
  img.Image dst, {
  required int x1,
  required int y1,
  required int x2,
  required int y2,
  required int radius,
  required img.Color color,
}) {
  final w = (x2 - x1).abs();
  final h = (y2 - y1).abs();
  int r = radius;
  if (r > w ~/ 2) r = w ~/ 2;
  if (r > h ~/ 2) r = h ~/ 2;

  // центральная полоса
  img.fillRect(dst, x1: x1 + r, y1: y1, x2: x2 - r, y2: y2, color: color);
  // вертикали
  img.fillRect(dst, x1: x1, y1: y1 + r, x2: x1 + r, y2: y2 - r, color: color);
  img.fillRect(dst, x1: x2 - r, y1: y1 + r, x2: x2, y2: y2 - r, color: color);
  // углы
  img.fillCircle(dst, x: x1 + r, y: y1 + r, radius: r, color: color);
  img.fillCircle(dst, x: x2 - r, y: y1 + r, radius: r, color: color);
  img.fillCircle(dst, x: x1 + r, y: y2 - r, radius: r, color: color);
  img.fillCircle(dst, x: x2 - r, y: y2 - r, radius: r, color: color);
}
