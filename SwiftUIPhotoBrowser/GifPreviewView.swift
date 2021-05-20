//
//  GifPreviewView.swift
//  VideoImagePicker
//
//  Created by 马元 on 2021/5/19.
//

import SwiftUI
import Photos
import SDWebImageSwiftUI

struct GifPreviewView: View {
    @Binding var asset: PHAsset
    var index: Int
    @ObservedObject var photoBrowser: PhotoBrowser
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    var body: some View {
        GeometryReader { geo in
            VStack{
                AnimatedImage(url: URL(string: photoBrowser.previewGifUrlString))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geo.size.width, height: geo.size.height)
            }.onAppear(perform: {
                photoBrowser.getGifAsstetsUrlToString(asset: asset)
            })
            .onDisappear(perform: {
                photoBrowser.previewGifUrlString = ""
            })
            .navigationBarItems(trailing: Button(action: {
                photoBrowser.gifRemove(at: index)
                self.mode.wrappedValue.dismiss()
            }){
                Image(systemName: "trash")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.blue)
            })
        }
    }
}

//struct GifPreviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        GifPreviewView()
//    }
//}
