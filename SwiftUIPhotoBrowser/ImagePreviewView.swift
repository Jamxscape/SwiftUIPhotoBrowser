//
//  ImagePreviewView.swift
//  VideoImagePicker
//
//  Created by 马元 on 2021/5/16.
//

import SwiftUI
import UIKit
import Kingfisher

struct ImagePreviewView: View {
    @ObservedObject var photoBrowser: PhotoBrowser
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    var index: Int
    @State var index2: Int = 0
    @State var maxIndex: Int = 0
    var body: some View {
        GeometryReader { geo in
            VStack{
                if photoBrowser.images.count >= 2{
                    PagingView(index: $index2.animation(), maxIndex: $maxIndex) {
                        ForEach(photoBrowser.images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geo.size.width, height: geo.size.height)
                        }
                    }
                }else if photoBrowser.images.count == 1{
                    Image(uiImage: photoBrowser.images[0])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width, height: geo.size.height)
                }else if photoBrowser.images.count == 0{
                    VStack{
                        
                    }.onAppear(perform: {
                        self.mode.wrappedValue.dismiss()
                    })
                }
            }.onAppear(perform: {
                index2 = index
                maxIndex = photoBrowser.images.count - 1
            })
            .navigationBarItems(trailing: Button(action: {
                photoBrowser.remove(at: index)
                maxIndex = photoBrowser.images.count - 1
            }){
                Image(systemName: "trash")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.blue)
            })
        }
    }
}
//struct ImageView: View{
//    @ObservedObject var photoBrowser: PhotoBrowser
//    var body: some View{
//        
//            
//        }
//    }
//}
// 在图片视图里单独执行放大缩小和获取单张的Url
//struct ImagePreviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImagePreviewView()
//    }
//}

