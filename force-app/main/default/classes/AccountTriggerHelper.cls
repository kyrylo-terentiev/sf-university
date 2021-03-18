public with sharing class AccountTriggerHelper {
    
    public static void validateAccountName(List<Account> newList) {
        for (Account acc : newList) {
            if (!Utils.validatePersonName(acc.LastName__c, acc.FirstName__c, acc.MiddleName__c)) {
                acc.addError(System.Label.InvalidName);
            }
        }
    }

    public static void setAccountName(List<Account> newList) {
        for (Account acc : newList) {
            acc.Name = Utils.getPersonRecordName(acc.LastName__c, acc.FirstName__c, acc.MiddleName__c);
            acc.LastName__c = acc.LastName__c.toLowerCase().capitalize();
            acc.FirstName__c = acc.FirstName__c.toLowerCase().capitalize();
            acc.MiddleName__c = !String.isEmpty(acc.MiddleName__c) 
                                ? acc.MiddleName__c.toLowerCase().capitalize() 
                                : null;
        }
    }

    public static void updateChildren(Map<Id, Account> newMap, Map<Id, Account> oldMap) {
        List<Professor__c> professorsToUpdate = new List<Professor__c>();
        Map<Id, List<Professor__c>> accToProfessorsMap = new Map<Id, List<Professor__c>>();
        for (Professor__c prof : [  SELECT Name, Account__c 
                                    FROM Professor__c 
                                    WHERE Account__c IN :newMap.keySet()]
        ) {
            if (accToProfessorsMap.get(prof.Account__c) == null) {
                accToProfessorsMap.put(prof.Account__c, new List<Professor__c>());
            }
            accToProfessorsMap.get(prof.Account__c).add(prof);
        }
        for (Id accId : accToProfessorsMap.keySet()) {
            Account newAcc = newMap.get(accId);
            Account oldAcc = oldMap.get(accId);
            List<Professor__c> professorList = accToProfessorsMap.get(accId);
            if (newAcc.Name != oldAcc.Name) {
                for (Professor__c prof : professorList) {
                    prof.Name = newAcc.Name;
                    professorsToUpdate.add(prof);
                }
            }
        }
        if (!professorsToUpdate.isEmpty()) {
            update professorsToUpdate;
        }
    }
}
