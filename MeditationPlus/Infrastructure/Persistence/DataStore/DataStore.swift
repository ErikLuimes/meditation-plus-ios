//
//  DataStore.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 06/05/16.
//
//  The MIT License
//  Copyright (c) 2016 Maya Interactive. All rights reserved.
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
import RealmSwift
import CocoaLumberjack

let dataStore = DataStore()

public protocol DataStoreProtocol
{
    // var chatItems: Results<ChatItem> { get set }
}

public struct DataStore: DataStoreProtocol
{
    private (set) var writeQueue = dispatch_queue_create("org.meditationplus.realm.write", DISPATCH_QUEUE_SERIAL)
    
    private (set) var backgroundQueue = dispatch_queue_create("org.meditationplus.realm.background", DISPATCH_QUEUE_CONCURRENT)

    private (set) var mainRealm: Realm
    
    public init()
    {
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
        
        mainRealm = try! Realm()
    }
    
    internal func performWriteBlock(writeBlock: (backgroundRealm:Realm) -> Void)
    {
        dispatch_async(self.writeQueue)
        {
            autoreleasepool
            {
                do {
                    let realm = try Realm()
                    
                    try realm.write()
                        {
                            writeBlock(backgroundRealm: realm)
                            try! realm.commitWrite()
                    }
                } catch let error as NSError {
                    DDLogError("DB Error: \(error.localizedDescription)")
                } catch {
                    DDLogError("DB Error: Generic Error")
                }
            }
        }
    }
    
    internal func performBackgroundBlock(backgroundBlock: (backgroundRealm:Realm) -> Void)
    {
        dispatch_async(self.backgroundQueue)
        {
            autoreleasepool
            {
                do {
                    let realm = try Realm()
                    backgroundBlock(backgroundRealm: realm)
                } catch let error as NSError {
                    DDLogError("DB Error: \(error.localizedDescription)")
                } catch {
                    DDLogError("DB Error: Generic Error")
                }
            }
        }
    }
    
    public func deleteAll()
    {
        performWriteBlock
            {
                (backgroundRealm) in
                backgroundRealm.deleteAll()
        }
    }
    
    public func addOrUpdateObject(object: Object)
    {
        addOrUpdateObjects([object])
    }
    
    public func addOrUpdateObjects(objects: [Object])
    {
        performWriteBlock
            {
                (backgroundRealm) in
                
                backgroundRealm.add(objects, update: true)
        }
    }
    
    public func deleteAllObjects<T:Object>(type: T.Type)
    {
        performWriteBlock
            {
                (backgroundRealm) in
                
                backgroundRealm.delete(backgroundRealm.objects(type))
        }
    }
    
    /**
     Deletes all objects.
     
     - parameter writeRealm: writeRealm description
     - parameter object:     Realm object to exclude from deletion
     - parameter type:       Realm object type
     */
    public func deleteAllObjects<T:Object>(ofType type: T.Type, excludingObject object: T?, inWriteRealm writeRealm: Realm)
    {
        deleteAllObjects(ofType: type, excludingObjects: object == nil ? nil : [object!], inWriteRealm: writeRealm)
    }
    
    /**
     Deletes all objects.
     
     - parameter writeRealm: writeRealm description
     - parameter objects:    Realm objects to exclude from deletion
     - parameter type:       Realm object type
     */
    public func deleteAllObjects<T:Object>(ofType type: T.Type, excludingObjects objects: [T]?, inWriteRealm writeRealm: Realm)
    {
        assert(writeRealm.inWriteTransaction, "Realm should be in write transaction")
        guard let primaryKey: String = type.primaryKey() else {
            return
        }
        
        guard let newObjects = objects else {
            writeRealm.delete(writeRealm.objects(type))
            return
        }
        
        let availableObjects = writeRealm.objects(type)
        
        var objectsToDelete: [Object] = [Object]()
        
        for availableObject in availableObjects {
            guard let primaryKeyValue = availableObject.valueForKey(primaryKey) as? String else {
                continue
            }
            
            if !newObjects.contains({
                bla in
                if let blaVal = bla.valueForKey(primaryKey) as? String {
                    return blaVal == primaryKeyValue
                }
                
                return false
            }) {
                objectsToDelete.append(availableObject)
            }
        }
        
        if objectsToDelete.count > 0 {
            DDLogInfo("Deleted \(objectsToDelete.count) objects of type: \(type)")
            writeRealm.delete(objectsToDelete)
        }
    }
    
    // MARK: Lazy Result Sets
    
    lazy public private(set) var chatItems: Results<ChatItem> =
    {
        return self.mainRealm.objects(ChatItem).sorted("time", ascending: false)
    }()
}
