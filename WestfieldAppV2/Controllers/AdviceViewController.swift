//
//  AdviceViewController.swift
//  WestfieldAppV2
//
//  Created by Arun Jack on 26/12/17.
//  Copyright © 2017 Arun Jack. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications
import TextToSpeechV1

class AdviceViewController: UIViewController, watsonChatCellDelegate,AVAudioPlayerDelegate {

    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var chatTableBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var chatTextField: ChatTextField!
    @IBOutlet weak var micImge: UIImageView!
    
    @IBOutlet weak var watsonSpeakImgView: UIImageView!
    @IBOutlet weak var speakButton: UIButton!
    @IBOutlet weak var overlayView: UIView!
    
    var heightAtIndexPath = NSMutableDictionary()

    var imageDimensionReduced : CGFloat = 1.0
    var timerAudio : Timer?
    let sharedInstnce = watsonSingleton.sharedInstance
    // MARK: - Properties
    var audioPlayer : AVAudioPlayer? = nil
    
    var messages = [Message]()
    var isTableScrolling : Bool = false
    var isSignOut : Bool = false
    var completedVideoURL = [URL]()
    var urlValue : URL? = nil

    var aboutToBecomeInvisibleCell = -1
    var visibleIP : IndexPath?

    // Settings View
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var settingPopover: UIView!
    @IBOutlet weak var voiceOnBut: UIButton!
    @IBOutlet weak var voiceOffBut: UIButton!
    
    var coverView: UIView?
    
    // MARK: - Services
    lazy var conversationService: ConversationService = ConversationService(delegate:self)
    lazy var speechToTextService: SpeechToTextService = SpeechToTextService(delegate:self)
    lazy var textToSpeechService: TextToSpeechService = TextToSpeechService(delegate:self)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.setupNavigationBar()
        self.settingsPageConfigure()
        
        self.chatTextField.layer.cornerRadius = 4.0
        self.chatTextField.layer.borderColor = UIColor.iwiSilver.cgColor
        self.chatTextField.layer.borderWidth = 0.5
        self.chatTextField.setLeftPaddingPoints(10)

        self.chatTextField.layer.shadowColor = UIColor.iwiSilver.cgColor
        self.chatTextField.layer.shadowOpacity = 1
        self.chatTextField.layer.shadowOffset = CGSize.zero
        self.chatTextField.layer.shadowRadius = 6

        self.micButton.layer.cornerRadius =  self.micButton.frame.size.width / 2
        self.micButton.layer.shadowColor = UIColor.iwiMicButtonShadow.cgColor
        self.micButton.layer.shadowOpacity = 1
        self.micButton.layer.shadowOffset = CGSize.zero
        self.micButton.layer.shadowRadius = 6

        chatTextField.chatViewController = self

