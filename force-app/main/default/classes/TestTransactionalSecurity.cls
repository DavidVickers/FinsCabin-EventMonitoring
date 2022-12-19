@isTest
public class TestTransactionalSecurity {
    //TODO
    // create 1 contact with vip flag = true;
    // Get id
    // Fake testevent.Records json
    //
    @testSetup static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            testAccts.add(new Account(Name = 'TestAcct'+i));
        }
        insert testAccts;
        List<Contact> testContacts = new List<Contact>();
        for(Integer i=0;i<1;i++) {
            testContacts.add(new Contact(FirstName = 'John'+i, lastName = 'Doe' + i, Vip__c = true));
        }
        insert testContacts;
    }
    
    static testMethod void testReportEventPositiveTestCase() {
        // set up our event and its field values
        // 
        List<contact> lc = [SELECT id from Contact];
        string cID = lc[0].id;
        String myrep = '{"totalSize":4,"rows":[{"datacells":["0014w00003d4Ec1AAE","' + cId + '","0054w00000BxW2EAAV"]}]}';
        ReportEvent testEvent = new ReportEvent();
        testEvent.QueriedEntities = 'Contact';
        testEvent.RowsProcessed = 1;
        testevent.Records = myrep;
        
        // test that the Apex returns true for this event
        CabinTransactionalSec2  eventCondition = new CabinTransactionalSec2();
         System.assert(eventCondition.evaluate(testEvent));   
    }
}