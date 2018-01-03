//
//  WatsonChatDetailViewController.swift
//  WestfieldAppV2
//
//  Created by Arun Jack on 28/12/17.
//  Copyright © 2017 Arun Jack. All rights reserved.
//

import UIKit

// MARK: - Type
class WatsonChatDetailViewController: UIViewController, UIWebViewDelegate {

    var urlStr: String?
    @IBOutlet weak var detailWebView: UIWebView!
    @IBOutlet weak var shareButton: UIButton!
    var indicatorView = ActivityView()
    var currentMsg: Message?
    var msgType: MessageType?
    var vUrls = [URL]()
    
    @IBOutlet weak var detailTable: UITableView!
    
    @IBOutlet weak var feedbackRatingView: RatingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.topItem?.title = ""
        // Do any additional setup after loading the view.
        
        let settingsBut = UIButton.init(type: .custom)
        settingsBut.setImage(UIImage(named: "Settings"), for: UIControlState.normal)
        settingsBut.imageView?.contentMode = .scaleAspectFit
        settingsBut.addTarget(self, action: #selector(WatsonChatDetailViewController.moveToSettingPage), for: UIControlEvents.touchUpInside)
        settingsBut.frame = CGRect(x: 0, y: 0, width: 48, height: 40)
        //settingsBut.backgroundColor = UIColor.yellow
        settingsBut.imageEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 0)
        
        let settingsBarButton = UIBarButtonItem(customView: settingsBut)
        self.navigationItem.setRightBarButton(settingsBarButton, animated: true)

        
        self.detailWebView.delegate = self
        
        detailTable.rowHeight = UITableViewAutomaticDimension
        detailTable.estimatedRowHeight = 140
        detailTable.scrollsToTop = false

        
        feedbackRatingView.backgroundColor = UIColor.clear
        feedbackRatingView.delegate = self
        feedbackRatingView.contentMode = UIViewContentMode.scaleAspectFit
        feedbackRatingView.type = .fullRatings

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if msgType == .Video {
            self.detailTable.isHidden = false
            self.detailWebView.isHidden = true
        } else {
            
            self.detailTable.isHidden = true
            self.detailWebView.isHidden = false

            self.loadUrlToWebView()
        }
    }
    func stopAnimating() {

        indicatorView.stopAnimating()
        indicatorView.hidesWhenStopped = true
        indicatorView.removeFromSuperview()
}
    
    func StartAnimating() {
        
        indicatorView.frame = CGRect(x:0,y:0,width:50,height:50)
        indicatorView.center = self.view.center//CGPoint(x:self.view.center,y:self.view)
        indicatorView.lineWidth = 5.0
        indicatorView.strokeColor = UIColor(red: 0.0/255, green: 122.0/255, blue: 255.0/255, alpha: 1)
        self.view.addSubview(indicatorView)
        indicatorView.startAnimating()
        
    }
    func webViewDidStartLoad(_ webView: UIWebView){
        //self.activityIndicator.startAnimating()
        self.StartAnimating()
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView){
        //self.activityIndicator.stopAnimating()
        self.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        //self.activityIndicator.stopAnimating()
        self.stopAnimating()
        
    }

    
    func loadUrlToWebView() {
        
        print("myUrl>>>>>>\(urlStr)")
        
        let videoID = self.extractYoutubeIdFromLink(link: urlStr!)
        
        if videoID != nil{
            detailWebView.allowsInlineMediaPlayback = true
            detailWebView.mediaPlaybackRequiresUserAction = false
            
            
            print(videoID!)
            // get the ID of the video you want to play
            //videoID = "Km8XxRCuCho" // https://www.youtube.com/watch?v=zN-GGeNPQEg
            
            // Set up your HTML.  The key URL parameters here are playsinline=1 and autoplay=1
            // Replace the height and width of the player here to match your UIWebView's  frame rect
            let embededHTML = "<html><body style='margin:0px;padding:0px;'><script type='text/javascript' src='http://www.youtube.com/iframe_api'></script><script type='text/javascript'>function onYouTubeIframeAPIReady(){ytplayer=new YT.Player('playerId',{events:{onReady:onPlayerReady}})}function onPlayerReady(a){a.target.playVideo();}</script><iframe id='playerId' type='text/html' width='\(self.view.frame.size.width)' height='\(self.view.frame.size.height)' src='http://www.youtube.com/embed/\(videoID!)?enablejsapi=1&rel=0&playsinline=1&autoplay=1&showinfo=0' frameborder='0'></body></html>"
            
            // Load your webView with the HTML we just set up
            detailWebView.loadHTMLString(embededHTML, baseURL: Bundle.main.bundleURL)
            
        }else{
            detailWebView.loadRequest(NSURLRequest(url: NSURL(string: urlStr!)! as URL) as URLRequest)
        }

    }

   @objc func moveToSettingPage()  {
    
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    let settingVc = storyBoard.instantiateViewController(withIdentifier: "settingsVC") as! SettingsViewController
    
    self.navigationController?.pushViewController(settingVc, animated: true)

    }
    
    @IBAction func shareAction(_ sender: Any) {
        
        
        let text = "Time for a little safety warm up"
        let myWebsite = NSURL(string:urlStr!)
        let shareAll = [text  , myWebsite ?? ""] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WatsonChatDetailViewController: videoCellDelegate {
    func loadFeedbackPage(_ videoUrl: String, cell: VideoViewCell) {
        
    }
    
    func sharingVideoUrl(_ videoUrl: String) {
        
    }
    
    func reloadVideo() {
        detailTable.reloadData()
    }
    
    
}

// MARK: - UITableViewDataSource
extension WatsonChatDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VideoViewCell.self),
                                                 for: indexPath) as! VideoViewCell
        cell.delegate = self
        cell.videoUrls = vUrls
//        //print(completedVideoURL)
        cell.page = "detail"
        cell.configure(withMessage: currentMsg!)
//
       // cell.chatViewController = self
        return cell

    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 273
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
       
            return 273
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }

    
}
extension WatsonChatDetailViewController{
    func extractYoutubeIdFromLink(link: String) -> String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        guard let regExp = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        let nsLink = link as NSString
        let options = NSRegularExpression.MatchingOptions(rawValue: 0)
        let range = NSRange(location: 0, length: nsLink.length)
        let matches = regExp.matches(in: link as String, options:options, range:range)
        if let firstMatch = matches.first {
            return nsLink.substring(with: firstMatch.range)
        }
        return nil
    }
    
}

extension WatsonChatDetailViewController: RatingViewDelegate {
    
}
