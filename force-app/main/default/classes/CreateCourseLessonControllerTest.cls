@isTest
private class CreateCourseLessonControllerTest {
    @testSetup 
    static void setup() {
        Account acc = TestObjectFactory.createAccount();
        insert acc;
        Professor__c prof = TestObjectFactory.createProfessor(acc);
        insert prof;
        Student__c stud = TestObjectFactory.createStudent(acc);
        insert stud;
        Faculty__c fac = TestObjectFactory.createFaculty(prof);
        insert fac;
        Department__c dep = TestObjectFactory.createDepartment(fac, prof);
        insert dep;
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup(dep);
        insert studGroup;
        List<StudentGroupMember__c> groupMembers = TestObjectFactory.createStudentGroupMembers(studGroup, new List<Student__c>{stud});
        insert groupMembers;
        Course__c course = TestObjectFactory.createCourse(fac);
        insert course;
        DepartmentCourse__c depCourse = TestObjectFactory.createDepartmentCourse(dep, course);
        insert depCourse;
        DepartmentProfessor__c depProf = TestObjectFactory.createDepartmentProfessor(dep, prof);
        insert depProf;
        DepartmentCourseProfessor__c depCourseProf = TestObjectFactory.createDepartmentCourseProfessor(dep, course, prof);
        insert depCourseProf;
        DepartmentCourseGroup__c depCourseGroup = TestObjectFactory.createDepartmentCourseGroup(course, studGroup);
        insert depCourseGroup;
        Lesson__c lsn = TestObjectFactory.createLesson(dep, course, prof);
        insert lsn;
    }

    @isTest 
    static void testGetAvailableGroupsForLessonSuccess() {
        Lesson__c lsn = getTestLesson();
        StudentGroup__c studGroup = getTestStudentGroup();
        Test.startTest();
        Boolean isThrown = false;
        Map<String, Id> res;
        try {
            res = CreateCourseLessonController.getAvailableGroupsForLesson(lsn.Id);
        } catch (Exception e) {
            isThrown = true;
        }
        Test.stopTest();
        System.assert(!isThrown, System.Label.TestExceptionNotExpected);
        System.assertNotEquals(null, res, 'Result expected');
        System.assertEquals(res.size(), 1, 'One available group expected');
        System.assertEquals(res.get(studGroup.Name), studGroup.Id, 'Available group expected');
    }

    @isTest
    static void testGetAvailableGroupsForLessonFailure() {
        Lesson__c lsn = getTestLesson();
        DepartmentCourseGroup__c depCourseGroup = getTestDepartmentCourseGroup();
        delete depCourseGroup;
        Test.startTest();
        Boolean isThrown = false;
        Map<String, Id> res;
        try {
            res = CreateCourseLessonController.getAvailableGroupsForLesson(lsn.Id);
        } catch (Exception e) {
            isThrown = true;
        }
        Test.stopTest();
        System.assert(isThrown, System.Label.TestExceptionExpected);
    }

    @isTest
    static void testGetAttendingGroupsForLesson() {
        Lesson__c lsn = getTestLesson();
        StudentGroup__c studGroup = getTestStudentGroup();
        DepartmentCourseGroupLesson__c groupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        insert groupLsn;
        Test.startTest();
        Boolean isThrown = false;
        Map<String, Id> res;
        try {
            res = CreateCourseLessonController.getAttendingGroupsForLesson(lsn.Id);
        } catch (Exception e) {
            isThrown = true;
        }
        Test.stopTest();
        System.assert(!isThrown, System.Label.TestExceptionNotExpected);
        System.assertNotEquals(null, res, 'Result expected');
        System.assertEquals(res.size(), 1, 'One attending group expected');
        System.assertEquals(res.get(studGroup.Name), studGroup.Id, 'Attending group expected');
    }

    @isTest
    static void testAddGroupsForLesson() {
        Lesson__c lsn = getTestLesson();
        StudentGroup__c studGroup = getTestStudentGroup();
        Test.startTest();
        Boolean isThrown = false;
        List<DepartmentCourseGroupLesson__c> groupLsnList;
        try {
            groupLsnList = CreateCourseLessonController.addGroupsForLesson(lsn.Id, new List<Id>{studGroup.Id});
        } catch (Exception e) {
            isThrown = true;
        }
        Test.stopTest();
        System.assert(!isThrown, System.Label.TestExceptionNotExpected);
        System.assertEquals(1, groupLsnList.size(), 'One attending group expected');
        System.assertEquals(studGroup.Id, groupLsnList[0].StudentGroup__c, 'Attending group expected');
    }

    static Lesson__c getTestLesson() {
        return [SELECT Id, IsActive__c FROM Lesson__c LIMIT 1];
    }

    static StudentGroup__c getTestStudentGroup() {
        return [SELECT Id, Name, IsActive__c FROM StudentGroup__c LIMIT 1];
    }

    static DepartmentCourseGroup__c getTestDepartmentCourseGroup() {
        return [SELECT Id, IsActive__c FROM DepartmentCourseGroup__c LIMIT 1];
    }

    static DepartmentCourseGroupLesson__c getTestDepartmentCourseGroupLesson() {
        return [SELECT Id, IsActive__c FROM DepartmentCourseGroupLesson__c LIMIT 1];
    }
}