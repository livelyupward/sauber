import SwiftUI
import SwiftData
import PhotosUI

struct BusinessProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [BusinessProfile]

    @State private var businessName = ""
    @State private var ownerName = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var address = ""
    @State private var website = ""
    @State private var logoData: Data?
    @State private var logoPickerItem: PhotosPickerItem?
    @State private var didLoad = false
    @State private var saveStatus: SaveStatus = .idle
    @State private var hideStatusTask: Task<Void, Never>?

    private enum SaveStatus: Equatable {
        case idle
        case saved
        case failed(String)
    }

    private var profile: BusinessProfile? { profiles.first }

    var body: some View {
        Form {
            Section {
                Text("This information appears on every proposal and job report PDF you send.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Logo") {
                HStack {
                    if let logoData, let uiImage = UIImage(data: logoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.secondarySystemBackground))
                            .frame(width: 60, height: 60)
                            .overlay(Image(systemName: "building.2").foregroundStyle(.secondary))
                    }
                    Spacer()
                    PhotosPicker(selection: $logoPickerItem, matching: .images) {
                        Text(logoData == nil ? "Add Logo" : "Change Logo")
                    }
                    if logoData != nil {
                        Button("Remove", role: .destructive) { logoData = nil }
                    }
                }
            }

            Section("Business Info") {
                TextField("Business Name", text: $businessName)
                TextField("Owner / Your Name", text: $ownerName)
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                TextField("Address", text: $address, axis: .vertical)
                TextField("Website", text: $website)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
            }

            Section {
                Color.clear.frame(height: 44)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .navigationTitle("Business Profile")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
            }
        }
        .safeAreaInset(edge: .bottom) {
            statusBanner
        }
        .onAppear(perform: loadIfNeeded)
        .onChange(of: logoPickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    logoData = data
                }
            }
        }
    }

    @ViewBuilder
    private var statusBanner: some View {
        switch saveStatus {
        case .idle:
            EmptyView()
        case .saved:
            banner(text: "Saved", systemImage: "checkmark.circle.fill", color: .green)
        case .failed(let message):
            banner(text: "Couldn't save: \(message)", systemImage: "exclamationmark.triangle.fill", color: .red)
        }
    }

    private func banner(text: String, systemImage: String, color: Color) -> some View {
        Label(text, systemImage: systemImage)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(color, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            .padding(.bottom, 8)
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func loadIfNeeded() {
        guard !didLoad else { return }
        didLoad = true
        if let profile {
            businessName = profile.businessName
            ownerName = profile.ownerName
            phone = profile.phone
            email = profile.email
            address = profile.address
            website = profile.website
            logoData = profile.logoData
        }
    }

    private func save() {
        let target = profile ?? BusinessProfile()
        target.businessName = businessName
        target.ownerName = ownerName
        target.phone = phone
        target.email = email
        target.address = address
        target.website = website
        target.logoData = logoData
        target.updatedAt = Date()
        if profile == nil {
            modelContext.insert(target)
        }

        hideStatusTask?.cancel()
        var visibleSeconds = 2.0
        do {
            try modelContext.save()
            withAnimation { saveStatus = .saved }
        } catch {
            withAnimation { saveStatus = .failed(error.localizedDescription) }
            visibleSeconds = 5.0
        }

        hideStatusTask = Task {
            try? await Task.sleep(for: .seconds(visibleSeconds))
            guard !Task.isCancelled else { return }
            withAnimation { saveStatus = .idle }
        }
    }
}
