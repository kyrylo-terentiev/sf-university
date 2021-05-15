public class StudentGroupMemberTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<SObject> newList) {
        StudentGroupMemberTriggerHelper.validateGroup((List<StudentGroupMember__c>) newList, null);
        StudentGroupMemberTriggerHelper.validateStudent((List<StudentGroupMember__c>) newList, null);
        StudentGroupMemberTriggerHelper.validateGroupMember((List<StudentGroupMember__c>) newList, null);
    }

    public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
    }
    
    public void beforeUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        StudentGroupMemberTriggerHelper.validateGroup((List<StudentGroupMember__c>) newList, (Map<Id, StudentGroupMember__c>) oldMap);
        StudentGroupMemberTriggerHelper.validateStudent((List<StudentGroupMember__c>) newList, (Map<Id, StudentGroupMember__c>) oldMap);
        StudentGroupMemberTriggerHelper.validateGroupMember((List<StudentGroupMember__c>) newList, (Map<Id, StudentGroupMember__c>) oldMap);
    }

    public void afterUpdate(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap) {
        StudentGroupMemberTriggerHelper.updateChildren((Map<Id, StudentGroupMember__c>) newMap, (Map<Id, StudentGroupMember__c>) oldMap);
    }

    public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    }

    public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    }

    public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
    }
}