        micButton.addTarget(self, action: #selector(userMicButton(sender:)), for: UIControlEvents.touchDown);
        micButton.addTarget(self, action: #selector(stopRecordings(sender:)), for: UIControlEvents.touchUpInside);
        micButton.addTarget(self, action: #selector(stopRecordings(sender:)), for: UIControlEvents.touchUpOutside);

        
        chatTableView.autoresizingMask = UIViewAutoresizing.flexibleHeight;
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.estimatedRowHeight = 140
        chatTableView.scrollsToTop = false
        
        self.registerNotificationObserver()
        
        // We need to send some dummy text to keep off the conversation
        conversationService.getValues()

        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Consultation"
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.65)

        overlayView.isHidden = true
        isSignOut = false
        chatTableBottomConstraint.constant = 10
        
        var screenRect = UIScreen.main.bounds
        screenRect.size.height = 90
        //create a new view with the same size
         coverView = UIView(frame: screenRect)
        // change the background color to black and the opacity to 0.6
        coverView?.backgroundColor = UIColor.black.withAlphaComponent(0.65)

        
        UIApplication.shared.isStatusBarHidden = false
        if sharedInstnce.isVoiceOn == true {
            
            if let url = Bundle.main.url(forResource: "Test", withExtension: "m4a"){
                audioPlayer = try! AVAudioPlayer(contentsOf: url)
            }
            
            watsonSpeakImgView.isHidden = false
            speakButton.isHidden = false
            micButton.isHidden = true
            micImge.isHidden = true
        } else {
            
            watsonSpeakImgView.isHidden = true
            speakButton.isHidden = true
            micButton.isHidden = false
            micImge.isHidden = false
            
        }
    }
    
    func setupNavigationBar()  {
        
        self.navigationController?.navigationBar.barTintColor = UIColor.iwiMainBlue
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]

        
        let progressBut = UIButton.init(type: .custom)
        progressBut.setImage(UIImage(named: "Progress_icon"), for: UIControlState.normal)
        progressBut.addTarget(self, action: #selector(AdviceViewController.moveProgressPage), for: UIControlEvents.touchUpInside)
        progressBut.imageView?.contentMode = .scaleAspectFit
        progressBut.frame = CGRect(x: 0, y: 0, width: 48, height: 40)
        progressBut.imageEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 0)
        //progressBut.backgroundColor = UIColor.yellow

        let settingsBut = UIButton.init(type: .custom)
        settingsBut.setImage(UIImage(named: "Settings"), for: UIControlState.normal)
        settingsBut.imageView?.contentMode = .scaleAspectFit
        settingsBut.addTarget(self, action: #selector(AdviceViewController.moveSettingPage), for: UIControlEvents.touchUpInside)
        settingsBut.frame = CGRect(x: 0, y: 0, width: 48, height: 40)
        //settingsBut.backgroundColor = UIColor.yellow
        settingsBut.imageEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 0)
        
        let toolBut = UIButton.init(type: .custom)
        toolBut.setImage(UIImage(named: "Toolbox_icon"), for: UIControlState.normal)
        toolBut.imageView?.contentMode = .scaleAspectFit
        toolBut.addTarget(self, action: #selector(AdviceViewController.moveToolBoxPage), for: UIControlEvents.touchUpInside)
        toolBut.frame = CGRect(x: 0, y: 0, width: 48, height: 40)
        toolBut.imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 25)
        //toolBut.backgroundColor = UIColor.yellow

        let progressBarButton = UIBarButtonItem(customView: progressBut)
        
        let settingsBarButton = UIBarButtonItem(customView: settingsBut)
        let toolboxBarButton = UIBarButtonItem(customView: toolBut)

        self.navigationItem.setLeftBarButton(toolboxBarButton, animated: true)
        self.navigationItem.setRightBarButtonItems([settingsBarButton, progressBarButton], animated: true)
        
    }
    
    @objc func moveProgressPage() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let progressVC = storyBoard.instantiateViewController(withIdentifier: "progressVC") as! ProgressViewController
        
