//
//  PreviewView.swift
//  VideoImagePicker
//
//  Created by 马元 on 2021/5/12.
//

import SwiftUI
import VideoPlayer

struct VideoPreviewView: View {
    @ObservedObject var photoBrowser: PhotoBrowser
    var index: Int
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @State private var autoReplay: Bool = false
    @State private var mute: Bool = true
    @State private var play: Bool = true
    var body: some View {
        ZStack{
//            Color.black
//            .ignoresSafeArea()
        ZStack(alignment: .bottomLeading){
            VideoPlayer(url: URL(string: photoBrowser.selectedVideoUrlString[index])!, play: $play)
                .autoReplay(autoReplay)
                .mute(mute)
                .aspectRatio(1.78, contentMode: .fit)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.7), radius: 6, x: 0, y: 2)
                .padding()
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
                }.padding(25)
        }}
            //.background(Color.black)
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
