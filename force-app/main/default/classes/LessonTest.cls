@isTest
private class LessonTest {
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
    }

    @isTest 
    static void testInsertSuccess() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Professor__c prof = getTestProfessor();
        DepartmentCourse__c depCourse = TestObjectFactory.createDepartmentCourse(dep, course);
        insert depCourse;
        DepartmentProfessor__c depProf = TestObjectFactory.createDepartmentProfessor(dep, prof);
        insert depProf;
        DepartmentCourseProfessor__c depCourseProf = TestObjectFactory.createDepartmentCourseProfessor(dep, course, prof);
        insert depCourseProf;
        Lesson__c lsn = TestObjectFactory.createLesson(dep, course, prof);
        Boolean isThrown = false;
        try {
            insert lsn;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    @isTest
    static void testInsertDepartmentCourseNotFoundFailure() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Professor__c prof = getTestProfessor();
        DepartmentProfessor__c depProf = TestObjectFactory.createDepartmentProfessor(dep, prof);
        insert depProf;
        Lesson__c lsn = TestObjectFactory.createLesson(dep, course, prof);
        Boolean isThrown = false;
        try {
            insert lsn;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest
    static void testInsertDeparmentProfessorNotFoundFailure() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Professor__c prof = getTestProfessor();
        DepartmentCourse__c depCourse = TestObjectFactory.createDepartmentCourse(dep, course);
        insert depCourse;
        Lesson__c lsn = TestObjectFactory.createLesson(dep, course, prof);
        Boolean isThrown = false;
        try {
            insert lsn;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest
    static void testInsertDeparmentCourseProfessorNotFoundFailure() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Professor__c prof = getTestProfessor();
        DepartmentCourse__c depCourse = TestObjectFactory.createDepartmentCourse(dep, course);
        insert depCourse;
        DepartmentProfessor__c depProf = TestObjectFactory.createDepartmentProfessor(dep, prof);
        insert depProf;
        Lesson__c lsn = TestObjectFactory.createLesson(dep, course, prof);
        Boolean isThrown = false;
        try {
            insert lsn;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest
    static void testInsertDeparmentCourseProfessorDuplicateFailure() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Professor__c prof = getTestProfessor();
        DepartmentCourse__c depCourse = TestObjectFactory.createDepartmentCourse(dep, course);
        insert depCourse;
        DepartmentProfessor__c depProf = TestObjectFactory.createDepartmentProfessor(dep, prof);
        insert depProf;
        DepartmentCourseProfessor__c depCourseProf = TestObjectFactory.createDepartmentCourseProfessor(dep, course, prof);
        insert depCourseProf;
        Lesson__c lsn = TestObjectFactory.createLesson(dep, course, prof);
        insert lsn;
        Lesson__c lsnDupl = TestObjectFactory.createLesson(dep, course, prof);
        Boolean isThrown = false;
        try {
            insert lsnDupl;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest
    static void testInactivateDepartmentCourseGroupLessons() {
        Account acc = getTestAccount();
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Professor__c prof = getTestProfessor();
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
        DepartmentCourseGroupLesson__c groupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        insert groupLsn;
        Boolean isThrown = false;
        lsn.IsActive__c = false;
        try {
            update lsn;
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

    static Course__c getTestCourse() {
        return [SELECT Id, IsActive__c FROM Course__c LIMIT 1];
    }

    static Professor__c getTestProfessor() {
        return [SELECT Id, IsActive__c FROM Professor__c LIMIT 1];
    }
}