public class ProfessorTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<sObject> newList) {
        ProfessorTriggerHelper.validateAccount((List<Professor__c>) newList, false);
        ProfessorTriggerHelper.setProfessorName((List<Professor__c>) newList);
    }

    public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {

    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        ProfessorTriggerHelper.validateAccount((List<Professor__c>) newList, true);
        ProfessorTriggerHelper.setProfessorName((List<Professor__c>) newList);
    }

    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        ProfessorTriggerHelper.updateChildren((Map<Id, Professor__c>) newMap, (Map<Id, Professor__c>) oldMap);
    }

    public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {

    }

    public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {

    }

    public void afterUndelete(List<sObject> newList, Map<Id, sObject> newMap) {
    }
}