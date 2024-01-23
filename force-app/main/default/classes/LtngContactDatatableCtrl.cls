public class LtngContactDatatableCtrl {
    private final static String MSG_RECORD_UPDATED = 'Contact record has been updated';
    private final static String MSG_RECORD_CREATED = 'Contact record has been created';

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts() {
        try {
            return [SELECT Id, FirstName, LastName, Email, Phone, MailingStreet, CreatedDate FROM Contact];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Contact getContactToUpdate(String contactId) {
        try {
            Contact con = [SELECT Id, FirstName, LastName, Email, Phone, MailingStreet, CreatedDate FROM Contact WHERE Id =: contactId LIMIT 1];
            return con;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String upsertContact(String contactId, String firstName, String lastName, String phone, String email, String mailingAddress) {
        Contact contactToUpsert;
        String messageToPass = '';
        // Query to check if a Contact with the provided email exists
        List<Contact> existingContacts = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];

        if (!existingContacts.isEmpty()) {
            // If an existing Contact is found, update it
            contactToUpsert = existingContacts[0];
            contactToUpsert.FirstName = firstName;
            contactToUpsert.LastName = lastName;
            contactToUpsert.Phone = phone;
            contactToUpsert.Email = email;
            contactToUpsert.MailingStreet = mailingAddress;

            messageToPass = MSG_RECORD_UPDATED;
        } else {
            // If no existing Contact is found, create a new one
            contactToUpsert = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Phone = phone,
                Email = email,
                MailingStreet = mailingAddress
            );
            messageToPass = MSG_RECORD_CREATED;
        }

        try {
            upsert contactToUpsert;
            return '{"message":"' + messageToPass + '"}';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteContacts(List<String> contactIds) {
        try {
            // Query for the contacts to be deleted
            List<Contact> contactsToDelete = [SELECT Id FROM Contact WHERE Id IN :contactIds];
    
            Set<Id> caseIdsToDelete = new Set<Id>();
    
            // Iterate through the contacts to collect related case IDs
            for (Contact contact : contactsToDelete) {
                caseIdsToDelete.add(contact.Id);
            }
    
            List<Case> relatedCases = [SELECT Id FROM Case WHERE ContactId IN :caseIdsToDelete];
    
            // Create a set to store case IDs for deletion
            Set<Id> casesToDelete = new Set<Id>();
            for (Case relatedCase : relatedCases) {
                casesToDelete.add(relatedCase.Id);
            }
    
            // Delete the related cases
            if (!casesToDelete.isEmpty()) {
                delete [SELECT Id FROM Case WHERE Id IN :casesToDelete];
            }
    
            delete contactsToDelete;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}