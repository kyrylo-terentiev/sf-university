public class AccountTriggerHandler implements ITriggerHandler {

    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() {
        return triggerDisabled;
    }

    public void beforeInsert(List<sObject> newList) {
        AccountTriggerHelper.validateAccountName((List<Account>) newList);
        AccountTriggerHelper.setAccountName((List<Account>) newList);
    }

    public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {

    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        AccountTriggerHelper.validateAccountName((List<Account>) newList);
        AccountTriggerHelper.setAccountName((List<Account>) newList);
    }

    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        AccountTriggerHelper.updateChildren((Map<Id, Account>) newMap, (Map<Id, Account>) oldMap);
    }

    public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {

    }

    public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {

    }

    public void afterUndelete(List<sObject> newList, Map<Id, sObject> newMap) {
    }
}