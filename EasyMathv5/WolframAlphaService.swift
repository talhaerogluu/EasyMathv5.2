import Foundation

class WolframAlphaService {
    private let apiKey = "3G7J2P-J8TJHWAW9L"

    func solveEquation(equation: String, completion: @escaping (Result<String, Error>) -> Void) {
        let query = equation.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.wolframalpha.com/v2/query?input=\(query)&format=plaintext&output=JSON&appid=\(apiKey)"

        guard let url = URL(string: urlString) else {
            print("Geçersiz URL: \(urlString)")
            completion(.failure(NSError(domain: "WolframAlphaService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçersiz URL"])))
            return
        }

        print("API URL'si: \(urlString)")

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("HTTP Hatası: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("Boş yanıt alındı.")
                completion(.failure(NSError(domain: "WolframAlphaService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Boş yanıt alındı"])))
                return
            }

            // Yanıtı ham JSON olarak yazdır
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Yanıtı JSON: \(jsonString)")
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("JSON Çözümleme Başarılı: \(json ?? [:])")

                if let pods = (json?["queryresult"] as? [String: Any])?["pods"] as? [[String: Any]] {
                    print("Pods Bulundu: \(pods.count) adet pod")

                    // Solution podunu bul ve çözüm adımlarını birleştir
                    if let solutionPod = pods.first(where: { $0["title"] as? String == "Solutions" }),
                       let subpods = solutionPod["subpods"] as? [[String: Any]] {
                        print("Çözüm Podu Bulundu: \(solutionPod)")

                        let solutions = subpods.compactMap { $0["plaintext"] as? String }.joined(separator: "\n")
                        print("Çözüm Adımları: \(solutions)")
                        completion(.success(solutions))
                    } else {
                        print("Çözüm pod'u bulunamadı.")
                        completion(.failure(NSError(domain: "WolframAlphaService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Çözüm bulunamadı"])))
                    }
                } else {
                    print("Pods bulunamadı.")
                    completion(.failure(NSError(domain: "WolframAlphaService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Yanıt çözülemedi"])))
                }
            } catch {
                print("JSON Çözümleme Hatası: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
