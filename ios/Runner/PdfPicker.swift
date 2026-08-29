import Flutter
import UIKit
import UniformTypeIdentifiers

final class PdfPicker: NSObject, UIDocumentPickerDelegate {
  static let channelName = "com.ababilx.diu/pdf_picker"

  private var pending: FlutterResult?

  func register(messenger: FlutterBinaryMessenger) {
    FlutterMethodChannel(name: Self.channelName, binaryMessenger: messenger)
      .setMethodCallHandler { [weak self] call, result in
        guard call.method == "pickPdf" else {
          result(FlutterMethodNotImplemented)
          return
        }
        self?.pick(result: result)
      }
  }

  private func pick(result: @escaping FlutterResult) {
    if pending != nil {
      result(FlutterError(code: "busy", message: "Picker already open", details: nil))
      return
    }
    guard let host = Self.topController() else {
      result(FlutterError(code: "read_failed", message: "No view controller", details: nil))
      return
    }
    pending = result
    let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
    picker.delegate = self
    picker.allowsMultipleSelection = false
    host.present(picker, animated: true)
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    finish(nil)
  }

  func documentPicker(
    _ controller: UIDocumentPickerViewController,
    didPickDocumentsAt urls: [URL]
  ) {
    guard let url = urls.first else {
      finish(nil)
      return
    }
    let accessed = url.startAccessingSecurityScopedResource()
    defer {
      if accessed { url.stopAccessingSecurityScopedResource() }
    }
    do {
      let dest = FileManager.default.temporaryDirectory
        .appendingPathComponent("picked_\(Int(Date().timeIntervalSince1970 * 1000)).pdf")
      if FileManager.default.fileExists(atPath: dest.path) {
        try FileManager.default.removeItem(at: dest)
      }
      try FileManager.default.copyItem(at: url, to: dest)
      finish(["path": dest.path, "name": url.lastPathComponent])
    } catch {
      let callback = pending
      pending = nil
      callback?(FlutterError(code: "read_failed", message: error.localizedDescription, details: nil))
    }
  }

  private func finish(_ value: [String: String]?) {
    let callback = pending
    pending = nil
    callback?(value)
  }

  private static func topController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let window = scenes.flatMap(\.windows).first(where: \.isKeyWindow)
    var controller = window?.rootViewController
    while let presented = controller?.presentedViewController {
      controller = presented
    }
    return controller
  }
}
