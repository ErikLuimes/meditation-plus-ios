//
//  MPViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 01/11/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class MPDhammaViewController: UIViewController
{
    private var videoListView: MPVideoListView
    {
        return view as! MPVideoListView
    }

    private var videoDataSource: MPVideoDataSource = MPVideoDataSource()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        tabBarItem = UITabBarItem(title: "Dhamma", image: UIImage(named: "dhamma-wheel"), tag: 0)
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
        videoListView.refreshControl.addTarget(self, action: #selector(MPDhammaViewController.refreshVideos(_:)), forControlEvents: UIControlEvents.ValueChanged)

        MPYoutubeManager.setup()
        MPYoutubeManager.sharedInstance.videoList
        {
            (videos) -> Void in
            self.videoDataSource.updateVideos(videos)
            self.videoListView.tableView.reloadData()
            self.calculateCellParallax()
        }
    }


    func refreshVideos(refreshControl: UIRefreshControl)
    {
        MPYoutubeManager.sharedInstance.videoList
        {
            (videos) -> Void in
            self.videoDataSource.updateVideos(videos)
            self.videoListView.tableView.reloadData()
            self.calculateCellParallax()
            refreshControl.endRefreshing()
        }
    }
}

extension MPDhammaViewController: UITableViewDelegate
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

            (cell as? MPVideoCell)?.setParallaxFactor(parallaxFactor)
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

extension MPDhammaViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
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
