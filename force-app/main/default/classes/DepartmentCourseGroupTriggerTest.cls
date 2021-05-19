@isTest
private class DepartmentCourseGroupTriggerTest {
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
    }
    
    @isTest 
    static void testInsertSuccess() {
        Course__c course = getTestCourse();
        StudentGroup__c studGroup = getTestStudentGroup();
        DepartmentCourseGroup__c courseGroup = TestObjectFactory.createDepartmentCourseGroup(course, studGroup);
        Boolean isThrown = false;
        try {
            insert courseGroup;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, System.Label.TestExceptionNotExpected);
    }

    @isTest 
    static void testInsertInactiveStudentGroup() {
        Course__c course = getTestCourse();
        StudentGroup__c studGroup = getTestStudentGroup();
        studGroup.IsActive__c = false;
        update studGroup;
        DepartmentCourseGroup__c courseGroup = TestObjectFactory.createDepartmentCourseGroup(course, studGroup);
        Boolean isThrown = false;
        try {
            insert courseGroup;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, System.Label.TestExceptionExpected);
    }

    @isTest 
    static void testInsertInactiveDepartmentCourse() {
        Course__c course = getTestCourse();
        StudentGroup__c studGroup = getTestStudentGroup();
        DepartmentCourse__c depCourse = getTestDepartmentCourse();
        depCourse.IsActive__c = false;
        update depCourse;
        DepartmentCourseGroup__c courseGroup = TestObjectFactory.createDepartmentCourseGroup(course, studGroup);
        Boolean isThrown = false;
        try {
            insert courseGroup;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, System.Label.TestExceptionExpected);
    }

    @isTest 
    static void testInsertDuplicate() {
        Course__c course = getTestCourse();
        StudentGroup__c studGroup = getTestStudentGroup();
        DepartmentCourseGroup__c courseGroup = TestObjectFactory.createDepartmentCourseGroup(course, studGroup);
        insert courseGroup;
        DepartmentCourseGroup__c courseGroupDupl = TestObjectFactory.createDepartmentCourseGroup(course, studGroup);
        Boolean isThrown = false;
        try {
            insert courseGroupDupl;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, System.Label.TestExceptionExpected);
    }

    @isTest
    static void testUpdateChildren() {
        Department__c dep = getTestDepartment();
        Professor__c prof = getTestProfessor();
        Course__c course = getTestCourse();
        StudentGroup__c studGroup = getTestStudentGroup();
        DepartmentCourseGroup__c courseGroup = TestObjectFactory.createDepartmentCourseGroup(course, studGroup);
        insert courseGroup;
        Lesson__c lsn = getTestLesson();
        DepartmentCourseGroupLesson__c groupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        insert groupLsn;
        courseGroup.IsActive__c = false;
        Boolean isThrown = false;
        try {
            update courseGroup;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, System.Label.TestExceptionNotExpected);
        DepartmentCourseGroupLesson__c groupLsnAfter = getTestDepartmentCourseGroupLesson();
        System.assertEquals(courseGroup.IsActive__c, groupLsnAfter.IsActive__c, 'Group Lesson should be deactivated with Course Group');
    }

    @isTest
    static void testUndelete() {
        Department__c dep = getTestDepartment();
        Professor__c prod = getTestProfessor();
        Course__c course = getTestCourse();
        StudentGroup__c studGroup = getTestStudentGroup();
        DepartmentCourseGroup__c courseGroup = TestObjectFactory.createDepartmentCourseGroup(course, studGroup);
        insert courseGroup;
        delete courseGroup;
        Boolean isThrown = false;
        try {
            undelete courseGroup;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, System.Label.TestExceptionNotExpected);
    }

    static Course__c getTestCourse() {
        return [SELECT Id, IsActive__c FROM Course__c LIMIT 1];
    }

    static StudentGroup__c getTestStudentGroup() {
        return [SELECT Id, IsActive__c FROM StudentGroup__c LIMIT 1];
    }

    static Department__c getTestDepartment() {
        return [SELECT Id, IsActive__c FROM Department__c LIMIT 1];
    }

    static Professor__c getTestProfessor() {
        return [SELECT Id, IsActive__c FROM Professor__c LIMIT 1];
    }

    static DepartmentCourse__c getTestDepartmentCourse() {
        return [SELECT Id, IsActive__c FROM DepartmentCourse__c LIMIT 1];
    }

    static Lesson__c getTestLesson() {
        return [SELECT Id, IsActive__c FROM Lesson__c LIMIT 1];
    }

    static DepartmentCourseGroupLesson__c getTestDepartmentCourseGroupLesson() {
        return [SELECT Id, IsActive__c FROM DepartmentCourseGroupLesson__c LIMIT 1];  
    }
}