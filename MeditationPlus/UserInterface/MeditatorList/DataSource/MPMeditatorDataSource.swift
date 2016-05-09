//
//  MPMeditatorDataSource.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 12/09/15.
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
import RealmSwift

//struct MPMeditatorsResultsCache
//{
//    var sections: [[MPMeditator]] = Array(count: MPMeditatorSectionData.numberOfSections, repeatedValue: [])
//
//    init(initialMeditators: [MPMeditator])
//    {
//        for meditator in initialMeditators {
//            sections[sectionIndexForMeditator(meditator)].append(meditator)
//        }
//    }
//
//    mutating func insertMeditator(meditator: MPMeditator) -> NSIndexPath
//    {
//        let sectionIndex = sectionIndexForMeditator(meditator)
//        sections[sectionIndex].insert(meditator, atIndex: 0)
//
//        return NSIndexPath(forRow: 0, inSection: sectionIndex)
//    }
//
//    mutating func deleteMeditator(meditator: MPMeditator) -> NSIndexPath?
//    {
//        if let deletedTaskIndex = (sections[0] as [MPMeditator]).indexOf(meditator) {
//            sections[0].removeAtIndex(deletedTaskIndex)
//            return NSIndexPath(forRow: deletedTaskIndex, inSection: 0)
//        }
//
//        return nil
//    }
//
//    private func sectionIndexForMeditator(meditator: MPMeditator) -> Int
//    {
//        return MPMeditatorSectionData(progress: meditator.normalizedProgress).rawValue
//    }
//}

//enum MPMeditatorSectionData: Int
//{
//    case Meditating
//    case Finished
//
//    init(progress: Double)
//    {
//        self = progress < 1.0 ? .Meditating : .Finished
//    }
//
//    var title: String
//    {
//        switch self {
//            case .Meditating: return "Currently meditating"
//            case .Finished: return "Finished meditating"
//        }
//    }
//
//    static var numberOfSections: Int
//    {
//        return 2
//    }
//}

public enum MeditatorSectionData: Int
{
    case Meditating
    case Finished
    
    public var title: String
    {
        switch self {
        case .Meditating: return "Currently meditating"
        case .Finished: return "Finished meditating"
        }
    }
    
    public static var numberOfSections: Int
    {
        return 2
    }
    
}

extension MeditatorSectionData
{
    public init(meditator: MPMeditator)
    {
        self = meditator.normalizedProgress < 1.0 ? .Meditating : .Finished
    }
}

private struct MeditatorSection
{
    let title: String
    var items: [MPMeditator] = [MPMeditator]()
    
    private init(title: String)
    {
        self.title = title
    }
}

public class MeditatorDataSource: NSObject, UITableViewDataSource
{
    private var results: Results<MPMeditator>!
    
    private var sections: [MeditatorSection] = []
    
    required public init(results: Results<MPMeditator>)
    {
        self.results = results

        // Setup sections
        for i in 0..<MeditatorSectionData.numberOfSections {
            let section = MeditatorSection(title: MeditatorSectionData(rawValue: i)!.title)
            sections.append(section)
        }
    }
    
