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

struct MPMeditatorsResultsCache {
    var sections: [[MPMeditator]] = Array(count: MPMeditatorSectionData.numberOfSections, repeatedValue: [])
    
    init(initialMeditators: [MPMeditator]) {
        for meditator in initialMeditators {
            sections[sectionIndexForMeditator(meditator)].append(meditator)
        }
    }

    mutating func insertMeditator(meditator: MPMeditator) -> NSIndexPath {
        let sectionIndex = sectionIndexForMeditator(meditator)
        sections[sectionIndex].insert(meditator, atIndex: 0)

        return NSIndexPath(forRow: 0, inSection: sectionIndex)
    }

    mutating func deleteMeditator(meditator: MPMeditator) -> NSIndexPath? {
        if let deletedTaskIndex = (sections[0] as [MPMeditator]).indexOf(meditator) {
            sections[0].removeAtIndex(deletedTaskIndex)
            return NSIndexPath(forRow: deletedTaskIndex, inSection: 0)
        }

        return nil
    }
    
    private func sectionIndexForMeditator(meditator: MPMeditator) -> Int {
        return MPMeditatorSectionData(progress: meditator.normalizedProgress).rawValue
    }
}

enum MPMeditatorSectionData: Int {
    case Meditating
    case Finished
    
    init(progress: Double) {
        self = progress < 1.0 ? .Meditating : .Finished
    }
    
    var title: String {
        switch self {
        case .Meditating: return "Currently meditating"
        case .Finished: return "Finished meditating"
        }
    }
    
    static var numberOfSections: Int {
        return 2
    }
}

struct MPMeditatorSection
{
    let title: String
    let items: [MPMeditator]
}

class MPMeditatorDataSource: NSObject, UITableViewDataSource {
    var cache: MPMeditatorsResultsCache
    
    var meditatorSections: [MPMeditatorSection] {
        return cache.sections.enumerate().map { index, meditators in
            return MPMeditatorSection(
                title: MPMeditatorSectionData(rawValue: index)!.title,
                items: meditators
            )
        }
    }

    static let MPMeditatorCellIdentifier: String = "MPMeditatorCellIdentifier"

    override init() {
        cache = MPMeditatorsResultsCache(initialMeditators: [])
        super.init()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.meditatorSections.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meditatorSections[section].items.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(MPMeditatorDataSource.MPMeditatorCellIdentifier)!

        if let meditator = self.meditatorForIndexPath(indexPath), meditatorCell = cell as? MPMeditatorCell {
            meditatorCell.configureWithMeditator(meditator, displayProgress: indexPath.section == 0)
        }

        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return meditatorSections[section].title
    }

    func meditatorForIndexPath(indexPath: NSIndexPath) -> MPMeditator? {
        return meditatorSections[indexPath.section].items[indexPath.row]
    }

    func updateMeditators(newMeditators: [MPMeditator]) {
//        var meditators: [MPMeditator] = [MPMeditator]()
//        let calendar = NSCalendar.currentCalendar()
//        let futureDate = calendar.dateByAddingUnit(NSCalendarUnit.Second, value: 5, toDate: NSDate(), options: [])
//        let pastDate = calendar.dateByAddingUnit(NSCalendarUnit.Second, value: -55, toDate: NSDate(), options: [])
//        
//        let meditator: MPMeditator = MPMeditator()
//        meditator.username = "Henk"
//        meditator.start = pastDate
//        meditator.end   = futureDate
//        meditator.timeDiff = 60
//        meditator.walkingMinutes = 1
//        meditators.append(meditator)
//        
//        let meditator1: MPMeditator = MPMeditator()
//        meditator1.username = "Henk 1"
//        meditator1.start = pastDate
//        meditator1.end   = calendar.dateByAddingUnit(NSCalendarUnit.Second, value: 9, toDate: NSDate(), options: [])
//        meditator1.timeDiff = 60
//        meditator1.walkingMinutes = 1
//        meditators.append(meditator1)
//        
//        let meditator2: MPMeditator = MPMeditator()
//        meditator2.username = "Henk 2"
//        meditator2.start = pastDate
//        meditator2.end   = calendar.dateByAddingUnit(NSCalendarUnit.Second, value: 6, toDate: NSDate(), options: [])
//        meditator2.timeDiff = 61
//        meditator2.walkingMinutes = 1
//        meditators.append(meditator2)
//        
//        meditators += newMeditators
        
        cache = MPMeditatorsResultsCache(initialMeditators: newMeditators)
    }
    
    func checkMeditatorProgress(tableView: UITableView)
    {
        var indexPathsToDelete: [NSIndexPath] = [NSIndexPath]()
        var meditatorsToMove: [MPMeditator]   = [MPMeditator]()
        var indexPathsToAdd: [NSIndexPath]    = [NSIndexPath]()
        
        for (index, currentlyMeditating) in cache.sections[0].enumerate() {
            if currentlyMeditating.normalizedProgress >= 1.0 {
                meditatorsToMove.append(currentlyMeditating)
                indexPathsToDelete.append(NSIndexPath(forRow: index, inSection: 0))
            }
        }
        
        for finischedMeditator in meditatorsToMove {
            cache.deleteMeditator(finischedMeditator)
            cache.insertMeditator(finischedMeditator)
        }
        
        for (index, finishedMeditating) in cache.sections[1].enumerate() {
            if meditatorsToMove.contains(finishedMeditating) {
                indexPathsToAdd.append(NSIndexPath(forRow: index, inSection: 1))
            }
        }
        
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: .Automatic)
        tableView.insertRowsAtIndexPaths(indexPathsToAdd, withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
}