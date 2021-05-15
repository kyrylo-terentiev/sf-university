public class ProfessorTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<SObject> newList) {
        ProfessorTriggerHelper.validateAccount((List<Professor__c>) newList, false);
        ProfessorTriggerHelper.setProfessorName((List<Professor__c>) newList);
    }

    public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {

    }
    
    public void beforeUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        ProfessorTriggerHelper.validateAccount((List<Professor__c>) newList, true);
        ProfessorTriggerHelper.setProfessorName((List<Professor__c>) newList);
    }

    public void afterUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        ProfessorTriggerHelper.updateChildren((Map<Id, Professor__c>) newMap, (Map<Id, Professor__c>) oldMap);
    }

    public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {

    }

    public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {

    }

    public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
    }
}