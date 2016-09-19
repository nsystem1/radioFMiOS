//
//  YouTubeCell.swift
//  fm100
//
//  Created by Leonid Angarov on 17/07/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class YouTubeCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgPicture: UIImageView!
    
    
    func configureCell(view: UIView, video:VideoYouTube) -> UIView {
        
        
        self.lblTitle.text = video.title
        self.imgPicture.kf_setImageWithURL(NSURL(string: video.thumbnail)!)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC");
        
        self.lblDate.text = dateFormatter.stringFromDate(video.published)
        
        return self
    }
}
