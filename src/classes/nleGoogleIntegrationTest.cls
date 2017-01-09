@isTest
private class nleGoogleIntegrationTest
{
    @testSetup static void testSetupData() {
        SetupData();
    }
    @isTest
    static void testGetTokens() {
        Test.startTest();
        
        nleGoogleCalendarCallouts_MockTest mockClass = new nleGoogleCalendarCallouts_MockTest();
        Test.setMock(HttpCalloutMock.class, mockClass);
        
        mockClass.calloutMethod = 'refreshToken';
        
        nleGoogleAuthController testController = new nleGoogleAuthController();
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('mode', 'token');
        ApexPages.currentPage().getParameters().put('code', '400');
        
        testController.Cmd_GetTokens();
        
        Test.stopTest();
    }

    @isTest
    static void testGetCalendarList() {
        Test.startTest();
        
        nleGoogleCalendarCallouts_MockTest mockClass = new nleGoogleCalendarCallouts_MockTest();
        Test.setMock(HttpCalloutMock.class, mockClass);
        
        mockClass.calloutMethod = 'getCalendarList';
        
        nleGoogleAuthController testController = new nleGoogleAuthController();
        testController.Cmd_GetTokens();
        Test.stopTest();
    }
    
    @isTest
    static void testRevoke() {
        Test.startTest();
        
        nleGoogleCalendarCallouts_MockTest mockClass = new nleGoogleCalendarCallouts_MockTest();
        Test.setMock(HttpCalloutMock.class, mockClass);
        
        mockClass.calloutMethod = 'refreshToken';
        
        nleGoogleAuthController testController = new nleGoogleAuthController();
        
        testController.Cmd_Revoke();
        testController.Cmd_ConnectToGoogle();
        
        Test.stopTest();
    }
    @isTest
    static void testSaveCalendar() {
        Test.startTest();
        
        nleGoogleCalendarCallouts_MockTest mockClass = new nleGoogleCalendarCallouts_MockTest();
        Test.setMock(HttpCalloutMock.class, mockClass);
        
        mockClass.calloutMethod = 'getCalendar';
        
        nleGoogleAuthController testController = new nleGoogleAuthController();
        
        testController.Cmd_SaveCalendar();
        
        Test.stopTest();
    }
    
    private static void SetupData() {
        nleGoogleAPISetting__c googleSetting = new nleGoogleAPISetting__c(Name = 'Test Google Setting');
        googleSetting.namle__Calendar_API_Key__c = 'serverkey';
        googleSetting.namle__Calendar_Client_Id__c = 'clientid';
        googleSetting.namle__Calendar_Client_Secret__c = 'clientsecret';
        insert googleSetting;
        
        String userName = UserInfo.getUserName();
        User activeUser = [Select Id, Name, Email From User where Username = : userName limit 1];
        
        namle__Google_Calendar_Account__c gAccount = new namle__Google_Calendar_Account__c();
        gAccount.namle__Calendar_Id__c = 'test@salesforce.com';
        gAccount.namle__Calendar_Access_Token__c = 'ya29.pAKW8SB6cw6C7KYC4bxBazDz-1rsaTUNVU-VWD73IZ8bWkJ4t3N3hOC7r7j0V2j_0g';
        gAccount.namle__Calendar_Refresh_Token__c = 'Bearer';
        gAccount.namle__Calendar_Token_Expire_On__c = system.now().addMinutes(-1);
        gAccount.namle__User__c = activeUser.Id;
        insert gAccount;
        
        Account account = new Account(Name = 'Test Account');        
        insert account;
        
        List<Contact> contacts = new List<Contact>();
        
        Contact testContact1 = new Contact(AccountId = account.Id, LastName = 'Test1', Email = 'test1@salesforce.com');
        contacts.add(testContact1);
        
        Contact testContact2 = new Contact(AccountId = account.Id, LastName = 'Test2', Email = 'test2@salesforce.com');
        contacts.add(testContact2);
        
        insert contacts;
        
        Event event = new Event();
        event.namle__Google_Event_ID__c = 'namle__Google_Event_ID__c';
        event.namle__Google_Calendar_Client_Id__c = 'namle__Google_Calendar_Client_Id__c';
        event.StartDateTime = system.now();
        event.EndDateTime = system.now().addMinutes(5);
        event.Subject = 'Subject';
        event.description = 'description';
        event.location = 'location';
        event.namle__Status__c = 'status';
            
        event.WhoId = testContact1.Id;
        event.WhatId = account.Id;
        insert event;
        
    }
}