//
//  HSTM.swift
//  HSTM
//  Created by Esha Sidhu
//

import UIKit
import os.log


class HSTM: NSObject, NSCoding {
    
    //Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int // Rating of 3=1Hr, 4/5=2Hrs
    var eventtype: String = "Homework" //Homework, Quiz,Xtra
    var eventdescription: String = "Sample description"
    var eventdate: Date? //when is task due
    

    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("hstms")
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let rating = "rating"
        static let eventtype = "eventtype"
        static let eventdescription = "eventdescription"
        static let eventdate = "eventdate"
    }
    
    //MARK: Initialization
    
    init?(name: String, photo: UIImage?, rating: Int, eventtype: String, eventdescription: String, eventdate: Date) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }

        // The rating must be between 0 and 5 inclusively
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || rating < 0  {
            return nil
        }
        
        // The eventtype must not be empty
        guard !eventtype.isEmpty else {
            return nil
        }
        
        // The eventtype must not be empty
        guard !eventdescription.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.rating = rating
        self.eventtype = eventtype
        self.eventdescription = eventdescription
        self.eventdate = eventdate

    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(rating, forKey: PropertyKey.rating)
        aCoder.encode(eventtype, forKey: PropertyKey.eventtype)
        aCoder.encode(eventdescription, forKey: PropertyKey.eventdescription)
        aCoder.encode(eventdate, forKey: PropertyKey.eventdate)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of event, just use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
        
        guard let eventtype = aDecoder.decodeObject(forKey: PropertyKey.eventtype) as? String else {
            os_log("Unable to decode the type for object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let eventdescription = aDecoder.decodeObject(forKey: PropertyKey.eventdescription) as? String else {
            os_log("Unable to decode the type for object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let eventdate = aDecoder.decodeObject(forKey: PropertyKey.eventdate) as? Date
            else {
                os_log("Unable to decode the type for object.", log: OSLog.default, type: .debug)
                return nil
        }

        // Must call designated initializer.
        self.init(name: name, photo: photo, rating: rating, eventtype: eventtype, eventdescription: eventdescription, eventdate: eventdate ?? Date() )
        
    }
}
