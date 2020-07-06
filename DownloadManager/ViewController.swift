//
//  ViewController.swift
//  DownloadManager
//
//  Created by Fikri on 06/07/20.
//  Copyright © 2020 Fikri Helmi. All rights reserved.
//

import UIKit

class DownloadManager: NSObject {
    static var shared = DownloadManager()
    
    var progress: ((Int64, Int64) -> ())? //mengukur progress unduh
    var completed: ((URL) -> ())? // Memberitahu jika file sudah selesai di unduh
    var downloadError: ((URLSessionTask, Error?) -> ())?
    
    
    lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "com.dicoding.downloadTask") //berjalan di background
        //let config = URLSessionConfiguration.default // akan terulang dari awal
        
        config.isDiscretionary = false
        
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }()
}

extension DownloadManager: URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesWritten > 0 {
            progress?(totalBytesWritten, totalBytesExpectedToWrite)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        completed?(location)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        downloadError?(task, error)
    }
}

class ViewController: UIViewController {

    let progressView: UIProgressView = {
        let v = UIProgressView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let messageView: UILabel = {
        let v = UILabel()
        
        v.textAlignment = .center
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    lazy var btnDownload: UIButton = {
        let v = UIButton(type: .roundedRect)
        
        v.setTitle("Download", for: .normal)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(downloadFile), for: .touchUpInside)
        
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        view.addSubview(progressView)
        view.addSubview(messageView)
        view.addSubview(btnDownload)
        
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 200),
            progressView.heightAnchor.constraint(equalToConstant: 20),
            
            messageView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 5),
            messageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            btnDownload.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 20),
            btnDownload.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    
        let _ = DownloadManager.shared.session
        
        DownloadManager.shared.progress = { (totalBytesWritten, totalBytesExpectedToWrite) in
            let totalMB = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .binary)
            let writtenMB = ByteCountFormatter.string(fromByteCount: totalBytesWritten, countStyle: .binary)
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            
            DispatchQueue.main.async {
                self.btnDownload.isEnabled = false
                self.progressView.progress = progress
                self.messageView.text = "Downloading \(writtenMB) of \(totalMB)"
            }
        }
        
        DownloadManager.shared.completed = { (location) in
            print("Download is Finished")
            
            try? FileManager.default.removeItem(at: location)
            
            DispatchQueue.main.async {
                self.btnDownload.isEnabled = true
            }
        }
        
        DownloadManager.shared.downloadError = { (task, error) in
            print("Task Completed: \(task), error: \(error)")
        }
    }
    
    @objc private func downloadFile() {
        let url = URL(string: "http://212.183.159.230/50MB.zip")
        
        let task = DownloadManager.shared.session.downloadTask(with: url!)
        
        task.resume()
    }
}

/* upload file
 let file = "Location/To/Your/File.mp4"
  
 var request = URLRequest(url: URL(string: "https://api.dicoding.com/upload")!)
 request.httpMethod = "POST"
 request.setValue(file.lastPathComponent, forHTTPHeaderField: "filename")
  
 let config = URLSessionConfiguration.background(withIdentifier: "it.dicoding.upload")
  
 config.isDiscretionary = false
 config.networkServiceType = .video
  
 let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
  
 let task = session.uploadTask(with: request, fromFile: file)
 task.resume()
 */

