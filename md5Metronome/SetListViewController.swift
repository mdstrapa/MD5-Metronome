//
//  SetListViewController.swift
//  md5Metronome
//
//  Created by Marcos Strapazon on 20/03/18.
//  Copyright © 2018 Marcos Strapazon. All rights reserved.
//

import UIKit

class SetListViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var tblSongs: UITableView!
    @IBOutlet weak var txtSetListName: UITextField!
    @IBOutlet weak var btnAddSong: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnEditSongList: UIButton!
    @IBOutlet weak var lblName: UILabel!
    
    
    var setListSongsList = [Songs]()
    var mode:viewMode = .add
    var deleteSongIndexPath: IndexPath? = nil
    var selectedSong:IndexPath?
    
    var currentSetList:SetLists?
    var didReOrder:Bool = false
    
 
    fileprivate func getSetListSongs() {
        setListSongsList = currentSetList?.songs?.allObjects as! [Songs]
        setListSongsList.sort(by: {$0.position < $1.position})
        
    }
    
    func setLanguage(){
        btnSave.setTitle(Settings.messages[14].value, for: .normal)
        lblName.text = Settings.messages[15].value
        btnAddSong.setTitle(Settings.messages[16].value, for: .normal)
        btnEditSongList.setTitle(Settings.messages[17].value, for: .normal)
        self.title = Settings.messages[3].value
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    fileprivate func setUpViewController() {
        if mode == .add {
            tblSongs.isHidden = true
            btnAddSong.isHidden = true
            btnEditSongList.isHidden = true
            
        }else if mode == .edit {
            txtSetListName.text = currentSetList?.name
            getSetListSongs()
            tblSongs.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpViewController()
        setLanguage()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mode == .add {
            return 0
        }else{
            return setListSongsList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblSongs.dequeueReusableCell(withIdentifier: "songCell") as! SongTableViewCell
        
        if mode == .edit{
            
            let song:Songs = setListSongsList[indexPath.row]
            
            cell.lblPosition.text = String(song.position)
            cell.lblSongName.text = song.name
            cell.lblBpm.text = String(song.bpm) + " bpm"
            
            cell.currentSong = song
            
            
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            deleteSongIndexPath = indexPath
            let songToDelete:Songs = setListSongsList[indexPath.row]
            confirmDelete(songToDelete: songToDelete)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSong = indexPath
        performSegue(withIdentifier: "EditSong", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        didReOrder = true;
    }
    
//    func reSortSongsOld(sourcePosition:Int,destinationPosition:Int){
//        var songsToReSort = [Songs]()
//
//        if (sourcePosition < destinationPosition) {
//            songsToReSort = setListSongsList.filter({$0.position <= (destinationPosition + 1)}).filter({$0.position >= (sourcePosition + 1)})
//        }else{
//            songsToReSort = setListSongsList.filter({$0.position >= (destinationPosition + 1)}).filter({$0.position <= (sourcePosition + 1)})
//        }
//        print(songsToReSort.count)
//        for song in songsToReSort{
//            print(song.name)
//        }
//    }
    
    
    func saveSetlist(){
        if mode == .add{
            let newSetList = SetLists(context: ContextCommons().moc!)
            newSetList.name = txtSetListName.text
            
            if (ContextCommons().saveMoc()){
                tblSongs.isHidden = false
                btnAddSong.isHidden = false
                btnEditSongList.isHidden = false
                currentSetList = newSetList
                AppCommons().showOKMessage(message: Settings.messages[21].value, view: self)
                mode = .edit
            }else{
                print("An error has happned during the atempt to save in the database.")
            }
            
        }else{
            currentSetList?.name = txtSetListName.text
            if (ContextCommons().saveMoc()){
                AppCommons().showOKMessage(message: Settings.messages[21].value, view: self)
            }else{
                print("An error has happned during the atempt to save in the database.")
            }
        }
    }
    
    @IBAction func saveSetList(_ sender: UIButton) {
        saveSetlist()
    }
    
    func confirmDelete(songToDelete:Songs) {
        
        let songName = songToDelete.name
        
        let alert = UIAlertController(title: Settings.messages[22].value, message: Settings.messages[23].value + " '" + songName! + "'?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: Settings.messages[24].value, style: .destructive, handler: {(alertAction) in
            self.deleteSongFromMoc(songToDelete: songToDelete)
            self.deleteSongFromTableView(songIndex: self.deleteSongIndexPath!)
            self.reSortSongs()
        })
        let CancelAction = UIAlertAction(title: Settings.messages[25].value, style: .cancel, handler: {(alertAction) in
            self.deleteSongIndexPath = nil
        })
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    fileprivate func deleteSongFromMoc(songToDelete:Songs){
        currentSetList?.removeFromSongs(songToDelete)
        if !(ContextCommons().saveMoc()) {print("An error has ocurred on deleting song")}
    }
    
    fileprivate func deleteSongFromTableView(songIndex:IndexPath){
        getSetListSongs()
        tblSongs.beginUpdates()
        tblSongs.deleteRows(at: [songIndex], with: .automatic)
        deleteSongIndexPath = nil
        tblSongs.endUpdates()
    }

    @IBAction func editSongList(_ sender: UIButton) {
        
        if tblSongs.numberOfRows(inSection: 0) > 1 {
            tblSongs.isEditing = !tblSongs.isEditing
            
            if tblSongs.isEditing {
                sender.setTitle(Settings.messages[26].value, for: .normal)
            }else{
                sender.setTitle(Settings.messages[17].value, for: .normal)
                if didReOrder { reSortSongs() }
            }
            
            showHideLabelsForEditing(isHidden: tblSongs.isEditing)
        }
    }
    
    func reSortSongs(){
        for row in 0 ... (tblSongs.numberOfRows(inSection: 0) - 1){
            let cell = tblSongs.cellForRow(at: [0,row]) as! SongTableViewCell
            cell.currentSong?.position = Int16(row.advanced(by: 1))
        }
        
        if ContextCommons().saveMoc() {
            print("Re sort done!!")
        }else{
            print("NOT saved")
        }
        
        getSetListSongs()
        tblSongs.reloadData()
        didReOrder = false
    }
    
    
    func showHideLabelsForEditing(isHidden:Bool){
        for row in 0 ... (tblSongs.numberOfRows(inSection: 0) - 1){
            let cell = tblSongs.cellForRow(at: [0,row]) as! SongTableViewCell
            cell.lblBpm.isHidden = isHidden
        }
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            case "-":
                print("Doing something else")
            case "AddSong":
                guard let songViewController = segue.destination as? SongViewController else {
                    print("error 1")
                    return
                }
                songViewController.currentSetList = currentSetList
            
            case "EditSong":
                guard let songViewController = segue.destination as? SongViewController else {
                    print("error 1")
                    return
                }
                songViewController.currentSong = setListSongsList[(selectedSong?.row)!]
            songViewController.mode = .edit
            default:
                print("Unexpected Segue Identifier; \(segue.identifier ?? "")")
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    
    
    
}
