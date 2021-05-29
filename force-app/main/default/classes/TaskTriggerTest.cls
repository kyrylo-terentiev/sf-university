@isTest
private class TaskTriggerTest {
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
    }

    @isTest 
    static void testInsertSuccess() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Lesson__c lsn = getTestLesson();
        Task__c tsk = TestObjectFactory.createTask(dep, course, lsn);
        Boolean isThrown = false;
        try {
            insert tsk; 
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, System.Label.TestExceptionNotExpected);
    }

    @isTest
    static void testInsertDepartmentCourseNotFound() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Lesson__c lsn = getTestLesson();
        delete lsn;
        DepartmentCourseProfessor__c depCourseProf = getTestDepartmentCourseProfessor();
        delete depCourseProf;
        DepartmentCourse__c depCourse = getTestDepartmentCourse();
        delete depCourse;
        Task__c tsk = TestObjectFactory.createTask(dep, course);
        Boolean isThrown = false;
        try {
            insert tsk; 
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, System.Label.TestExceptionExpected);
    }

    @isTest
    static void testUpdate() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Lesson__c lsn = getTestLesson();
        Task__c tsk = TestObjectFactory.createTask(dep, course, lsn);
        insert tsk;
        Boolean isThrown = false;
        try {
            tsk.Name = 'NewName';
            update tsk;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, System.Label.TestExceptionNotExpected);
    }

    @isTest
    static void testUndelete() {
        Department__c dep = getTestDepartment();
        Course__c course = getTestCourse();
        Lesson__c lsn = getTestLesson();
        Task__c tsk = TestObjectFactory.createTask(dep, course, lsn);
        insert tsk;
        Boolean isThrown = false;
        try {
            delete tsk;
            undelete tsk;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, System.Label.TestExceptionNotExpected);
    }

    static Department__c getTestDepartment() {
        return [SELECT Id, IsActive__c FROM Department__c LIMIT 1];
    }

    
    static Course__c getTestCourse() {
        return [SELECT Id, IsActive__c FROM Course__c LIMIT 1];
    }
    
    static DepartmentCourse__c getTestDepartmentCourse() {
        return [SELECT Id, IsActive__c FROM DepartmentCourse__c LIMIT 1];
    }

    static DepartmentCourseProfessor__c getTestDepartmentCourseProfessor() {
        return [SELECT Id, IsActive__c FROM DepartmentCourseProfessor__c LIMIT 1];
    }

    static Lesson__c getTestLesson() {
        return [SELECT Id, IsActive__c FROM Lesson__c LIMIT 1];
    }
}