        self.navigationController?.pushViewController(progressVC, animated: true)


    }
    
    @objc func moveSettingPage()  {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let settingVc = storyBoard.instantiateViewController(withIdentifier: "settingsVC") as! SettingsViewController
        
        self.navigationController?.pushViewController(settingVc, animated: true)
    }

    @objc func moveToolBoxPage()  {
        
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let toolBoxVc = storyBoard.instantiateViewController(withIdentifier: "toolboxVC") as! ToolboxViewController
        
        self.navigationController?.pushViewController(toolBoxVc, animated: true)

    }

    
    func settingsPageConfigure(){
        
        self.settingPopover.layer.shadowColor = UIColor.iwiSilver.cgColor
        self.settingPopover.layer.shadowOpacity = 1
        self.settingPopover.layer.shadowOffset = CGSize.zero
        self.settingPopover.layer.shadowRadius = 6
        
        self.settingsView.layer.cornerRadius = 4.0
        self.settingsView.clipsToBounds = true
        
     self.settingPopover.isHidden = true
        
    }
    @IBAction func turnOnVoiceAction(_ sender: Any) {
        sharedInstnce.isVoiceOn = true
        self.settingPopover.isHidden = true
        watsonSpeakImgView.isHidden = false
        speakButton.isHidden = false
        micButton.isHidden = true
        micImge.isHidden = true
        
        self.reEnableComponents()
    }
    
    @IBAction func trunOffVoiceAction(_ sender: Any) {
        sharedInstnce.isVoiceOn = false
        self.settingPopover.isHidden = true
        
        watsonSpeakImgView.isHidden = true
        speakButton.isHidden = true
        micButton.isHidden = false
        micImge.isHidden = false
        
        self.reEnableComponents()
    }
    
    @IBAction func speakButtonAction(_ sender: Any) {
        
        self.chatTableView.isUserInteractionEnabled = false
        self.chatTextField.isUserInteractionEnabled = false
        
        self.settingPopover.isHidden = false

    }
    func reEnableComponents()  {
        self.chatTableView.isUserInteractionEnabled = true
        self.chatTextField.isUserInteractionEnabled = true
    }
    @objc func userMicButton(sender:UIButton)
    {
        

        self.view.endEditing(true)
        
        let parentWindow = UIApplication.shared.keyWindow

        if self.micButton.isSelected {
            
            self.micButton.isSelected = false
            
            chatTextField.text = ""
            speechToTextService.stopTranscribing()

            self.micButton.layer.shadowColor = UIColor.iwiMicButtonShadow.cgColor
            self.micButton.layer.shadowOpacity = 1
            self.micButton.layer.shadowOffset = CGSize.zero
            self.micButton.layer.shadowRadius = 6
            
            self.micImge.layer.shadowOpacity = 0.0
            
            overlayView.isHidden = true

            coverView?.removeFromSuperview()
            
        } else {
            
            self.micButton.isSelected = true
            
            self.micButton.layer.shadowColor = UIColor.iwiMicSelectedShadow.cgColor
            self.micButton.layer.shadowOpacity = 1
            self.micButton.layer.shadowOffset = CGSize.zero
            self.micButton.layer.shadowRadius = 25
            
            
            self.micImge.layer.shadowColor = UIColor.iwiMicImageShadow.cgColor
            self.micImge.layer.shadowOpacity = 1
            self.micImge.layer.shadowOffset = CGSize.zero
            self.micImge.layer.shadowRadius = 16.2
            
            
            parentWindow?.addSubview(coverView!)
            
            
            overlayView.isHidden = false
            
            if sharedInstnce.isVoiceOn == true {
                if audioPlayer != nil{
                    if (audioPlayer?.isPlaying)!{
                        audioPlayer?.stop()
                        audioPlayer = nil
                    }
                }
                
                
            }
            chatTextField.text = "Recording..."
            speechToTextService.startRecording()

        }
        
    }
    
    @objc func stopRecordings(sender: UIButton) {
        
        chatTextField.text = ""
        speechToTextService.stopTranscribing()
    }
    
    
    func registerNotificationObserver()  {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self,selector: #selector(self.playerDidFinishPlaying),name:NSNotification.Name.UIWindowDidBecomeHidden,object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(imageDidLoadNotification(notification:)), name:NSNotification.Name(rawValue: "videoPlayingNotification"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(videoEndedPlaying),name: NSNotification.Name(rawValue: "videoEndedPlayingNotification"),object: nil)
        NotificationCenter.default.addObserver(self,selector:#selector(audioRouteChangeListener(notification:)),name: NSNotification.Name.AVAudioSessionRouteChange,
                                               object: nil)

    }
    
    @objc func playerDidFinishPlaying() {
        //UIApplication.shared.isStatusBarHidden = false
        //self.headerView.frame = CGRect(x:0,y:0,width:self.view.frame.size.width,height:self.headerView.frame.size.height)
        //self.headerView.setNeedsDisplay()
        
        // print("ppppppppppppp>>>>>>>>>>>PPPPPPPPlayeeeerrrrrrrMethod")
    }
    
    @objc func imageDidLoadNotification(notification: NSNotification) {
        print("VideoPlaying")
        if chatTextField != nil{
            self.chatTextField.isEnabled = false
            self.micButton.isEnabled = false
            //self.chatFieldBgImage.alpha = 0.5
            //self.micImage.alpha = 0.5
        }
        if sharedInstnce.isVoiceOn == true {
            if audioPlayer != nil{
                if (audioPlayer?.isPlaying)!{
                    //audioPlayer?.pause()
                    timerAudio?.invalidate()
                    timerAudio = nil
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "watsonSpeakingNotification"), object:self)
                }
            }
            
            
        }
        
        
        
    }
    
    @objc func videoEndedPlaying() {
        self.setNeedsStatusBarAppearanceUpdate()
        if chatTextField != nil{
            self.chatTextField.isEnabled = true
            self.micButton.isEnabled = true
            //self.chatFieldBgImage.alpha = 1.0
            //self.micImage.alpha = 1.0
        }
        
        if urlValue != nil{
            self.completedVideoURL.append(urlValue!)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (sharedInstnce.isVoiceOn == true){
            do {
                if let url = Bundle.main.url(forResource: "Test", withExtension: "m4a"){
                    audioPlayer = try! AVAudioPlayer(contentsOf: url)
                    audioPlayer?.stop()
                    audioPlayer?.currentTime = 0.0
                    audioPlayer = nil
                    isSignOut = true
                }
                //            if (audioPlayer?.isPlaying)!{
                //                audioPlayer?.stop()
                //            }
                //                audioPlayer = nil
                
            }
        }
        timerAudio?.invalidate()
        timerAudio = nil
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "watsonSpeakingNotification"), object:self)
        
    }

    
    
    
    /// Dismiss keyboard on screen tap
    override func dismissKeyboard() {
        chatTableBottomConstraint.constant = 10
        view.endEditing(true)
    }

    func appendChat(withMessage message: Message) {
        
        if isSignOut == false{
            guard let text = message.text,
                (text.characters.count > 0 || message.options != nil ||
                    message.mapUrl != nil || message.videoUrl != nil || message.imageUrl != nil)
                else { return }
            
            
            if message.type == MessageType.User && text.characters.count > 0 {
                conversationService.sendMessage(withText: text)
            }
            
            if let _ = messages.last?.options {
                /// If user speak or types instead of tapping option button, reload that cell
                let indexPath = NSIndexPath(row: messages.count - 1, section: 0) as IndexPath
                messages[messages.count - 1] = message
                chatTableView.reloadRows(at: [indexPath], with: .none)
            } else {
                messages.append(message)
                /// Add new row to chatTableView
                let indexPath = NSIndexPath(row: messages.count - 1, section: 0) as IndexPath
                chatTableView.beginUpdates()
                chatTableView.insertRows(at: [indexPath], with: .none)
                chatTableView.endUpdates()
                let when = DispatchTime.now()
                DispatchQueue.main.asyncAfter(deadline: when + 0.1) {
                    //self.scrollChatTableToBottom()
                    self.scrollChatTableToBottom()
                }
                
            }
        }
        
        //self.chatTableView.reloadData()
    }
    
    
    func scrollChatTableToBottom() {
        guard self.messages.count > 0 else { return }
        
        let indexPath = NSIndexPath(row: self.messages.count - 1, section: 0) as IndexPath
        chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        //self.chatTableView.reloadData()
    }
    
    // MARK: - Private
    // This will only execute on the simulator and NOT on a real device
    private func setupSimulator() {
        #if DEBUG
            
        #endif
    }
    
    func SendMessageWithButtonValue(with value:String, atIndex : Int){
        messages[atIndex].isEnableRdBtn = false
        messages[atIndex].selectedOption = value
        chatTableView.reloadData()
        let userMessage = Message(type: MessageType.User, text: value, options: nil,enableButton : true,selectedOption:"")
        self.appendChat(withMessage: userMessage)
        dismissKeyboard()
        
        
    }
    
    func gettabbarInfo() {
    }
    
    func moveImage(view: UIImageView){
        let toPoint: CGPoint = CGPoint(x:0.0, y:-10.0)
        let fromPoint : CGPoint = CGPoint.zero
        
        let movement = CABasicAnimation(keyPath: "movement")
        movement.isAdditive = true
        movement.fromValue =  NSValue(cgPoint: fromPoint)
        movement.toValue =  NSValue(cgPoint: toPoint)
        movement.duration = 0.3
        
        view.layer.add(movement, forKey: "move")
    }
    
    
    func loadUrlLink(url : String?){
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let detailVc = storyBoard.instantiateViewController(withIdentifier: "WatsonChatDetail") as! WatsonChatDetailViewController
        detailVc.urlStr = url

        self.navigationController?.pushViewController(detailVc, animated: true)
        
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
// MARK: - UITableViewDataSource
extension AdviceViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        switch message.type {
        case MessageType.Map:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MapViewCell.self),
                                                     for: indexPath) as! MapViewCell
            cell.configure(withMessage: message)
            return cell
            
        case MessageType.Watson:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WatsonChatViewCell.self),
                                                     for: indexPath) as! WatsonChatViewCell
            
            cell.delegate = self
            cell.indexNumber = indexPath.row
            cell.configure(withMessage: message)
            return cell
            
        case MessageType.User:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UserChatViewCell.self),
                                                     for: indexPath) as! UserChatViewCell
            cell.configure(withMessage: message)
            cell.chatViewController = self
            return cell
            
        case MessageType.Video:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VideoViewCell.self),
                                                     for: indexPath) as! VideoViewCell
            urlValue = message.videoUrl!
            cell.videoUrls = completedVideoURL
            //print(completedVideoURL)
            cell.configure(withMessage: message)
            
            cell.chatViewController = self
            return cell
            
        case MessageType.image:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MapViewCell.self),
                                                     for: indexPath) as! MapViewCell
            //cell.imageSizeScale = self.imageDimensionReduced
            cell.configure(withMessage: message)
            return cell
        }
        
    }
    
}

