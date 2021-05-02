@isTest
private class StudentGroupMemberTriggerTest {
    @testSetup 
    static void setup() {
        Account acc = TestObjectFactory.createAccount();
        insert acc;
        Student__c stud = TestObjectFactory.createStudent(acc);
        insert stud;
        Professor__c prof = TestObjectFactory.createProfessor(acc);
        insert prof;
        Faculty__c fac = TestObjectFactory.createFaculty(prof);
        insert fac;
        Department__c dep = TestObjectFactory.createDepartment(fac, prof);
        insert dep;
    }

    @isTest 
    static void testInsertSuccess() {
        Department__c dep = getTestDepartment();
        Student__c stud = getTestStudent();
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup(dep);
        insert studGroup;
        List<StudentGroupMember__c> members = TestObjectFactory.createStudentGroupMembers(studGroup, new List<Student__c>{stud});
        Boolean isThrown = false;
        try {
            insert members;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    @isTest 
    static void testInsertInactiveGroupFailure() {
        Department__c dep = getTestDepartment();
        Student__c stud = getTestStudent();
        stud.IsActive__c = false;
        update stud;
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup(dep);
        insert studGroup;
        List<StudentGroupMember__c> members = TestObjectFactory.createStudentGroupMembers(studGroup, new List<Student__c>{stud});
        Boolean isThrown = false;
        try {
            insert members;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest 
    static void testInsertInactiveStudentFailure() {
        Department__c dep = getTestDepartment();
        Student__c stud = getTestStudent();
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup(dep);
        studGroup.IsActive__c = false;
        insert studGroup;
        List<StudentGroupMember__c> members = TestObjectFactory.createStudentGroupMembers(studGroup, new List<Student__c>{stud});
        Boolean isThrown = false;
        try {
            insert members;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest 
    static void testInsertDuplicateFailure() {
        Department__c dep = getTestDepartment();
        Student__c stud = getTestStudent();
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup(dep);
        insert studGroup;
        List<StudentGroupMember__c> members = TestObjectFactory.createStudentGroupMembers(studGroup, new List<Student__c>{stud});
        insert members;
        List<StudentGroupMember__c> duplMembers = TestObjectFactory.createStudentGroupMembers(studGroup, new List<Student__c>{stud});
        Boolean isThrown = false;
        try {
            insert duplMembers;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest 
    static void testUpdateInactivate() {
        Department__c dep = getTestDepartment();
        Student__c stud = getTestStudent();
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup(dep);
        insert studGroup;
        List<StudentGroupMember__c> members = TestObjectFactory.createStudentGroupMembers(studGroup, new List<Student__c>{stud});
        insert members;
        studGroup.HeadOfGroup__c = stud.Id;
        update studGroup;
        for (StudentGroupMember__c member : members) {
            member.IsActive__c = false;
        }
        Boolean isThrown = false;
        try {
            update members;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    @isTest 
    static void testUndeleteSuccess() {
        Department__c dep = getTestDepartment();
        Student__c stud = getTestStudent();
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup(dep);
        insert studGroup;
        List<StudentGroupMember__c> members = TestObjectFactory.createStudentGroupMembers(studGroup, new List<Student__c>{stud});
        insert members;
        delete members;
        Boolean isThrown = false;
        try {
            undelete members;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    static Student__c getTestStudent() {
        return [SELECT Id, Name, IsActive__c FROM Student__c LIMIT 1];
    }

    static Department__c getTestDepartment() {
        return [SELECT Id, IsActive__c FROM Department__c LIMIT 1];
    }
}