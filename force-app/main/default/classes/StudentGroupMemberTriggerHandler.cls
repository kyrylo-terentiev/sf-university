public class StudentGroupMemberTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<sObject> newList) {
        StudentGroupMemberTriggerHelper.validateGroup((List<StudentGroupMember__c>) newList, null);
        StudentGroupMemberTriggerHelper.validateStudent((List<StudentGroupMember__c>) newList, null);
        StudentGroupMemberTriggerHelper.validateGroupMember((List<StudentGroupMember__c>) newList, null);
    }

    public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        StudentGroupMemberTriggerHelper.validateGroup((List<StudentGroupMember__c>) newList, (Map<Id, StudentGroupMember__c>) oldMap);
        StudentGroupMemberTriggerHelper.validateStudent((List<StudentGroupMember__c>) newList, (Map<Id, StudentGroupMember__c>) oldMap);
        StudentGroupMemberTriggerHelper.validateGroupMember((List<StudentGroupMember__c>) newList, (Map<Id, StudentGroupMember__c>) oldMap);
    }

    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        StudentGroupMemberTriggerHelper.updateChildren((Map<Id, StudentGroupMember__c>) newMap, (Map<Id, StudentGroupMember__c>) oldMap);
    }

    public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    }

    public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    }

    public void afterUndelete(List<sObject> newList, Map<Id, sObject> newMap) {
    }
}