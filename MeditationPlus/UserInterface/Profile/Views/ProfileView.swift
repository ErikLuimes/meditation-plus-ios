//
//  ProfileView.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/11/15.
//  Copyright (c) 2015 Maya Interactive.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit
import Charts

class ProfileView: UIView {
    @IBOutlet weak var profileBackgroundImageView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var aboutLabel: UILabel!
    
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var contentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set vertical effect
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -20
        verticalMotionEffect.maximumRelativeValue = 20
        
        // Set horizontal effect
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -20
        horizontalMotionEffect.maximumRelativeValue = 20
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        profileBackgroundImageView.addMotionEffect(group)
        
        barChartView.descriptionText = ""
        barChartView.xAxis.labelPosition = .Bottom
//        barChartView.xAxis.labelRotationAngle = 90
        barChartView.xAxis.labelFont = UIFont.systemFontOfSize(7)
        barChartView.xAxis.drawAxisLineEnabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.axisLabelModulus = 0
        barChartView.backgroundColor = UIColor.clearColor()
//        barChartView.animate(yAxisDuration: 0.5)
        barChartView.drawGridBackgroundEnabled = false
        barChartView.drawBordersEnabled = false
        barChartView.leftAxis.drawLabelsEnabled = false
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.drawAxisLineEnabled = false
        barChartView.rightAxis.drawLabelsEnabled = false
        barChartView.rightAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.drawAxisLineEnabled = false
    
        profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        profileImageView.layer.borderWidth = 3.0
        
        contentView.layer.cornerRadius = 5.0
    }
    
    func configureWithProfile(profile: Profile) {
        guard !profile.invalidated else {
            return
        }
        
        if let avatarURL = NSURL(profile: profile) {
            profileBackgroundImageView.sd_setImageWithURL(avatarURL)
            profileImageView.sd_setImageWithURL(avatarURL)
        }
        
        usernameLabel.text = profile.username
        
        aboutLabel.text = profile.about
        
        var dataEntries: [BarChartDataEntry] = []
        var xVals: [String] = []
        
        for (index, value) in (profile.hours?.enumerate())! {
            let dataEntry = BarChartDataEntry(value: Double(value), xIndex: index)
            dataEntries.append(dataEntry)
            xVals.append(String(index))
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Minutes meditated")
        chartDataSet.colors = [UIColor.orangeColor()]
        let chartData = BarChartData(xVals: xVals, dataSet: chartDataSet)
        barChartView.data = chartData
        barChartView.animate(xAxisDuration: 0.3, easingOption: ChartEasingOption.EaseInOutSine)
        barChartView.zoomAndCenterViewAnimated(scaleX: 3, scaleY: 1, xIndex: 0, yValue: 0, axis: ChartYAxis.AxisDependency.Left, duration: 1.0)
    }
}
