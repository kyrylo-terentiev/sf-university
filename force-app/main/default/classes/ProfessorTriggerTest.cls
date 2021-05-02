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
        System.assertEquals(acc.Name, profAfter.Name, 'Professor name should equal to master account name');
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

    @isTest
    static void testUpdateChildrenNames() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        Professor__c prof = TestObjectFactory.createProfessor(acc);
        insert prof;
        Faculty__c fac = TestObjectFactory.createFaculty(prof);
        insert fac;
        Department__c dep = TestObjectFactory.createDepartment(fac, prof);
        insert dep;
        DepartmentProfessor__c depProf = TestObjectFactory.createDepartmentProfessor(dep, prof);
        insert depProf;
        acc.FirstName__c = 'NewTestFirstName';
        Test.startTest();
        update acc;
        Test.stopTest();
        Account accAfter = [SELECT Name FROM Account WHERE Id = :acc.Id];
        Professor__c profAfter = [SELECT Name FROM Professor__c WHERE Id = :prof.Id];
        System.assertEquals(accAfter.Name, profAfter.Name, 'Updated Professor name should equal to Account name');
    }

    @isTest
    static void testInactivateChildren() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        Professor__c prof = TestObjectFactory.createProfessor(acc);
        insert prof;
        Faculty__c fac = TestObjectFactory.createFaculty(prof);
        insert fac;
        Department__c dep = TestObjectFactory.createDepartment(fac, prof);
        insert dep;
        DepartmentProfessor__c depProf = TestObjectFactory.createDepartmentProfessor(dep, prof);
        insert depProf;
        prof.IsActive__c = false;
        Test.startTest();
        update prof;
        Test.stopTest();
        Professor__c profAfter = [SELECT IsActive__c FROM Professor__c WHERE Id = :prof.Id];
        DepartmentProfessor__c depProfAfter = [SELECT IsActive__c FROM DepartmentProfessor__c WHERE Id = :depProf.Id];
        System.assertEquals(profAfter.IsActive__c, depProfAfter.IsActive__c, 'Department Professor should be deactivated with the Professor');
    }
}