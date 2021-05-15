@isTest
private class DepartmentCourseProfessorTriggerTest {
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
    }

    @isTest 
    static void testInsertSuccess() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Professor__c prof = getTestProfessor();
        DepartmentCourseProfessor__c depCourseProf = TestObjectFactory.createDepartmentCourseProfessor(dep, course, prof);
        Boolean isThrown = false;
        try {
            insert depCourseProf;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    @isTest 
    static void testInsertDepartmentProfessorNotFound() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Account newAcc = TestObjectFactory.createAccount();
        insert newAcc;
        Professor__c newProf = TestObjectFactory.createProfessor(newAcc);
        insert newProf;
        DepartmentCourseProfessor__c depCourseProf = TestObjectFactory.createDepartmentCourseProfessor(dep, course, newProf);
        Boolean isThrown = false;
        try {
            insert depCourseProf;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest 
    static void testInsertDepartmentCourseNotFound() {
        Faculty__c fac = getTestFaculty();
        Professor__c prof = getTestProfessor();
        Department__c dep = getTestDepartment();
        Course__c newCourse = TestObjectFactory.createCourse(fac, 'NEW');
        insert newCourse;
        DepartmentCourseProfessor__c depCourseProf = TestObjectFactory.createDepartmentCourseProfessor(dep, newCourse, prof);
        Boolean isThrown = false;
        try {
            insert depCourseProf;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest 
    static void testInsertInactiveDepartmentCourse() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Professor__c prof = getTestProfessor();
        DepartmentCourse__c depCourse = getTestDepartmentCourse();
        depCourse.IsActive__c = false;
        update depCourse;
        DepartmentCourseProfessor__c depCourseProf = TestObjectFactory.createDepartmentCourseProfessor(dep, course, prof);
        Boolean isThrown = false;
        try {
            insert depCourseProf;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest 
    static void testInsertInactiveDepartmentProfessor() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Professor__c prof = getTestProfessor();
        DepartmentProfessor__c depProf = getTestDepartmentProfessor();
        depProf.IsActive__c = false;
        update depProf;
        DepartmentCourseProfessor__c depCourseProf = TestObjectFactory.createDepartmentCourseProfessor(dep, course, prof);
        Boolean isThrown = false;
        try {
            insert depCourseProf;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest
    static void testUpdateLessons() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Professor__c prof = getTestProfessor();
        DepartmentCourseProfessor__c depCourseProf = TestObjectFactory.createDepartmentCourseProfessor(dep, course, prof);
        insert depCourseProf;
        Lesson__c lsn = TestObjectFactory.createLesson(dep, course, prof);
        insert lsn;
        depCourseProf.IsActive__c = false;
        Boolean isThrown = false;
        try {
            update depCourseProf;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
        DepartmentCourseProfessor__c depCourseProfAfter = getTestDepartmentCourseProfessor();
        Lesson__c lsnAfter = getTestLesson();
        System.assertEquals(depCourseProfAfter.IsActive__c, lsnAfter.isActive__c, 'Lesson should be deactivated with depatment course professor');
    }

    @isTest 
    static void testUndelete() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Professor__c prof = getTestProfessor();
        DepartmentCourseProfessor__c depCourseProf = TestObjectFactory.createDepartmentCourseProfessor(dep, course, prof);
        insert depCourseProf;
        delete depCourseProf;
        Boolean isThrown = false;
        try {
            undelete depCourseProf;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    static Faculty__c getTestFaculty() {
        return [SELECT Id, IsActive__c FROM Faculty__c LIMIT 1];
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

    static DepartmentCourse__c getTestDepartmentCourse() {
        return [SELECT Id, Department__c, IsActive__c FROM DepartmentCourse__c LIMIT 1];
    }

    static DepartmentProfessor__c getTestDepartmentProfessor() {
        return [SELECT Id, IsActive__c FROM DepartmentProfessor__c LIMIT 1];
    }

    static DepartmentCourseProfessor__c getTestDepartmentCourseProfessor() {
        return [SELECT Id, IsActive__c FROM DepartmentCourseProfessor__c LIMIT 1];
    }

    static Lesson__c getTestLesson() {
        return [SELECT Id, IsActive__c FROM Lesson__c LIMIT 1];
    }
}