@isTest
private class ParkLocatorTest {
    @isTest static void testCallout() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new ParkServiceMock());
        // Call the method that invokes a callout
        Double x = 1.0;
        Double y = 2.0;
        List<String> expected = new List<String>{'Hamburg Wadden Sea National Park'};
        List<String> actual = ParkLocator.country('Germany');
        // Verify that a fake result is returned
        System.assertEquals(expected[0], actual[0]); 
    }
}