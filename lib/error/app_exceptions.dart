class InvalidFileException implements Exception {
  final String message =
      'you have selected an invalid file, please select a .txt or .zip file';
}

class TxtFileNotFoundException implements Exception {
  final String message =
      'Txt File not found, please make sure the zip file is valid';
}
