//
//  Person.swift
//  TestSwift
//
//  Created by Giovanni Amati on 24/01/2018.
//  Copyright © 2018 Messagenet. All rights reserved.
//

import Foundation

class Person {
    
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
}

class Job {
    
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
}

class Worker {
    
    var person: Person?
    var job: Job?
    
    init(person: Person?, job: Job?) {
        self.person = person
        self.job = job
    }
    
}

class NoWorker: Worker {
    
    init(person: Person?) {
        super.init(person: person, job: nil)
    }
    
}

