@isTest
private class StudentGroupTriggerTest {

    @testSetup 
    static void setup() {
        Account acc = TestObjectFactory.createAccount();
        insert acc;
        Professor__c prof = TestObjectFactory.createProfessor(acc);
        insert prof;
        Faculty__c fac = TestObjectFactory.createFaculty(prof);
        insert fac;
        Department__c dep = TestObjectFactory.createDepartment(fac, prof);
        insert dep;
    }

    @isTest 
    static void testInsertUpdateSuccess() {
        Account acc = getTestAccount();
        Student__c head = TestObjectFactory.createStudent(acc);
        insert head;
        Professor__c courator = getTestProfessor();
        Department__c dep = getTestDepartment();
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup(dep);
        insert studGroup;
        List<StudentGroupMember__c> groupMembers = TestObjectFactory.createStudentGroupMembers(studGroup, new List<Student__c>{head});
        insert groupMembers;
        studGroup.HeadOfGroup__c = head.Id;
        DepartmentProfessor__c depProf = TestObjectFactory.createDepartmentProfessor(dep, courator);
        insert depProf; 
        studGroup.GroupCourator__c = courator.Id;
        Boolean isThrown = false;
        try {
            update studGroup;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    @isTest 
    static void testInsertFailureInactiveHeadInsert() {
        Account acc = getTestAccount();
        Department__c dep = getTestDepartment();
        Student__c head = TestObjectFactory.createStudent(acc);
        insert head;
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup(dep);
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
        Account acc = getTestAccount();
        Department__c dep = getTestDepartment();
        Student__c head = TestObjectFactory.createStudent(acc);
        insert head;
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup(dep);
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
        Account acc = getTestAccount();
        Department__c dep = getTestDepartment();
        Student__c head = TestObjectFactory.createStudent(acc);
        insert head;
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup(dep);
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
    static void testInsertInactiveCourator() {
        Account acc = getTestAccount();
        Professor__c prof = getTestProfessor();
        Faculty__c fac = getTestFaculty();
        Department__c dep = getTestDepartment();
        DepartmentProfessor__c depProf = TestObjectFactory.createDepartmentProfessor(dep, prof);
        depProf.IsActive__c = false;
        insert depProf; 
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup(dep);
        insert studGroup;
        studGroup.GroupCourator__c = prof.Id;
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
        Account acc = getTestAccount();
        Department__c dep = getTestDepartment();
        Student__c stud = TestObjectFactory.createStudent(acc);
        insert stud;
        StudentGroup__c groupBefore = TestObjectFactory.createStudentGroup(dep);
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
        Faculty__c fac = getTestFaculty();
        Course__c course = TestObjectFactory.createCourse(fac);
        insert course;
        Department__c dep = getTestDepartment();
        Account acc = getTestAccount();
        Student__c stud = TestObjectFactory.createStudent(acc);
        insert stud;
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup(dep);
        insert studGroup;
        List<StudentGroupMember__c> groupMembers = TestObjectFactory.createStudentGroupMembers(studGroup, new List<Student__c>{stud});
        insert groupMembers;
        studGroup.HeadOfGroup__c = stud.Id;
        update studGroup;
        DepartmentCourse__c depCourse = TestObjectFactory.createDepartmentCourse(dep, course);
        insert depCourse;
        DepartmentCourseGroup__c depCourseGroup = TestObjectFactory.createDepartmentCourseGroup(course, studGroup);
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
        Account acc = getTestAccount();
        Department__c dep = getTestDepartment();
        Student__c head = TestObjectFactory.createStudent(acc);
        insert head;
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup(dep);
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

    static Account getTestAccount() {
        return [SELECT Id, IsActive__c FROM Account LIMIT 1];
    }

    static Department__c getTestDepartment() {
        return [SELECT Id, IsActive__c FROM Department__c LIMIT 1];
    }

    static Faculty__c getTestFaculty() {
        return [SELECT Id, IsActive__c FROM Faculty__c LIMIT 1];
    }

    static Professor__c getTestProfessor() {
        return [SELECT Id, IsActive__c FROM Professor__c LIMIT 1];
    }
}