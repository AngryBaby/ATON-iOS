//
//  VoteDetailHeader.swift
//  platonWallet
//
//  Created by Ned on 27/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class VoteDetailHeader: UIView {
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var id: UILabel!

    func updateView(_ detail: NodeVote){
        name.text = detail.name
        id.text = detail.nodeId?.add0x()
    }

}
