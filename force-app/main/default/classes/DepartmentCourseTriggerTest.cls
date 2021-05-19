@isTest
private class DepartmentCourseTriggerTest {
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
        DepartmentCourse__c depCourse = TestObjectFactory.createDepartmentCourse(dep, course);
        Boolean isThrown = false;
        try {
            insert depCourse;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, System.Label.TestExceptionNotExpected);
    }

    @isTest 
    static void testInsertInactiveDepartment() {
        Department__c dep = getTestDepartment();
        dep.IsActive__c = false;
        update dep;
        Course__c course = getTestCourse();
        DepartmentCourse__c depCourse = TestObjectFactory.createDepartmentCourse(dep, course);
        Boolean isThrown = false;
        try {
            insert depCourse;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, System.Label.TestExceptionExpected);
    }

    @isTest 
    static void testInsertInactiveCourse() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        course.IsActive__c = false;
        update course;
        DepartmentCourse__c depCourse = TestObjectFactory.createDepartmentCourse(dep, course);
        Boolean isThrown = false;
        try {
            insert depCourse;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, System.Label.TestExceptionExpected);
    }

    @isTest
    static void testInactivateChildren() {
        Department__c dep = getTestDepartment();
        Professor__c prof = getTestProfessor();
        Course__c course = getTestCourse();
        DepartmentCourse__c depCourse = TestObjectFactory.createDepartmentCourse(dep, course);
        insert depCourse;
        DepartmentProfessor__c depProf = TestObjectFactory.createDepartmentProfessor(dep, prof);
        insert depProf;
        DepartmentCourseProfessor__c depCourseProf = TestObjectFactory.createDepartmentCourseProfessor(dep, course, prof);
        insert depCourseProf;
        depCourse.IsActive__c = false;
        Test.startTest();
        update depCourse;
        Test.stopTest();
        DepartmentCourse__c depCourseAfter = [SELECT IsActive__c FROM DepartmentCourse__c WHERE Id = :depCourse.Id];
        DepartmentCourseProfessor__c depCourseProfAfter = [SELECT IsActive__c FROM DepartmentCourseProfessor__c WHERE Id = :depCourseProf.Id];
        System.assertEquals(depCourseAfter.IsActive__c, depCourseProfAfter.IsActive__c, 'Department Course Professor should be deactivated with the Department Course');
    }

    @isTest
    static void testUndelete() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        DepartmentCourse__c depCourse = TestObjectFactory.createDepartmentCourse(dep, course);
        insert depCourse;
        delete depCourse;
        Boolean isThrown = false;
        try {
            undelete depCourse;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, System.Label.TestExceptionNotExpected);
    }

    static Department__c getTestDepartment() {
        return [SELECT Id, IsActive__c FROM Department__c LIMIT 1];
    }

    static Professor__c getTestProfessor() {
        return [SELECT Id, IsActive__c FROM Professor__c LIMIT 1];
    }

    static Course__c getTestCourse() {
        return [SELECT Id, IsActive__c FROM Course__c LIMIT 1];
    }
}