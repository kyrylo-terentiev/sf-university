@isTest
private class EmployeeTriggerTest {

    static final Integer EMPLOYEE_NUM = 5;

    @testSetup
    static void setup() {
        List<Employee__c> employeeList = TestObjectFactory.createEmployees(EMPLOYEE_NUM);
        insert employeeList;
    }

    @isTest
    static void testInsertFailure() {
        Employee__c empl = TestObjectFactory.createEmployee();
        empl.FirstName__c = '123';
        Boolean isThrown = false;
        try {
            insert empl;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest
    static void testUpdateFailure() {
        Employee__c empl = getTestEmployees()[0];
        empl.FirstName__c = '123';
        Boolean isThrown = false;
        try {
            update empl;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(isThrown, 'Exception expected');
    }

    @isTest
    static void testUpdateSuccess() {
        Employee__c empl = getTestEmployees()[0];
        empl.FirstName__c = 'NewFirstName';
        Boolean isThrown = false;
        try {
            update empl;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    @isTest
    static void testUndelete() {
        Employee__c empl = getTestEmployees()[0];
        Id employeeId = empl.Id;
        delete empl;
        Boolean isThrown = false;
        try {
            undelete empl;
        } catch (Exception e) {
            isThrown = true;
        }
        System.assert(!isThrown, 'Exception not expected');
    }

    @isTest
    static void testUpdateChildren() {
        Employee__c empl = getTestEmployees()[0];
        Professor__c prof = TestObjectFactory.createProfessor(empl);
        insert prof;
        empl.FirstName__c = 'NewTestFirstName';
        Test.startTest();
        update empl;
        Test.stopTest();
        Employee__c emplAfter = [SELECT Name FROM Employee__c WHERE Id = :empl.Id];
        Professor__c profAfter = [SELECT Name FROM Professor__c WHERE Id = :prof.Id];
        System.assertEquals(emplAfter.Name, profAfter.Name, 'Updated Professor\'s name should equal to Employee\'s name');
    }

    static List<Employee__c> getTestEmployees() {
        return [
            SELECT Id
                , Name
                , FirstName__c
                , LastName__c
                , MiddleName__c
                , DateOfBirth__c
                , FullName__c
                , User__c
            FROM Employee__c
        ];
    }
}