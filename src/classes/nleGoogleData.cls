global class nleGoogleData {
	global class CalloutResult {
        public Calendar Calendar {get;set;} // Google bye my love
        public Item GoogleEvent {get;set;}
        public CalendarList CalendarList {get;set;}
        public namle__Google_Calendar_Account__c gAccount {get;set;}
        public string AccessToken {get;set;}
        public integer ExpiresIn {get;set;}
        public boolean HasError {get;set;}
        public string ErrorMessage {get;set;}
        
        public CalloutResult() {
            this.HasError = false;
            this.ErrorMessage = '';
        }
    }
    
    global class Error {
        public integer code { get; set; }
        public string message { get; set; }
    }
    
    global class ErrorRootObject {
        public Error error { get; set; }
    }
    
    global class Start {
        public Date dateValue {get;set;}
        public DateTime dateTimeValue { get; set; }
    }
    
    global class EventEnd {
        public Date dateValue {get;set;}
        public DateTime dateTimeValue { get; set; }
    }
    
    global class Attendee {
        public string email { get;set; }
    }
    
    global class Item {
        public string id { get; set; }
        public string summary { get; set; }
        public string description { get; set; }
        public string location { get; set; }
        public Start start { get; set; }
        public String status { get; set; }
        public Datetime updated { get; set; }
        public EventEnd eventEnd { get; set; }
        public List<Attendee> attendees { get; set; }
        
        public Item() {
            start = new Start();
            eventEnd = new EventEnd();
            attendees = new List<Attendee>();
        }
    }
    
    global class Calendar {
        public string summary { get; set; }
        public string timeZone { get; set; }
        public List<Item> items { get; set; }
        
        public Calendar() {
            this.items = new List<Item>();
        }
    }
    
    global class CalendarListItem {
        public boolean primary { get; set; }
        public boolean selected { get; set; }
        public string summary { get; set; }
        public string timeZone { get; set; }
        public string id { get; set; }
        public string description { get; set; }
    }
    
    global class CalendarList {
        public List<CalendarListItem> items { get; set; }
        
        public CalendarList() {
            this.items = new List<CalendarListItem>();
        }
    }
}