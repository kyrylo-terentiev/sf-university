@isTest
private class AccountTriggerTest {
    
    static final Integer ACCOUNT_NUM = 5;

    @testSetup
    static void setup() {
        List<Account> accList = TestObjectFactory.createAccounts(ACCOUNT_NUM);
        insert accList;
    }

    @isTest
    static void testInsertFailure() {
        Account acc = TestObjectFactory.createAccount();
        acc.FirstName__c = '123';
        Boolean isThrown = false;
        try {
            insert acc;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest
    static void testUpdateFailure() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        acc.FirstName__c = '123';
        Boolean isThrown = false;
        try {
            update acc;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest
    static void testUpdateSuccess() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        acc.FirstName__c = 'NewFirstName';
        Boolean isThrown = false;
        try {
            update acc;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    @isTest
    static void testUndelete() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        delete acc;
        Boolean isThrown = false;
        try {
            undelete acc;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    @isTest
    static void testDelete() {

    }

    @isTest
    static void testUpdateChildren() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        Professor__c prof = TestObjectFactory.createProfessor(acc);
        insert prof;
        acc.FirstName__c = 'NewTestFirstName';
        Test.startTest();
        update acc;
        Test.stopTest();
        Account accAfter = [SELECT Name FROM Account WHERE Id = :acc.Id];
        Professor__c profAfter = [SELECT Name FROM Professor__c WHERE Id = :prof.Id];
        System.assertEquals(accAfter.Name, profAfter.Name, 'Updated Professor name should equal to Account name');
    }
}