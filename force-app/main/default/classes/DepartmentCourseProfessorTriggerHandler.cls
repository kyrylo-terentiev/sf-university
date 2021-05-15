public class DepartmentCourseProfessorTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<SObject> newList) {
        DepartmentCourseProfessorTriggerHelper.validate((List<DepartmentCourseProfessor__c>) newList, null);
    }

    public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
    }
    
    public void beforeUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        DepartmentCourseProfessorTriggerHelper.validate((List<DepartmentCourseProfessor__c>) newList, (Map<Id, DepartmentCourseProfessor__c>) oldMap);
    }

    public void afterUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        DepartmentCourseProfessorTriggerHelper.updateChildren((Map<Id, DepartmentCourseProfessor__c>) newMap, (Map<Id, DepartmentCourseProfessor__c>) oldMap);
    }

    public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    }

    public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    }

    public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
    }
}