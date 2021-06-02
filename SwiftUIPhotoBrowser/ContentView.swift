//
//  ContentView.swift
//  VideoImagePicker
//
//  Created by 马元 on 2021/5/11.
//

import SwiftUI
import Photos
import ZLPhotoBrowser
import Kingfisher

import UIKit

struct ContentView: View {
    @ObservedObject var photoBrowser = PhotoBrowser()
    var body: some View {
        NavigationView{
            VStack{
            VStack{
                Button("保存全部") {
                    let group = DispatchGroup()
                    for i in 0..<3 {
                        if i == 0{
                            photoBrowser.saveAllImagesToDocumentDirectory(group: group)
                        }else if i == 1{
                            photoBrowser.saveAllVideosToDocumentDirectory(group: group)
                        }else if i == 2{
                            photoBrowser.saveAllGifToDocumentDirectory(group: group)
                        }
                    }
                    group.notify(queue: .main) {
                        print(photoBrowser.outputImageFilename)
                        print(photoBrowser.outputVideoFilename)
                        print(photoBrowser.outputGifFilename)
                    }
                }
            }
        VStack {
            
            Button("保存图片") {
                let group = DispatchGroup()
                photoBrowser.saveAllImagesToDocumentDirectory(group: group)
                group.notify(queue: .main) {
                    print(photoBrowser.outputImageFilename)
                }
                
            }
            Button("保存视频") {
                let group = DispatchGroup()
                photoBrowser.saveAllVideosToDocumentDirectory(group: group)
                
                group.notify(queue: .main) {
                    print(photoBrowser.outputVideoFilename)
                }
            }
            Button("保存动图"){
                let group = DispatchGroup()
                photoBrowser.saveAllGifToDocumentDirectory(group: group)
                group.notify(queue: .main) {
                    print(photoBrowser.outputGifFilename)
                }
            }
            Button("选择多个照片") {
                photoBrowser.reset()
                photoBrowser.selectMutiplePhotos()
            }
            Button("选择多个视频") {
                photoBrowser.videoReset()
                photoBrowser.selectMultipleVideos()
            }
            Button("选择多个表情包"){
                photoBrowser.gifReset()
                photoBrowser.selectMultipleGif()
            }
            Button("预览"){
                photoBrowser.preview()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                if photoBrowser.images.count != 0{
                    HStack {
                        ForEach(0..<photoBrowser.images.count, id: \.self) { i in
                            NavigationLink(destination: ImagePreviewView(photoBrowser: photoBrowser, index: i ))
                                {
                                    ZStack{
                                        Image(uiImage: photoBrowser.images[i])
                                            .resizable()
                                            .frame(width: 150, height: 100)
                                    }
                                }
                        }
                    }
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                if photoBrowser.videoImages != []{
                    HStack {
                        ForEach(0..<photoBrowser.videoImages.count, id: \.self) { i in
                            NavigationLink(
                                destination: VideoPreviewView(index: i, photoBrowser: photoBrowser))
                                {
                                    ZStack{
                                            Image(uiImage: photoBrowser.videoImages[i])
                                              .resizable()
                                              .frame(width: 150, height: 100)
                                            Image(systemName: "play.circle")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.white)
                                    }
                            }
                        }
                    }
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                if photoBrowser.gifImages != []{
                    HStack {
                        ForEach(0..<photoBrowser.gifImages.count, id: \.self) { i in
                                NavigationLink(
                                    destination: GifPreviewView(asset: $photoBrowser.gifAssets[i], index: i, photoBrowser: photoBrowser))
                                    {
                                        ZStack(alignment: .bottomLeading){
                                            Image(uiImage: photoBrowser.gifImages[i])
                                              .resizable()
                                              .frame(width: 150, height: 100)
                                            if photoBrowser.isGif[i] {
                                                Text("GIF")
                                                    .foregroundColor(.white)
                                            }
                                        }
                                }
                        }
                    }
                }
            }
        }
        }
        }
    }
    
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

