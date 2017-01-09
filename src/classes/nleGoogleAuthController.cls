public class nleGoogleAuthController {
    public List<namle__Google_Calendar_Account__c> gAccounts {get;set;}
    public List<SelectOption> Calendars {get;set;}
    
    public boolean isConnected {get;set;}
    public integer NoOfResources {
        get {
            return gAccounts != NULL ? gAccounts.size() : 0;
        }
    }
    
    private string baseUrl;
    private string oAuthRedirectUri;
    
    public nleGoogleAuthController() {
        getGAccounts();
        isConnected = false;
        if (this.gAccounts.size() > 0) {
            isConnected = !string.isBlank(this.gAccounts.get(0).namle__Calendar_Refresh_Token__c);
        }
        
        this.baseUrl = ApexPages.currentPage().getHeaders().get('Host');
        this.oAuthRedirectUri = 'https://' +  this.BaseURL + '/apex/nleGoogleAuth?mode=token';
    }
    
    public void Cmd_SaveCalendar() {
        // Sync for last  6 months
        
        List<nleGoogleData.CalloutResult> resultList = new List<nleGoogleData.CalloutResult>();
        Integer months = 6;
        if (Test.isRunningTest()) {
            months = 1;
        }
        for (integer i = 0; i < months; i ++) {
            integer a = -i;
            integer b = -i-1;
            DateTime startTime = System.now().addMonths(b);
            DateTime endTime = System.now().addMonths(a);
            nleGoogleData.CalloutResult listEvents = nleGoogleCalendarCallouts.getEventsByPeriod(gAccounts[0], startTime, endTime);
            resultList.add(listEvents);   
        }

        nleGoogleDataHandler.updateEventsToContacts(resultList);

        // schedule for 15 mins
        String scheduleName = 'nleGoogleSyncScheduler%';
        List<CronTrigger> schedules = [SELECT Id, CronJobDetail.Name, CronJobDetail.Id, State FROM CronTrigger WHERE CronJobDetail.Name LIKE :scheduleName];
        if (schedules.size() > 0) {
            for (CronTrigger schedule : schedules) {
                System.abortJob(schedule.Id);
            }
        }
            System.schedule('nleGoogleSyncScheduler 1', '0 0 * * * ?', new nleGoogleSyncScheduler());
            System.schedule('nleGoogleSyncScheduler 2', '0 15 * * * ?', new nleGoogleSyncScheduler());
            System.schedule('nleGoogleSyncScheduler 3', '0 30 * * * ?', new nleGoogleSyncScheduler());
            System.schedule('nleGoogleSyncScheduler 4', '0 45 * * * ?', new nleGoogleSyncScheduler());
        
        UPSERT this.gAccounts;
    }
    
    public void Cmd_Revoke() {
        for (namle__Google_Calendar_Account__c gAccount : this.gAccounts) {
            gAccount.namle__Calendar_Access_Token__c = '';
            gAccount.namle__Calendar_Refresh_Token__c = '';
            gAccount.namle__Calendar_Id__c = '';
            gAccount.namle__Calendar_Token_Expire_On__c = NULL;
        }
        this.isConnected = false;
        UPSERT this.gAccounts;
    }
    
    public pageReference Cmd_ConnectToGoogle() {
        nleGoogleAPISetting__c googleApiSetting = GetGoogleApiSetting();
        string x = 'https://accounts.google.com/o/oauth2/auth' 
            + '?scope=' + EncodingUtil.urlEncode('https://www.googleapis.com/auth/calendar','UTF-8')
            + '&redirect_uri=' + EncodingUtil.urlEncode(this.oAuthRedirectUri,'UTF-8')
            + '&response_type=code&client_id=' 
            + googleApiSetting.Calendar_Client_Id__c
            + '&approval_prompt=force'
            + '&access_type=offline';
        
        pageReference p = new pageReference(x);
        return p;
    }
    
    public pageReference Cmd_GetTokens() {
        string modeParam = apexPages.currentPage().getParameters().get('mode');
        if (!string.isBlank(modeParam) && modeParam == 'token') {
            isConnected = true;
            string codeParam = apexPages.currentPage().getParameters().get('code');
            if (!string.isBlank(codeParam)) {
                nleGoogleAPISetting__c googleApiSetting = GetGoogleApiSetting();
                
                String body = 'code=' + codeparam
                    + '&client_id=' 
                    + googleApiSetting.Calendar_Client_Id__c
                    + '&client_secret=' 
                    + googleApiSetting.Calendar_Client_Secret__c
                    + '&redirect_uri=' + EncodingUtil.urlEncode(this.oAuthRedirectUri,'UTF-8')
                    + '&grant_type=authorization_code';
                
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://accounts.google.com/o/oauth2/token');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setMethod('POST');
                req.setBody(body);
                
                try {
                    Http h = new Http();
                    HttpResponse res = h.send(req);
                    JSONParser parser = JSON.createParser(res.getBody());
                    system.debug('res.getBody(): ' + res.getBody());
                    string access_token, refresh_token;
                    integer expiresIn;
                    while (parser.nextToken() != null) {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                            parser.nextToken();
                            access_token = parser.getText();
                        }
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'refresh_token')) {
                            parser.nextToken();
                            refresh_token = parser.getText();
                        }
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'expires_in')) {
                            parser.nextToken();
                            expiresIn = parser.getIntegerValue();
                        }
                    }
                    
                    for (namle__Google_Calendar_Account__c gAccount : this.gAccounts) {
                        gAccount.namle__Calendar_Access_Token__c = access_token;
                        gAccount.namle__Calendar_Refresh_Token__c = refresh_token;
                        if (expiresIn != NULL) {
                            gAccount.namle__Calendar_Token_Expire_On__c = System.Now().addMinutes(-1).addSeconds(expiresIn);
                        }
                    }
                    getCalendarListWithToken(access_token);
                    
                    UPSERT this.gAccounts;
                } 
                catch (Exception ex) {
                    system.debug('#error#' + ex.getMessage());
                    system.debug('#error#' + ex.getStackTraceString());
                }
            }
        } else {
            if (isConnected) {
                getCalendarList(this.gAccounts.get(0).Id);
            }
        }
        return null;
    }
    
    private void getCalendarListWithToken(string accessToken) {
        nleGoogleData.CalendarList calendarList = nleGoogleCalendarCallouts.getCalendarListWithToken(accessToken);
        this.Calendars = new List<SelectOption>();
        this.Calendars.add(new SelectOption('', 'None'));
        if (calendarList != NULL && CalendarList.Items != NULL) {
            for (nleGoogleData.CalendarListItem item : calendarList.Items) {
                this.Calendars.add(new SelectOption(item.id, item.summary));
            }
        }
    }
    
    private void getCalendarList(string contactId) {
        nleGoogleData.CalloutResult result = nleGoogleCalendarCallouts.getCalendarList(contactId);
        this.Calendars = new List<SelectOption>();
        this.Calendars.add(new SelectOption('', 'None'));
        if (result.CalendarList != NULL && result.CalendarList.Items != NULL) {
            for (nleGoogleData.CalendarListItem item : result.CalendarList.Items) {
                this.Calendars.add(new SelectOption(item.id, item.summary));
            }
        }
    }
    
    private void getGAccounts() {
        String userName = UserInfo.getUserName();
        User activeUser = [Select Id, Name, Email From User where Username = : userName limit 1];

        this.gAccounts = [SELECT Id, Name, namle__Google_App__c, namle__Calendar_Access_Token__c, namle__Calendar_Id__c, namle__Calendar_Refresh_Token__c, namle__Calendar_Token_Expire_On__c, namle__User__r.Name
                                FROM namle__Google_Calendar_Account__c
                                WHERE namle__User__c = :activeUser.Id AND namle__Google_App__c = 'Calendar API'];

        if (this.gAccounts.size() == 0) {
            namle__Google_Calendar_Account__c gAccount = new namle__Google_Calendar_Account__c(namle__User__c = activeUser.Id, namle__Google_App__c = 'Calendar API');
            this.gAccounts.add(gAccount);
        }
    }
    
        
    private nleGoogleAPISetting__c GetGoogleApiSetting() {
        return nleGoogleAPISetting__c.getOrgDefaults();
    }
}