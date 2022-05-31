//
//  Prospect.swift
//  HotProspects
//
//  Created by Michael & Diana Pascucci on 5/30/22.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    
    // MARK: - PROPERTIES
    var id = UUID()
    var name = "Anonymnous"
    var emailAddress = ""
    fileprivate(set) var isContacted = false
}

@MainActor class Prospects: ObservableObject {
    
    // MARK: - PROPERTIES
    @Published private(set) var people: [Prospect]
    //Added for Challenge 16-2
    let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedPlaces")
    // Removed for Challenge 16-2
    // let saveKey = "SavedData"
    
    // MARK: - INITIALIZER
    init() {
        // Removed for Challenge 16-2
        // if let data = UserDefaults.standard.data(forKey: saveKey) { -- Removed for Challenge 16-2
        // Added for Challenge 16-2
        if let data = try? Data(contentsOf: savePath) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                people = decoded
                return
            }
        }
        people = []
    }
    
    // MARK: - METHODS
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            // Removed for Challenge 16-2
            // UserDefaults.standard.set(encoded, forKey: saveKey) -- Removed for Challenge 16-2
            // Added for Challenge 16-2
            try? encoded.write(to: savePath, options: [.atomic, .completeFileProtection])
        }
    }
}
