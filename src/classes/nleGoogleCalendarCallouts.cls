public class nleGoogleCalendarCallouts {
    private string ClientId;
    private string ClientSecret;
    
    public static nleGoogleData.CalendarList getCalendarListWithToken(string accessToken) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string requestString = 'https://www.googleapis.com/calendar/v3/users/me/calendarList'; 
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setEndpoint(requestString);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        try {
            HttpResponse res = h.send(req);
            string jsonResultString = res.getBody();
            nleGoogleData.CalendarList calendarList = (nleGoogleData.CalendarList)(JSON.deserialize(jsonResultString, nleGoogleData.CalendarList.class));
            return calendarList;
        } catch (Exception ex) {
            system.debug('#error#' + ex.getMessage());
            system.debug('#error#' + ex.getStackTraceString());
        }
        return null;
    }  
    
    public static nleGoogleData.CalloutResult getCalendarList(string gAccountId) {
        nleGoogleData.CalloutResult result = getToken(gAccountId);
        
        result.CalendarList = getCalendarListWithToken(result.accessToken);
        
        return result;
    }

    public static nleGoogleData.CalloutResult getEventsByPeriod(namle__Google_Calendar_Account__c gAccount, DateTime startTime, DateTime endTime) {
        nleGoogleData.CalloutResult result = getToken(gAccount);
        
        nleGoogleAPISetting__c googleApiSetting = GetGoogleApiSetting();
        if (string.isBlank(googleApiSetting.Calendar_API_Key__c)) {
            return null;
        }
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string requestString = 'https://www.googleapis.com/calendar/v3/calendars/' + gAccount.namle__Calendar_Id__c + '/events?key=' + googleApiSetting.Calendar_API_Key__c + '&access_token=' + result.AccessToken; 
        
        string timeMin = json.serialize(startTime).remove('"');
        requestString += '&timeMin=' + timeMin;
        string timeMax = json.serialize(endTime).remove('"');
        requestString += '&timeMax=' + timeMax;
        
        req.setEndpoint(requestString);
        system.debug('#requestString#' + requestString);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        try {
            string jsonResult = '';
            
            HttpResponse res = h.send(req);
            jsonResult = res.getBody();
            

            system.debug('#jsonResult#' + jsonResult);
            jsonResult = jsonResult.replace('"dateTime"', '"dateTimeValue"');
            jsonResult = jsonResult.replace('"date"', '"dateValue"');
            jsonResult = jsonResult.replace('"end"', '"EventEnd"');
            result.Calendar = (nleGoogleData.Calendar)(JSON.deserialize(jsonResult, nleGoogleData.Calendar.class));
            if (string.isBlank(result.Calendar.summary)) {
                result.HasError = true;
                nleGoogleData.ErrorRootObject googleError = (nleGoogleData.ErrorRootObject)(Json.deserialize(jsonResult, nleGoogleData.ErrorRootObject.class));
                result.ErrorMessage = googleError.Error.message;
            }
        } catch (Exception e) {
            result.HasError = true;
            result.ErrorMessage = e.getMessage() + '\n' + e.getStackTraceString();
        }
        
        return result;
    }

    public static nleGoogleData.CalloutResult getEventsByPeriod(namle__Google_Calendar_Account__c gAccount, DateTime updatedMin) {
        nleGoogleData.CalloutResult result = getToken(gAccount);
        
        nleGoogleAPISetting__c googleApiSetting = GetGoogleApiSetting();
        if (string.isBlank(googleApiSetting.Calendar_API_Key__c)) {
            return null;
        }
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string requestString = 'https://www.googleapis.com/calendar/v3/calendars/' + gAccount.namle__Calendar_Id__c + '/events?key=' + googleApiSetting.Calendar_API_Key__c + '&access_token=' + result.AccessToken; 
        
        string timeUpdatedMin = json.serialize(updatedMin).remove('"');
        requestString += '&updatedMin=' + timeUpdatedMin;
        
        req.setEndpoint(requestString);
        system.debug('#requestString#' + requestString);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        try {
            string jsonResult = '';
            
            if (Test.isRunningTest()) {
                nleGoogleData.Calendar tempResult = new nleGoogleData.Calendar();
                nleGoogleData.Item item1 = new nleGoogleData.Item();
                item1.id = 'item1id';
                item1.summary = 'test google event';
                item1.start.dateTimeValue = system.now();
                item1.eventEnd.dateTimeValue = system.now().addHours(1);
                tempResult.items.add(item1);
                nleGoogleData.Item item2 = new nleGoogleData.Item();
                item2.id = 'item2id';
                item2.summary = 'test google event';
                item2.start.dateTimeValue = system.now();
                item2.eventEnd.dateTimeValue = system.now().addHours(1);
                tempResult.items.add(item2);
                jsonResult = Json.serialize(tempResult);
            }
            else {
                HttpResponse res = h.send(req);
                jsonResult = res.getBody();
            }
            /*
            HttpResponse res = h.send(req);
            jsonResult = res.getBody();
            */

            system.debug('#jsonResult#' + jsonResult);
            jsonResult = jsonResult.replace('"dateTime"', '"dateTimeValue"');
            jsonResult = jsonResult.replace('"date"', '"dateValue"');
            jsonResult = jsonResult.replace('"end"', '"EventEnd"');
            result.Calendar = (nleGoogleData.Calendar)(JSON.deserialize(jsonResult, nleGoogleData.Calendar.class));
            if (string.isBlank(result.Calendar.summary)) {
                result.HasError = true;
                nleGoogleData.ErrorRootObject googleError = (nleGoogleData.ErrorRootObject)(Json.deserialize(jsonResult, nleGoogleData.ErrorRootObject.class));
                result.ErrorMessage = googleError.Error.message;
            }
        } catch (Exception e) {
            result.HasError = true;
            result.ErrorMessage = e.getMessage() + '\n' + e.getStackTraceString();
        }
        
        return result;
    }

    public static nleGSheetData getSheetRanges(namle__Google_Calendar_Account__c gAccount, String range) {
        nleGoogleData.CalloutResult callResult = getToken(gAccount);
        system.debug(gAccount);
        nleGoogleAPISetting__c googleApiSetting = nleGoogleAPISetting__c.getOrgDefaults();
        if (string.isBlank(googleApiSetting.Calendar_API_Key__c)) {
            return null;
        }
        system.debug(googleApiSetting);
        
        String Base_URI = 'https://sheets.googleapis.com/v4/spreadsheets/';
        String spreadsheetId = '13Mc5Cj3JMXfgzvGoFYsdNwpGL9FGaWbX3Erd_zjJ7oU';

        String GET_URI = Base_URI  + spreadsheetId + '/values/' + range + '?key=' + googleApiSetting.Calendar_API_Key__c + '&access_token=' + callResult.AccessToken; 
        system.debug(GET_URI);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(GET_URI);
        req.setMethod('GET');
        req.setTimeout(60000);

        try {
            string jsonResult = '';
            HttpResponse res = h.send(req);
            system.debug(res);
            jsonResult = res.getBody();
            nleGSheetData result = (nleGSheetData)(JSON.deserialize(jsonResult, nleGSheetData.class));
            
            system.debug(result);
            return result;
        } catch (Exception e) {
            system.debug(e);
        }

        return null;
    }

    public static nleGSheetData doSearchByEmail(namle__Google_Calendar_Account__c gAccount, String searchValue) {   
        String range = 'NleNewMaster!L2:L';
        nleGSheetData dataResponse = getSheetRanges(gAccount, range);
        if (dataResponse != null && dataResponse.values != null) {
            List<List<String>> emails = dataResponse.values;
            Integer size = emails.size();
            Integer index = null;
            for (Integer i = 0; i < size; i++) {
                List<String> email = emails.get(i);
                if (email.size() > 0 && email.get(0) == searchValue) {
                    index = i;
                }
            }

            if (index != null) {
                index += 2;
                range = 'NleNewMaster!A' + index + ':P' + index;
                nleGSheetData result = getSheetRanges(gAccount, range);
                return result;
            }
        }

        return null;
    }
    
    /**************************** Private methods ****************************/ 
    
    private static nleGoogleAPISetting__c getGoogleApiSetting() {
        return nleGoogleAPISetting__c.getOrgDefaults();
    }

    private static nleGoogleData.CalloutResult getToken(string gAccountId) {
        namle__Google_Calendar_Account__c gAccount = [SELECT Id, namle__Calendar_Access_Token__c, namle__Calendar_Id__c, namle__Calendar_Refresh_Token__c, namle__Calendar_Token_Expire_On__c
                           FROM namle__Google_Calendar_Account__c 
                           WHERE Id = :gAccountId];
        return getToken(gAccount);
    }
    
    private static nleGoogleData.CalloutResult getToken(namle__Google_Calendar_Account__c gAccount) {
        nleGoogleData.CalloutResult result = new nleGoogleData.CalloutResult();
        if (gAccount.namle__Calendar_Token_Expire_On__c < system.now()) {
            result = refreshToken(gAccount);
        } else {
            result.AccessToken = gAccount.namle__Calendar_Access_Token__c;
            result.gAccount = gAccount;
        }
        return result;
    }
    
    public static nleGoogleData.CalloutResult refreshToken(namle__Google_Calendar_Account__c gAccount) {
        nleGoogleAPISetting__c googleApiSetting = GetGoogleApiSetting();
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string body = 'client_id=' + EncodingUtil.urlEncode(googleApiSetting.Calendar_Client_Id__c, 'UTF-8');
        body += '&client_secret=' + EncodingUtil.urlEncode(googleApiSetting.Calendar_Client_Secret__c, 'UTF-8');
        body += '&refresh_token=' + EncodingUtil.urlEncode(gAccount.namle__Calendar_Refresh_Token__c, 'UTF-8');
        body += '&grant_type=refresh_token';
        
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        req.setBody(body);
        req.setEndpoint('https://www.googleapis.com/oauth2/v3/token');
        req.setMethod('POST');
        req.setTimeout(60000);
        
        nleGoogleData.CalloutResult result = new nleGoogleData.CalloutResult();
        result.gAccount = gAccount;
        try {
            HttpResponse res = h.send(req);
            JSONParser parser = JSON.createParser(res.getBody());
            
            system.debug('#response#' + res.getBody());
            
            string access_token;
            integer expiresIn;
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    access_token = parser.getText();
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'expires_in')) {
                    parser.nextToken();
                    expiresIn = parser.getIntegerValue();
                }
            }
            
            result.AccessToken = access_token;
            result.ExpiresIn = expiresIn;
            system.debug('refreshToken result: ' + result);
            return result;
            
        } catch (Exception e) {
            result.HasError = true;
            result.ErrorMessage = e.getMessage() + '\n' + e.getStackTraceString();
            system.debug('#error#' + result.ErrorMessage);
        }
        return null;
    }
}