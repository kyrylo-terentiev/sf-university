public class DepartmentCourseTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<SObject> newList) {
        DepartmentCourseTriggerHelper.validateDepartment((List<DepartmentCourse__c>) newList, null);
        DepartmentCourseTriggerHelper.validateCourse((List<DepartmentCourse__c>) newList, null);
    }

    public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
    }
    
    public void beforeUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        DepartmentCourseTriggerHelper.validateDepartment((List<DepartmentCourse__c>) newList, (Map<Id, DepartmentCourse__c>) oldMap);
        DepartmentCourseTriggerHelper.validateCourse((List<DepartmentCourse__c>) newList, (Map<Id, DepartmentCourse__c>) oldMap);
    }

    public void afterUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        DepartmentCourseTriggerHelper.updateChildren((Map<Id, DepartmentCourse__c>) newMap, (Map<Id, DepartmentCourse__c>) oldMap);
    }

    public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    }

    public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    }

    public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
    }
}