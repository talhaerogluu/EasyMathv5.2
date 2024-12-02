import SwiftUI

struct ResultView: View {
    let result: String

    var body: some View {
        VStack {
            Text("Çözüm Adımları")
                .font(.title)
                .padding()

            ScrollView {
                VStack(alignment: .leading) {
                    if result.isEmpty {
                        Text("Çözüm bulunamadı veya işlem başarısız.")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        let steps = result.components(separatedBy: "\n").filter { !$0.isEmpty }
                        
                        if steps.isEmpty {
                            Text("Çözüm bulunamadı veya işlem başarısız.")
                                .foregroundColor(.red)
                                .padding()
                        } else {
                            ForEach(steps, id: \.self) { step in
                                Text("• \(step)")
                                    .padding(.vertical, 4)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .padding()
            }

            Button(action: {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = UIHostingController(rootView: HomePageView())
                    window.makeKeyAndVisible()
                }
            }) {
                Text("Yeni Bir Denklem Çöz")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .onAppear {
            print("ResultView Görüntülendi. Gelen Sonuç: \(result)")
        }
    }
}
