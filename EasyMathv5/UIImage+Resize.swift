import UIKit

extension UIImage {
    func enhancedForOCR() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }

        // Kontrastı artırma ve siyah-beyaza dönüştürme
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(1.5, forKey: "inputContrast") // Kontrast artırma
        filter?.setValue(0.0, forKey: "inputSaturation") // Siyah-beyaza dönüştürme
        guard let outputImage = filter?.outputImage else { return nil }

        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }
}
