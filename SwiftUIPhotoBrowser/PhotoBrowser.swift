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
    @Published var selectedVideoUrlString: String = ""
   // @Published var fileType: String = ""
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
        
        //config.hudStyle = .dark
        config.themeColorDeploy.navBarColor = UIColor.white
        config.themeColorDeploy.navTitleColor = UIColor.blue // 取消，recent按钮颜色
        config.navViewBlurEffect = nil
        config.bottomToolViewBlurEffect = nil
        
        config.themeColorDeploy.albumListBgColor = UIColor.white
        config.themeColorDeploy.albumListTitleColor = UIColor.black
        config.themeColorDeploy.albumListCountColor = UIColor.black
        config.themeColorDeploy.separatorColor = UIColor.systemGray6 // 下拉相册列表分离器
        config.themeColorDeploy.navEmbedTitleViewBgColor = UIColor.systemGray6 // 下拉相册列表按钮的背景色
        
        config.themeColorDeploy.thumbnailBgColor = UIColor.white // 相册背景
        
        config.themeColorDeploy.bottomToolViewBgColor = UIColor.white
        config.themeColorDeploy.bottomToolViewBtnNormalTitleColor = UIColor.blue
        config.themeColorDeploy.bottomToolViewBtnDisableTitleColor = UIColor.white
        config.themeColorDeploy.bottomToolViewBtnNormalBgColor = UIColor.white //选择完成后按钮背景颜色
        config.themeColorDeploy.bottomToolViewBtnDisableBgColor = UIColor.white
        
        config.themeColorDeploy.cameraRecodeProgressColor = UIColor.systemGray6
        config.themeColorDeploy.cameraCellBgColor = UIColor.systemGray4 // 相机颜色
        
        config.themeColorDeploy.indexLabelBgColor = UIColor.init(red: 18 / 255, green: 150 / 255, blue: 219 / 255, alpha: 1) // 选择后数字下层按钮的颜色
        config.themeColorDeploy.selectedBorderColor = UIColor.systemGray4  // 不起作用
        
        
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
        outputImageFilename = []
    }
    public func remove(at: Int){
        images.remove(at: at)
        assets.remove(at: at)
        //selectedUrlString.remove(at: at)
    }
    
    ////// ----video 选择方法 ---//////
    public func getVideoAsstetsUrlToString(asset: PHAsset){ //
        asset.getURL(){ [self] url in
            selectedVideoUrlString = url!.absoluteString
            print("selectedUrlString", selectedVideoUrlString)
        }
    }
