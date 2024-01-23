@isTest
public class LtngContactDatatableCtrl_Test {
    @TestSetup
    static void makeData(){
        // Insert test Contact records
        List<Contact> contactList = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            Contact con = new Contact();
            con.FirstName = 'TestFirstName' + i;
            con.LastName = 'TestLastName' + i;
            con.Phone = '555-555-555' + i;
            con.Email = 'TestEmail' + i + '@gmail.com';
            con.MailingStreet = 'TestMailingStreet ' + i;
            contactList.add(con);
        }

        insert contactList;

        // Insert a test Case record
        Case testCase = new Case(
            Subject = 'Test Case Subject',
            Description = 'Test Case Description',
            ContactId = contactList[0].Id  // Link the Case to the test Contact
        );
        insert testCase;
    }

    @isTest
    static void testGetContactsPositive() {
        // Call the getContacts() method
        Test.startTest();
        List<Contact> contactList = LtngContactDatatableCtrl.getContacts();
        Test.stopTest();

        // Assert the results 
        System.assert(contactList.size() > 0);
        System.assertEquals(10, contactList.size());
    }

    @isTest
    static void testGetContactsNegative() {
        AuraHandledException unexcpectedException;

        Test.startTest();
        
        try {
            List<Contact> contacts = LtngContactDatatableCtrl.getContacts();
            
        } catch (AuraHandledException ahx) {
            // Assert that an AuraHandledException was thrown
            unexcpectedException = ahx;
        }
        
        Test.stopTest();

        system.assertEquals(null, unexcpectedException, 'Exceptions should be handled by the method');
    }

    
    @isTest
    static void testGetContactToUpdate() {
        // Create a test Contact record
        Contact insertedContact = [SELECT Id, FirstName, LastName, Email, Phone, MailingStreet, CreatedDate FROM Contact LIMIT 1];

        Test.startTest();
        Contact returnedContact = LtngContactDatatableCtrl.getContactToUpdate(insertedContact.Id);
        Test.stopTest();

        // Assert the result (e.g., check if the returned Contact matches the test data)
        System.assertEquals(insertedContact.FirstName, returnedContact.FirstName);
        System.assertEquals(insertedContact.LastName, returnedContact.LastName);
        System.assertEquals(insertedContact.Email, returnedContact.Email);
    }
     
    @isTest
    static void testInsertContactPostive() {
        // Create a test Contact record
        Contact con = new Contact();
        con.FirstName = 'TestNewCon';
        con.LastName = 'TestNewConLastName';
        con.Phone = '777-555-555';
        con.Email = 'TestEmailNew@gmail.com';
        con.MailingStreet = 'TestNewMailingStreet';

        Test.startTest();
        String messageRetrieved = LtngContactDatatableCtrl.upsertContact(con.Id, con.FirstName, con.LastName, con.Phone, con.Email, con.MailingStreet);
        Test.stopTest();

        // Parse the returned JSON string to extract the message
        Map<String, Object> messageMap = (Map<String, Object>) JSON.deserializeUntyped(messageRetrieved);
        String message = (String) messageMap.get('message');

        // Assert the results (e.g., check if the message matches the expected message)
        Contact insertedContact = [SELECT Id, FirstName, LastName FROM Contact WHERE Email = 'TestEmailNew@gmail.com' LIMIT 1];
        System.assertEquals('Contact record has been created', message);
        System.assertEquals(con.FirstName, insertedContact.FirstName);
        System.assertEquals(con.LastName, insertedContact.LastName);
    }

    @isTest
    static void testUpdateContact() {
        Contact con = [SELECT Id, FirstName, LastName, Email, Phone, MailingStreet, CreatedDate FROM Contact LIMIT 1];
        // Update the contact's information
        con.FirstName = 'UpdatedFirstName';
        con.LastName = 'UpdatedLastName';
        con.Phone = '888-555-555';

        Test.startTest();
        String messageRetrieved = LtngContactDatatableCtrl.upsertContact(
            con.Id, con.FirstName, con.LastName, con.Phone, con.Email, con.MailingStreet
        );
        Test.stopTest();

        // Parse the returned JSON string to extract the message
        Map<String, Object> messageMap = (Map<String, Object>) JSON.deserializeUntyped(messageRetrieved);
        String message = (String) messageMap.get('message');

        // Assert the results
        Contact updatedContact = [SELECT Id, FirstName, LastName, Phone, Email, MailingStreet FROM Contact WHERE Id = :con.Id LIMIT 1];
        System.assertEquals('Contact record has been updated', message);
        System.assertEquals(con.FirstName, updatedContact.FirstName);
        System.assertEquals(con.LastName, updatedContact.LastName);
        System.assertEquals(con.Phone, updatedContact.Phone);
    }

    @isTest
    static void testUpsertContactNegative() {
        // Create a test Contact record with invalid data (e.g., missing required fields)
        Contact testContact = new Contact();
        
        // Call the upsertContact method and expect it to throw an exception
        AuraHandledException unexpectedException = null;

        Test.startTest();
        
        try {
            // Attempt to upsert the testContact
            String result = LtngContactDatatableCtrl.upsertContact(
                testContact.Id,
                testContact.FirstName,
                testContact.LastName,
                testContact.Phone,
                testContact.Email,
                testContact.MailingStreet
            );
        } catch (AuraHandledException ahx) {
            // Capture the exception
            unexpectedException = ahx;
        }
        
        Test.stopTest();

        // Assert that an AuraHandledException was thrown
        System.assertNotEquals(null, unexpectedException, 'Exceptions should be handled by the method');
    }

    
    @isTest
    static void testDeleteContactsPositive() {
        List<Contact> contactList = [SELECT Id, FirstName, LastName, Email, Phone, MailingStreet, CreatedDate FROM Contact];
        List<Id> contactIds = new List<Id>();

        // Get the Contact Ids to be deleted
        for (Contact con : contactList) {
            contactIds.add(con.Id);
        }
        
        // Call the deleteContacts() method
        Test.startTest();
        LtngContactDatatableCtrl.deleteContacts(contactIds);
        Test.stopTest();

        List<Contact> deletedContacts = [SELECT Id FROM Contact WHERE Id IN :contactIds];
        List<Case> deletedCases = [SELECT Id FROM Case WHERE ContactId IN :contactIds];

        // Assert that the Contact and Case lists are empty after deletion
        System.assertEquals(0, deletedContacts.size(), 'Contacts should be deleted.');
        System.assertEquals(0, deletedCases.size(), 'Cases should be deleted.');
    }
}