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
        DepartmentCourse__c depCourse = getTestDepartmentCourse();
        DepartmentProfessor__c depProf = getTestDepartmentProfessor();
        DepartmentCourseProfessor__c depCourseProf = TestObjectFactory.createDepartmentCourseProfessor(depCourse, depProf);
        Boolean isThrown = false;
        try {
            insert depCourseProf;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    @isTest 
    static void testInsertInactiveDepartmentCourse() {
        DepartmentCourse__c depCourse = getTestDepartmentCourse();
        depCourse.IsActive__c = false;
        update depCourse;
        DepartmentProfessor__c depProf = getTestDepartmentProfessor();
        DepartmentCourseProfessor__c depCourseProf = TestObjectFactory.createDepartmentCourseProfessor(depCourse, depProf);
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
        DepartmentCourse__c depCourse = getTestDepartmentCourse();
        DepartmentProfessor__c depProf = getTestDepartmentProfessor();
        depProf.IsActive__c = false;
        update depProf;
        DepartmentCourseProfessor__c depCourseProf = TestObjectFactory.createDepartmentCourseProfessor(depCourse, depProf);
        Boolean isThrown = false;
        try {
            insert depCourseProf;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest 
    static void testUndelete() {
        DepartmentCourse__c depCourse = getTestDepartmentCourse();
        DepartmentProfessor__c depProf = getTestDepartmentProfessor();
        DepartmentCourseProfessor__c depCourseProf = TestObjectFactory.createDepartmentCourseProfessor(depCourse, depProf);
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

    static DepartmentCourse__c getTestDepartmentCourse() {
        return [SELECT Id, Department__c, IsActive__c FROM DepartmentCourse__c LIMIT 1];
    }

    static DepartmentProfessor__c getTestDepartmentProfessor() {
        return [SELECT Id, IsActive__c FROM DepartmentProfessor__c LIMIT 1];
    }
}