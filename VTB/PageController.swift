
import UIKit

class PageController: UIPageViewController {

    let pcDataSource = PageControllerDataSource()
    var urlProvider: IUrlProvider!
    
    init() {
        super.init(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let loader = UIActivityIndicatorView()
        loader.style = .large
        loader.color = .white
        self.view.addSubview(loader)

        loader.startAnimating()
        
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        urlProvider = UrlProvider()
        urlProvider.obtainUrls { [weak self] (urls, error) in
            loader.stopAnimating()
            loader.removeFromSuperview()
            if let urls = urls {
                self?.configurePages(urls)
            }
            else if let error = error { 
                self?.processError(error)
            }
        }
    }
        
    func configurePages(_ urls: [String]) {
        pcDataSource.urls = urls
        self.dataSource = pcDataSource
        self.setViewControllers([pcDataSource.controllers.first!], direction: .forward, animated: false, completion: nil)
        
    }
    
    func processError(_ error: Error) {
        
        let errorText: String
        switch error {
        case UrlProviderError.obtainDataError(let str) :
            errorText = str
        case ConfigurationParserError.wrongJson(let str) :
            errorText = str
        default:
            errorText = "unknown error"
        }
        
        let errorLabel = UILabel()
        errorLabel.text = errorText
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = .white
        self.view.addSubview(errorLabel)
        errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}
