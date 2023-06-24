import SwiftUI

struct Person: Identifiable {
    let id = UUID()
    let fullName: String
    let email: String
    let phone: String
    
    init(firstName: String, lastName: String, email: String, phone: String) {
            self.fullName = "\(firstName) \(lastName)"
            self.email = email
            self.phone = phone
        }
}

class DataStore: ObservableObject {
    @Published var contacts: [Person] = []
    
    private let names = ["Artem", "Vlad", "Boby", "Sara", "Maksim", "Olivia"]
    private let lastNames = ["Golores", "Kyznecov", "Cherry", "Polska", "Martusik", "Goicov"]
    private let emails = ["mail@example.com", "mail@example.com", "mail@example.com", "mail@example.com", "mail@example.com", "mail@example.com"]
    private let phones = ["1234567890", "9876543210", "5551234567", "9998887777", "4445556666", "1112223333"]
    
    func generateRandomContacts() {
        for _ in 0..<10 {
            let randomName = names.randomElement() ?? ""
            let randomLastName = lastNames.randomElement() ?? ""
            let randomEmail = emails.randomElement() ?? ""
            let randomPhone = phones.randomElement() ?? ""
            
            let newPerson = Person(firstName: randomName, lastName: randomLastName, email: randomEmail, phone: randomPhone)



            contacts.append(newPerson)
        }
    }
    
    func addContact(person: Person) {
        contacts.append(person)
    }
    
    func removeContact(at index: Int) {
        contacts.remove(at: index)
    }
}

struct ContentView: View {
    @StateObject private var dataStore = DataStore()
    @State private var isShowingAddContactSheet = false
    @State private var selectedContact: Person?
    
    var body: some View {
        TabView {
            NavigationView {
                List {
                    ForEach(dataStore.contacts) { person in
                        Button(action: {
                            selectedContact = person
                        }) {
                            Text(person.fullName)
                        }
                    }
                    .onDelete(perform: deleteContact)
                }
                .navigationTitle("Contacts")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingAddContactSheet = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $isShowingAddContactSheet) {
                    AddContactView(dataStore: dataStore, isPresented: $isShowingAddContactSheet)
                }
            }
            .tabItem {
                Image(systemName: "person.3")
                Text("Contacts")
            }
            
            NavigationView {
                List {
                    ForEach(dataStore.contacts) { person in
                        Section(header: Text(person.fullName)) {
                            Text("Email: \(person.email)")
                            Text("Phone: \(person.phone)")
                        }
                    }
                }
                .navigationTitle("Contact Details")
            }
            .tabItem {
                Image(systemName: "phone")
                Text("Numbers")
            }
        }
        .onAppear {
            dataStore.generateRandomContacts()
        }
        .sheet(item: $selectedContact) { person in
            ContactDetailView(person: person)
        }
    }
    
    private func deleteContact(at offsets: IndexSet) {
        offsets.forEach { index in
            dataStore.removeContact(at: index)
        }
    }
}

struct AddContactView: View {
    @ObservedObject var dataStore: DataStore
    @Binding var isPresented: Bool
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }
                
                Section(header: Text("Contact Details")) {
                    TextField("Email", text: $email)
                    TextField("Phone", text: $phone)
                }
            }
            .navigationTitle("Add Contact")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newPerson = Person(firstName: firstName, lastName: lastName, email: email, phone: phone)
                        dataStore.addContact(person: newPerson)
                        isPresented = false
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty || email.isEmpty || phone.isEmpty)
                }
            }
        }
    }
}

struct ContactDetailView: View {
    let person: Person
    
    var body: some View {
        VStack {
            Text(person.fullName)
                .font(.title)
                .padding()
            Text("Email: \(person.email)")
            Text("Phone: \(person.phone)")
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
