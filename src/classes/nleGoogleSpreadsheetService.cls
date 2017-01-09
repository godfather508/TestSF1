public with sharing class nleGoogleSpreadsheetService {
	public static void get(namle__Google_Calendar_Account__c gAccount) {
		system.debug(gAccount);
        nleGoogleAPISetting__c googleApiSetting = nleGoogleAPISetting__c.getOrgDefaults();
        if (string.isBlank(googleApiSetting.Calendar_API_Key__c)) {
            return;
        }
        system.debug(googleApiSetting);
		String API_KEY = 'AIzaSyBU-go4iS8rJQ6J8QPK8JI6maCsfZaXAx0';
		String Client_ID = '753530112531-f8gik4smb2p83ju3ea8st4g9kvbfva0b.apps.googleusercontent.com';
		String Client_Secret = 'SGrgjHPU4HZ2a1f1C9PoOEWR';
		String Base_URI = 'https://sheets.googleapis.com/v4/spreadsheets/';
		String spreadsheetId = '13Mc5Cj3JMXfgzvGoFYsdNwpGL9FGaWbX3Erd_zjJ7oU';
		String range = '2:19';
		String GET_URI = Base_URI  + spreadsheetId + '/values/' + range + '?key=' + googleApiSetting.Calendar_API_Key__c + '&access_token=' + gAccount.namle__Calendar_Access_Token__c; 
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
        } catch (Exception e) {
            system.debug(e);
        }
	}

	public static void put(namle__Google_Calendar_Account__c gAccount, String searchValue) {
		system.debug(gAccount);
        nleGoogleAPISetting__c googleApiSetting = nleGoogleAPISetting__c.getOrgDefaults();
        if (string.isBlank(googleApiSetting.Calendar_API_Key__c)) {
            return;
        }
        system.debug(googleApiSetting);
		
		String spreadsheetId = '13Mc5Cj3JMXfgzvGoFYsdNwpGL9FGaWbX3Erd_zjJ7oU';
		String range = 'R2:R2';
		//String searchValue = 'kcubine@ccah.com';
		String body = '{ "valueInputOption": "USER_ENTERED", "data": [ { "values": [ [ "' + searchValue + '" ] ], "range": "' + range + '" } ] }';
		String Base_URI = 'https://sheets.googleapis.com/v4/spreadsheets/';

		String GET_URI = Base_URI + spreadsheetId + '/values:batchUpdate' + '?key=' + googleApiSetting.Calendar_API_Key__c + '&access_token=' + gAccount.namle__Calendar_Access_Token__c; 
		system.debug(GET_URI);
		Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(GET_URI);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setbody(body);
        request.setTimeout(60000);

        try {
        	HttpResponse response = http.send(request);

            if (response.getStatusCode() != 201) {
			    System.debug('The status code returned was not expected: ' +
			        response.getStatusCode() + ' ' + response.getStatus());
			} else {
			    System.debug(response.getBody());
			}
        } catch (Exception e) {
            system.debug(e);
        }
	}

	public static void doSreach(namle__Google_Calendar_Account__c gAccount, String searchValue) {	
		put(gAccount, searchValue);
		get(gAccount);
	}


}