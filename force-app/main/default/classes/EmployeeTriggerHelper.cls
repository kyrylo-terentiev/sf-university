public with sharing class EmployeeTriggerHelper {
    
    public static void setEmployeeName(List<Employee__c> newList) {
        for (Employee__c empl : newList) {
            empl.Name = Utils.getPersonRecordName(
                empl.LastName__c, 
                empl.FirstName__c, 
                empl.MiddleName__c
            );
        }
    }

    public static void updateChildren(List<Employee__c> newList, Map<Id, Employee__c> oldMap) {
        List<sObject> childrenToUpdate = new List<sObject>();
        for (Employee__c newEmpl : newList) {
            Employee__c oldEmpl = oldMap.get(newEmpl.Id);
            if (newEmpl.Name != oldEmpl.Name) {
                
            }
        }

        if (!childrenToUpdate.isEmpty()) {
            update childrenToUpdate;
        }
    }
}
