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
            meditatorCell.configureWithMeditator(meditator)
        }

        return cell
    }

    func meditatorForIndexPath(indexPath: NSIndexPath) -> MPMeditator? {
        return meditatorSections[indexPath.section].items[indexPath.row]
    }

    func updateMeditators(meditators: [MPMeditator]) {
        cache = MPMeditatorsResultsCache(initialMeditators: meditators)
    }
}