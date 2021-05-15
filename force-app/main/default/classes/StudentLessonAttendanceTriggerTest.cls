@isTest
private class StudentLessonAttendanceTriggerTest {
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
        StudentGroup__c studGroup = TestObjectFactory.createStudentGroup(dep);
        insert studGroup;
        DepartmentCourseGroup__c courseGroup = TestObjectFactory.createDepartmentCourseGroup(course, studGroup);
        insert courseGroup;
        Student__c stud = TestObjectFactory.createStudent(acc);
        insert stud;
        List<StudentGroupMember__c> groupMembers = TestObjectFactory.createStudentGroupMembers(studGroup, new List<Student__c> {stud});
        insert groupMembers;
    }

    @isTest 
    static void testInsertSuccess() {
        Student__c stud = getTestStudent();
        StudentGroup__c studGroup = getTestStudentGroup();
        StudentGroupMember__c groupMember = getTestStudentGroupMember();
        Lesson__c lsn = getTestLesson();
        DepartmentCourseGroupLesson__c groupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        Boolean isThrown = false;
        try {
            insert groupLsn;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
        StudentLessonAttendance__c attendance = getTestStudentLessonAttendance();
        System.assertEquals(stud.Id, attendance.Student__c, 'Attendance should be related to student');
        System.assertEquals(studGroup.Id, attendance.StudentGroup__c, 'Attendance should be related to student group');
        System.assertEquals(groupMember.Id, attendance.StudentGroupMember__c, 'Attendance should be related to student group member');
        System.assertEquals(groupLsn.Id, attendance.DepartmentCourseGroupLesson__c, 'Attendance should be related to student group lesson');
    }

    @isTest 
    static void testInsertGroupMemberNotFoundFailure() {
        Student__c stud = getTestStudent();
        StudentGroup__c studGroup = getTestStudentGroup();
        Lesson__c lsn = getTestLesson();
        StudentGroupMember__c groupMember = getTestStudentGroupMember();
        delete groupMember;
        DepartmentCourseGroupLesson__c groupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        insert groupLsn;
        StudentLessonAttendance__c attendance = TestObjectFactory.createStudentLessonAttendance(stud, studGroup, lsn);
        Boolean isThrown = false;
        try {
            insert attendance;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest 
    static void testInsertInactiveGroupMemberFailure() {
        Student__c stud = getTestStudent();
        StudentGroup__c studGroup = getTestStudentGroup();
        Lesson__c lsn = getTestLesson();
        StudentGroupMember__c groupMember = getTestStudentGroupMember();
        groupMember.IsActive__c = false;
        update groupMember;
        DepartmentCourseGroupLesson__c groupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        insert groupLsn;
        Boolean isThrown = false;
        StudentLessonAttendance__c attendance = TestObjectFactory.createStudentLessonAttendance(stud, studGroup, lsn);
        try {
            insert attendance;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest 
    static void testInsertGroupLessonNotFoundFailure() {
        Student__c stud = getTestStudent();
        StudentGroup__c studGroup = getTestStudentGroup();
        Lesson__c lsn = getTestLesson();
        StudentLessonAttendance__c attendance = TestObjectFactory.createStudentLessonAttendance(stud, studGroup, lsn);
        Boolean isThrown = false;
        try {
            insert attendance;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest 
    static void testInsertInactiveGroupLessonFailure() {
        Student__c stud = getTestStudent();
        StudentGroup__c studGroup = getTestStudentGroup();
        Lesson__c lsn = getTestLesson();
        DepartmentCourseGroupLesson__c groupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        groupLsn.IsActive__c = false;
        Boolean isThrown = false;
        try {
            insert groupLsn;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest
    static void testInsertDuplicateFailure() {
        Student__c stud = getTestStudent();
        StudentGroup__c studGroup = getTestStudentGroup();
        Lesson__c lsn = getTestLesson();
        DepartmentCourseGroupLesson__c groupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        Boolean isThrown = false;
        insert groupLsn;
        StudentLessonAttendance__c attendance = TestObjectFactory.createStudentLessonAttendance(stud, studGroup, lsn);
        try {
            insert attendance;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest
    static void testUpdate() {
        StudentGroup__c studGroup = getTestStudentGroup();
        Lesson__c lsn = getTestLesson();
        DepartmentCourseGroupLesson__c groupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        insert groupLsn;
        StudentLessonAttendance__c attendance = getTestStudentLessonAttendance();
        attendance.IsAttending__c = true;
        Boolean isThrown = false;
        try {
            update attendance;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    @isTest
    static void testUndelete() {
        StudentGroup__c studGroup = getTestStudentGroup();
        Lesson__c lsn = getTestLesson();
        DepartmentCourseGroupLesson__c groupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        insert groupLsn;
        StudentLessonAttendance__c attendance = getTestStudentLessonAttendance();
        Boolean isThrown = false;
        try {
            delete attendance;
            undelete attendance;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    static Lesson__c getTestLesson() {
        return [SELECT Id, IsActive__c FROM Lesson__c LIMIT 1];
    }
    
    static Student__c getTestStudent() {
        return [SELECT Id, IsActive__c FROM Student__c LIMIT 1];
    }

    static StudentGroup__c getTestStudentGroup() {
        return [SELECT Id, IsActive__c FROM StudentGroup__c LIMIT 1];
    }

    static StudentGroupMember__c getTestStudentGroupMember() {
        return [SELECT Id, IsActive__c FROM StudentGroupMember__c LIMIT 1];
    }

    static StudentLessonAttendance__c getTestStudentLessonAttendance() {
        return [SELECT Id, Student__c, StudentGroup__c, StudentGroupMember__c, DepartmentCourseGroupLesson__c FROM StudentLessonAttendance__c LIMIT 1];
    }
}