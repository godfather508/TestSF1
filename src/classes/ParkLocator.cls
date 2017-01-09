public class ParkLocator {
    public static List<String> country(String names) {
        ParkService.ParksImplPort parkService = new ParkService.ParksImplPort();
        return parkService.byCountry(names);
    }
}