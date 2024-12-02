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

        ocrService.performOCR(on: enhancedImage) { result in
            switch result {
            case .success(let equation):
                // Denklemi temizle
                var cleanedEquation = equation
                    .replacingOccurrences(of: " ", with: "") // Boşlukları kaldır
                    .replacingOccurrences(of: "x2", with: "x^2") // x2 → x^2 dönüşümü
                    .replacingOccurrences(of: "(?<=\\d)x", with: "*x", options: .regularExpression)
                    .replacingOccurrences(of: "(?<=x)(\\d)", with: "*$1", options: .regularExpression)

                // API'ye gönderilecek denklemi kontrol et
                if !cleanedEquation.contains("=") {
                    cleanedEquation += "=0" // Eşitlik ekle (ör: eksikse)
                }

                print("Düzeltilmiş Denklem (API'ye Gönderilen): \(cleanedEquation)")

                wolframService.solveEquation(equation: cleanedEquation) { apiResult in
                    switch apiResult {
                    case .success(let solution):
                        DispatchQueue.main.async {
                            equationResult = solution
                            showResult = true
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            equationResult = "API Hatası: \(error.localizedDescription)"
                            showResult = true
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    equationResult = "OCR Hatası: \(error.localizedDescription)"
                    showResult = true
                }
            }
        }
    }


    
    
    

}
