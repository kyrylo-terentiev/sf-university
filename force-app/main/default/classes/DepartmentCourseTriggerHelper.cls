public with sharing class DepartmentCourseTriggerHelper {
    
    public static void validateDepartment(List<DepartmentCourse__c> newList, Map<Id, DepartmentCourse__c> oldMap) {
        Set<Id> depIdSet = new Set<Id>();
        for (DepartmentCourse__c depCourse : newList) {
            depIdSet.add(depCourse.Department__c);
        }
        Map<Id, Department__c> depMap = new Map<Id, Department__c>([
            SELECT IsActive__c
            FROM Department__c
            WHERE Id IN :depIdSet
        ]);
        for (DepartmentCourse__c depCourse : newList) {
            Boolean isActiveDep = depMap.get(depCourse.Department__c).IsActive__c;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depCourse.Id);
            Boolean isInactivation = isUpdate && !depCourse.IsActive__c;
            if (!isActiveDep && !isInactivation) {
                depCourse.addError(System.Label.InactiveDepartment);
            }
        }
    }

    public static void validateCourse(List<DepartmentCourse__c> newList, Map<Id, DepartmentCourse__c> oldMap) {
        Set<Id> courseIdSet = new Set<Id>();
        for (DepartmentCourse__c depCourse : newList) {
            courseIdSet.add(depCourse.Course__c);
        }
        Map<Id, Course__c> courseMap = new Map<Id, Course__c>([
            SELECT IsActive__c
            FROM Course__c
            WHERE Id IN :courseIdSet
        ]);
        for (DepartmentCourse__c depCourse : newList) {
            Boolean isActiveCourse = courseMap.get(depCourse.Course__c).IsActive__c;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depCourse.Id);
            Boolean isInactivation = isUpdate && !depCourse.IsActive__c;
            if (!isActiveCourse && !isInactivation) {
                depCourse.addError(System.Label.InactiveCourse);
            }
        }
    }

    public static void updateChildren(Map<Id, DepartmentCourse__c> newMap, Map<Id, DepartmentCourse__c> oldMap) {
        List<sObject> childrenToUpdate = new List<sObject>();
        childrenToUpdate.addAll(getUpdatedDepartmentCourseProfessors(newMap, oldMap));
        if (!childrenToUpdate.isEmpty()) {
            update childrenToUpdate;
        }
    }

    public static List<DepartmentCourseProfessor__c> getUpdatedDepartmentCourseProfessors(Map<Id, DepartmentCourse__c> newMap, Map<Id, DepartmentCourse__c> oldMap) {
        List<DepartmentCourseProfessor__c> depCourseProfsToUpdate = new List<DepartmentCourseProfessor__c>();
        Map<Id, List<DepartmentCourseProfessor__c>> depCourseToDepCourseProfsMap = new Map<Id, List<DepartmentCourseProfessor__c>>();
        for (DepartmentCourseProfessor__c depCourseProf : [SELECT DepartmentCourse__c, IsActive__c 
                                                           FROM DepartmentCourseProfessor__c 
                                                           WHERE DepartmentCourse__c IN :newMap.keySet()])
        {
            if (depCourseToDepCourseProfsMap.get(depCourseProf.DepartmentCourse__c) == null) {
                depCourseToDepCourseProfsMap.put(depCourseProf.DepartmentCourse__c, new List<DepartmentCourseProfessor__c>());
            }
            depCourseToDepCourseProfsMap.get(depCourseProf.DepartmentCourse__c).add(depCourseProf);
        }
        for (Id depCourseId : depCourseToDepCourseProfsMap.keySet()) {
            DepartmentCourse__c newDepCourse = newMap.get(depCourseId);
            DepartmentCourse__c oldDepCourse = oldMap.get(depCourseId);
            Boolean isInactivated = !newDepCourse.IsActive__c && oldDepCourse.IsActive__c;
            if (isInactivated) {
                for (DepartmentCourseProfessor__c depCourseProf : depCourseToDepCourseProfsMap.get(depCourseId)) {
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