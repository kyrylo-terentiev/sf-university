@isTest
private class StudentTriggerTest {

    @testSetup 
    static void setup() {
        Account acc = TestObjectFactory.createAccount();
        insert acc;
    }

    @isTest 
    static void testInsertSuccess() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        String validStudentId = 'AA00000000';
        Student__c studBefore = TestObjectFactory.createStudent(acc, validStudentId);
        Boolean isThrown = false;
        try {
            insert studBefore;
        } catch (Exception e) {
            isThrown = true;
        }
        Student__c studAfter = [SELECT Name, Account__c FROM Student__c WHERE Id = :studBefore.Id];
        System.assert(!isThrown, 'Exception not expected');
        System.assertEquals(acc.Id, studAfter.Account__c, 'Student should have master account');
        System.assertEquals(acc.Name, studAfter.Name, 'Student name should equal to master account name');
    }

    @isTest 
    static void testInsertFailure() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        String invalidStudentId = 'AA********';
        Student__c stud = TestObjectFactory.createStudent(acc, invalidStudentId);
        Boolean isThrown = false;
        try {
            insert stud;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest 
    static void testUpdateSuccess() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        String validStudentId = 'AA00000000';
        Student__c stud = TestObjectFactory.createStudent(acc, validStudentId);
        insert stud;
        stud.FormOfStudy__c = 'Part-Time';
        Boolean isThrown = false;
        try {
            update stud;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    @isTest 
    static void testUndeleteSuccess() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        String validStudentId = 'AA00000000';
        Student__c stud = TestObjectFactory.createStudent(acc, validStudentId);
        insert stud;
        delete stud;
        Boolean isThrown = false;
        try {
            undelete stud;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }
}