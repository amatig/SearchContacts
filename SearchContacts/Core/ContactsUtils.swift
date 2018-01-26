//
//  ContactsUtils.swift
//  TestSwift
//
//  Created by Giovanni Amati on 22/11/2017.
//  Copyright © 2017 Messagenet. All rights reserved.
//

import Foundation
import Contacts

class ContactsUtils {
    
    // MARK: - Properties
    
    private static var sharedContactsUtils: ContactsUtils = {
        let contactsUtils = ContactsUtils()
        
        // Configuration
        // ..
        
        return contactsUtils
    }()
    
    private let contactStore = CNContactStore()
    private var arrayOfAllContacts: NSMutableArray = []
    private var isInSync: AtomicBoolean = AtomicBoolean.init(initialValue: false)
    private var isSyncDone: AtomicBoolean = AtomicBoolean.init(initialValue: false)
    
    
    // MARK: -
    
    // Initialization
    
    private init() {
        
    }
    
    // MARK: - Accessors
    
    class func shared() -> ContactsUtils {
        return sharedContactsUtils
    }
    
    func checkPermission(completion: @escaping (Bool, Error?) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
        case .authorized:
            completion(true, nil);
            break
        case .denied, .notDetermined:
            contactStore.requestAccess(for: .contacts, completionHandler: { (granted, error) in
                if granted {
                    completion(granted, error)
                } else {
                    if authorizationStatus == .denied {
                        // message??
                    }
                    completion(false, nil)
                }
            })
            break
        default:
            completion(false, nil);
            break
        }
        
    }
    
    func refresh(completion: @escaping (Bool) -> Void) {
        if (!self.isInSync.get() && !self.isSyncDone.get()) {
            _ = self.isInSync.getAndSet(value: true)
            
            self.cacheContacts()
            
            _ = self.isInSync.getAndSet(value: false)
            _ = self.isSyncDone.getAndSet(value: true)
            completion(true)
        } else {
            completion(false)
        }
    }
    
    private func cacheContacts() {
        self.arrayOfAllContacts.removeAllObjects()
        
        let keysToFetch = [CNContactIdentifierKey,
                           CNContactGivenNameKey,
                           CNContactFamilyNameKey,
                           CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        fetchRequest.sortOrder = .givenName
        
        do {
            try self.contactStore.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespacesAndNewlines)
                
                if fullName.count > 0 {
                    for number in contact.phoneNumbers {
                        var contactDict = [String: String]()
                        
                        let numberFormat: String = number.value.stringValue
                        
                        contactDict["identifier"] = contact.identifier
                        contactDict["fullName"] = fullName
                        contactDict["givenName"] = contact.givenName
                        contactDict["familyName"] = contact.familyName
                        contactDict["number"] = numberFormat.components(separatedBy: CharacterSet.init(charactersIn: "1234567890").inverted).joined(separator: "")
                        contactDict["numberFormat"] = numberFormat
                        
                        self.arrayOfAllContacts.add(contactDict)
                    }
                }
            })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func getImageFromContact(idetifier: String) -> Data? {
        let keysToFetch = [CNContactThumbnailImageDataKey] as [CNKeyDescriptor]
        
        do {
            let contact = try self.contactStore.unifiedContact(withIdentifier: idetifier, keysToFetch: keysToFetch)
            return contact.thumbnailImageData
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    func getAllContacts(predicate: NSPredicate?) -> NSArray {
        if (predicate != nil) {
            return arrayOfAllContacts.filtered(using: predicate!) as NSArray
        } else {
            return self.arrayOfAllContacts
        }
    }
    
}

