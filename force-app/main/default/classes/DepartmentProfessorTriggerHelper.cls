public with sharing class DepartmentProfessorTriggerHelper {
     
    public static void setDepartmentProfessorName(List<DepartmentProfessor__c> newList) {
        Map<Id, DepartmentProfessor__c> profToDepProfMap = new Map<Id, DepartmentProfessor__c>();
        for (DepartmentProfessor__c depProf : newList) {
            profToDepProfMap.put(depProf.Professor__c, depProf);
        }
        Map<Id, Professor__c> profMap = new Map<Id, Professor__c>([
            SELECT Name
            FROM Professor__c
            WHERE Id IN :profToDepProfMap.keySet()
        ]);
        for (Id profId : profToDepProfMap.keySet()) {
            profToDepProfMap.get(profId).Name = profMap.get(profId).Name;
        }
    }

    public static void validateDepartment(List<DepartmentProfessor__c> newList, Map<Id, DepartmentProfessor__c> oldMap) {
        Set<Id> depIdSet = new Set<Id>();
        for (DepartmentProfessor__c depProf : newList) {
            depIdSet.add(depProf.Department__c);
        }
        Map<Id, Department__c> depMap = new Map<Id, Department__c>([
            SELECT IsActive__c
            FROM Department__c
            WHERE Id IN :depIdSet
        ]);
        for (DepartmentProfessor__c depProf : newList) {
            Boolean isActiveDep = depMap.get(depProf.Department__c).IsActive__c;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depProf.Id);
            Boolean isInactivation = isUpdate && !depProf.IsActive__c && oldMap.get(depProf.Id).IsActive__c;
            if (!isActiveDep && !isInactivation) {
                depProf.addError(System.Label.InactiveDepartment);
            }
        }
    }

    public static void validateProfessor(List<DepartmentProfessor__c> newList, Map<Id, DepartmentProfessor__c> oldMap) {
        Set<Id> profIdSet = new Set<Id>();
        for (DepartmentProfessor__c depProf : newList) {
            profIdSet.add(depProf.Professor__c);
        }
        Map<Id, Professor__c> profMap = new Map<Id, Professor__c>([
            SELECT IsActive__c
            FROM Professor__c
            WHERE Id IN :profIdSet
        ]);
        for (DepartmentProfessor__c depProf : newList) {
            Boolean isActiveProf = profMap.get(depProf.Professor__c).IsActive__c;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depProf.Id);
            Boolean isInactivation = isUpdate && !depProf.IsActive__c && oldMap.get(depProf.Id).IsActive__c;
            if (!isActiveProf && !isInactivation) {
                depProf.addError(System.Label.InactiveProfessor);
            }
        }
    }

    public static void validateDepartmentProfessor(List<DepartmentProfessor__c> newList, Map<Id, DepartmentProfessor__c> oldMap) {
        Map<Id, Map<Id, DepartmentProfessor__c>> profToDepToDepProf = new Map<Id, Map<Id, DepartmentProfessor__c>>();
        for (DepartmentProfessor__c depProf : newList) {
            profToDepToDepProf.put(depProf.Professor__c, new Map<Id, DepartmentProfessor__c>());
            profToDepToDepProf.get(depProf.Professor__c).put(depProf.Department__c, null);
        }
        for (DepartmentProfessor__c depProf : [SELECT Professor__c, Department__c, IsActive__c 
                                                  FROM DepartmentProfessor__c 
                                                  WHERE Professor__c IN :profToDepToDepProf.keySet()])
        {
            if (profToDepToDepProf.get(depProf.Professor__c).containsKey(depProf.Department__c)) {
                profToDepToDepProf.get(depProf.Professor__c).put(depProf.Department__c, depProf);
            }
        }
        for (DepartmentProfessor__c depProf : newList) {
            DepartmentProfessor__c duplDepProf = profToDepToDepProf.get(depProf.Professor__c).get(depProf.Department__c);
            Boolean isDuplicate = duplDepProf != null;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depProf.Id);
            if (isUpdate && isDuplicate) {
                isDuplicate = oldMap.get(depProf.Id).Id != duplDepProf.Id;
            }
            Boolean isInactivation = isUpdate && !depProf.IsActive__c && oldMap.get(depProf.Id).IsActive__c;
            if (isDuplicate && !isInactivation) {
                depProf.addError(System.Label.DuplicateDepartmentProfessor);
            }
        }
    }
}