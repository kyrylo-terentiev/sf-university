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

    public static void updateChildren(Map<Id, Professor__c> newMap, Map<Id, Professor__c> oldMap) {
        List<sObject> childrenToUpdate = new List<sObject>();
        childrenToUpdate.addAll(getUpdatedDepartmentProfessors(newMap, oldMap));
        if (!childrenToUpdate.isEmpty()) {
            update childrenToUpdate;
        }
    }

    private static List<DepartmentProfessor__c> getUpdatedDepartmentProfessors(Map<Id, Professor__c> newMap, Map<Id, Professor__c> oldMap) {
        List<DepartmentProfessor__c> depProfsToUpdate = new List<DepartmentProfessor__c>();
        Map<Id, List<DepartmentProfessor__c>> profToDepProfsMap = new Map<Id, List<DepartmentProfessor__c>>();
        for (DepartmentProfessor__c depProf : [SELECT Professor__c, IsActive__c 
                                                  FROM DepartmentProfessor__c 
                                                  WHERE Professor__c IN :newMap.keySet()])
        {
            if (profToDepProfsMap.get(depProf.Professor__c) == null) {
                profToDepProfsMap.put(depProf.Professor__c, new List<DepartmentProfessor__c>());
            }
            profToDepProfsMap.get(depProf.Professor__c).add(depProf);
        }
        for (Id profId : profToDepProfsMap.keySet()) {
            Professor__c newProf = newMap.get(profId);
            Professor__c oldProf = oldMap.get(profId);
            Boolean isNameChanged = newProf.Name != oldProf.Name;
            Boolean isInactivated = !newProf.IsActive__c && oldProf.IsActive__c;
            if (isNameChanged || isInactivated) {
                for (DepartmentProfessor__c depProf : profToDepProfsMap.get(profId)) {
                    if (isNameChanged) depProf.Name = newProf.Name;
                    if (isInactivated) depProf.IsActive__c = newProf.IsActive__c;
                    depProfsToUpdate.add(depProf);
                }
            }
        }

        return depProfsToUpdate;
    }
}