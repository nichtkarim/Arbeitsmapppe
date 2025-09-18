//
//  CompressPNGNetworkService.swift
//  UXLLM under the MIT License (MIT)
//  
//
//  Created on 15.11.23.
//

import Foundation
import Cocoa

class TinfyImageCompressorNetworkService: ImageCompressor {
    
    // MARK: - Properties
    private let tinfyShrinkURL = URL(string: "https://api.tinify.com/shrink")!
    private let tinyPNGKey: String
    
    // MARK: - Init
    init(tinyPNGKey: String) {
        self.tinyPNGKey = tinyPNGKey
    }
    
    // MARK: - Interface
    func resizeAndShrink(imageData: Data, size: CGSize) async throws -> Data {
        let jpegData = try convertToJPEGData(imageData)
        let shrinkResponse = try await shrinkImage(jpegData)
        return try await resizeImage(location: shrinkResponse.location, size: size)
    }
    
    // MARK: - Helpers
    private func convertToJPEGData(_ imageData: Data) throws -> Data {
        guard let jpegData = NSImage(data: imageData)?.jpegData() else {
            throw AppError.failedConvertingImageData
        }
        return jpegData
    }

    private func shrinkImage(_ jpegData: Data) async throws -> (location: URL, response: URLResponse) {
        var shrinkRequest = URLRequest(url: tinfyShrinkURL)
        shrinkRequest.httpMethod = "POST"
        shrinkRequest.allHTTPHeaderFields = header()
        shrinkRequest.httpBody = jpegData
        
        let (_, response) = try await URLSession.shared.data(for: shrinkRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201,
              let locationString = httpResponse.value(forHTTPHeaderField: "Location"),
              let location = URL(string: locationString) else {
            let httpResponseErrorCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw AppError.httpResponse(httpResponseErrorCode)
        }
        
        print("Shrink Response:\n", response)
        return (location, response)
    }

    private func resizeImage(location: URL, size: CGSize) async throws -> Data {
        var resizeRequest = URLRequest(url: location)
        resizeRequest.httpMethod = "POST"
        resizeRequest.allHTTPHeaderFields = header()
        
        let resizeBody = ["resize": ["method": "fit", 
                                     "width": size.width,
                                     "height": size.height]]
        resizeRequest.httpBody = try JSONSerialization.data(withJSONObject: resizeBody)
        
        let (data, response) = try await URLSession.shared.data(for: resizeRequest)
        print("Resize Response:\n", response)
        data.printSizeKB()
        return data
    }
    
    private func header() -> [String: String] {
        ["Content-Type": "application/json",
         "Authorization": generateAuthHeaderValue(),
         "Accept": "application/json"]
    }

    private func generateAuthHeaderValue() -> String {
        let auth = "api:\(tinyPNGKey)"
        let authData = auth.data(using: .utf8)?.base64EncodedString(options: .lineLength64Characters)
        return "Basic \(authData!)"
    }
}

private extension Data {
    func printSizeKB() {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useKB]
        byteCountFormatter.countStyle = .file
        let sizeInBytes = Int64(self.count)
        let formattedSize = byteCountFormatter.string(fromByteCount: sizeInBytes)
        print("Data size: \(formattedSize)")
    }
}
