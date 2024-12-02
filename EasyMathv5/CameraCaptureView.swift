//
//  CameraCaptureView.swift
//  EasyMathv5
//
//  Created by Talha Eroğlu on 1.12.2024.
//

import SwiftUI
import AVFoundation

struct CameraCaptureView: UIViewControllerRepresentable {
    var onPhotoCaptured: (UIImage) -> Void // Fotoğraf çekildiğinde dışarıya gönderilecek closure

    // UIViewControllerRepresentable gereklilikleri
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraVC = CameraViewController()
        cameraVC.onPhotoCaptured = onPhotoCaptured
        return cameraVC
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // Burada herhangi bir güncelleme yapılmayabilir. UI güncellemeleri gerektiğinde kullanılır.
    }

    // Koordinatör eklenmesi (opsiyonel ancak SwiftUI ve UIKit iletişimi için faydalı olabilir)
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Koordinatör tanımı
    class Coordinator: NSObject {
        var parent: CameraCaptureView

        init(_ parent: CameraCaptureView) {
            self.parent = parent
        }
    }
}
//sdfsdfsdfsdfsadgadsgsdfgasd
