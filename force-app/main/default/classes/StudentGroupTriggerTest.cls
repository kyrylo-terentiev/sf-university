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
        Student__c stud = TestObjectFactory.createStudent(acc);
        insert stud;
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
    static void testInsertFailureInactiveHeadInsert() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        Student__c head = TestObjectFactory.createStudent(acc);
        insert head;
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup();
        studGroup.HeadOfGroup__c = head.Id;
        Boolean isThrown = false;
        try {
            insert studGroup;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest 
    static void testInsertFailureHeadNotInGroup() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        Student__c head = TestObjectFactory.createStudent(acc);
        insert head;
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup();
        insert studGroup;
        studGroup.HeadOfGroup__c = head.Id;
        Boolean isThrown = false;
        try {
            update studGroup;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest 
    static void testInsertFailureInactiveHead() {
        Account acc = TestObjectFactory.getTestAccounts()[0];
        Student__c head = TestObjectFactory.createStudent(acc);
        insert head;
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup();
        insert studGroup;
        List<StudentGroupMember__c> groupMembers = TestObjectFactory.createStudentGroupMembers(studGroup, new List<Student__c>{head});
        groupMembers[0].IsActive__c = false;
        insert groupMembers[0];
        studGroup.HeadOfGroup__c = head.Id;
        Boolean isThrown = false;
        try {
            update studGroup;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest 
    static void testUpdateGroupMembers() {
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
    static void testUpdateDepartmentCourseGroups() {
        Faculty__c fac = new Faculty__c(Name = 'TestFaculty');
        insert fac;
        Course__c course = TestObjectFactory.createCourse(fac);
        insert course;
        Department__c dep = new Department__c(Name = 'TestDepartment', Faculty__c = fac.Id);
        insert dep;
        Account acc = TestObjectFactory.getTestAccounts()[0];
        Student__c stud = TestObjectFactory.createStudent(acc);
        insert stud;
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup();
        insert studGroup;
        List<StudentGroupMember__c> groupMembers = TestObjectFactory.createStudentGroupMembers(studGroup, new List<Student__c>{stud});
        insert groupMembers;
        studGroup.HeadOfGroup__c = stud.Id;
        update studGroup;
        DepartmentCourse__c depCourse = TestObjectFactory.createDepartmentCourse(dep, course);
        insert depCourse;
        DepartmentCourseGroup__c depCourseGroup = TestObjectFactory.createDepartmentCourseGroup(depCourse, studGroup);
        insert depCourseGroup;
        studGroup.IsActive__c = false;
        Boolean isThrown = false;
        try {
            update studGroup;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
        StudentGroup__c studGroupAfter = [SELECT IsActive__c FROM StudentGroup__c WHERE Id = :studGroup.Id];
        DepartmentCourseGroup__c depCourseGroupAfter = [SELECT IsActive__c FROM DepartmentCourseGroup__c WHERE Id = :depCourseGroup.Id];
        System.assertEquals(depCourseGroupAfter.IsActive__c, studGroupAfter.IsActive__c, 'Department course group should be inactivated with student group');
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
