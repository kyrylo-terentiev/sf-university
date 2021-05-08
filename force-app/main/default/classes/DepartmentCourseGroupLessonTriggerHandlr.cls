public class DepartmentCourseGroupLessonTriggerHandlr implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<sObject> newList) {
        DepartmentCourseGroupLessonTriggerHelper.validate((List<DepartmentCourseGroupLesson__c>) newList, null);
    }

    public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
        DepartmentCourseGroupLessonTriggerHelper.createStudentAttendance((List<DepartmentCourseGroupLesson__c>) newList);
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        DepartmentCourseGroupLessonTriggerHelper.validate((List<DepartmentCourseGroupLesson__c>) newList, (Map<Id, DepartmentCourseGroupLesson__c>) oldMap);
    }

    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
    }

    public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    }

    public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    }

    public void afterUndelete(List<sObject> newList, Map<Id, sObject> newMap) {
    }
}