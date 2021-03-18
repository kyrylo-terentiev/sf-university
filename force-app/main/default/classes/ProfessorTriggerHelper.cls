public with sharing class ProfessorTriggerHelper {
    
    public static void setProfessorName(List<Professor__c> newList) {
        Map<Id, Professor__c> accToProfMap = new Map<Id, Professor__c>();
        for (Professor__c prof : newList) {
            accToProfMap.put(prof.Account__c, prof);
        }
        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Name
            FROM Account
            WHERE Id IN :accToProfMap.keySet()
        ]);
        for (Id accId : accToProfMap.keySet()) {
            accToProfMap.get(accId).Name = accMap.get(accId).Name;
        }
    }

    public static void validateAccount(List<Professor__c> newList, Boolean isUpdate) {
        Map<Id, Id> accToProfMap = new Map<Id, Id>();
        for (Professor__c prof : newList) {
            accToProfMap.put(prof.Account__c, null);
        }
        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Id, 
            (SELECT Id FROM Professors__r)
            FROM Account
            WHERE Id IN :accToProfMap.keySet()
        ]);
        for (Id accId : accToProfMap.keySet()) {
            Account acc = accMap.get(accId);
            Boolean isProfessor = acc != null && acc.Professors__r != null && !acc.Professors__r.isEmpty();
            if (isProfessor) {
                accToProfMap.put(accId, acc.Professors__r[0].Id);
            }
        }
        for (Professor__c prof : newList) {
            Id existingProfId = accToProfMap.get(prof.Account__c);
            if (existingProfId != null) {
                if (!isUpdate || existingProfId != prof.Id) {
                    prof.addError(System.Label.AccountAlreadyHasProfessor);
                }
            }
        }
    }
}
