public class DepartmentCourseGroupTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<SObject> newList) {
        DepartmentCourseGroupTriggerHelper.validate((List<DepartmentCourseGroup__c>) newList, null);
    }

    public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
    }
    
    public void beforeUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        DepartmentCourseGroupTriggerHelper.validate((List<DepartmentCourseGroup__c>) newList, (Map<Id, DepartmentCourseGroup__c>) oldMap);
    }

    public void afterUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        DepartmentCourseGroupTriggerHelper.updateChildren((Map<Id, DepartmentCourseGroup__c>) newMap, (Map<Id, DepartmentCourseGroup__c>) oldMap);
    }

    public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {

    }

    public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {

    }

    public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
    }
}