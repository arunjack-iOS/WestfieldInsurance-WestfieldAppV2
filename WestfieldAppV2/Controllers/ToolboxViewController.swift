//
//  ToolboxViewController.swift
//  WestfieldAppV2
//
//  Created by Arun Jack on 28/12/17.
//  Copyright © 2017 Arun Jack. All rights reserved.
//

import UIKit

class ToolboxViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.topItem?.title = ""
        
        self.navigationItem.title = "Tool Box"
        
        // Do any additional setup after loading the view.
        
        
        let settingsBut = UIButton.init(type: .custom)
        settingsBut.setImage(UIImage(named: "Settings"), for: UIControlState.normal)
        settingsBut.imageView?.contentMode = .scaleAspectFit
        settingsBut.addTarget(self, action: #selector(ToolboxViewController.moveToSettingPage), for: UIControlEvents.touchUpInside)
        settingsBut.frame = CGRect(x: 0, y: 0, width: 48, height: 40)
        //settingsBut.backgroundColor = UIColor.yellow
        settingsBut.imageEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 0)
        
        let settingsBarButton = UIBarButtonItem(customView: settingsBut)
        self.navigationItem.setRightBarButton(settingsBarButton, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Tool Box"

    }
    @objc func moveToSettingPage()  {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let settingVc = storyBoard.instantiateViewController(withIdentifier: "settingsVC") as! SettingsViewController
        
        self.navigationController?.pushViewController(settingVc, animated: true)
        
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
