import SwiftUI
import SwiftData

struct ServiceCatalogListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ServiceCatalogItem.sortOrder) private var items: [ServiceCatalogItem]

    @State private var editingItem: ServiceCatalogItem?
    @State private var isPresentingNew = false

    var body: some View {
        List {
            if items.isEmpty {
                ContentUnavailableView(
                    "No Services Yet",
                    systemImage: "list.bullet.rectangle",
                    description: Text("Add the services you offer so you can quickly build proposals.")
                )
            } else {
                ForEach(items) { item in
                    Button {
                        editingItem = item
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name).foregroundStyle(.primary)
                                if !item.itemDescription.isEmpty {
                                    Text(item.itemDescription)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            Text(Formatting.currencyString(item.defaultUnitPrice))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle("Services")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { isPresentingNew = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $isPresentingNew) {
            NavigationStack {
                ServiceCatalogItemEditView(item: nil)
            }
        }
        .sheet(item: $editingItem) { item in
            NavigationStack {
                ServiceCatalogItemEditView(item: item)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}
