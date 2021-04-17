public with sharing class DepartmentCourseProfessorTriggerHelper {
    
    public static void validateDepartmentProfessor(List<DepartmentCourseProfessor__c> newList, Map<Id, DepartmentCourseProfessor__c> oldMap) {
        Set<Id> depProfIdSet = new Set<Id>();
        for (DepartmentCourseProfessor__c depCourseProf : newList) {
            depProfIdSet.add(depCourseProf.DepartmentProfessor__c);
        }
        Map<Id, DepartmentProfessor__c> depProfMap = new Map<Id, DepartmentProfessor__c>([
            SELECT IsActive__c
            FROM DepartmentProfessor__c
            WHERE Id IN :depProfIdSet
        ]);
        for (DepartmentCourseProfessor__c depCourseProf : newList) {
            Boolean isActiveDepProf = depProfMap.get(depCourseProf.DepartmentProfessor__c).IsActive__c;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depCourseProf.Id);
            Boolean isInactivation = isUpdate && !depCourseProf.IsActive__c;
            if (!isActiveDepProf && !isInactivation) {
                depCourseProf.DepartmentProfessor__c.addError(System.Label.InactiveDepartmentProfessor);
            }
        }
    }

    public static void validateDepartmentCourse(List<DepartmentCourseProfessor__c> newList, Map<Id, DepartmentCourseProfessor__c> oldMap) {
        Set<Id> depCourseIdSet = new Set<Id>();
        for (DepartmentCourseProfessor__c depCourseProf : newList) {
            depCourseIdSet.add(depCourseProf.DepartmentCourse__c);
        }
        Map<Id, DepartmentCourse__c> depCourseMap = new Map<Id, DepartmentCourse__c>([
            SELECT IsActive__c
            FROM DepartmentCourse__c
            WHERE Id IN :depCourseIdSet
        ]);
        for (DepartmentCourseProfessor__c depCourseProf : newList) {
            Boolean isActiveDepCourse = depCourseMap.get(depCourseProf.DepartmentCourse__c).IsActive__c;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depCourseProf.Id);
            Boolean isInactivation = isUpdate && !depCourseProf.IsActive__c;
            if (!isActiveDepCourse && !isInactivation) {
                depCourseProf.DepartmentCourse__c.addError(System.Label.InactiveDepartmentCourse);
            }
        }
    }

    public static void updateChildren(Map<Id, DepartmentCourseProfessor__c> newMap, Map<Id, DepartmentCourseProfessor__c> oldMap) {
        List<sObject> childrenToUpdate = new List<sObject>();
        childrenToUpdate.addAll(getUpdatedLessons(newMap, oldMap));
        if (!childrenToUpdate.isEmpty()) {
            update childrenToUpdate;
        }
    }

    private static List<Lesson__c> getUpdatedLessons(Map<Id, DepartmentCourseProfessor__c> newMap, Map<Id, DepartmentCourseProfessor__c> oldMap) {
        List<Lesson__c> lessonsToUpdate = new List<Lesson__c>();
        Map<Id, List<Lesson__c>> depCourseProfToLessonsMap = new Map<Id, List<Lesson__c>>();
        for (Lesson__c lsn : [SELECT DepartmentCourseProfessor__c, IsActive__c 
                              FROM Lesson__c 
                              WHERE DepartmentCourseProfessor__c IN :newMap.keySet()])
        {
            if (depCourseProfToLessonsMap.get(lsn.DepartmentCourseProfessor__c) == null) {
                depCourseProfToLessonsMap.put(lsn.DepartmentCourseProfessor__c, new List<Lesson__c>());
            }
            depCourseProfToLessonsMap.get(lsn.DepartmentCourseProfessor__c).add(lsn);
        }
        for (Id depCourseProfId : depCourseProfToLessonsMap.keySet()) {
            DepartmentCourseProfessor__c newDepCourseProf = newMap.get(depCourseProfId);
            DepartmentCourseProfessor__c oldDepCourseProf = oldMap.get(depCourseProfId);
            Boolean isInactivated = !newDepCourseProf.IsActive__c && oldDepCourseProf.IsActive__c;
            if (isInactivated) {
                for (Lesson__c lsn : depCourseProfToLessonsMap.get(depCourseProfId)) {
                    if (lsn.IsActive__c) {
                        lsn.IsActive__c = false;
                        lessonsToUpdate.add(lsn);
                    }
                }
            }
        }

        return lessonsToUpdate;
    }
}