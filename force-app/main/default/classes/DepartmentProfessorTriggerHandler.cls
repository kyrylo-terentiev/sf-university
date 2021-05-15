public class DepartmentProfessorTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<SObject> newList) {
        DepartmentProfessorTriggerHelper.validateProfessor((List<DepartmentProfessor__c>) newList, null);
        DepartmentProfessorTriggerHelper.validateDepartment((List<DepartmentProfessor__c>) newList, null);
        DepartmentProfessorTriggerHelper.validateDepartmentProfessor((List<DepartmentProfessor__c>) newList, null);
    }

    public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
    }
    
    public void beforeUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        DepartmentProfessorTriggerHelper.validateProfessor((List<DepartmentProfessor__c>) newList, (Map<Id, DepartmentProfessor__c>) oldMap);
        DepartmentProfessorTriggerHelper.validateDepartment((List<DepartmentProfessor__c>) newList, (Map<Id, DepartmentProfessor__c>) oldMap);
        DepartmentProfessorTriggerHelper.validateDepartmentProfessor((List<DepartmentProfessor__c>) newList, (Map<Id, DepartmentProfessor__c>) oldMap);
    }

    public void afterUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        DepartmentProfessorTriggerHelper.updateChildren((Map<Id, DepartmentProfessor__c>) newMap, (Map<Id, DepartmentProfessor__c>) oldMap);
    }

    public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    }

    public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    }

    public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
    }
}