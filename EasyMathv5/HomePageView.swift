//
//  HomePageView.swift
//  EasyMathv5
//
//  Created by Talha Eroğlu on 1.12.2024.
//

import SwiftUI

struct HomePageView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("EasyMath Uygulamasına Hoş Geldiniz!")
                    .font(.largeTitle)
                    .padding()

                NavigationLink(destination: CameraView()) {
                    Text("Başlat")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}
