//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Lena on 28.08.2022.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place){
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(place: Place){
        try! realm.write {
            realm.delete(place)
        }
    }
    
    // MARK: - Seeding data
    
    static let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]
    
    static func seedPlaces() {
        let places = realm.objects(Place.self)
        guard places.count == 0 else { return }

        for name in restaurantNames {
            let place = Place(name: name,
                              location: "Bon",
                              type: "Ресторан",
                              imageData: UIImage(named: name)?.pngData())
            StorageManager.saveObject(place)
        }
    }
    
}
