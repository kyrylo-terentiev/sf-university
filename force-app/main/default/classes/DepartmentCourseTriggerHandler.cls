public class DepartmentCourseTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<sObject> newList) {
        DepartmentCourseTriggerHelper.validateDepartment((List<DepartmentCourse__c>) newList, null);
        DepartmentCourseTriggerHelper.validateCourse((List<DepartmentCourse__c>) newList, null);
    }

    public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        DepartmentCourseTriggerHelper.validateDepartment((List<DepartmentCourse__c>) newList, (Map<Id, DepartmentCourse__c>) oldMap);
        DepartmentCourseTriggerHelper.validateCourse((List<DepartmentCourse__c>) newList, (Map<Id, DepartmentCourse__c>) oldMap);
    }

    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        DepartmentCourseTriggerHelper.updateChildren((Map<Id, DepartmentCourse__c>) newMap, (Map<Id, DepartmentCourse__c>) oldMap);
    }

    public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    }

    public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    }

    public void afterUndelete(List<sObject> newList, Map<Id, sObject> newMap) {
    }
}