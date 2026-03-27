import UIKit
import ImageIO
import UniformTypeIdentifiers

final class ImageCompressionService {
    static let shared = ImageCompressionService()
    private init() {}

    func compressImage(_ image: UIImage, maxDimension: CGFloat = 1024, quality: CGFloat = 0.7) -> Data? {
        let resized = resizeImage(image, maxDimension: maxDimension)
        if let heicData = heicData(from: resized, quality: quality) {
            return heicData
        }
        return resized.jpegData(compressionQuality: quality)
    }

    func compressForSharing(_ image: UIImage, maxDimension: CGFloat = 800) -> Data? {
        let resized = resizeImage(image, maxDimension: maxDimension)
        return resized.jpegData(compressionQuality: 0.8)
    }

    func compressForThumbnail(_ image: UIImage, size: CGFloat = 200) -> Data? {
        let resized = resizeImage(image, maxDimension: size)
        return resized.jpegData(compressionQuality: 0.6)
    }

    func compressDataForUpload(_ imageData: Data, maxDimension: CGFloat = 1024, quality: CGFloat = 0.7) -> Data? {
        guard let image = UIImage(data: imageData) else { return nil }
        return compressImage(image, maxDimension: maxDimension, quality: quality)
    }

    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        guard size.width > maxDimension || size.height > maxDimension else { return image }

        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    private func heicData(from image: UIImage, quality: CGFloat) -> Data? {
        guard let cgImage = image.cgImage else { return nil }
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data as CFMutableData,
            UTType.heic.identifier as CFString,
            1,
            nil
        ) else { return nil }

        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality
        ]
        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)

        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }
}
