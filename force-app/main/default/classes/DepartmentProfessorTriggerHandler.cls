public class DepartmentProfessorTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<sObject> newList) {
        DepartmentProfessorTriggerHelper.validateProfessor((List<DepartmentProfessor__c>) newList, null);
        DepartmentProfessorTriggerHelper.validateDepartment((List<DepartmentProfessor__c>) newList, null);
        DepartmentProfessorTriggerHelper.validateDepartmentProfessor((List<DepartmentProfessor__c>) newList, null);
        DepartmentProfessorTriggerHelper.setDepartmentProfessorName(newList);
    }

    public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        DepartmentProfessorTriggerHelper.validateProfessor((List<DepartmentProfessor__c>) newList, (Map<Id, DepartmentProfessor__c>) oldMap);
        DepartmentProfessorTriggerHelper.validateDepartment((List<DepartmentProfessor__c>) newList, (Map<Id, DepartmentProfessor__c>) oldMap);
        DepartmentProfessorTriggerHelper.validateDepartmentProfessor((List<DepartmentProfessor__c>) newList, (Map<Id, DepartmentProfessor__c>) oldMap);
        DepartmentProfessorTriggerHelper.setDepartmentProfessorName(newList);
    }

    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        DepartmentProfessorTriggerHelper.updateChildren((Map<Id, DepartmentProfessor__c>) newMap, (Map<Id, DepartmentProfessor__c>) oldMap);
    }

    public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    }

    public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    }

    public void afterUndelete(List<sObject> newList, Map<Id, sObject> newMap) {
    }
}
