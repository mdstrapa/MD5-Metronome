//
//  PreferencesViewController.swift
//  md5Metronome
//
//  Created by Marcos Strapazon on 18/03/18.
//  Copyright © 2018 Marcos Strapazon. All rights reserved.
//

import UIKit
import AVFoundation

class PreferencesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK:Properties
    var setListList = [SetLists]()
    @IBOutlet weak var tblSetListList: UITableView!
    @IBOutlet weak var seguementChooseSound: UISegmentedControl!
    @IBOutlet weak var lblChooseTheSound: UILabel!
    @IBOutlet weak var lblSelectTheLanguage: UILabel!
    @IBOutlet weak var segSelectTheLanguage: UISegmentedControl!
    @IBOutlet weak var lblManageSetLists: UILabel!
    @IBOutlet weak var btnAddSetList: UIButton!
    
    
    var selectedSetList:IndexPath!

    

    
    var deleteSetListIndexPath: NSIndexPath? = nil
    var player = AVAudioPlayer()
    
    func setLanguage(){
        lblChooseTheSound.text = Settings.messages[6].value
        lblSelectTheLanguage.text = Settings.messages[10].value
        lblManageSetLists.text = Settings.messages[11].value
        btnAddSetList.setTitle(Settings.messages[12].value, for: .normal)
        self.title = Settings.messages[4].value
        
    }
    
    func getSetLists(){
        setListList = ContextCommons().getSetListList()!
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    //MARK: Table-related funcions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setListList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        let cell = tblSetListList.dequeueReusableCell(withIdentifier: "setListCell") as! SetListTableViewCell
        let currentSetList = setListList[indexPath.row]
        
        cell.lblName.text = currentSetList.name
        var auxString = ""
        if currentSetList.songs?.count == 1{
            auxString = Settings.messages[27].value
        }else{
            auxString = Settings.messages[28].value
        }
        cell.lblSongsCount.text = String(currentSetList.songs?.count ?? 0) + " " + auxString

        return cell
        
    }
    
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            deleteSetListIndexPath = indexPath as NSIndexPath

            let setListToDelete:SetLists = setListList[indexPath.row]
            confirmDelete(setListToDelete: setListToDelete)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedSetList = indexPath
        performSegue(withIdentifier: "EditSetList", sender: nil)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        setLanguage()
        
        if Settings.lang == "EN" {
            segSelectTheLanguage.selectedSegmentIndex = 0
        }else{
            segSelectTheLanguage.selectedSegmentIndex = 1
        }
    
        
        seguementChooseSound.selectedSegmentIndex = metronomeSound - 1
        getSetLists()
        tblSetListList.reloadData()
    }
    
    
    @IBAction func changeMetronomeSound(_ sender: UISegmentedControl) {
        metronomeSound = sender.selectedSegmentIndex + 1
        loadMetronomeSound()
        player.play()
    }
    
    
    func loadMetronomeSound(){
        do{
            try player = AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "metronome" + String(metronomeSound), ofType: "wav")!))
            player.prepareToPlay()
        }catch{
            print(error)
        }
    }

    
    func confirmDelete(setListToDelete:SetLists) {
        
        let setListName = setListToDelete.name
        
        let alert = UIAlertController(title: Settings.messages[29].value, message: Settings.messages[30].value + " '" + setListName! + "'?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: Settings.messages[24].value, style: .destructive, handler: handleDeleteSetList)
        let CancelAction = UIAlertAction(title: Settings.messages[25].value, style: .cancel, handler: cancelDeleteSetList)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    func handleDeleteSetList(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteSetListIndexPath {
            tblSetListList.beginUpdates()
            
            let setListToDelete:SetLists = setListList[indexPath.row]
            
            setListToDelete.managedObjectContext?.delete(setListToDelete)
            if !ContextCommons().saveMoc() {print("an error has ocurred")}
            
            getSetLists()
            
            tblSetListList.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            
            deleteSetListIndexPath = nil
            
            tblSetListList.endUpdates()
        }
    }
    
    
    func cancelDeleteSetList(alertAction: UIAlertAction!) {
        deleteSetListIndexPath = nil
    }
    
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        
        switch(segue.identifier ?? "") {
            
        case "AddSetList":
            print("Will ADD a set list")
            
        case "EditSetList":
            print("Will EDIT a set list")
            
            
            guard let setListViewController = segue.destination as? SetListViewController else {
                print("error 1")
                return
            }
            setListViewController.mode = .edit
            setListViewController.currentSetList = setListList[selectedSetList.row]
            
        default:
            print("Unexpected Segue Identifier; \(segue.identifier ?? "")")
        }
        
    }
 
    @IBAction func changeLanguage(_ sender: UISegmentedControl) {
        Settings.lang = (sender.selectedSegmentIndex==0) ? "EN" : "PT"
        Settings.messages = AppCommons().getLanguage()
        setLanguage()
        tblSetListList.reloadData()
    }
    
}
