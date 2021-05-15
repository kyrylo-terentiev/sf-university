public with sharing class DepartmentProfessorTriggerHelper {
     
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
            Boolean isActiveDep = depMap.get(depProf.Department__c)?.IsActive__c != null
                                  ? depMap.get(depProf.Department__c).IsActive__c
                                  : false;
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
            Boolean isActiveProf = profMap.get(depProf.Professor__c)?.IsActive__c != null
                                   ? profMap.get(depProf.Professor__c).IsActive__c
                                   : false;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depProf.Id);
            Boolean isInactivation = isUpdate && !depProf.IsActive__c;
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

    public static void updateChildren(Map<Id, DepartmentProfessor__c> newMap, Map<Id, DepartmentProfessor__c> oldMap) {
        List<SObject> childrenToUpdate = new List<SObject>();
        childrenToUpdate.addAll(getUpdatedDepartmentCourseProfessors(newMap, oldMap));
        if (!childrenToUpdate.isEmpty()) {
            update childrenToUpdate;
        }
    }

    public static List<DepartmentCourseProfessor__c> getUpdatedDepartmentCourseProfessors(Map<Id, DepartmentProfessor__c> newMap, Map<Id, DepartmentProfessor__c> oldMap) {
        List<DepartmentCourseProfessor__c> depCourseProfsToUpdate = new List<DepartmentCourseProfessor__c>();
        Map<Id, List<DepartmentCourseProfessor__c>> depProfToDepCourseProfsMap = new Map<Id, List<DepartmentCourseProfessor__c>>();
        for (DepartmentCourseProfessor__c depCourseProf : [SELECT DepartmentProfessor__c, IsActive__c 
                                                           FROM DepartmentCourseProfessor__c 
                                                           WHERE DepartmentProfessor__c IN :newMap.keySet()])
        {
            if (depProfToDepCourseProfsMap.get(depCourseProf.DepartmentProfessor__c) == null) {
                depProfToDepCourseProfsMap.put(depCourseProf.DepartmentProfessor__c, new List<DepartmentCourseProfessor__c>());
            }
            depProfToDepCourseProfsMap.get(depCourseProf.DepartmentProfessor__c).add(depCourseProf);
        }
        for (Id depProfId : depProfToDepCourseProfsMap.keySet()) {
            DepartmentProfessor__c newDepProf = newMap.get(depProfId);
            DepartmentProfessor__c oldDepProf = oldMap.get(depProfId);
            Boolean isInactivated = !newDepProf.IsActive__c && oldDepProf.IsActive__c;
            if (isInactivated) {
                for (DepartmentCourseProfessor__c depCourseProf : depProfToDepCourseProfsMap.get(depProfId)) {
                    if (depCourseProf.IsActive__c) {
                        depCourseProf.IsActive__c = false;
                        depCourseProfsToUpdate.add(depCourseProf);
                    }
                }
            }
        }

        return depCourseProfsToUpdate;
    }
}