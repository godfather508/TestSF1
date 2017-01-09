@IsTest
private class AccountManagerTest {

    @isTest static void testGetAccount() {
        Id accountId = createTestRecord();
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://ap1.salesforce.com/services/apexrest/Accounts/' + accountId + '/contacts';
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        Account result = AccountManager.getAccount();
        // Verify results
        System.assert(result != null);
        System.assertEquals('Nam Le', result.Name);
    }
    
    // Helper method
    static Id createTestRecord() {
        // Create test record
        Account account = new Account(Name = 'Nam Le');
        insert account;
        
		Contact contact = new Contact(Account = account, LastName = 'Nam');
        insert contact;
        return account.Id;
    }       
}