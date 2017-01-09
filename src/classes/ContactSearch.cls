public class ContactSearch {
    public static List<Contact> searchForContacts(String lastName, String mailingPostCode) {
        List<Contact> contacts = [SELECT Name, Id FROM Contact WHERE LastName=:lastName AND MailingPostalCode=:mailingPostCode];
        return contacts;
    }
}