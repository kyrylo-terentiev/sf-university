public class DepartmentCourseProfessorTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<sObject> newList) {
        DepartmentCourseProfessorTriggerHelper.validateDepartmentCourse((List<DepartmentCourseProfessor__c>) newList, null);
        DepartmentCourseProfessorTriggerHelper.validateDepartmentProfessor((List<DepartmentCourseProfessor__c>) newList, null);
    }

    public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        DepartmentCourseProfessorTriggerHelper.validateDepartmentCourse((List<DepartmentCourseProfessor__c>) newList, (Map<Id, DepartmentCourseProfessor__c>) oldMap);
        DepartmentCourseProfessorTriggerHelper.validateDepartmentProfessor((List<DepartmentCourseProfessor__c>) newList, (Map<Id, DepartmentCourseProfessor__c>) oldMap);
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