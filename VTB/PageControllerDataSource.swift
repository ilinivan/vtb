import Foundation
import UIKit
import AVFoundation
import AVKit

class PageControllerDataSource: NSObject, UIPageViewControllerDataSource {
    
    var urls: [String] = []
    
    lazy var controllers: [UIViewController] = {
        var controllers:[AVPlayerViewController] = []
        for url in urls {
            let controller = playerWithUrl(url: url)
            controllers.append(controller!)
        }
        return controllers
    }()
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        let index = controllers.firstIndex(of: viewController)!
        if index == 0 {
            return nil
        }
        let vc = controllers[index - 1]
        return vc
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        let index = controllers.firstIndex(of: viewController)!
        
        if index == controllers.count - 1 {
            return nil
        }
        let vc = controllers[index + 1]
        return vc
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return controllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func playerWithUrl(url: String) -> AVPlayerViewController? {
        guard let url = URL(string: url) else {
            print("can not create URL: \(url)")
            return nil
        }

        let playerItem = AVPlayerItem(url: url)
        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        let player = AVPlayer(playerItem: playerItem)
        let controller = AVPlayerViewController()
        controller.player = player
        
        return controller
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let item = object as? AVPlayerItem {
            if keyPath == "status" && item.status == .failed {
                
                let controller = controllers.first { ($0 as? AVPlayerViewController)?.player?.currentItem == item }
                
                guard let controller = controller else {
                    return
                }
                
                let error = item.error?.localizedDescription ?? "unknown error"
                showError(error, on: controller)
            }
        }
    }
    
    func showError(_ error: String, on controller: UIViewController) {
        let errorLabel = UILabel()
        errorLabel.textColor = .white
        errorLabel.text = error
        errorLabel.lineBreakMode = .byWordWrapping
        errorLabel.numberOfLines = 0
        controller.view.addSubview(errorLabel)
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor).isActive = true
        errorLabel.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: 20).isActive = true
        errorLabel.rightAnchor.constraint(equalTo: controller.view.rightAnchor, constant: -20).isActive = true
    }
    
    deinit {
        for controller in controllers {
            let item = (controller as? AVPlayerViewController)?.player?.currentItem
            item?.removeObserver(self, forKeyPath: "status")
        }
    }
}
