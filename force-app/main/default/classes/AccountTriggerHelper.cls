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
        List<sObject> childrenToUpdate = new List<sObject>();
        childrenToUpdate.addAll(getUpdatedProfessors(newMap, oldMap));
        childrenToUpdate.addAll(getUpdatedStudents(newMap, oldMap));
        if (!childrenToUpdate.isEmpty()) {
            update childrenToUpdate;
        }
    }

    private static List<Professor__c> getUpdatedProfessors(Map<Id, Account> newMap, Map<Id, Account> oldMap) {
        List<Professor__c> professorsToUpdateList = new List<Professor__c>();
        Map<Id, List<Professor__c>> accToProfessorsMap = new Map<Id, List<Professor__c>>();
        for (Professor__c prof : [SELECT Name, Account__c, IsActive__c 
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
            Boolean isAccChanged = newAcc.Name != oldAcc.Name || newAcc.IsActive__c != oldAcc.IsActive__c;
            if (isAccChanged) {
                for (Professor__c prof : accToProfessorsMap.get(accId)) {
                    prof.Name = newAcc.Name;
                    prof.IsActive__c = newAcc.IsActive__c;
                    professorsToUpdateList.add(prof);
                }
            }
        }

        return professorsToUpdateList;
    }

    private static List<Student__c> getUpdatedStudents(Map<Id, Account> newMap, Map<Id, Account> oldMap) {
        List<Student__c> studentsToUpdateList = new List<Student__c>();
        Map<Id, List<Student__c>> accToStudentsMap = new Map<Id, List<Student__c>>();
        for (Student__c stud : [SELECT Name, Account__c, IsActive__c 
                                FROM Student__c 
                                WHERE Account__c IN :newMap.keySet()]
        ) {
            if (accToStudentsMap.get(stud.Account__c) == null) {
                accToStudentsMap.put(stud.Account__c, new List<Student__c>());
            }
            accToStudentsMap.get(stud.Account__c).add(stud);
        }
        for (Id accId : accToStudentsMap.keySet()) {
            Account newAcc = newMap.get(accId);
            Account oldAcc = oldMap.get(accId);
            Boolean isAccChanged = newAcc.Name != oldAcc.Name || newAcc.IsActive__c != oldAcc.IsActive__c;
            if (isAccChanged) {
                for (Student__c stud : accToStudentsMap.get(accId)) {
                    stud.Name = newAcc.Name;
                    stud.IsActive__c = newAcc.IsActive__c;
                    studentsToUpdateList.add(stud);
                }
            }
        }

        return studentsToUpdateList;
    }
}
