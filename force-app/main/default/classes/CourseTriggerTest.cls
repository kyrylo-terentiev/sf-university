@isTest
private class CourseTriggerTest {
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
    }

    @isTest 
    static void testInsertSuccess() {
        Faculty__c fac = getTestFaculty();
        Course__c course = TestObjectFactory.createCourse(fac);
        Boolean isThrown = false;
        try {
            insert course;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    @isTest
    static void testUpdateChildrenNames() {
        Faculty__c fac = getTestFaculty();
        Department__c dep = getTestDepartment();
        Course__c course = TestObjectFactory.createCourse(fac);
        insert course;
        DepartmentCourse__c depCourse = TestObjectFactory.createDepartmentCourse(dep, course);
        insert depCourse;
        course.Name = 'NewTestCourseName';
        Test.startTest();
        update course;
        Test.stopTest();
        Course__c courseAfter = [SELECT Name FROM Course__c WHERE Id = :course.Id];
        DepartmentCourse__c depCourseAfter = [SELECT Name FROM DepartmentCourse__c WHERE Id = :depCourse.Id];
        System.assertEquals(courseAfter.Name, depCourseAfter.Name, 'Updated Department Course name should equal to Course name');
    }

    @isTest
    static void testInactivateChildren() {
        Faculty__c fac = getTestFaculty();
        Department__c dep = getTestDepartment();
        Course__c course = TestObjectFactory.createCourse(fac);
        insert course;
        DepartmentCourse__c depCourse = TestObjectFactory.createDepartmentCourse(dep, course);
        insert depCourse;
        course.IsActive__c = false;
        Test.startTest();
        update course;
        Test.stopTest();
        Course__c courseAfter = [SELECT IsActive__c FROM Course__c WHERE Id = :course.Id];
        DepartmentCourse__c depCourseAfter = [SELECT IsActive__c FROM DepartmentCourse__c WHERE Id = :depCourse.Id];
        System.assertEquals(courseAfter.IsActive__c, depCourseAfter.IsActive__c, 'Department Course should be deactivated with the Course');
    }

    @isTest
    static void testUndelete() {
        Faculty__c fac = getTestFaculty();
        Course__c course = TestObjectFactory.createCourse(fac);
        insert course;
        delete course;
        Boolean isThrown = false;
        try {
            undelete course;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    static Faculty__c getTestFaculty() {
        return [SELECT Id, IsActive__c FROM Faculty__C LIMIT 1];
    }

    static Department__c getTestDepartment() {
        return [SELECT Id, IsActive__c FROM Department__c LIMIT 1];
    }
}