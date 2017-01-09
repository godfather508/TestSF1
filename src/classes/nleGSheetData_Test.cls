@IsTest
public class nleGSheetData_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'  \"range\": \"NleNewMaster!A1\",'+
		'  \"majorDimension\": \"ROWS\",'+
		'  \"values\": ['+
		'    ['+
		'      \"Date Added\"'+
		'    ]'+
		'  ]'+
		'}';
		nleGSheetData obj = nleGSheetData.parse(json);
		System.assert(obj != null);
	}
}