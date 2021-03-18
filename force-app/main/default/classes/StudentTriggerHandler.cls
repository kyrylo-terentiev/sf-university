public class StudentTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<sObject> newList) {
        StudentTriggerHelper.validateStudentId((List<Student__c>) newList);
        StudentTriggerHelper.setStudentName((List<Student__c>) newList);
    }

    public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {

    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        StudentTriggerHelper.validateStudentId((List<Student__c>) newList);
        StudentTriggerHelper.setStudentName((List<Student__c>) newList);
    }

    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {

    }

    public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {

    }

    public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {

    }

    public void afterUndelete(List<sObject> newList, Map<Id, sObject> newMap) {
        List<Student__c> studentList = [
            SELECT Id
                , Account__c
                , StudentID__c
            FROM Student__c 
            WHERE Id IN :newMap.keySet()
        ];
        StudentTriggerHelper.validateStudentId(studentList);
        StudentTriggerHelper.setStudentName(studentList);
        update studentList;
    }
}
