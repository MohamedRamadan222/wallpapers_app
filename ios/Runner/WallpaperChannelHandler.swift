import Flutter
import UIKit

/// Host side of `wallpapers_app/native` on iOS.
/// iOS exposes no wallpaper API, so `setWallpaper` reports unsupported and
/// the Flutter UI guides the user to set the image manually from Photos.
final class WallpaperChannelHandler {
  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "wallpapers_app/native", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "saveToGallery":
        guard let args = call.arguments as? [String: Any],
          let typed = args["bytes"] as? FlutterStandardTypedData
        else {
          result(FlutterError(code: "bad_args", message: "Missing image bytes.", details: nil))
          return
        }
        PhotoSaver.save(typed.data, result: result)
      case "setWallpaper":
        result(
          FlutterError(
            code: "unsupported",
            message:
              "iOS does not allow apps to change the wallpaper. Use Download, then set it from Photos.",
            details: nil))
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

private final class PhotoSaver: NSObject {
  /// Retained until each save completes; the album callback does not retain us.
  private static var pending: [PhotoSaver] = []
  private let result: FlutterResult

  private init(result: @escaping FlutterResult) {
    self.result = result
  }

  static func save(_ data: Data, result: @escaping FlutterResult) {
    guard let image = UIImage(data: data) else {
      result(FlutterError(code: "decode", message: "Could not decode image.", details: nil))
      return
    }
    let saver = PhotoSaver(result: result)
    pending.append(saver)
    UIImageWriteToSavedPhotosAlbum(
      image, saver,
      #selector(PhotoSaver.finished(_:didFinishSavingWithError:contextInfo:)),
      nil)
  }

  @objc private func finished(
    _ image: UIImage,
    didFinishSavingWithError error: Error?,
    contextInfo: UnsafeRawPointer
  ) {
    if let error = error {
      result(FlutterError(code: "save_failed", message: error.localizedDescription, details: nil))
    } else {
      result(nil)
    }
    Self.pending.removeAll { $0 === self }
  }
}
