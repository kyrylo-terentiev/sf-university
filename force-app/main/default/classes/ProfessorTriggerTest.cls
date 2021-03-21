@isTest
private class ProfessorTriggerTest {

    static final Integer ACCOUNT_NUM = 5;

    @testSetup 
    static void setup() {
        List<Account> accList = TestObjectFactory.createAccounts(ACCOUNT_NUM);
        insert accList;
    }

    @isTest 
    static void testInsertSuccess() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        Professor__c prof = TestObjectFactory.createProfessor(acc);
        insert prof;
        Professor__c profAfter = [SELECT Name, Account__c FROM Professor__c WHERE Id = :prof.Id];
        System.assertEquals(acc.Id, profAfter.Account__c, 'Professor should have master account');
        System.assertEquals(acc.Name, profAfter.Name, 'Professor name should equal to master Account name');
    }

    @isTest 
    static void testInsertFailure() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        Professor__c prof1 = TestObjectFactory.createProfessor(acc);
        insert prof1;
        Professor__c prof2 = TestObjectFactory.createProfessor(acc);
        Boolean isThrown = false;
        try {
            insert prof2;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest
    static void testUpdateSuccess() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        Professor__c prof = TestObjectFactory.createProfessor(acc);
        insert prof;
        prof.IsActive__c = false;
        Boolean isThrown = false;
        try {
            update prof;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    @isTest
    static void testUndeleteSuccess() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        Professor__c prof = TestObjectFactory.createProfessor(acc);
        insert prof;
        delete prof;
        Boolean isThrown = false;
        try {
            undelete prof;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }
}