public class nleGSheetData {
	public String range;
	public String majorDimension;
	public List<List<String>> values;

// Update	
	public static nleGSheetData parse(String json) {
		return (nleGSheetData) System.JSON.deserialize(json, nleGSheetData.class);
	}
}