    public func updateCache()
    {
        for meditator in results {
            sections[MeditatorSectionData(meditator: meditator).rawValue].items.append(meditator)
        }
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return self.sections.count
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sections[section].items.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("MPMeditatorCellIdentifier")!

        if let meditator = self.meditatorForIndexPath(indexPath), meditatorCell = cell as? MPMeditatorCell {
            meditatorCell.configureWithMeditator(meditator, displayProgress: indexPath.section == 0)
        }

        return cell
    }

    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        guard section < sections.count else {
            return nil
        }
        return sections[section].title
    }

    func meditatorForIndexPath(indexPath: NSIndexPath) -> MPMeditator?
    {
        return sections[indexPath.section].items[indexPath.row]
    }
    
    func checkMeditatorProgress(tableView: UITableView)
    {
        var indexPathsToDelete: [NSIndexPath] = [NSIndexPath]()
        var meditatorsToMove: [MPMeditator]   = [MPMeditator]()
        var indexPathsToAdd: [NSIndexPath]    = [NSIndexPath]()

        for (index, currentlyMeditating) in sections[0].items.enumerate() {
            if currentlyMeditating.normalizedProgress >= 1.0 {
                meditatorsToMove.append(currentlyMeditating)
                indexPathsToDelete.append(NSIndexPath(forRow: index, inSection: 0))
            }
        }

        for finischedMeditator in meditatorsToMove {
            deleteMeditator(finischedMeditator)
            insertMeditator(finischedMeditator)
        }

        for (index, finishedMeditating) in sections[1].items.enumerate() {
            if meditatorsToMove.contains(finishedMeditating) {
                indexPathsToAdd.append(NSIndexPath(forRow: index, inSection: 1))
            }
        }

        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: .Automatic)
        tableView.insertRowsAtIndexPaths(indexPathsToAdd, withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
    
    private func insertMeditator(meditator: MPMeditator) -> NSIndexPath
    {
        let sectionIndex = MeditatorSectionData(meditator: meditator).rawValue
        sections[sectionIndex].items.insert(meditator, atIndex: 0)

        return NSIndexPath(forRow: 0, inSection: sectionIndex)
    }

    private func deleteMeditator(meditator: MPMeditator) -> NSIndexPath?
    {
        if let deletedTaskIndex = sections[0].items.indexOf(meditator) {
            sections[0].items.removeAtIndex(deletedTaskIndex)
            return NSIndexPath(forRow: deletedTaskIndex, inSection: 0)
        }

        return nil
    }
}

//class MPMeditatorDataSource: NSObject, UITableViewDataSource
//{
//    var cache: MPMeditatorsResultsCache
//
//    var meditatorSections: [MPMeditatorSection]
//    {
//        return cache.sections.enumerate().map
//        {
//            index, meditators in
//            return MPMeditatorSection(
//            title: MPMeditatorSectionData(rawValue: index)!.title,
//            items: meditators
//            )
//        }
//    }
//
//    static let MPMeditatorCellIdentifier: String = "MPMeditatorCellIdentifier"
//
//    override init()
//    {
//        cache = MPMeditatorsResultsCache(initialMeditators: [])
//        super.init()
//    }
//
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int
//    {
//        return self.meditatorSections.count
//    }
//
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
//    {
//        return meditatorSections[section].items.count
//    }
//
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
//    {
//        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(MPMeditatorDataSource.MPMeditatorCellIdentifier)!
//
//        if let meditator = self.meditatorForIndexPath(indexPath), meditatorCell = cell as? MPMeditatorCell {
//            meditatorCell.configureWithMeditator(meditator, displayProgress: indexPath.section == 0)
//        }
//
//        return cell
//    }
//
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
//    {
//        return meditatorSections[section].title
//    }
//
//    func meditatorForIndexPath(indexPath: NSIndexPath) -> MPMeditator?
//    {
//        return meditatorSections[indexPath.section].items[indexPath.row]
//    }
//
//    func updateMeditators(newMeditators: [MPMeditator])
//    {
//        cache = MPMeditatorsResultsCache(initialMeditators: newMeditators)
//    }
//
//    func checkMeditatorProgress(tableView: UITableView)
//    {
//        var indexPathsToDelete: [NSIndexPath] = [NSIndexPath]()
//        var meditatorsToMove: [MPMeditator] = [MPMeditator]()
//        var indexPathsToAdd: [NSIndexPath] = [NSIndexPath]()
//
//        for (index, currentlyMeditating) in cache.sections[0].enumerate() {
//            if currentlyMeditating.normalizedProgress >= 1.0 {
//                meditatorsToMove.append(currentlyMeditating)
//                indexPathsToDelete.append(NSIndexPath(forRow: index, inSection: 0))
//            }
//        }
//
//        for finischedMeditator in meditatorsToMove {
//            cache.deleteMeditator(finischedMeditator)
//            cache.insertMeditator(finischedMeditator)
//        }
//
//        for (index, finishedMeditating) in cache.sections[1].enumerate() {
//            if meditatorsToMove.contains(finishedMeditating) {
//                indexPathsToAdd.append(NSIndexPath(forRow: index, inSection: 1))
//            }
//        }
//
//        tableView.beginUpdates()
//        tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: .Automatic)
//        tableView.insertRowsAtIndexPaths(indexPathsToAdd, withRowAnimation: .Automatic)
//        tableView.endUpdates()
//    }
//}
