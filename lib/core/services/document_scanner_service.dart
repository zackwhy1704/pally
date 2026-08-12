import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pally/core/utils/logger.dart';

/// Result of [DocumentScannerService.scan]. [originalName] is only set when
/// the plain-camera fallback was used (the native scanner result has no
/// caller-facing name, so callers synthesize one from a timestamp).
class ScannedPhoto {
  const ScannedPhoto({required this.path, this.originalName});

  final String path;
  final String? originalName;
}

class DocumentScannerService {
  /// Launches the native document scanner (auto-crop + deskew + brightness).
  /// Falls back to a plain camera capture on any platform error (e.g.
  /// Android < 10, or a simulator without ML Kit play services).
  static Future<ScannedPhoto?> scan({required String logTag}) async {
    try {
      final paths = await CunningDocumentScanner.getPictures(
        noOfPages: 1,
        isGalleryImportAllowed: false,
      );
      if (paths == null || paths.isEmpty) return null;
      return ScannedPhoto(path: paths.first);
    } catch (e) {
      appLog.w('[$logTag] Document scanner unavailable, falling back to ImagePicker: $e');
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
      if (image == null) return null;
      return ScannedPhoto(path: image.path, originalName: image.name);
    }
  }
}