// MARK: - UITableViewDataSource
extension AdviceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        
        if message.type == MessageType.image {
            //print(message.text ?? "")
            if message.text == "1"{
                return 200
            }else{
                let value = CGFloat(Float(message.text!)!)
                
                return 200*value
            }
            
        }
        
        if message.type == MessageType.Video {
            //UIScreen.main.bounds.size.width * 0.66
            return 368
        }
        
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
            return CGFloat(height.floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = NSNumber(value: Float(cell.frame.size.height))
        print("height >>>>>>> \(height)")
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        isTableScrolling = true
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool){
        isTableScrolling = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isTableScrolling == true{
            let indexPaths = self.chatTableView.indexPathsForVisibleRows
            var cells = [Any]()
            for ip in indexPaths!{
                if let videoCell = self.chatTableView.cellForRow(at: ip) as? VideoViewCell{
                    cells.append(videoCell)
                }
            }
            let cellCount = cells.count
            if cellCount == 0 {return}
            if cellCount == 1{
                if visibleIP != indexPaths?[0]{
                    visibleIP = indexPaths?[0]
                }
                if let videoCell = cells.last! as? VideoViewCell{
                    self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?.last)!)
                }
            }
            if cellCount >= 2 {
                for i in 0..<cellCount{
                    let cellRect = self.chatTableView.rectForRow(at: (indexPaths?[i])!)
                    let intersect = cellRect.intersection(self.chatTableView.bounds)
                    let currentHeight = intersect.height
                    let cellHeight = (cells[i] as AnyObject).frame.size.height
                    print(currentHeight)
                    print(cellHeight * 0.95)
                    if currentHeight > (cellHeight * 0.95){
                        if visibleIP != indexPaths?[i]{
                            visibleIP = indexPaths?[i]
                            if let videoCell = cells[i] as? VideoViewCell{
                                self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?[i])!)
                            }
                        }
                    }
                    else{
                        if aboutToBecomeInvisibleCell != indexPaths?[i].row{
                            aboutToBecomeInvisibleCell = (indexPaths?[i].row)!
                            if let videoCell = cells[i] as? VideoViewCell{
                                self.stopPlayBack(cell: videoCell, indexPath: (indexPaths?[i])!)
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    func playVideoOnTheCell(cell : VideoViewCell, indexPath : IndexPath){
        cell.startPlayback()
    }
    
    func stopPlayBack(cell : VideoViewCell, indexPath : IndexPath){
        cell.stopPlayback()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //print("end = \(indexPath)")
        if let videoCell = cell as? VideoViewCell {
            videoCell.stopPlayback()
        }
    }
    
    func watsonStopedSpeaking() {
        //
    }
    
    
}
// MARK: - ConversationServiceDelegate
extension AdviceViewController: ConversationServiceDelegate {
    
    func errorReceiveResponse(){
        let vc = UIAlertController(title: "Error", message: "Error occured while receiving response", preferredStyle: UIAlertControllerStyle.alert)
        vc.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(vc, animated: false, completion: nil)
        
    }
    
    internal func didReceiveMessage(withText text: String, options: [String]?) {
        guard text.characters.count > 0 else { return }
        var text = text
        print(text)
        if text.contains("pindrop to"){
            let range2 = text.range(of: "(?<=<pindrop to=)[^><]+(?=>)", options: .regularExpression)
            if range2 != nil {
                let optionsStringNew = text.substring(with: range2!)
                print(optionsStringNew)
                if optionsStringNew.contains("advice icon"){
                    let userInfo = ["to":"0","from":"0"]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue : "DropPinInView"), object: nil, userInfo: userInfo)
                }
                if optionsStringNew.contains("toolbox icon"){
                    let userInfo = ["to":"1","from":"0"]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue : "DropPinInView"), object: nil, userInfo: userInfo)
                }
                if optionsStringNew.contains("news icon"){
                    let userInfo = ["to":"2","from":"0"]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue : "DropPinInView"), object: nil, userInfo: userInfo)
                }
                if optionsStringNew.contains("progress icon"){
                    let userInfo = ["to":"3","from":"0"]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue : "DropPinInView"), object: nil, userInfo: userInfo)
                }
                if optionsStringNew.contains("settings icon"){
                    let userInfo = ["to":"4","from":"0"]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue : "DropPinInView"), object: nil, userInfo: userInfo)
                }
                let rangeText2 = text.range(of:"<pindrop[^>]*>(.*?)</pindrop>", options:.regularExpression)
                
                if rangeText2 != nil {
                    let optionsStringNewOpt = text.substring(with: rangeText2!)
                    print(optionsStringNewOpt)
                    text = text.replacingOccurrences(of: optionsStringNewOpt, with: "")
                    
                }
                
            }
        }
        
        
        var opt = [String]()
        timerAudio?.invalidate()
        timerAudio = nil
        
        let rangeN = text.range(of:"\",\"", options:.regularExpression)
        if (rangeN != nil) {
            let textN = text.replacingOccurrences(of: "\",\"", with: "n&n")
            opt = textN.components(separatedBy: "n&n")
            var foundText = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            
            let regex = try! NSRegularExpression(pattern: "([hH][tT][tT][pP][sS]?:\\/\\/[^ ,'\">\\]\\)]*[^\\. ,'\">\\]\\)])")
            let nsString = foundText as NSString
            if let result = regex.matches(in: foundText, range: NSRange(location: 0, length: nsString.length)).last {
                let optionsString = nsString.substring(with: result.range)
                foundText = foundText.replacingOccurrences(of: optionsString, with: "")
            }else{
            }
            for item in 0..<opt.count{
                self.appendChat(withMessage: Message(type: MessageType.Watson, text: opt[item], options: nil,enableButton : true,selectedOption:""))
            }
            
        }else{
            
            var foundText = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            let regex = try! NSRegularExpression(pattern: "([hH][tT][tT][pP][sS]?:\\/\\/[^ ,'\">\\]\\)]*[^\\. ,'\">\\]\\)])")
            let nsString = foundText as NSString
            if let result = regex.matches(in: foundText, range: NSRange(location: 0, length: nsString.length)).last {
                let optionsString = nsString.substring(with: result.range)
                foundText = foundText.replacingOccurrences(of: optionsString, with: "")
            }else{
            }
            self.appendChat(withMessage: Message(type: MessageType.Watson, text: text, options: nil,enableButton : true,selectedOption:""))
        }
        
    }
    
    internal func didReceiveMessageForTexttoSpeech(withText text: String){
        self.imageDimensionReduced = 1.0
        var foundText = ""
        var text = text
        // print(text)
        
        let rangeText2 = text.range(of:"<pindrop[^>]*>(.*?)</pindrop>", options:.regularExpression)
        
        if rangeText2 != nil {
            let optionsStringNewOpt = text.substring(with: rangeText2!)
            print(optionsStringNewOpt)
            text = text.replacingOccurrences(of: optionsStringNewOpt, with: "")
            
        }
        
        if text.contains("tts="){
            let rangetts = text.range(of: "(?<=tts=)[^><]+(?=>)", options: .regularExpression)
            if rangetts != nil {
                var optionsString = text.substring(with: rangetts!)
                optionsString = optionsString.replacingOccurrences(of: "\"", with: "")
                let rangeImage = text.range(of:"<a[^>]*>(.*?)</a>", options:.regularExpression)
                if rangeImage != nil {
                    let optionsStringNew = text.substring(with: rangeImage!)
                    print(optionsStringNew)
                    if optionsString == "false" {
                        text = text.replacingOccurrences(of: optionsStringNew, with: "")
                    }
                }
            }
        }
        
        if text.contains("<wcs:input>"){
            text = text.replacingOccurrences(of: "<wcs:input>", with: "PauseVT")
        }
        
        let range2 = text.range(of: "(?<=<sub alias=)[^><]+(?=>)", options: .regularExpression)
        if range2 != nil {
            var correctedArray = [String]()
            let nsString = text as NSString
            let regex = try! NSRegularExpression(pattern: "(?<=<sub alias=)[^><]+(?=>)")
            for text in regex.matches(in: text, range: NSRange(location: 0, length: nsString.length)) {
                print(text.numberOfRanges)
                for i in 0..<text.numberOfRanges{
                    let  rangg = text.range(at: i)
                    
                    var stringST = nsString.substring(with: rangg)
                    stringST = stringST.replacingOccurrences(of: "\"", with: "")
                    stringST = stringST.replacingOccurrences(of: "\\", with: "")
                    //print(stringST)
                    correctedArray.append(stringST)
                    
                }
            }
            foundText = text
            
            if correctedArray.count>0{
                
                for i in 0..<correctedArray.count{
                    let rangeText2 = foundText.range(of:"<sub[^>]*>(.*?)</sub>", options:.regularExpression)
                    
                    if rangeText2 != nil {
                        let optionsStringNew = foundText.substring(with: rangeText2!)
                        //print(optionsStringNew)
                        foundText = foundText.replacingOccurrences(of: optionsStringNew, with: correctedArray[i])
                        //print(foundText)
                        //print(text)
                        
                    }
                }
                foundText = foundText.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression, range: nil)
            }
            
        }else{
            foundText = text.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression, range: nil)
        }
        
        //print("myyyyyfirstTeexxttt>>>\(text)")
        let regex = try! NSRegularExpression(pattern: "([hH][tT][tT][pP][sS]?:\\/\\/[^ ,'\">\\]\\)]*[^\\. ,'\">\\]\\)])")
        let nsString = foundText as NSString
        if let result = regex.matches(in: foundText, range: NSRange(location: 0, length: nsString.length)).last {
            let optionsString = nsString.substring(with: result.range)
            //print("With optionsString..\(optionsString)")
            foundText = foundText.replacingOccurrences(of: optionsString, with: "")
            //   print("Speech textt>URRRRLLL>>>\(foundText)")
        }
        
        
        
        foundText = foundText.replacingOccurrences(of: "\",\"", with: "<paragraph> </paragraph>")
        foundText = foundText.replacingOccurrences(of: "PauseVT", with: "<paragraph> </paragraph>")
        foundText = foundText.replacingOccurrences(of: " – ", with: " ")
        foundText = foundText.replacingOccurrences(of: ";", with: ",")
        foundText = foundText.replacingOccurrences(of: ":", with: ".")
        if (sharedInstnce.isVoiceOn == true){
            
            self.textToSpeechService.synthesizeSpeech(withText: foundText)
        }
    }
    
    
    
    
    
    internal func didReceiveImageResizeFactor(with Value:Float){
        self.imageDimensionReduced = CGFloat(Value)
        // self.chatTableView.reloadData()
    }
    
    internal func didReceiveMap(withUrl mapUrl: URL) {
        var message = Message(type: MessageType.Map, text: "", options: nil,enableButton : true,selectedOption:"")
        message.mapUrl = mapUrl
        self.appendChat(withMessage: message)
    }
    
    internal func didReceiveVideo(withUrl videoUrl: URL) {
        var message = Message(type: MessageType.Video, text: "", options: nil,enableButton : true,selectedOption:"")
        message.videoUrl = videoUrl
        self.appendChat(withMessage: message)
    }
    
    internal func didReceiveImage(withUrl imageUrl: URL, andScale:String) {
        var message = Message(type: MessageType.image, text: "", options: nil,enableButton : true,selectedOption:"")
        message.imageUrl = imageUrl
        message.text = andScale
        self.appendChat(withMessage: message)
    }
    
}

