@isTest
private class LessonAttendanceControllerTest {
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
        DepartmentCourseGroupLesson__c depCourseGroupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        insert depCourseGroupLsn;
    }

    @isTest 
    static void testGetActiveAttendances() {
        Lesson__c lsn = getTestLesson();
        List<StudentLessonAttendance__c> attendances;
        Test.startTest();
        Boolean isThrown = false;
        try {
            attendances = LessonAttendanceController.getActiveAttendances(lsn.Id);
        } catch (Exception e) {
            isThrown = true;
        }
        Test.stopTest();
        System.assert(!isThrown, System.Label.TestExceptionNotExpected);
    }

    @isTest
    static void testUpdateAttendancesSuccess() {
        StudentLessonAttendance__c attendanceBefore = getTestAttendance();
        Test.startTest();
        Boolean isThrown = false;
        try {
            attendanceBefore.IsAttending__c = true;
            LessonAttendanceController.updateAttendances(JSON.serialize(new List<StudentLessonAttendance__c> {attendanceBefore}));
        } catch (Exception e) {
            isThrown = true;
        }
        Test.stopTest();
        System.assert(!isThrown, System.Label.TestExceptionNotExpected);
        StudentLessonAttendance__c attendanceAfter = getTestAttendance();
        System.assert(attendanceAfter.IsAttending__c, 'Update expected');
    }

    @isTest
    static void testUpdateAttendancesFailure() {
        Test.startTest();
        Boolean isThrown = false;
        try {
            StudentLessonAttendance__c attendance = new StudentLessonAttendance__c();
            LessonAttendanceController.updateAttendances(JSON.serialize(new List<StudentLessonAttendance__c> {attendance}));
        } catch (Exception e) {
            isThrown = true;
        }
        Test.stopTest();
        System.assert(isThrown, System.Label.TestExceptionExpected);
    }

    static Lesson__c getTestLesson() {
        return [SELECT Id, IsActive__c FROM Lesson__c LIMIT 1];
    }

    static StudentLessonAttendance__c getTestAttendance() {
        return [SELECT Id, IsActive__c, IsAttending__c FROM StudentLessonAttendance__c LIMIT 1];
    }
}