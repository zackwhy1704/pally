import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart' as mlkit;

class TextRecognitionService {
  static Future<String> recognize(String photoPath) async {
    final inputImage = mlkit.InputImage.fromFilePath(photoPath);
    final recognizer = mlkit.TextRecognizer(script: mlkit.TextRecognitionScript.latin);
    try {
      final recognised = await recognizer.processImage(inputImage);
      return recognised.text;
    } finally {
      await recognizer.close();
    }
  }
}
