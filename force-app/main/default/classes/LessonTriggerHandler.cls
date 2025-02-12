public class LessonTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<SObject> newList) {
        LessonTriggerHelper.setDateTime((List<Lesson__c>) newList);
        LessonTriggerHelper.validate((List<Lesson__c>) newList, null);
    }

    public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
    }
    
    public void beforeUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        LessonTriggerHelper.setDateTime((List<Lesson__c>) newList);
        LessonTriggerHelper.validate((List<Lesson__c>) newList, (Map<Id, Lesson__c>) oldMap);
    }

    public void afterUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        LessonTriggerHelper.updateChildren((Map<Id, Lesson__c>) newMap, (Map<Id, Lesson__c>) oldMap);
    }

    public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
        LessonTriggerHelper.deleteChildren((Map<Id, Lesson__c>) oldMap);
    }

    public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {

    }

    public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
    }
}