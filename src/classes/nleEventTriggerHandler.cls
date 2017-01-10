public class nleEventTriggerHandler {
    public static void afterInsert(List<Event> newEvents) {
        afterInsertUpdate(null, newEvents);
    }
    
    public static void afterUpdate(Map<Id, Event> oldEvents, List<Event> newEvents) {
        afterInsertUpdate(oldEvents, newEvents);
    }
    
    private static void afterInsertUpdate(Map<Id, Event> oldEvents, List<Event> newEvents) {
        List<Id> contactIds = new List<Id>();
        for (Event newEvent : newEvents) {
            
            Id contactId = newEvent.WhoId;
            if (contactId == null || contactId.getSobjectType() != Contact.SobjectType) {
                continue;
            }
            // team meeting
            if (oldEvents != null) {
                Event oldEvent = oldEvents.get(newEvent.Id);
                if (oldEvent.StartDateTime != newEvent.StartDateTime) {
                    contactIds.add(contactId);
                }
            } else {
                contactIds.add(contactId);
            }
        }


        /// Line 2
        
        List<Contact> contacts = new List<Contact>();
        List<SObject> mapEvents = [SELECT WhoId contactId, Max(StartDateTime) MaxMeetingDate FROM Event WHERE WhoId IN :contactIds GROUP BY WhoId];
        Map<String, Datetime> mapContactDatetime = new Map<String, Datetime>();
        for (SObject event : mapEvents) {
            mapContactDatetime.put((String)event.get('contactId'), (Datetime)event.get('MaxMeetingDate'));
        }
        if (mapContactDatetime.size() > 0) {
            contacts = [SELECT Id, nleLast_Meeting_Date__c FROM Contact WHERE Id IN :mapContactDatetime.keySet()];
        }

        // nle3

        for (Contact contact : contacts) {
            contact.nleLast_Meeting_Date__c = mapContactDatetime.get(contact.Id);
        }
        if (contacts.size() > 0) {
            UPDATE contacts;
        }
    }
}