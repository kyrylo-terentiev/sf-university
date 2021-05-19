@isTest
private class DepartmentProfessorTriggerTest {
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
        Professor__c prof = getTestProfessor();
        DepartmentProfessor__c depProf = TestObjectFactory.createDepartmentProfessor(dep, prof);
        Boolean isThrown = false;
        try {
            insert depProf;
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
        Professor__c prof = getTestProfessor();
        DepartmentProfessor__c depProf = TestObjectFactory.createDepartmentProfessor(dep, prof);
        Boolean isThrown = false;
        try {
            insert depProf;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, System.Label.TestExceptionExpected);
    }

    @isTest 
    static void testInsertInactiveProfessor() {
        Department__c dep = getTestDepartment();
        Professor__c prof = getTestProfessor();
        prof.IsActive__c = false;
        update prof;
        DepartmentProfessor__c depProf = TestObjectFactory.createDepartmentProfessor(dep, prof);
        Boolean isThrown = false;
        try {
            insert depProf;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, System.Label.TestExceptionExpected);
    }

    @isTest 
    static void testInsertDuplicate() {
        Department__c dep = getTestDepartment();
        Professor__c prof = getTestProfessor();
        DepartmentProfessor__c depProf = TestObjectFactory.createDepartmentProfessor(dep, prof);
        insert depProf;
        DepartmentProfessor__c depProfDupl = TestObjectFactory.createDepartmentProfessor(dep, prof);
        Boolean isThrown = false;
        try {
            insert depProfDupl;
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
        depProf.IsActive__c = false;
        Test.startTest();
        update depProf;
        Test.stopTest();
        DepartmentProfessor__c depProfAfter = [SELECT IsActive__c FROM DepartmentProfessor__c WHERE Id = :depProf.Id];
        DepartmentCourseProfessor__c depCourseProfAfter = [SELECT IsActive__c FROM DepartmentCourseProfessor__c WHERE Id = :depCourseProf.Id];
        System.assertEquals(depProfAfter.IsActive__c, depCourseProfAfter.IsActive__c, 'Department Course Professor should be deactivated with the Department Professor');
    }

    @isTest
    static void testUndelete() {
        Department__c dep = getTestDepartment();
        Professor__c prof = getTestProfessor();
        DepartmentProfessor__c depProf = TestObjectFactory.createDepartmentProfessor(dep, prof);
        insert depProf;
        delete depProf;
        Boolean isThrown = false;
        try {
            undelete depProf;
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