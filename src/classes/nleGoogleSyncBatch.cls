global class nleGoogleSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global nleGoogleSyncBatch() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        integer timeInFuture = 60;
        
        List<string> fields = new List<string>();
        List<string> conditions = new List<string>();
        
        fields.add('namle__Calendar_Access_Token__c');
        fields.add('namle__Calendar_Id__c');
        fields.add('namle__Calendar_Refresh_Token__c');
        fields.add('namle__Calendar_Token_Expire_On__c');
        
        conditions.add('namle__Calendar_Refresh_Token__c <> NULL');
        
        string queryString = 'SELECT ' + string.join(fields, ',') + ' FROM namle__Google_Calendar_Account__c WHERE ' +  string.join(conditions, ' AND ');
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        list<namle__Google_Calendar_Account__c> gAccounts = (list<namle__Google_Calendar_Account__c>)scope;
        List<nleGoogleData.CalloutResult> resultList = new List<nleGoogleData.CalloutResult>();
        
        for (namle__Google_Calendar_Account__c gAccount : gAccounts) {
            if (string.isBlank(gAccount.namle__Calendar_Id__c)) {
                continue;
            }
            
            DateTime startTime = System.now().addMinutes(-15);
            nleGoogleData.CalloutResult listEvents = nleGoogleCalendarCallouts.getEventsByPeriod(gAccount, startTime);
			resultList.add(listEvents);
        }
        
        if (resultList.size() > 0) {
            nleGoogleDataHandler.updateEventsToContacts(resultList);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    	/*
        if (!Test.isRunningTest()) {
            Database.executeBatch(new skedPullGoogleEventBatch(), 10);
        }
        */
    }   
}