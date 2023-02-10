//
//  ViewController.swift
//  md5Metronome
//
//  Created by Marcos Strapazon on 07/10/17.
//  Copyright © 2017 Marcos Strapazon. All rights reserved.
//

import UIKit
import AVFoundation

var metronomeSound = 1



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    //MARK: Properties
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var sliderVolume: UISlider!
    @IBOutlet weak var labelTempo: UILabel!
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var increaseButton: UIButton!
    @IBOutlet weak var decreaseButton: UIButton!
    @IBOutlet weak var lblSetList: UILabel!
    @IBOutlet weak var stackSongNavigation: UIStackView!
    @IBOutlet weak var viewSetListList: UIVisualEffectView!
    @IBOutlet weak var lblCurrentSongName: UILabel!
    @IBOutlet weak var btnCloseSetListList: UIButton!
    @IBOutlet weak var btnSaveBpmModification: UIButton!
    @IBOutlet weak var tblSetListList: UITableView!
    @IBOutlet weak var segPlayMode: UISegmentedControl!
    @IBOutlet weak var preferencesButton: UIButton!
    @IBOutlet weak var lblChooseSetList: UILabel!
    
    
    
    var player = AVAudioPlayer()
    var timer = Timer()
    var timer_tempo = Timer()
    var counter = 0
    var timerInterval = 0.0
    var seconds = 0
    var bpmValue = 120
    var preBpmValue = 120
    
    var selectedSetListSongs:[Songs]!
    var selectedSetListSongIndex = 0
    
    var setListList = [SetLists]()
    var playMode:metronomeMode = .simple
    
    func getSetLists(){
        setListList = ContextCommons().getSetListList()!
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setListList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setListCell") as! SetListSelectionTableViewCell
        let setList:SetLists = setListList[indexPath.row]
        cell.lblSetListName.text = setList.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSetList = setListList[indexPath.row]
        lblSetList.text = "Set List: " + (selectedSetList.name!)
        selectedSetListSongs = selectedSetList.songs?.allObjects as! [Songs]
        selectedSetListSongs.sort(by: {$0.position < $1.position})
        lblCurrentSongName.text = "\(selectedSetListSongs.first?.position ?? 0)  - " + (selectedSetListSongs.first?.name)!
        if let selectedSongBpm = selectedSetListSongs.first?.bpm {
            bpmLabel.text = String(selectedSongBpm)
        }
        toggleSetListListVisibility(show: false)
        activateSetListMode()
    }
    
    
    @IBAction func increaseBpm(_ sender: UIButton) {
        bpmLabel.text = String(Int(bpmLabel.text!)! + 1)
        if playMode == .setList { currentSongBpmchanged() }
        resetMetronome()
    }
    
    @IBAction func decreaseBpm(_ sender: UIButton) {
        if Int(bpmLabel.text!)! > 0{
            bpmLabel.text = String(Int(bpmLabel.text!)! - 1)
        }
        if playMode == .setList { currentSongBpmchanged() }
        resetMetronome()
    }
    
    
    func secondsToHoursMinutesSeconds (sec : Int) -> (Int, Int) {
        return ((sec % 3600) / 60, (sec % 3600) % 60)
    }
    
    @objc func tick(){
        
        if player.isPlaying {
            player.currentTime = 0
        }
        
         player.play()

        if counter % 2 == 0{
            view.backgroundColor = UIColor(red:0.91, green:0.91, blue:0.91, alpha:1.0)
            counter += 1
        }else{
            view.backgroundColor = UIColor(red:1.00, green:0.97, blue:0.97, alpha:1.0)
            counter -= 1
        }
        
    }
    
    
    @objc func tempo(){
        var aux_second = ""
        var aux_minute = ""
        
        seconds += 1
        
        let (m,s) = secondsToHoursMinutesSeconds(sec: seconds)
                
        //formating the seconds counter into time format
        if s <= 9{ aux_second = "0"}
        if m <= 9{ aux_minute = "0"}
        labelTempo.text = "\(aux_minute)\(m):\(aux_second)\(s)"
        
    }
    
    fileprivate func startStopMetronome() {
        if timer.isValid{
            timer.invalidate()
            timer_tempo.invalidate()
            seconds = 0
            view.backgroundColor=UIColor.white
            startButton.setTitle(Settings.messages[0].value, for: .normal)
        }else{
            
            startButton.setTitle(Settings.messages[1].value, for: .normal)
            
            if let bpm = bpmLabel.text{
                timerInterval = 60 / Double(bpm)!
                
                //storing the bpm for further usage
                UserDefaults.standard.set(bpmLabel.text, forKey: "md5Metronome_bpm")
                
            }
            
            if !timer.isValid {
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(timerInterval), target: self, selector: (#selector(ViewController.tick)), userInfo: nil, repeats: true)
                timer_tempo = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: (#selector(ViewController.tempo)), userInfo: nil, repeats: true)
            }
        }
    }
    
    @IBAction func startButton(_ sender: Any) {
        startStopMetronome()
    }

    
    
    
    
    
    @IBAction func sliderVolume(_ sender: Any) {
        player.volume = sliderVolume.value
    }
    
    func loadMetronomeSound(){
        do{
            try player = AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "metronome" + String(metronomeSound), ofType: "wav")!))
            player.prepareToPlay()
        }catch{
            print(error)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //getting the BPM value, if any
        if let initialBpm = UserDefaults.standard.object(forKey: "md5Metronome_bpm") as? String{
            bpmLabel.text = initialBpm
        }
        
        

    }
    
    func setLanguage(){
        startButton.setTitle(Settings.messages[0].value, for: .normal)
        preferencesButton.setTitle(Settings.messages[4].value, for: .normal)
        segPlayMode.setTitle(Settings.messages[2].value, forSegmentAt: 0)
        segPlayMode.setTitle(Settings.messages[3].value, forSegmentAt: 1)
        btnSaveBpmModification.setTitle(Settings.messages[5].value, for: .normal)
        lblChooseSetList.text = Settings.messages[20].value
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        Settings.messages = AppCommons().getLanguage()
        setLanguage()
        
        getSetLists()
        tblSetListList.reloadData()
        loadMetronomeSound()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    
    
    fileprivate func currentSongBpmchanged() {
        btnSaveBpmModification.isHidden = false
        lblCurrentSongName.textColor = .red
    }
    
    fileprivate func cancelcCurrentSongBpmchanged() {
        if !btnSaveBpmModification.isHidden{
            btnSaveBpmModification.isHidden = true
            lblCurrentSongName.textColor = .black
        }
    }
    
    @IBAction func changeBpmValue(_ sender: UIPanGestureRecognizer) {
        let theView = sender.view!
        if sender.state == .changed{
            let trans = sender.translation(in: theView)
            if (bpmValue >= 40 && bpmValue <= 240){
                bpmValue = preBpmValue + Int((trans.y / 2) * -1)
                bpmLabel.text = String(bpmValue)
            }
        }else if sender.state == .ended{
            if bpmValue > 230{
                bpmValue = 230
            }else if bpmValue < 50 {
                bpmValue = 50
            }
            preBpmValue = bpmValue
        }
        
        if playMode == .setList {
            currentSongBpmchanged()
        }
        
        resetMetronome()
    }
    
    
    @IBAction func setMode(_ sender: UISegmentedControl) {
        
        if  sender.selectedSegmentIndex == 1 {
            toggleSetListListVisibility(show: true)
        }else{
            activateSimpleMode()
            cancelcCurrentSongBpmchanged()
            
        }
    }
    
    func activateSetListMode(){
        playMode = .setList
        lblSetList.isHidden = false
        stackSongNavigation.isHidden = false
    }
    
    func activateSimpleMode(){
        playMode = .simple
        lblSetList.isHidden = true
        stackSongNavigation.isHidden = true
        segPlayMode.selectedSegmentIndex = 0
    }
    
    func toggleSetListListVisibility(show:Bool){
        
        let finalAlpha:CGFloat
        
        if show {
            finalAlpha = 1
        }else{
            finalAlpha = 0
        }
        
        UIView.animate(withDuration: 0.7, animations: {
            self.viewSetListList.alpha = finalAlpha
        })

    }
    
    
    fileprivate func resetMetronome() {
        if timer.isValid{
            startStopMetronome()
            startStopMetronome()
        }
    }
    
    func setNewSongFromSetList(direction:directionsForSelectedSong){
        if direction == .next{
            
            if selectedSetListSongIndex != selectedSetListSongs.count - 1 {
                selectedSetListSongIndex += 1
            }else{
                selectedSetListSongIndex = 0
            }
        }else{
            
            if selectedSetListSongIndex != 0 {
                selectedSetListSongIndex -= 1
            }else{
                selectedSetListSongIndex = selectedSetListSongs.count - 1
            }
        }
        
        lblCurrentSongName.text = "\(selectedSetListSongs[selectedSetListSongIndex].position) - " + selectedSetListSongs[selectedSetListSongIndex].name!
        if let selectedSongBpm = selectedSetListSongs?[selectedSetListSongIndex].bpm {
            bpmLabel.text = String(selectedSongBpm)
        }
        
        resetMetronome()
        cancelcCurrentSongBpmchanged()
    }
    
    
    @IBAction func selectNextSong(_ sender: UIButton) {
        setNewSongFromSetList(direction: .next)
    }
    
    @IBAction func selectPreviousSong(_ sender: UIButton) {
        setNewSongFromSetList(direction: .previous)
    }
    
    
    @IBAction func closeSetListList(_ sender: UIButton) {
        toggleSetListListVisibility(show: false)
        activateSimpleMode()
    }
    
    @IBAction func saveBpmModifications(_ sender: UIButton) {
        selectedSetListSongs[selectedSetListSongIndex].bpm = Int16(bpmLabel.text!)!
        if ContextCommons().saveMoc() {print("Song saved")}
        sender.isHidden = true
        lblCurrentSongName.textColor = .black
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.title = Settings.messages[13].value
    }

    
    
    
}
