import 'package:budgets/features/home/domain/models/receipt_input_result.dart';
import 'package:camera/camera.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';

class ReceiptInputService {
  const ReceiptInputService();

  Future<ReceiptInputResult?> importFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result == null) return null;

    final path = result.files.single.xFile.path;
    return ReceiptInputResult(
      source: ReceiptInputSource.importedFile,
      paths: [path],
    );
  }

  Future<ReceiptInputResult?> scanReceipt() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw StateError('No camera is available on this device.');
    }

    final paths = await CunningDocumentScanner.getPictures(
      noOfPages: 10,
      scannerSource: ScannerSource.camera,
    );
    if (paths == null || paths.isEmpty) return null;

    return ReceiptInputResult(
      source: ReceiptInputSource.scannedReceipt,
      paths: paths,
    );
  }
}
