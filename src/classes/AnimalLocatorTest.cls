@isTest
private class AnimalLocatorTest {
	@isTest static void testGetAnimalNameById() {
    // Set mock callout class 
    Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock()); 
    // This causes a fake response to be sent
    // from the class that implements HttpCalloutMock. 
    String actualValue = AnimalLocator.getAnimalNameById(1);
    String expectedValue = 'chicken';///Test
    System.assertEquals(actualValue, expectedValue);
}
}