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
                depCourseProf.addError(System.Label.InactiveDepartmentProfessor);
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
                depCourseProf.addError(System.Label.InactiveDepartmentCourse);
            }
        }
    }
}