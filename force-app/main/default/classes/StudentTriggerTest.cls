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
    static void testUpdateChildren() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        String validStudentId = 'AA00000000';
        Student__c studBefore = TestObjectFactory.createStudent(acc, validStudentId);
        insert studBefore;
        StudentGroup__c groupBefore = TestObjectFactory.createStudentGroup(studBefore);
        insert groupBefore;
        List<StudentGroupMember__c> membersBefore = TestObjectFactory.createStudentGroupMembers(groupBefore, new List<Student__c>{studBefore});
        insert membersBefore;
        Set<Id> memberIdSet = new Set<Id>();
        for (StudentGroupMember__c member : membersBefore) {
            memberIdSet.add(member.Id);
        }
        studBefore.IsActive__c = false;
        Boolean isThrown = false;
        try {
            update studBefore;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
        Student__c studAfter = [SELECT IsActive__c FROM Student__c WHERE Id = :studBefore.Id];
        List<StudentGroupMember__c> membersAfter = [SELECT IsActive__c FROM StudentGroupMember__c WHERE Id IN :memberIdSet];
        for (StudentGroupMember__c member : membersAfter) {
            System.assertEquals(studAfter.IsActive__c, member.IsActive__c, 'Group Member should be deactivated with the Student');
        }
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