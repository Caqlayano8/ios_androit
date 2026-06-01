import Contacts
import Foundation

final class ContactsStore {
    private let store = CNContactStore()

    func requestAuthorization(completion: @escaping (String) -> Void) {
        store.requestAccess(for: .contacts) { success, error in
            if let error = error {
                completion("Error: \(error.localizedDescription)")
            } else {
                completion(success ? "Allowed" : "Denied")
            }
        }
    }

    func loadDisplayNames(limit: Int = 50) -> [[String: String]] {
        let keys = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey
        ] as [CNKeyDescriptor]

        let request = CNContactFetchRequest(keysToFetch: keys)
        var contacts: [[String: String]] = []

        do {
            try store.enumerateContacts(with: request) { contact, stop in
                let name = [contact.givenName, contact.familyName]
                    .filter { !$0.isEmpty }
                    .joined(separator: " ")

                let phone = contact.phoneNumbers.first?.value.stringValue ?? ""

                if !name.isEmpty || !phone.isEmpty {
                    contacts.append([
                        "name": name,
                        "phone": phone
                    ])
                }

                if contacts.count >= limit {
                    stop.pointee = true
                }
            }
        } catch {
            return []
        }

        return contacts
    }
}
