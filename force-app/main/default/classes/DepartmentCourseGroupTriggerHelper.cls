public with sharing class DepartmentCourseGroupTriggerHelper {

    public static void validate(List<DepartmentCourseGroup__c> newList, Map<Id, DepartmentCourseGroup__c> oldMap) {
        validateDepartmentCourse(newList, oldMap);
        validateGroup(newList, oldMap);
    }

    public static void validateDepartmentCourse(List<DepartmentCourseGroup__c> newList, Map<Id, DepartmentCourseGroup__c> oldMap) {
        Set<Id> depCourseIdSet = new Set<Id>();
        for (DepartmentCourseGroup__c depCourseGroup : newList) {
            depCourseIdSet.add(depCourseGroup.DepartmentCourse__c);
        }
        Map<Id, DepartmentCourse__c> depCourseMap = new Map<Id, DepartmentCourse__c>([
            SELECT IsActive__c
            FROM DepartmentCourse__c
            WHERE Id IN :depCourseIdSet
        ]);
        for (DepartmentCourseGroup__c depCourseGroup : newList) {
            Boolean isActiveDepCourse = depCourseMap.get(depCourseGroup.DepartmentCourse__c).IsActive__c;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depCourseGroup.Id);
            Boolean isInactivation = isUpdate && !depCourseGroup.IsActive__c;
            if (!isActiveDepCourse && !isInactivation) {
                depCourseGroup.DepartmentCourse__c.addError(System.Label.InactiveDepartmentCourse);
            }
        }
    }

    public static void validateGroup(List<DepartmentCourseGroup__c> newList, Map<Id, DepartmentCourseGroup__c> oldMap) {
        Set<Id> groupIdSet = new Set<Id>();
        for (DepartmentCourseGroup__c depCourseGroup : newList) {
            groupIdSet.add(depCourseGroup.StudentGroup__c);
        }
        Map<Id, StudentGroup__c> groupMap = new Map<Id, StudentGroup__c>([
            SELECT IsActive__c
            FROM StudentGroup__c
            WHERE Id IN :groupIdSet
        ]);
        for (DepartmentCourseGroup__c depCourseGroup : newList) {
            Boolean isActiveGroup = groupMap.get(depCourseGroup.StudentGroup__c).IsActive__c;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depCourseGroup.Id);
            Boolean isInactivation = isUpdate && !depCourseGroup.IsActive__c && oldMap.get(depCourseGroup.Id).IsActive__c;
            if (!isActiveGroup && !isInactivation) {
                depCourseGroup.StudentGroup__c.addError(System.Label.InactiveStudentGroup);
            }
        }
    }

    public static void updateChildren(Map<Id, DepartmentCourseGroup__c> newMap, Map<Id, DepartmentCourseGroup__c> oldMap) {
        List<sObject> childrenToUpdate = new List<sObject>();
        childrenToUpdate.addAll(getUpdatedDepartmentCourseGroupLessons(newMap, oldMap));
        if (!childrenToUpdate.isEmpty()) {
            update childrenToUpdate;
        }
    }

    private static List<DepartmentCourseGroupLesson__c> getUpdatedDepartmentCourseGroupLessons(Map<Id, DepartmentCourseGroup__c> newMap, Map<Id, DepartmentCourseGroup__c> oldMap) {
        List<DepartmentCourseGroupLesson__c> lessonsToUpdate = new List<DepartmentCourseGroupLesson__c>();
        Map<Id, List<DepartmentCourseGroupLesson__c>> depCourseGroupToLessonsMap = new Map<Id, List<DepartmentCourseGroupLesson__c>>();
        for (DepartmentCourseGroupLesson__c lsn : [SELECT DepartmentCourseGroup__c, IsActive__c 
                                                   FROM DepartmentCourseGroupLesson__c 
                                                   WHERE DepartmentCourseGroup__c IN :newMap.keySet()])
        {
            if (depCourseGroupToLessonsMap.get(lsn.DepartmentCourseGroup__c) == null) {
                depCourseGroupToLessonsMap.put(lsn.DepartmentCourseGroup__c, new List<DepartmentCourseGroupLesson__c>());
            }
            depCourseGroupToLessonsMap.get(lsn.DepartmentCourseGroup__c).add(lsn);
        }
        for (Id depCourseGroupId : depCourseGroupToLessonsMap.keySet()) {
            DepartmentCourseGroup__c newDepCourseGroup = newMap.get(depCourseGroupId);
            DepartmentCourseGroup__c oldDepCourseGroup = oldMap.get(depCourseGroupId);
            Boolean isInactivated = !newDepCourseGroup.IsActive__c && oldDepCourseGroup.IsActive__c;
            if (isInactivated) {
                for (DepartmentCourseGroupLesson__c lsn : depCourseGroupToLessonsMap.get(depCourseGroupId)) {
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
