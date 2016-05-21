//
//  VideoDataSource.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 07/11/15
//
//  The MIT License
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
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
//
// Except as contained in this notice, the name of Maya Interactive and Meditation+
// shall not be used in advertising or otherwise to promote the sale, use or other
// dealings in this Software without prior written authorization from Maya Interactive.
//

import Foundation
import UIKit
import SDWebImage

class VideoDataSource: NSObject, UITableViewDataSource
{
    private var videos: [VideoItem] = [VideoItem]()

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.videos.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: VideoCell = tableView.dequeueReusableCellWithIdentifier(R.nib.videoCell.name, forIndexPath: indexPath) as! VideoCell

        if let video = self.videoForIndexPath(indexPath) {
            let style: NSMutableParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            style.alignment = NSTextAlignment.Justified
            style.firstLineHeadIndent = 10.0
            style.headIndent = 10.0
            style.tailIndent = -10.0
            style.paragraphSpacing = 10

            cell.titleLabel.attributedText = NSAttributedString(string: video.title ?? "", attributes: [NSParagraphStyleAttributeName: style])
            if let imageUrl = video.thumbnail {
                cell.videoImageView.sd_setImageWithURL(imageUrl, completed: { (image, error, cacheType, url) in
                    if cacheType == SDImageCacheType.None {
                        UIView.transitionWithView(cell.videoImageView, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                            cell.videoImageView.image = image
                        }, completion: nil)
                    } else {
                        cell.videoImageView.image = image
                    }
                })
            }
        }

        return cell
    }

    func videoForIndexPath(indexPath: NSIndexPath) -> VideoItem?
    {
        return videos[safe: indexPath.row]
    }

    func updateVideos(newVideos: [VideoItem])
    {
        videos.removeAll()
        videos += newVideos
    }
}
