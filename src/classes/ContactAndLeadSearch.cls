public class ContactAndLeadSearch {
    public static List<List< SObject>> searchContactsAndLeads(String textSearch){
        List<List< SObject>> result = [FIND :textSearch IN ALL FIELDS RETURNING Account(Name), Lead(FirstName,LastName)];
        return result;
    }
}