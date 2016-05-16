//
//  VideoDataSource.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 07/11/15
//  Copyright (c) 2015 Maya Interactive
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

class VideoDataSource: NSObject, UITableViewDataSource
{
    private var videos: [VideoItem] = [VideoItem]()

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.videos.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: VideoCell = tableView.dequeueReusableCellWithIdentifier("VideoCell") as! VideoCell

        if let video = self.videoForIndexPath(indexPath) {
            let style: NSMutableParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            style.alignment = NSTextAlignment.Justified
            style.firstLineHeadIndent = 10.0
            style.headIndent = 10.0
            style.tailIndent = -10.0
            style.paragraphSpacing = 10

            cell.titleLabel.attributedText = NSAttributedString(string: video.title ?? "", attributes: [NSParagraphStyleAttributeName: style])
            if video.thumbnail != nil {
                cell.videoImageView.sd_setImageWithURL(video.thumbnail!)
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
