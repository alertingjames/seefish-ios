//
//  DownloadTask.swift
//  See Fish
//
//  Created by james on 8/26/23.
//

import Foundation
import UIKit


class DownloadTask: NSObject {
    var totalDownloaded: Float = 0 {
        didSet {
            self.handleDownloadedProgressPercent?(totalDownloaded)
        }
    }
    typealias progressClosure = ((Float) -> Void)
    var handleDownloadedProgressPercent: progressClosure!
    
    // MARK: - Properties
    private var configuration: URLSessionConfiguration
    private lazy var session: URLSession = {
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
        
        return session
    }()
    
    // MARK: - Initialization
    override init() {
        self.configuration = URLSessionConfiguration.background(withIdentifier: "backgroundTasks")
        
        super.init()
    }

    func download(url: String, progress: ((Float) -> Void)?) {
        /// bind progress closure to View
        self.handleDownloadedProgressPercent = progress
        
        /// handle url
        guard let url = URL(string: url) else {
            preconditionFailure("URL isn't true format!")
        }
        
        let task = session.downloadTask(with: url)
        task.resume()
    }

}

extension DownloadTask: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        self.totalDownloaded = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        print("downloaded : \(location.downloadURL)")
        if let shareAlert = gShareAlert {
            shareAlert.finalizeDownload(furl: location)
        }
    }
}

