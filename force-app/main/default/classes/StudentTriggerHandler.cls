public class StudentTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<SObject> newList) {
        StudentTriggerHelper.validateStudentId((List<Student__c>) newList);
        StudentTriggerHelper.setStudentName((List<Student__c>) newList);
    }

    public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {

    }
    
    public void beforeUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        StudentTriggerHelper.validateStudentId((List<Student__c>) newList);
        StudentTriggerHelper.setStudentName((List<Student__c>) newList);
    }

    public void afterUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        StudentTriggerHelper.updateChildren((Map<Id, Student__c>) newMap, (Map<Id, Student__c>) oldMap);
    }

    public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {

    }

    public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {

    }

    public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
    }
}