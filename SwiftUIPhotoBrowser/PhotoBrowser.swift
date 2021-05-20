//
//  PhotoBrowser.swift
//  VideoImagePicker
//
//  Created by 马元 on 2021/5/14.
//

import SwiftUI
import Photos
import ZLPhotoBrowser
import Kingfisher
import ImageIO
import MobileCoreServices

class PhotoBrowser: ObservableObject{
    @Published var images: [UIImage] = []
    @Published var assets: [PHAsset] = []
    @Published var selectedUrlString: [String] = []
    @Published var selectedFileType: [String] = []
    @Published var outputImageFilename: [String] = []
    
    @Published var videoImages: [UIImage] = []
    @Published var videoAssets: [PHAsset] = []
    @Published var hasSelectVideo = false
    @Published var selectedVideoUrlString: [String] = []
    @Published var fileType: String = ""
    @Published var outputVideoFilename: [String] = []
    
    @Published var gifImages: [UIImage] = []
    @Published var gifAssets: [PHAsset] = []
    @Published var previewGifUrlString: String = ""
    @Published var isGif: [Bool] = []
    @Published var outputGifFilename: [String] = []
    
    public func selectMutiplePhotos(){
        let config = ZLPhotoConfiguration.default()
        config.allowSelectImage = true
        config.allowSelectGif = false
        config.allowSelectLivePhoto = true
        config.allowSelectVideo = false
        config.allowSelectOriginal = true
        config.cropVideoAfterSelectThumbnail = false
        config.allowMixSelect = true
        config.maxSelectCount = 20
        
        let scene = UIApplication.shared.connectedScenes.first
        let root = (scene as? UIWindowScene)?.windows.first?.rootViewController
        if root != nil {
            let ac = ZLPhotoPreviewSheet()
            ac.selectImageBlock = { [self] (image, asset, _) in
                images.append(contentsOf: image)
                assets.append(contentsOf: asset)
            }
            ac.showPhotoLibrary(sender: root!)
        }
    }
    //////// ----存在错误----////
    public func getImageAsstetsUrlToString(){
        let mainQueue = DispatchQueue.main
        if assets != []{
            for (i, item) in assets.enumerated(){
                print(i, item)
                item.getURL(){ [self] url in
                    mainQueue.async {
                    //print(url ?? "无值")
                    //print(type(of: url))
                    print(i, item)
                    selectedUrlString.append(url!.absoluteString)
                    print("selectedUrlString", selectedUrlString)
                    
                    let isVideo = assets[i].mediaType == .video
                    if let type = url?.absoluteString.components(separatedBy: ".")[1]{
                        selectedFileType.append("." + type)
                    }else{
                        selectedFileType.append( isVideo ? ".mp4" : ".png")
                    }
                }}
            }
        }
    }
    ////////-     ---- 未使用，存在错误   -------////////
    func fetchAssetType(assets: [PHAsset]) {
        for asset in assets {
            ZLPhotoManager.fetchAssetFilePath(asset: asset) { (filePath) in
                let isVideo = asset.mediaType == .video
                let fileName: String
                if let value = filePath?.components(separatedBy: "/").last {
                    fileName = value
                } else {
                    fileName = "video" + (isVideo ? ".mp4" : ".jpg")
                }
                debugPrint("fileName: \(fileName)")
                debugPrint("isVideo: \(isVideo)")
            }
        }
    }
    public func reset(){
        images = []
        assets = []
        selectedUrlString = []
    }
    public func remove(at: Int){
        images.remove(at: at)
        assets.remove(at: at)
        //selectedUrlString.remove(at: at)
    }
    
