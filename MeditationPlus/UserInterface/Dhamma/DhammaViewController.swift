//
//  DhammaViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 01/11/15.
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

import UIKit
import DZNEmptyDataSet

class DhammaViewController: UIViewController
{
    private var videoListView: VideoListView
    {
        return view as! VideoListView
    }

    private var videoDataSource: VideoDataSource = VideoDataSource()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "dhamma-wheel"), tag: 0)
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        videoListView.tableView.dataSource = videoDataSource
        videoListView.tableView.delegate = self
        videoListView.tableView.emptyDataSetSource = self
        videoListView.tableView.emptyDataSetDelegate = self
        videoListView.refreshControl.addTarget(self, action: #selector(DhammaViewController.refreshVideos(_:)), forControlEvents: UIControlEvents.ValueChanged)

        YoutubeManager.setup()
        YoutubeManager.sharedInstance.videoList
        {
            (videos) -> Void in
            self.videoDataSource.updateVideos(videos)
            self.videoListView.tableView.reloadData()
            self.calculateCellParallax()
        }
    }


    func refreshVideos(refreshControl: UIRefreshControl)
    {
        YoutubeManager.sharedInstance.videoList
        {
            (videos) -> Void in
            self.videoDataSource.updateVideos(videos)
            self.videoListView.tableView.reloadData()
            self.calculateCellParallax()
            refreshControl.endRefreshing()
        }
    }
}

extension DhammaViewController: UITableViewDelegate
{
    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        guard let videoItemId = videoDataSource.videoForIndexPath(indexPath)?.id else {
            return
        }

        if let youtubeURL = NSURL(string: "http://www.youtube.com/watch?v=\(videoItemId)") {
            UIApplication.sharedApplication().openURL(youtubeURL)
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        calculateCellParallax()
    }

    func calculateCellParallax()
    {
        let top = -videoListView.tableView.rowHeight
        let bottom = UIScreen.mainScreen().bounds.size.height + abs(top)

        for cell in videoListView.tableView.visibleCells {
            let viewPosition = cell.convertRect(cell.bounds, toView: self.view).origin.y
            let parallaxFactor = clamp((viewPosition - top) / bottom, lowerBound: 0.0, upperBound: 1.0)

            (cell as? VideoCell)?.setParallaxFactor(parallaxFactor)
        }
    }

    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        var nextIndex: Int
        let rowHeight = videoListView.tableView.rowHeight;

        if (targetContentOffset.memory.y < -scrollView.contentInset.top) {
            return
        } else if (targetContentOffset.memory.y > -scrollView.contentInset.top && targetContentOffset.memory.y < 0) {
            if (velocity.y > 0.0) {
                targetContentOffset.memory.y = -scrollView.contentInset.top;
            } else if (velocity.y < 0.0) {
                targetContentOffset.memory.y = 0;
            }

            return;
        }

        if (velocity.y > 0.0) {
            // Down scroll
            nextIndex = Int(floor(targetContentOffset.memory.y / rowHeight))
            let newTargetYOffset = (CGFloat(nextIndex) * rowHeight) - self.videoListView.tableView.contentInset.top
            let maxScrollViewOffset = scrollView.contentSize.height - CGRectGetHeight(scrollView.frame);

            if (Int(targetContentOffset.memory.y) >= Int(maxScrollViewOffset)) {
                targetContentOffset.memory.y = maxScrollViewOffset + self.videoListView.tableView.contentInset.bottom
            } else {
                targetContentOffset.memory.y = newTargetYOffset;
            }
        } else if (velocity.y < 0.0) {
            // Up scroll
            nextIndex = Int(floor(targetContentOffset.memory.y / rowHeight))
            targetContentOffset.memory.y = CGFloat(nextIndex) * rowHeight - self.videoListView.tableView.contentInset.top
        }
    }

}

extension DhammaViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{
    // MARK: DZNEmptyDataSetDelegate

    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage!
    {
        return UIImage(named: "dhamma-wheel")
    }

    func imageAnimationForEmptyDataSet(scrollView: UIScrollView!) -> CAAnimation!
    {
        let animation = CABasicAnimation(keyPath: "transform")

        animation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(CATransform3D: CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 1.0, 0.0))
        animation.duration = 0.75
        animation.cumulative = true
        animation.repeatCount = 1000

        return animation
    }

    func emptyDataSetShouldAnimateImageView(scrollView: UIScrollView!) -> Bool
    {
        return true
    }
}
