import Vision
import UIKit

class OCRService {
    func performOCR(on image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(NSError(domain: "OCRService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçersiz görüntü"])))
            return
        }

        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.failure(NSError(domain: "OCRService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Metin algılanamadı"])))
                return
            }

            let recognizedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")
            print("OCR Çıktısı (Ham): \(recognizedText)")

            // Temizlenmiş metni filtreleme
            let cleanedText = self.cleanOCRText(recognizedText)
            print("OCR Çıktısı (Temizlenmiş): \(cleanedText)")

            completion(.success(cleanedText))
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([request])
        } catch {
            completion(.failure(error))
        }
    }

    private func cleanOCRText(_ text: String) -> String {
        // Gereksiz boşlukları ve eksik operatörleri düzelt
        let cleanedText = text
            .replacingOccurrences(of: " ", with: "")          // Tüm boşlukları kaldır
            .replacingOccurrences(of: "x2", with: "x^2")     // x2 → x^2
            .replacingOccurrences(of: "(?<=\\d)x", with: "*x", options: .regularExpression) // Sayı ve x arasına çarpma işareti ekle
            .replacingOccurrences(of: "(?<=x)(\\d)", with: "*$1", options: .regularExpression) // x'ten sonra sayı varsa çarpma ekle
            .replacingOccurrences(of: "(?<=\\d)(?=[a-zA-Z])", with: "*", options: .regularExpression) // Sayı ile harf arasında çarpma ekle
        print("OCR Çıktısı (Daha İyi Temizleme): \(cleanedText)")
        return cleanedText
    }


}
