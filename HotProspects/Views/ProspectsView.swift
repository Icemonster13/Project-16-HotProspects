//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Michael & Diana Pascucci on 5/30/22.
//

import SwiftUI
import CodeScanner
import UserNotifications

struct ProspectsView: View {
    
    // MARK: - ENUMERATIONS
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    // Added for Challenge 16-3
    enum SortType {
        case name, date
    }
    
    // MARK: - PROPERTIES
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    
    // Added for Challenge 16-3
    @State private var sortOrder = SortType.date
    @State private var isShowingSortOptions = false
    
    let filter: FilterType
    
    // MARK: - COMPUTED PROPERTIES
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted People"
        case .uncontacted:
            return "Uncontacted People"
        }
    }
    
    var filteredProspects: [Prospect] {
        // Added for Challenge 16-3
        let result: [Prospect]
        
        // Removed Returns and changed them to result = as part of Challenge 16-3
        switch filter {
        case .none:
            result = prospects.people
        case .contacted:
            result = prospects.people.filter { $0.isContacted }
        case .uncontacted:
            result = prospects.people.filter { !$0.isContacted }
        }
        
        // Added for Challenge 16-3
        if sortOrder == .name {
            return result.sorted { $0.name < $1.name }
        } else {
            return result.reversed()
        }
    }
    
    // MARK: - BODY
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspects) { prospect in
                    
                    HStack {
                        // Added HStack and Image (with modifiers) for challenge 16-1
                        Image(systemName: prospect.isContacted ? "person.crop.circle.badge.checkmark" : "person.crop.circle.badge.questionmark")
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 28, height: 28, alignment: .center)
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                    }
                    .swipeActions {
                        if prospect.isContacted {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
                            }
                            .tint(.blue)
                        } else {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                            }
                            .tint(.green)
                            Button {
                                addNotification(for: prospect)
                            } label: {
                                Label("Remind Me", systemImage: "bell")
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                // Added for Challenge 16-3
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isShowingSortOptions = true
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)
            }
            // Added for Challenge 16-3
            .confirmationDialog("Sort By", isPresented: $isShowingSortOptions) {
                Button("Name (A-Z)") { sortOrder = .name }
                Button("Date (Newest First)") { sortOrder = .date }
            }
        }
    }
    
    // MARK: - METHODS
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            
            prospects.add(person)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh")
                    }
                }
            }
        }
    }
}

// MARK: - PREVIEW
struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
