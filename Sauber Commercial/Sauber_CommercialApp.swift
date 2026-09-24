//
//  Sauber_CommercialApp.swift
//  Sauber Commercial
//

import SwiftUI
import SwiftData

@main
struct Sauber_CommercialApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BusinessProfile.self,
            Customer.self,
            ServiceCatalogItem.self,
            Proposal.self,
            ProposalLineItem.self,
            WorkOrder.self,
            JobReport.self,
            ChecklistItem.self,
            PhotoAttachment.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.livelyupward.Sauber-Commercial")
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
