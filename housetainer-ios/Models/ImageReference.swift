//
//  ImageReference.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/17/24.
//

import Foundation
import UIKit
import Photos

enum ImageReferenceError: Error{
    case unknownData
}

enum ImageReference: Codable{
    case photo(PHAsset)
    case url(URL)
    case image(UIImage)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let data = try? container.decode(Data.self, forKey: .data), let image = UIImage(data: data){
            self = .image(image)
        }else if let urlString = try? container.decode(String.self, forKey: .url), let URL = URL(string: urlString){
            self = .url(URL)
        }else if let assetId = try? container.decode(String.self, forKey: .assetId), let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject {
            self = .photo(asset)
        }else{
            throw ImageReferenceError.unknownData
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self{
        case let .photo(asset):
            try container.encode(asset.localIdentifier, forKey: .assetId)
        case let .url(URL):
            try container.encode(URL.absoluteString, forKey: .url)
        case let .image(uiImage):
            try container.encode(uiImage.pngData(), forKey: .data)
        }
    }
    
    enum CodingKeys: String, CodingKey{
    case data
    case url
    case assetId
    }
}

extension ImageReference{
    var isRemoteResource: Bool{
        guard case let .url(URL) = self else{ return false }
        return URL.scheme == "http" || URL.scheme == "https"
    }
    
    var absoluteString: String?{
        guard case let .url(URL) = self else{ return nil }
        return URL.absoluteString
    }
    
    var data: Data?{
        get async{
            switch self{
            case let .photo(asset):
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isNetworkAccessAllowed = true
                options.isSynchronous = false
                
                let wrapper = ConcurrencyWrapper{ (continuation: CheckedContinuation<Data?, Never>) in
                    let requestId = PHImageManager.shared.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                        continuation.resume(returning: data)
                    }
                    return ClosureCancellable{ PHImageManager.shared.cancelImageRequest(requestId) }
                }
                return await withTaskCancellationHandler {
                    await withCheckedContinuation {
                        wrapper.resume(with: $0)
                    }
                } onCancel: {
                    wrapper.cancel()
                }
            case let .image(uiImage):
                return uiImage.jpegData(compressionQuality: 1)
            case let .url(URL):
                return try? Data(contentsOf: URL)
            }
        }
    }
}
