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
        Course__c course = TestObjectFactory.createCourse(fac);
        insert course;
        DepartmentCourse__c depCourse = TestObjectFactory.createDepartmentCourse(dep, course);
        insert depCourse;
        DepartmentProfessor__c depProf = TestObjectFactory.createDepartmentProfessor(dep, prof);
        insert depProf;
        DepartmentCourseProfessor__c depCourseProf = TestObjectFactory.createDepartmentCourseProfessor(dep, course, prof);
        insert depCourseProf;
        Lesson__c lsn = TestObjectFactory.createLesson(dep, course, prof);
        insert lsn;
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
        System.assert(!isThrown, System.Label.TestExceptionNotExpected);
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
        System.assert(isThrown, System.Label.TestExceptionExpected);
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
        System.assert(isThrown, System.Label.TestExceptionExpected);
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
        System.assert(isThrown, System.Label.TestExceptionExpected);
    }

    @isTest 
    static void testUpdateInactivate() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Student__c stud = getTestStudent();
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup(dep);
        insert studGroup;
        List<StudentGroupMember__c> members = TestObjectFactory.createStudentGroupMembers(studGroup, new List<Student__c>{stud});
        insert members;
        DepartmentCourseGroup__c courseGroup = TestObjectFactory.createDepartmentCourseGroup(course, studGroup);
        insert courseGroup;
        Lesson__c lsn = getTestLesson();
        DepartmentCourseGroupLesson__c groupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        insert groupLsn;
        studGroup.HeadOfGroup__c = stud.Id;
        update studGroup;
        for (StudentGroupMember__c member : members) {
            member.IsActive__c = false;
        }
        Test.startTest();
        Boolean isThrown = false;
        try {
            update members;
        } catch (Exception e) {
            isThrown = true;
        }
        Test.stopTest();
        System.assert(!isThrown, System.Label.TestExceptionNotExpected);
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
        System.assert(!isThrown, System.Label.TestExceptionNotExpected);
    }

    static Student__c getTestStudent() {
        return [SELECT Id, Name, IsActive__c FROM Student__c LIMIT 1];
    }

    static Department__c getTestDepartment() {
        return [SELECT Id, IsActive__c FROM Department__c LIMIT 1];
    }

    static Course__c getTestCourse() {
        return [SELECT Id, IsActive__c FROM Course__c LIMIT 1];
    }

    static Lesson__c getTestLesson() {
        return [SELECT Id, IsActive__c FROM Lesson__c LIMIT 1];
    }
}