    ////// ----video 选择方法 ---//////
    public func getVideoAsstetsUrlToString(){ //
        if videoAssets != []{
            for (i, element) in videoAssets.enumerated(){
                print("输出", i, element)
                videoAssets[i].getURL(){ [self] url in
                    print(url ?? "无值")
                    print(type(of: url))
                    selectedVideoUrlString.append(url!.absoluteString)
                    print("selectedUrlString", selectedVideoUrlString)
                }
            }
        }
    }
    public func selectMultipleVideos() { // 选择多个视频
        let config = ZLPhotoConfiguration.default()
        config.allowSelectImage = false
        config.allowSelectVideo = videoImages.count == 0
        config.allowSelectGif = false
        config.allowSelectLivePhoto = false
        config.allowSelectOriginal = false
        config.cropVideoAfterSelectThumbnail = false
        config.allowEditVideo = true
//        config.allowMixSelect = false
//        config.maxSelectCount = 5
        //config.minVideoSelectCount = 1
        config.maxVideoSelectCount = 3
        config.maxEditVideoTime = 1000
        
        
        let scene = UIApplication.shared.connectedScenes.first
        let root = (scene as? UIWindowScene)?.windows.first?.rootViewController
        if root != nil {
            let ac = ZLPhotoPreviewSheet()
            ac.selectImageBlock = { [self] (image, asset, _) in
                hasSelectVideo = videoAssets.first?.mediaType == .video
                videoImages.append(contentsOf: image)
                videoAssets.append(contentsOf: asset)
            }
            ac.showPhotoLibrary(sender: root!)
            // ac.showPreview(animate: true, sender: root!)
        }
    }
    public func fetchFileType(_ asset: PHAsset){ // 选择的类型
        asset.getURL(){ [self] url in
                DispatchQueue.main.sync {
                let isVideo = asset.mediaType == .video
                if let type = url?.absoluteString.components(separatedBy: ".")[1]{
                    fileType = "." + type
                }else{
                    fileType = isVideo ? ".mp4" : ".png"
                }
                }
            }
    }
    public func saveAllVideosToDocumentDirectory(){
        if videoAssets != []{
            for (i, element) in videoAssets.enumerated(){
                print(element)
                saveVideoToDocumentDirectory(videoAssets[i], i) {(url, error) in
                    print(url as Any)
                }
            }
        }
    }
    public func saveVideoToDocumentDirectory(_ chosenVideo: PHAsset,_ fileOrder: Int, completion: @escaping ( (URL?, Error?) -> Void )){   // 保存到此APP文件夹内
            let directoryPath = NSHomeDirectory().appending("/Documents/")
            if !FileManager.default.fileExists(atPath: directoryPath) {
                do {
                    try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directoryPath), withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error)
                }
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddhhmmss"
            fetchFileType(chosenVideo)
            PHCachingImageManager().requestAVAsset(forVideo: chosenVideo, options: nil, resultHandler: { [self](asset, audioMix, info)in
                let avAsset: AVAsset = (asset as? AVURLAsset)!
                let filename = "HS" + dateFormatter.string(from: Date()) + "_" + String(fileOrder) + fileType
                outputVideoFilename.append(filename)
                let filepath = directoryPath.appending(filename)
                let url = URL(fileURLWithPath: filepath)
                print(filepath)
                guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough) else {
                    completion(nil, NSError(domain: "", code: -1000, userInfo: [NSLocalizedDescriptionKey: "video export failed"]))
                    return
                }
                exportSession.outputURL = url
                // 不同的类型确定不同的导出类型
                exportSession.outputFileType = .mp4
                exportSession.exportAsynchronously(completionHandler: {
                    let suc = exportSession.status == .completed
                    if exportSession.status == .failed {
                        debugPrint("ZLPhotoBrowser:视频导出失败 \(exportSession.error?.localizedDescription ?? "")")
                    }
                    DispatchQueue.main.async {
                        completion(suc ? url : nil, exportSession.error)
                    }
                })
                fileType = ""
                outputVideoFilename.sort()
                // 执行写入数据库的函数
            })
    }
    public func videoReset(){
        videoImages = []
        videoAssets = []
        hasSelectVideo = false
        selectedVideoUrlString = []
    }
    public func videoRemove(at: Int){
        videoImages.remove(at: at)
        videoAssets.remove(at: at)
        selectedVideoUrlString.remove(at: at)
    }
    
    
    ////// - GIF 选择------///////
    public func selectMultipleGif() { // 选择多个GIF
        let config = ZLPhotoConfiguration.default()
        config.allowSelectImage = true
        config.allowSelectGif = true
        config.allowSelectLivePhoto = false
        config.allowSelectVideo = false
        config.allowSelectOriginal = true
        config.cropVideoAfterSelectThumbnail = false
        config.maxSelectCount = 20
        
        
        let scene = UIApplication.shared.connectedScenes.first
        let root = (scene as? UIWindowScene)?.windows.first?.rootViewController
        if root != nil {
            let ac = ZLPhotoPreviewSheet()
            ac.selectImageBlock = { [self] (image, asset, _) in
                gifImages.append(contentsOf: image)
                gifAssets.append(contentsOf: asset)
                for (i, _) in asset.enumerated(){
                    let zlPhotoModel = ZLPhotoModel(asset: asset[i])
                    isGif.append(zlPhotoModel.transformAssetType(for: asset[i]) == .gif)
                }
            }
            ac.showPhotoLibrary(sender: root!)
        }
    }
    public func preview(){
        let scene = UIApplication.shared.connectedScenes.first
        let root = (scene as? UIWindowScene)?.windows.first?.rootViewController
        if root != nil {
            let ac = ZLPhotoPreviewSheet()
            ac.previewAssets(sender: root!, assets: gifAssets, index: 0, isOriginal: false, showBottomViewAndSelectBtn: false)
        }
    }
    public func gifReset(){
        gifImages = []
        gifAssets = []
        previewGifUrlString = ""
    }
    public func getGifAsstetsUrlToString(asset: PHAsset){ //
        asset.getURL(){ [self] url in
            previewGifUrlString = url!.absoluteString
        }
    }
    public func gifRemove(at: Int){
        gifImages.remove(at: at)
        gifAssets.remove(at: at)
        previewGifUrlString = ""
    }
    public func saveAllGifToDocumentDirectory(){
        if gifAssets != []{
            for (i, _) in gifAssets.enumerated(){
                saveGifToDocumentDirectory(images[i], assets[i], i)
            }
        }
    }
    
    public func saveAllImagesToDocumentDirectory(){
        if assets != []{
            for (i, _) in assets.enumerated(){
                saveImageToDocumentDirectory(images[i], assets[i], i)
            }
        }
    }
    public func saveImageToDocumentDirectory(_ chosenImage: UIImage, _ asset: PHAsset, _ fileOrder: Int){   // 保存到此APP文件夹内
            let directoryPath =  NSHomeDirectory().appending("/Documents/")
            if !FileManager.default.fileExists(atPath: directoryPath) {
                do {
                    try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directoryPath), withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error)
                }
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddhhmmss"
            asset.getURL{ [self] url in
                let isVideo = asset.mediaType == .video
                var imageType: String
                if let type = url?.absoluteString.components(separatedBy: ".")[1]{
                    imageType = "." + type
                }else{
                    imageType = isVideo ? ".mp4" : ".png"
                }
                let filename = "HS" + dateFormatter.string(from: Date()) + "_" + String(fileOrder) + imageType
                outputImageFilename.append(filename)
                let filepath = directoryPath.appending(filename)
                let url = NSURL.fileURL(withPath: filepath)
                do {
                    try chosenImage.jpegData(compressionQuality: 0.75)?.write(to: url, options: .atomic)
                } catch {
                    print(error)
                    print("图片导出失败 \(filepath), with error : \(error)")
                }
                // 对文件名进行排序
                outputImageFilename.sort()
                // print(outputImageFilename)
                // 执行写入数据库的
            }
    }
    public func saveGifToDocumentDirectory(_ chosenImage: UIImage, _ asset: PHAsset, _ fileOrder: Int){   // 保存到此APP文件夹内
            let directoryPath =  NSHomeDirectory().appending("/Documents/")
            if !FileManager.default.fileExists(atPath: directoryPath) {
                do {
                    try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directoryPath), withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error)
                }
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddhhmmss"
            asset.getURL{ [self] url in
                let isVideo = asset.mediaType == .video
                var imageType: String
                if let type = url?.absoluteString.components(separatedBy: ".")[1]{
                    imageType = "." + type
                }else{
                    imageType = isVideo ? ".mp4" : ".png"
                }
                let filename = "HS" + dateFormatter.string(from: Date()) + "_" + String(fileOrder) + imageType
                outputGifFilename.append(filename)
                let filepath = directoryPath.appending(filename)
                let url = NSURL.fileURL(withPath: filepath)
                if imageType == ".GIF" || imageType == ".Gif" || imageType == "gif"{
                    _ = PhotoBrowser.fetchOriginalImageData(for: asset){ (data, _, _) in
                        do{
                            try data.write(to: url, options: .atomic)
                        }catch{
                            print(error)
                        }
                    }
                }else{
                do {
                    try chosenImage.jpegData(compressionQuality: 0.75)?.write(to: url, options: .atomic)
                } catch {
                    print(error)
                    print("GIF导出失败 \(filepath), with error : \(error)")
                }}
                outputGifFilename.sort()
                //执行写入数据库的操作
            }
    }
    @discardableResult
    class func fetchOriginalImageData(for asset: PHAsset, progress: ( (CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void )? = nil, completion: @escaping ( (Data, [AnyHashable: Any]?, Bool) -> Void)) -> PHImageRequestID {
        let option = PHImageRequestOptions()
        if (asset.value(forKey: "filename") as? String)?.hasSuffix("GIF") == true {
            option.version = .original
        }
        option.isNetworkAccessAllowed = true
        option.resizeMode = .fast
        option.deliveryMode = .highQualityFormat
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                progress?(CGFloat(pro), error, stop, info)
            }
        }
        
        return PHImageManager.default().requestImageData(for: asset, options: option) { (data, _, _, info) in
            let cancel = info?[PHImageCancelledKey] as? Bool ?? false
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            if !cancel, let data = data {
                completion(data, info, isDegraded)
            }
        }
    }
}

extension Binding where Value: MutableCollection, Value.Index == Int {
    func element(_ idx: Int) -> Binding<Value.Element> {
        return Binding<Value.Element>(
            get: {
                return self.wrappedValue[idx]
        }, set: { (value: Value.Element) -> () in
            self.wrappedValue[idx] = value
        })
    }
}

extension PHAsset {
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

extension FileManager {

    open func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }

}
