@isTest
global class nleGoogleCalendarCallouts_MockTest implements HttpCalloutMock {
    
    global string calloutMethod {get;set;}
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        
        if (calloutMethod == 'createEvent' || calloutMethod == 'updateEvent') {
            res.setHeader('Content-Type', 'application/json');
            nleGoogleData.Item result = new nleGoogleData.Item();
            result.id = 'id';
            result.summary = 'event summary';
            res.setBody(Json.serialize(result));
            res.setStatusCode(200);
        } 
        else if (calloutMethod == 'createEvent_Error' || calloutMethod == 'updateEvent_Error') {
            res.setHeader('Content-Type', 'application/json');
            nleGoogleData.Item result = new nleGoogleData.Item();
            res.setBody(Json.serialize(result));
            res.setStatusCode(200);
        }
        else if (calloutMethod == 'getCalendar') {
            res.setHeader('Content-Type', 'application/json');
            nleGoogleData.Calendar result = new nleGoogleData.Calendar();
            nleGoogleData.Item item1 = new nleGoogleData.Item();
            item1.id = 'namle__Google_Event_ID__c';
            item1.updated = system.now().addMinutes(-1);
            item1.summary = 'test google event';
            item1.start.dateTimeValue = system.now();
            item1.eventEnd.dateTimeValue = system.now().addHours(1);
            List<nleGoogleData.Attendee> attendees = new List<nleGoogleData.Attendee>();
            nleGoogleData.Attendee attendee = new nleGoogleData.Attendee();
            attendee.email = 'test1@salesforce.com';
            attendees.add(attendee);
            item1.attendees = attendees;
            result.items.add(item1);
            res.setBody(Json.serialize(result));
            res.setStatusCode(200);
        }
        else if (calloutMethod == 'getCalendarList') {
            res.setHeader('Content-Type', 'application/json');
            nleGoogleData.CalendarList result = new nleGoogleData.CalendarList();
            nleGoogleData.CalendarListItem item1 = new nleGoogleData.CalendarListItem();
            item1.primary = true;
            item1.selected = true;
            item1.id = 'item1id';
            item1.description = 'item1id';
            item1.summary = 'item1id';
            result.items.add(item1);
            res.setBody(Json.serialize(result));
            res.setStatusCode(200);
        }
        else if (calloutMethod == 'refreshToken') {
            res.setHeader('Content-Type', 'application/json');
            RefreshTokenObject refreshToken = new RefreshTokenObject();
            refreshToken.access_token = 'ya29.pAKW8SB6cw6C7KYC4bxBazDz-1rsaTUNVU-VWD73IZ8bWkJ4t3N3hOC7r7j0V2j_0g';
            refreshToken.token_type = 'Bearer';
            refreshToken.expires_in = 3600;
            res.setBody(Json.serialize(refreshToken));
            res.setStatusCode(200);
        }
        
        return res;
    }
    
    public class RefreshTokenObject {
        public string access_token {get;set;}
        public string token_type {get;set;}
        public integer expires_in {get;set;}	
    }
    
}