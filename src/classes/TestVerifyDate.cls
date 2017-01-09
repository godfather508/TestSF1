@isTest
public class TestVerifyDate {
    @isTest static void testCheckDatesDateWithin30Days() {
        Date date1 = Date.newInstance(2012, 12, 8);
        Date date2 = date1.addDays(10);
        Date result = VerifyDate.CheckDates(date1, date2);
        System.assertEquals(date2, result);
    }
    
     @isTest static void testCheckDatesDateOver30Days() {
        Date date1 = Date.newInstance(2012, 12, 8);
        Date date2 = date1.addDays(-1);
        Date result = VerifyDate.CheckDates(date1, date2);
        Integer totalDays = Date.daysInMonth(date1.year(), date1.month());
        Date lastDay = Date.newInstance(date1.year(), date1.month(), totalDays);
        System.assertEquals(lastDay, result);
    }
        
    @isTest static void testDateWithin30DaysTrue() {
        Date date1 = Date.newInstance(2012, 12, 8);
        Date date2 = date1.addDays(31);
        Date result = VerifyDate.CheckDates(date1, date2);
        Integer totalDays = Date.daysInMonth(date1.year(), date1.month());
        Date lastDay = Date.newInstance(date1.year(), date1.month(), totalDays);
        System.assertEquals(lastDay, result);
    }
}