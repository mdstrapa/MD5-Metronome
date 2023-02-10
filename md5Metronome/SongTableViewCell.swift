//
//  SongTableViewCell.swift
//  md5Metronome
//
//  Created by Marcos Strapazon on 25/03/18.
//  Copyright © 2018 Marcos Strapazon. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var lblPosition: UILabel!
    @IBOutlet weak var lblSongName: UILabel!
    @IBOutlet weak var lblBpm: UILabel!
    var currentSong:Songs?

}
