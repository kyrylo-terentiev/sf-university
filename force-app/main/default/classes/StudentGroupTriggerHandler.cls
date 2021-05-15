public class StudentGroupTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<SObject> newList) {
        StudentGroupTriggerHelper.validateHeadOfGroup((List<StudentGroup__c>) newList);
        StudentGroupTriggerHelper.validateGroupCourator((List<StudentGroup__c>) newList);
    }

    public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
    }
    
    public void beforeUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        StudentGroupTriggerHelper.validateHeadOfGroup((List<StudentGroup__c>) newList);
        StudentGroupTriggerHelper.validateGroupCourator((List<StudentGroup__c>) newList);
    }

    public void afterUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        StudentGroupTriggerHelper.updateChildren((Map<Id, StudentGroup__c>) newMap, (Map<Id, StudentGroup__c>) oldMap);
    }

    public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    }

    public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    }

    public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
    }
}