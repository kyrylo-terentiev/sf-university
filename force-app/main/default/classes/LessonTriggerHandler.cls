public class LessonTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<sObject> newList) {
        LessonTriggerHelper.setStartDateTime((List<Lesson__c>) newList);
        LessonTriggerHelper.setEndDateTime((List<Lesson__c>) newList);
    }

    public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
        LessonTriggerHelper.setDepartmentCourseGroup((List<Lesson__c>) newList);
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        LessonTriggerHelper.setStartDateTime((List<Lesson__c>) newList);
        LessonTriggerHelper.setEndDateTime((List<Lesson__c>) newList);
    }

    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        LessonTriggerHelper.updateChildren((Map<Id, Lesson__c>) newMap, (Map<Id, Lesson__c>) oldMap);
    }

    public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {

    }

    public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {

    }

    public void afterUndelete(List<sObject> newList, Map<Id, sObject> newMap) {
    }
}