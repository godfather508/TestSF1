public class NewCaseListController {
    public List<Case> getNewCases() {
        List<Case> cs = [SELECT Id, CaseNumber FROM Case WHERE 	Status='New' ];
        return cs;
    }

}