//    public func getGifAsstetsUrlToString(asset: PHAsset){ //
//        asset.getURL(){ [self] url in
//            previewGifUrlString = url!.absoluteString
//        }
//    }
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
        
        //config.hudStyle = .dark
        config.themeColorDeploy.navBarColor = UIColor.white
        config.themeColorDeploy.navTitleColor = UIColor.blue // 取消，recent按钮颜色
        config.navViewBlurEffect = nil
        config.bottomToolViewBlurEffect = nil
        
        config.themeColorDeploy.albumListBgColor = UIColor.white
        config.themeColorDeploy.albumListTitleColor = UIColor.black
        config.themeColorDeploy.albumListCountColor = UIColor.black
        config.themeColorDeploy.separatorColor = UIColor.systemGray6 // 下拉相册列表分离器
        config.themeColorDeploy.navEmbedTitleViewBgColor = UIColor.systemGray6 // 下拉相册列表按钮的背景色
        
        config.themeColorDeploy.thumbnailBgColor = UIColor.white // 相册背景
        
        config.themeColorDeploy.bottomToolViewBgColor = UIColor.white
        config.themeColorDeploy.bottomToolViewBtnNormalTitleColor = UIColor.blue
        config.themeColorDeploy.bottomToolViewBtnDisableTitleColor = UIColor.white
        config.themeColorDeploy.bottomToolViewBtnNormalBgColor = UIColor.white //选择完成后按钮背景颜色
        config.themeColorDeploy.bottomToolViewBtnDisableBgColor = UIColor.white
        
        config.themeColorDeploy.cameraRecodeProgressColor = UIColor.systemGray6
        config.themeColorDeploy.cameraCellBgColor = UIColor.systemGray4 // 相机颜色
        
        config.themeColorDeploy.indexLabelBgColor = UIColor.init(red: 18 / 255, green: 150 / 255, blue: 219 / 255, alpha: 1) // 选择后数字下层按钮的颜色
        config.themeColorDeploy.selectedBorderColor = UIColor.systemGray4  // 不起作用
        
        
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
//    public func fetchFileType(_ asset: PHAsset){ // 选择的类型
//        asset.getURL(){ [self] url in
//                DispatchQueue.main.sync {
//                let isVideo = asset.mediaType == .video
//                if let type = url?.absoluteString.components(separatedBy: ".")[1]{
//                    fileType = "." + type
//                }else{
//                    fileType = isVideo ? ".mp4" : ".png"
//                }
//                }
//            }
//    }
    public func saveAllVideosToDocumentDirectory(group: DispatchGroup){
        if videoAssets != []{
            for (i, _) in videoAssets.enumerated(){
                saveVideoToDocumentDirectory(videoAssets[i], i, group: group)
            }
        }
    }
    public func saveVideoToDocumentDirectory(_ chosenVideo: PHAsset,_ fileOrder: Int, group: DispatchGroup){   // 保存到此APP文件夹内
        group.enter()
            chosenVideo.getURL(){ [self] url in
            PHCachingImageManager().requestAVAsset(forVideo: chosenVideo, options: nil, resultHandler: { [self](asset, audioMix, info)in
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
                var fileType: String = ""
                let isVideo = chosenVideo.mediaType == .video
                if let type = url?.absoluteString.components(separatedBy: ".")[1]{
                    fileType = "." + type
                }else{
                    fileType = isVideo ? ".mp4" : ".png"
                }
                let avAsset: AVAsset = (asset as? AVURLAsset)!
                let filename = "HS" + dateFormatter.string(from: Date()) + "_" + String(fileOrder) + fileType
                DispatchQueue.main.async {
                    outputVideoFilename.append(filename)
                }
                let filepath = directoryPath.appending(filename)
                let url = URL(fileURLWithPath: filepath)
                guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough) else {
                    //completion(nil, NSError(domain: "", code: -1000, userInfo: [NSLocalizedDescriptionKey: "video export failed"]))
                    return
                }
                exportSession.outputURL = url
                // 不同的类型确定不同的导出类型
                exportSession.outputFileType = .mp4
                exportSession.exportAsynchronously(completionHandler: {
                    //let suc = exportSession.status == .completed
                    if exportSession.status == .failed {
                        debugPrint("ZLPhotoBrowser:视频导出失败 \(exportSession.error?.localizedDescription ?? "")")
                    }
                })
                fileType = ""
                DispatchQueue.main.async {
                    outputVideoFilename.sort()
                }
                // 执行写入数据库的函数
                group.leave()
            })
            }
    }
    public func resolutionSizeForLocalVideo(url:NSURL) -> CGSize? {
        guard let track = AVAsset(url: url as URL).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        print(CGSize(width: abs(size.width), height: abs(size.height)))
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    public func videoReset(){
        videoImages = []
        videoAssets = []
        hasSelectVideo = false
        selectedVideoUrlString = ""
        outputVideoFilename = []
    }
    public func videoRemove(at: Int){
        videoImages.remove(at: at)
        videoAssets.remove(at: at)
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
        
        //config.hudStyle = .dark
        config.themeColorDeploy.navBarColor = UIColor.white
        config.themeColorDeploy.navTitleColor = UIColor.blue // 取消，recent按钮颜色
        config.navViewBlurEffect = nil
        config.bottomToolViewBlurEffect = nil
        
        config.themeColorDeploy.albumListBgColor = UIColor.white
        config.themeColorDeploy.albumListTitleColor = UIColor.black
        config.themeColorDeploy.albumListCountColor = UIColor.black
        config.themeColorDeploy.separatorColor = UIColor.systemGray6 // 下拉相册列表分离器
        config.themeColorDeploy.navEmbedTitleViewBgColor = UIColor.systemGray6 // 下拉相册列表按钮的背景色
        
        config.themeColorDeploy.thumbnailBgColor = UIColor.white // 相册背景
        
        config.themeColorDeploy.bottomToolViewBgColor = UIColor.white
        config.themeColorDeploy.bottomToolViewBtnNormalTitleColor = UIColor.blue
        config.themeColorDeploy.bottomToolViewBtnDisableTitleColor = UIColor.white
        config.themeColorDeploy.bottomToolViewBtnNormalBgColor = UIColor.white //选择完成后按钮背景颜色
        config.themeColorDeploy.bottomToolViewBtnDisableBgColor = UIColor.white
        
        config.themeColorDeploy.cameraRecodeProgressColor = UIColor.systemGray6
        config.themeColorDeploy.cameraCellBgColor = UIColor.systemGray4 // 相机颜色
        
        config.themeColorDeploy.indexLabelBgColor = UIColor.init(red: 18 / 255, green: 150 / 255, blue: 219 / 255, alpha: 1) // 选择后数字下层按钮的颜色
        config.themeColorDeploy.selectedBorderColor = UIColor.systemGray4  // 不起作用
        
        
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
            ac.previewAssets(sender: root!, assets: assets, index: 0, isOriginal: false, showBottomViewAndSelectBtn: false)
        }
    }
    public func gifReset(){
        gifImages = []
        gifAssets = []
        previewGifUrlString = ""
        outputGifFilename = []
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
    public func saveAllGifToDocumentDirectory(group: DispatchGroup){
        if gifAssets != []{
            for (i, _) in gifAssets.enumerated(){
                saveGifToDocumentDirectory(gifImages[i], gifAssets[i], i, group: group)
            }
        }
    }
    
    public func saveAllImagesToDocumentDirectory(group: DispatchGroup){
        if assets != []{
            for (i, _) in assets.enumerated(){
                
                saveImageToDocumentDirectory(images[i], assets[i], i, group: group)
            }
        }
    }
    public func saveImageToDocumentDirectory(_ chosenImage: UIImage, _ asset: PHAsset, _ fileOrder: Int, group: DispatchGroup){   // 保存到此APP文件夹内
        group.enter()
            asset.getURL{ [self] url in
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
                let isVideo = asset.mediaType == .video
                var imageType: String
                if let type = url?.absoluteString.components(separatedBy: ".")[1]{
                    imageType = "." + type
                }else{
                    imageType = isVideo ? ".mp4" : ".png"
                }
                let filename = "HS" + String(fileOrder) + "_" + dateFormatter.string(from: Date()) + imageType
                DispatchQueue.main.async {
                    outputImageFilename.append(filename)
                }
                let filepath = directoryPath.appending(filename)
                let url = NSURL.fileURL(withPath: filepath)
                do {
                    try chosenImage.jpegData(compressionQuality: 0.75)?.write(to: url, options: .atomic)
                } catch {
                    print(error)
                    print("图片导出失败 \(filepath), with error : \(error)")
                }
                // 对文件名进行排序
                DispatchQueue.main.async {
                    outputImageFilename.sort{ $0.compare($1, options: .numeric) == .orderedAscending}
                }
                // print(outputImageFilename)
                // 执行写入数据库的
                group.leave()
            }
    }
    public func saveGifToDocumentDirectory(_ chosenImage: UIImage, _ asset: PHAsset, _ fileOrder: Int, group: DispatchGroup){   // 保存到此APP文件夹内
        group.enter()
            
            asset.getURL{ [self] url in
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
                let isVideo = asset.mediaType == .video
                var imageType: String
                if let type = url?.absoluteString.components(separatedBy: ".")[1]{
                    imageType = "." + type
                }else{
                    imageType = isVideo ? ".mp4" : ".png"
                }
                let filename = "HS" + String(fileOrder) + "_" + dateFormatter.string(from: Date()) + imageType
                DispatchQueue.main.async {
                    outputGifFilename.append(filename)
                }
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
                DispatchQueue.main.async {
                    outputGifFilename.sort{ $0.compare($1, options: .numeric) == .orderedAscending}
                }
                group.leave()
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
