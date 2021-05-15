public class StudentLessonAttendanceTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<sObject> newList) {
        StudentLessonAttendanceTriggerHelper.validate((List<StudentLessonAttendance__c>) newList, null);
    }

    public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
        StudentLessonAttendanceTriggerHelper.updateGroupLesson((List<StudentLessonAttendance__c>) newList);
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        StudentLessonAttendanceTriggerHelper.validate((List<StudentLessonAttendance__c>) newList, (Map<Id, StudentLessonAttendance__c>) oldMap);
    }

    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        StudentLessonAttendanceTriggerHelper.updateGroupLesson((List<StudentLessonAttendance__c>) newList);
    }

    public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    }

    public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    }

    public void afterUndelete(List<sObject> newList, Map<Id, sObject> newMap) {
    }
}