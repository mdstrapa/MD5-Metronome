//
//  SongViewController.swift
//  md5Metronome
//
//  Created by Marcos Strapazon on 20/03/18.
//  Copyright © 2018 Marcos Strapazon. All rights reserved.
//

import UIKit

class SongViewController: UIViewController,UITextFieldDelegate {
    
    
    //MARK: Properties
    var bpmValue = 120
    var preBpmValue = 120
    @IBOutlet weak var lblBpm: UILabel!
    @IBOutlet weak var txtSongName: UITextField!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnSaveSong: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInstructions: UILabel!
    var currentSetList:SetLists?
    var currentSong:Songs?
    var mode:viewMode = .add
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if mode == .edit{
            setUpView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setLanguage()
    }
    
    func setLanguage(){
        btnSaveSong.setTitle(Settings.messages[18].value, for: .normal)
        lblName.text = Settings.messages[15].value
        lblInstructions.text = Settings.messages[19].value
        self.title = Settings.messages[16].value
    }
    
    fileprivate func setUpView(){
        if let songName = currentSong?.name {
            txtSongName.text = songName
        }
        if let songBpm = currentSong?.bpm {
            lblBpm.text = String(songBpm)
        }
    }
    
    func saveSong(){
        
        if mode == .add {
            let newSong = Songs(context: ContextCommons().moc!)
            
            newSong.name = txtSongName.text
            newSong.bpm = Int16(lblBpm.text!)!
            var songPosition:Int
            if currentSetList?.songs?.allObjects.count == nil {
                songPosition = 1
            }else{
                songPosition = (currentSetList?.songs?.allObjects.count)! + 1
            }
            newSong.position = Int16(songPosition)
            currentSetList?.addToSongs(newSong)
            
        }else{
            currentSong?.name = txtSongName.text
            currentSong?.bpm = Int16(lblBpm.text!)!
        }
        
        if ContextCommons().saveMoc(){
            AppCommons().showOKMessage(message: Settings.messages[21].value, view: self)
            if mode == .add{
                txtSongName.text = ""
                lblBpm.text = "120"
            }
            
        }else{
            print("There was an error while trying to save the song.")
        }
        
    }
    
    @IBAction func changeBpm(_ sender: UIPanGestureRecognizer) {
        let theView = sender.view!
        
        if sender.state == .began{
            print("touch begans")
        }else if sender.state == .changed{
            let trans = sender.translation(in: theView)
            if (bpmValue >= 40 && bpmValue <= 240){
                bpmValue = preBpmValue + Int((trans.y / 2) * -1)
                lblBpm.text = String(bpmValue)
            }
        }else if sender.state == .ended{
            if bpmValue > 230{
                bpmValue = 230
            }else if bpmValue < 50 {
                bpmValue = 50
            }
            preBpmValue = bpmValue
        }
    }
    
    @IBAction func increaseBpm(_ sender: UIButton) {
        lblBpm.text = String(Int(lblBpm.text!)! + 1)
    }
    
    
    @IBAction func decreaseBpm(_ sender: UIButton) {
        if Int(lblBpm.text!)! > 0 {
            lblBpm.text = String(Int(lblBpm.text!)! - 1)
        }
    }
    
    @IBAction func saveSong(_ sender: UIButton) {
        saveSong()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
