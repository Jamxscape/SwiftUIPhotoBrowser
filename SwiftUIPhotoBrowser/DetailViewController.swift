//
//  Detail.swift
//  VideoImagePicker
//
//  Created by 马元 on 2021/5/12.
//

//import SwiftUI
//import UIKit
//import Photos
//import ZLPhotoBrowser
//
//struct DetailViewController: UIViewControllerRepresentable {
//    
//    
//    typealias UIViewControllerType = UIViewController
//    
//    var datas: [UIImage]
//    
//    
//    func makeUIViewController(context: Context) -> DetailViewController.UIViewControllerType{
//        let videoSuffixs = ["mp4", "mov", "avi", "rmvb", "rm", "flv", "3gp", "wmv", "vob", "dat", "m4v", "f4v", "mkv"] // and more suffixs
//        let vc = ZLImagePreviewController(datas: datas, index: 0, showSelectBtn: true) { (url) -> ZLURLType in
//            if let sf = url.absoluteString.split(separator: ".").last, videoSuffixs.contains(String(sf)) {
//                return .video
//            } else {
//                return .image
//            }
//        } urlImageLoader: { (url, imageView, progress, loadFinish) in
//            imageView.kf.setImage(with: url) { (receivedSize, totalSize) in
//                    let percentage = (CGFloat(receivedSize) / CGFloat(totalSize))
//                    progress(percentage)
//                } completionHandler: { (_) in
//                    loadFinish()
//                }
//        }
//
//        vc.doneBlock = { (datas) in
//            debugPrint(datas)
//        }
//        vc.modalPresentationStyle = .fullScreen
//        showDetailViewController(vc, sender: nil)
//        return UIViewController()
//    }
//    
//    func updateUIViewController(_ uiViewController: DetailViewController.UIViewControllerType, context: Context) {
//        
//    }
//}
