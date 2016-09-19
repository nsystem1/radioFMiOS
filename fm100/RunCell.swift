//
//  RunCell.swift
//  fm100
//
//  Created by Leonid Angarov on 31/08/2016.
//  Copyright © 2016 Leonid Angarov. All rights reserved.
//

import Foundation
import UIKit

class RunCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    func printSecondsToHoursMinutesSeconds (seconds : Int) -> (String) {
        let (h, m, s) = secondsToHoursMinutesSeconds (seconds)
        return h == 0 ? String(format: "%02d:%02d", m, s) : String(format: "%d:%02d:%02d", h, m, s)
    }
    
    func configureCell(run:RunRecord) -> UIView {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM HH:mm"
        let localTimeZoneStr = dateFormatter.stringFromDate(run.create_date);
        
        self.lblTitle.text = localTimeZoneStr
        self.lblTime.text = printSecondsToHoursMinutesSeconds( Int(run.time) )
        self.lblDistance.text = String(format:"%.2f ק״מ", run.distance / 1000)
        return self
    }
}