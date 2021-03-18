public class EmployeeTriggerHandler /* implements ITriggerHandler */ {

    // public static Boolean triggerDisabled = true;

    // public Boolean isDisabled() {
    //     return triggerDisabled;
    // }

    // public void beforeInsert(List<sObject> newList) {
    //     EmployeeTriggerHelper.validateEmployeeName((List<Employee__c>) newList);
    //     EmployeeTriggerHelper.setEmployeeName((List<Employee__c>) newList);
    // }

    // public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {

    // }
    
    // public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
    //     EmployeeTriggerHelper.validateEmployeeName((List<Employee__c>) newList);
    //     EmployeeTriggerHelper.setEmployeeName((List<Employee__c>) newList);
    // }

    // public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
    //     EmployeeTriggerHelper.updateChildren((Map<Id, Employee__c>) newMap, (Map<Id, Employee__c>) oldMap);
    // }

    // public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {

    // }

    // public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {

    // }

    // public void afterUndelete(List<sObject> newList, Map<Id, sObject> newMap) {
    //     List<Employee__c> employeeList = [
    //         SELECT Id
    //             , Name
    //             , FirstName__c
    //             , LastName__c
    //             , MiddleName__c
    //         FROM Employee__c 
    //         WHERE Id IN :newMap.keySet()
    //     ];
    //     EmployeeTriggerHelper.validateEmployeeName(employeeList);
    //     EmployeeTriggerHelper.setEmployeeName(employeeList);
    //     update employeeList;
    // }
}
