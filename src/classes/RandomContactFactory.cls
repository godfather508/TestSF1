public class RandomContactFactory {
    public static List<Contact> generateRandomContacts(Integer num, String name) {
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0;i<num;i++) {
            Contact c = new Contact(FirstName=name + ' ' + i);
            contacts.add(c);
        }
		return contacts;
	}
}