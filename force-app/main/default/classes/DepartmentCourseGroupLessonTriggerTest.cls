@isTest
private class DepartmentCourseGroupLessonTriggerTest {
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
    }

    @isTest 
    static void testInsertSuccess() {
        Lesson__c lsn = getTestLesson();
        StudentGroup__c studGroup = getTestStudentGroup();
        DepartmentCourseGroupLesson__c groupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        Boolean isThrown = false;
        try {
            insert groupLsn;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    @isTest
    static void testInsertInactiveLessonFailure() {
        StudentGroup__c studGroup = getTestStudentGroup();
        Lesson__c lsn = getTestLesson();
        lsn.IsActive__c = false;
        update lsn;
        DepartmentCourseGroupLesson__c groupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        Boolean isThrown = false;
        try {
            insert groupLsn;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest
    static void testInsertCourseGroupNotFound() {
        StudentGroup__c studGroup = getTestStudentGroup();
        Lesson__c lsn = getTestLesson();
        DepartmentCourseGroup__c courseGroup = getTestDepartmentCourseGroup();
        delete courseGroup;
        DepartmentCourseGroupLesson__c groupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
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
        Lesson__c lsn = getTestLesson();
        StudentGroup__c studGroup = getTestStudentGroup();
        DepartmentCourseGroupLesson__c groupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        insert groupLsn;
        DepartmentCourseGroupLesson__c groupLsnDupl = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        Boolean isThrown = false;
        try {
            insert groupLsnDupl;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest
    static void testDelete() {
        Lesson__c lsn = getTestLesson();
        StudentGroup__c studGroup = getTestStudentGroup();
        DepartmentCourseGroupLesson__c groupLsn = TestObjectFactory.createDepartmentCourseGroupLesson(lsn, studGroup);
        insert groupLsn;
        Boolean isThrown = false;
        try {
            delete groupLsn;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    static Lesson__c getTestLesson() {
        return [SELECT Id, IsActive__c FROM Lesson__c LIMIT 1];
    }

    static StudentGroup__c getTestStudentGroup() {
        return [SELECT Id, IsActive__c FROM StudentGroup__c LIMIT 1];
    }

    static DepartmentCourseGroup__c getTestDepartmentCourseGroup() {
        return [SELECT Id, IsActive__c FROM DepartmentCourseGroup__c LIMIT 1];
    }
}