// MARK: - SpeechToTextServiceDelegate
extension AdviceViewController: SpeechToTextServiceDelegate {
    
    func didFinishTranscribingSpeech(withText text: String) {
        appendChat(withMessage: Message(type: MessageType.User, text: text, options: nil,enableButton : true,selectedOption:""))
    }
    
}

// MARK: - TextToSpeechServiceDelegate
extension AdviceViewController: TextToSpeechServiceDelegate {
    
    func textToSpeechDidFinishSynthesizing(withAudioData audioData: Data) {
        
        
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs.count > 0 {
            for description in currentRoute.outputs {
                print(description.portType)
                if description.portType == AVAudioSessionPortHeadphones {
                    print("headphone plugged in")
                }
                else if description.portType == AVAudioSessionPortBluetoothA2DP{
                    print("Bluetooth plugged in")
                }
                else {
                    print("headphone pulled out")
                }
            }
        } else {
            print("requires connection to device")
        }
        
        
        if isSignOut == false{
            audioPlayer = try! AVAudioPlayer(data: audioData)
            audioPlayer?.delegate = self
            
           // #if !DEBUG
                
                audioPlayer?.play()
                timerAudio = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(playingAudio), userInfo: nil, repeats: true)
           // #endif
            
        }
        
    }
    
    @objc func audioRouteChangeListener(notification:NSNotification) {
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        
        switch audioRouteChangeReason {
        case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue:
            print("headphone plugged in")
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.none)
                
            } catch _ {
                
            }
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue:
            print("headphone pulled out")
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
                
            } catch _ {
                
            }
        default:
            break
        }
    }
    
    @objc func playingAudio()  {
        print("timerRunning")
        if audioPlayer != nil{
            if (audioPlayer?.isPlaying)!{
                timerAudio?.invalidate()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "watsonSpeakingNotification"), object:self)
                
            }
        }
        
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //print("AUDIOOOO ENDDED")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "watsonStopSpeakingNotification"), object:self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        //swift 3
        //getScreenSize()
        if UIDevice.current.orientation.isLandscape {
            print("Landscape1")
        } else {
            print("Portrait1")
        }
    }
    
    
}
