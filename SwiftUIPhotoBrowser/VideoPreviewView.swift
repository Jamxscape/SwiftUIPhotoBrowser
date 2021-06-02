//
//  PreviewView.swift
//  VideoImagePicker
//
//  Created by 马元 on 2021/5/12.
//

import SwiftUI
import VideoPlayer
import Photos

struct VideoPreviewView: View {
    var index: Int
    @ObservedObject var photoBrowser: PhotoBrowser
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @State private var autoReplay: Bool = false
    @State private var mute: Bool = true
    @State private var play: Bool = true
    @State private var videoSize: CGSize = CGSize(width: 0, height: 0)
    var body: some View {
//            Color.black
//            .ignoresSafeArea()
        ZStack(alignment: .bottomLeading){
            if photoBrowser.selectedVideoUrlString != "" {
                if videoSize.width / videoSize.height >= 1{
                    VideoPlayer(url: URL(string: photoBrowser.selectedVideoUrlString)!, play: $play)
                        .autoReplay(autoReplay)
                        .mute(mute)
                        //.cornerRadius(16)
                        //.shadow(color: Color.black.opacity(0.7), radius: 6, x: 0, y: 2)
                        .aspectRatio(1.78, contentMode: .fit)
                }else{
                    GeometryReader { geo in
                    VStack{
                    VideoPlayer(url: URL(string: photoBrowser.selectedVideoUrlString)!, play: $play)
                        .autoReplay(autoReplay)
                        .mute(mute)
                        //.cornerRadius(16)
                        //.shadow(color: Color.black.opacity(0.7), radius: 6, x: 0, y: 2)
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                    }
                }
                HStack{
                    HStack {
                        Button(action: {
                            self.play.toggle()
                        }) {
                            if self.play == true{
                                Image(systemName: "pause")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }else if self.play == false{
                                Image(systemName: "play")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    Spacer()
                    HStack{
                        Button(action: {
                            self.mute.toggle()
                        }) {
                            if self.mute == false{
                                Image(systemName: "speaker.wave.2")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }else if self.mute == true{
                                Image(systemName: "speaker.slash")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(25)
                .onAppear(perform:{
                    videoSize = photoBrowser.resolutionSizeForLocalVideo(url: NSURL(string:photoBrowser.selectedVideoUrlString)!)!
                })
            }
            }
            .onAppear(perform: {
                photoBrowser.getVideoAsstetsUrlToString(asset: photoBrowser.videoAssets[index])
            })
            .onDisappear(perform: {
                photoBrowser.selectedVideoUrlString = ""
                VideoPlayer.cleanAllCache() // 清除缓存
            })
            .navigationBarItems(trailing: Button(action: {
                photoBrowser.videoRemove(at: index)
                self.mode.wrappedValue.dismiss()
            }){
                Image(systemName: "trash")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.blue)
            })
    }
}

//struct PreviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviewView()
//    }
//}
