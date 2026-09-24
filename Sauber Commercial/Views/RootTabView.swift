import SwiftUI
import SwiftData

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ProposalsListView()
            }
            .tabItem { Label("Proposals", systemImage: "doc.text") }

            NavigationStack {
                CustomersListView()
            }
            .tabItem { Label("Customers", systemImage: "person.2") }

            NavigationStack {
                ServiceCatalogListView()
            }
            .tabItem { Label("Services", systemImage: "list.bullet.rectangle") }

            NavigationStack {
                BusinessProfileView()
            }
            .tabItem { Label("Business", systemImage: "building.2") }
        }
    }
}
