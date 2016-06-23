//
//  Weather+CoreDataProperties.swift
//  04-CoreLocation-Weather-CoreData
//
//  Created by Gianfranco Cotumaccio on 23/06/16.
//  Copyright © 2016 Propaganda Studio. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Weather {

    @NSManaged var cityName: String?
    @NSManaged var weatherDescription: String?

}
