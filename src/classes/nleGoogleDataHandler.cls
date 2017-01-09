public with sharing class nleGoogleDataHandler {    
    public static void updateEventsbyContact(nleGoogleData.CalloutResult result) {
        List<nleGoogleData.CalloutResult> lst = new List<nleGoogleData.CalloutResult>();
        lst.add(result);
        addEventsToContactsByCalloutResult(lst);
    }
    
    public static void updateEventsToContacts(List<nleGoogleData.CalloutResult> results) {
        addEventsToContactsByCalloutResult(results);
    }
    
    private static void addEventsToContactsByCalloutResult(List<nleGoogleData.CalloutResult> results) {
        List<Event> upsertEvents = new List<Event>();
        List<Event> delEvents = new List<Event>();

        Map<String, String> emailList = new Map<String, String>();
        List<String> googleEventIds = new List<String>();
        
        for (nleGoogleData.CalloutResult result : results) {
            if (result.Calendar == null) {
                continue;
            }
            
            List<nleGoogleData.Item> items = result.Calendar.items;
            if (items != null && items.size() > 0) {
                for (nleGoogleData.Item item : items) {
                    googleEventIds.add(item.Id);
                    if (item.attendees == null) {
                        continue;
                    }
                    for (nleGoogleData.Attendee attendee : item.attendees) {
                        emailList.put(attendee.email, attendee.email);
                    }
                }
            }
        }

        // Exist events
        List<Event> existEvents = [SELECT Id, WhoId, namle__Google_Event_ID__c FROM Event WHERE namle__Google_Event_ID__c IN :googleEventIds];
        Map<String, Map<String, Event>> existMapEvents = new Map<String, Map<String, Event>>();
        for (Event existEvent : existEvents) {
            Map<String, Event> lst = existMapEvents.get(existEvent.namle__Google_Event_ID__c);
            if (lst == null) {
                lst = new Map<String, Event>();
            }
            lst.put(existEvent.WhoId, existEvent);
            existMapEvents.put(existEvent.namle__Google_Event_ID__c, lst);
        }
        
        // Base on exist contacts
        List<Contact> contacts = new List<Contact>();
        Map<String, Contact> mapContacts = new Map<String, Contact>();
        if (emailList.size() > 0) {
            contacts = [SELECT Id, Name, Account.Id, Email FROM Contact WHERE Email IN : emailList.values()];
            for (Contact contact : contacts) {
                mapContacts.put(contact.Email, contact);
            }
        }
        
        if (contacts.size() > 0) {
            for (nleGoogleData.CalloutResult result : results) {
                if (result.Calendar == null) {
                    continue;
                }
                
                List<nleGoogleData.Item> items = result.Calendar.items;
                for (nleGoogleData.Item item : items) {
                    if (item.attendees == null) {
                        continue;
                    }
                    Map<String, Event> lst = existMapEvents.get(item.id);

                    // Find NEW and UPDATE events
                    for (nleGoogleData.Attendee attendee : item.attendees) {
                        Contact contact = mapContacts.get(attendee.email);
                        if (contact != null) {
                            Event event = new Event(); 
                            if (lst != null) {
                                event = lst.get(contact.Id);
                                if (event == null) {
                                    event = new Event();
                                }
                            }

                            event.namle__Google_Event_ID__c = item.id;
                            event.namle__Google_Calendar_Client_Id__c = result.gAccount.namle__Calendar_Id__c;
                            event.StartDateTime = item.start.dateTimeValue;
                            event.EndDateTime = item.eventEnd.dateTimeValue;
                            event.Subject = item.summary;
                            event.description = item.description;
                            event.location = item.location;
                            event.namle__Status__c = item.status;
                            //event.namle__Html_Link__c = item.htmlLink;
                            event.WhoId = contact.Id;
                            event.WhatId = contact.Account.Id;  

                            upsertEvents.add(event);  
                        }
                    }
                }
            }
        }

        // Find DELETE events
        for (Event existEvent : existEvents) {
            Boolean isDelete = true;
            for (Event upsertEvent : upsertEvents) {
                if (existEvent.namle__Google_Event_ID__c == upsertEvent.namle__Google_Event_ID__c 
                    && existEvent.WhoId == upsertEvent.WhoId) {
                    isDelete = false;
                    continue;
                }
            }

            if (isDelete) {
                delEvents.add(existEvent);
            }
        }

        if (upsertEvents.size() > 0) {
            UPSERT upsertEvents;
        }

        if (delEvents.size() > 0) {
            DELETE delEvents;
        }
    }
}