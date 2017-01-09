public class AccountHandler {
    public static Account insertNewAccount(String name) {
        Account a = new Account(Name=name);
        try {
        	insert a;    
        } catch (DmlException e) {
            return null;        
    	}
        return a;
    }
}