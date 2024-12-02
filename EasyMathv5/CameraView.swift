import SwiftUI

struct CameraView: View {
    @State private var showResult = false
    @State private var equationResult: String = ""
    private let ocrService = OCRService()
    private let wolframService = WolframAlphaService()

    var body: some View {
        VStack {
            Text("Denklemin Fotoğrafını Çek")
                .font(.headline)
                .padding()

            Spacer()

            CameraCaptureView { capturedImage in
                processCapturedPhoto(capturedImage)
            }
            .frame(height: 400)

            Spacer()

            Button(action: {
                NotificationCenter.default.post(name: Notification.Name("CapturePhoto"), object: nil)
                print("Fotoğraf Çek Butonuna Basıldı")
            }) {
                Text("Fotoğraf Çek")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .fullScreenCover(isPresented: $showResult) {
            ResultView(result: equationResult)
        }
    }

    
    func processCapturedPhoto(_ image: UIImage) {
        guard let enhancedImage = image.enhancedForOCR() else {
            print("Görüntü işlenemedi.")
            return
        }

        func processCapturedPhoto(_ image: UIImage) {
            guard let enhancedImage = image.enhancedForOCR() else {
                print("Görüntü işlenemedi.")
                return
            }

            ocrService.performOCR(on: enhancedImage) { result in
                switch result {
                case .success(let equation):
                    print("OCR Çıktısı (Ham): \(equation)") // OCR'nin ham çıktısı

                    let cleanedEquation = equation
                        .replacingOccurrences(of: " ", with: "") // Boşlukları temizle
                        .replacingOccurrences(of: "x2", with: "x^2") // x2 -> x^2 dönüşümü
                        .replacingOccurrences(of: "(?<=\\d)x", with: "*x", options: .regularExpression) // Sayı ve x arasında çarpma işareti ekle
                        .replacingOccurrences(of: "(?<=x)(\\d)", with: "*$1", options: .regularExpression) // x'ten sonra sayı varsa çarpma ekle

                    print("OCR Çıktısı (Temizlenmiş): \(cleanedEquation)") // Temizlenmiş denklem

                    // API'ye gönderim
                    wolframService.solveEquation(equation: cleanedEquation) { apiResult in
                        switch apiResult {
                        case .success(let solution):
                            DispatchQueue.main.async {
                                print("API'den Gelen Çözüm: \(solution)") // API sonucunu kontrol et
                                equationResult = solution
                                showResult = true
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                print("API Hatası: \(error.localizedDescription)") // API hatası kontrolü
                                equationResult = "API Hatası: \(error.localizedDescription)"
                                showResult = true
                            }
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print("OCR Hatası: \(error.localizedDescription)") // OCR hatası kontrolü
                        equationResult = "OCR Hatası: \(error.localizedDescription)"
                        showResult = true
                    }
                }
            }
        }

    }

}
