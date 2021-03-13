public with sharing class EmployeeTriggerHelper {
    
    public static void setEmployeeName(List<Employee__c> employeeList) {
        for (Employee__c empl : employeeList) {
            empl.Name = Utils.getPersonRecordName(empl.LastName__c, empl.FirstName__c, empl.MiddleName__c);
        }
    }
}
