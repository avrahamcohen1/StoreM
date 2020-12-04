import UIKit

class WebFileDownloader {
    static func downloadFileSync(fileName:String, completion: @escaping (String?, Error?) -> Void){
        let webUrlStr = "http://" + UserDefaults.standard.string(forKey:"wareIP")! + "/Downloads/" + fileName
        let webUrl = URL(string: webUrlStr)
      
        let localUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        
        if let dataFromURL = NSData(contentsOf: webUrl!){
               if dataFromURL.write(to: localUrl, atomically: true){
                   completion(localUrl.path, nil)
                   //print("Saved: \(localUrl.path)")
               } else{
                   print("error saving file")
                   let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                   completion(localUrl.path, error)
               }
        } else{
               let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
               print("Error downloading file \(error)")
               completion(localUrl.path, error)
        }
    }
}

class WebFileDownloaderNew {
    static func downloadFileSync(fileName:String, completion: @escaping (String?, Error?) -> Void){
        let webUrlStr = "http://" + UserDefaults.standard.string(forKey:"wareIP")! + "/Downloads/" + fileName
        let webUrl = URL(string: webUrlStr)!
      
        let localUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        
        Downloader.downloadFileSync(url: webUrl, to: localUrl)
    }
}

class Downloader {
    class func downloadFileSync(url: URL, to localUrl: URL) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url)

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }

                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                   // completion()
                } catch (let writeError) {
                    print("error writing file \(localUrl) : \(writeError)")
                }

            } else {
                print("Failure: %@", error?.localizedDescription);
            }
        }
        task.resume()
    }
}
