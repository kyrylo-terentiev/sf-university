@isTest
private class StudentGroupTriggerTest {

    @testSetup 
    static void setup() {
        Account acc = TestObjectFactory.createAccount();
        insert acc;
    }

    @isTest 
    static void testInsertSuccess() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        Student__c head = TestObjectFactory.createStudent(acc);
        insert head;
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup();
        Boolean isThrown = false;
        try {
            insert studGroup;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    @isTest 
    static void testUpdateChildren() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        Student__c stud = TestObjectFactory.createStudent(acc);
        insert stud;
        StudentGroup__c groupBefore = TestObjectFactory.createStudentGroup();
        insert groupBefore;
        List<StudentGroupMember__c> membersBefore = TestObjectFactory.createStudentGroupMembers(groupBefore, new List<Student__c>{stud});
        insert membersBefore;
        Set<Id> memberIdSet = new Set<Id>();
        for (StudentGroupMember__c member : membersBefore) {
            memberIdSet.add(member.Id);
        }
        groupBefore.IsActive__c = false;
        Boolean isThrown = false;
        try {
            update groupBefore;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
        StudentGroup__c groupAfter = [SELECT IsActive__c FROM StudentGroup__c WHERE Id = :groupBefore.Id];
        List<StudentGroupMember__c> membersAfter = [SELECT IsActive__c FROM StudentGroupMember__c WHERE Id IN :memberIdSet];
        for (StudentGroupMember__c member : membersAfter) {
            System.assertEquals(groupAfter.IsActive__c, member.IsActive__c, 'Group Member should be deactivated with the Group');
        }
    }

    @isTest 
    static void testUndeleteSuccess() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        Student__c head = TestObjectFactory.createStudent(acc);
        insert head;
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup();
        insert studGroup;
        delete studGroup;
        Boolean isThrown = false;
        try {
            undelete studGroup;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }
}
