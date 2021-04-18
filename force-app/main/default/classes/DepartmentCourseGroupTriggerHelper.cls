public with sharing class DepartmentCourseGroupTriggerHelper {

    public static void validate(List<DepartmentCourseGroup__c> newList, Map<Id, DepartmentCourseGroup__c> oldMap) {
        validateGroup(newList, oldMap);
        setDepartment(newList);
        setDepartmentCourse(newList);
        validateDepartmentCourse(newList, oldMap);
        validateDepartmentCourseGroup(newList, oldMap);
    }

    private static void validateGroup(List<DepartmentCourseGroup__c> newList, Map<Id, DepartmentCourseGroup__c> oldMap) {
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
            Boolean isActiveGroup = groupMap.get(depCourseGroup.StudentGroup__c)?.IsActive__c != null
                                    ? groupMap.get(depCourseGroup.StudentGroup__c).IsActive__c
                                    : false;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depCourseGroup.Id);
            Boolean isInactivation = isUpdate && !depCourseGroup.IsActive__c && oldMap.get(depCourseGroup.Id).IsActive__c;
            if (!isActiveGroup && !isInactivation) {
                depCourseGroup.StudentGroup__c.addError(System.Label.InactiveStudentGroup);
            }
        }
    }

    private static void setDepartment(List<DepartmentCourseGroup__c> newList) {
        Set<Id> groupIdSet = new Set<Id>();
        for (DepartmentCourseGroup__c depCourseGroup : newList) {
            groupIdSet.add(depCourseGroup.StudentGroup__c);
        }
        Map<Id, Id> groupToDeptMap = new Map<Id, Id>();
        for (StudentGroup__c studGroup : [SELECT Department__c
                              FROM StudentGroup__c
                              WHERE Id IN :groupIdSet])
        {
            groupToDeptMap.put(studGroup.Id, studGroup.Department__c);
        }
        for (DepartmentCourseGroup__c depCourseGroup : newList) {
            depCourseGroup.Department__c = groupToDeptMap.get(depCourseGroup.StudentGroup__c);
        }
    }

    private static void setDepartmentCourse(List<DepartmentCourseGroup__c> newList) {
        Map<String, List<DepartmentCourseGroup__c>> deptAndCourseToDepCourseGroupsMap = new Map<String, List<DepartmentCourseGroup__c>>();
        Set<Id> deptIdSet = new Set<Id>();
        Set<Id> courseIdSet = new Set<Id>();
        for (DepartmentCourseGroup__c depCourseGroup : newList) {
            deptIdSet.add(depCourseGroup.Department__c);
            courseIdSet.add(depCourseGroup.Course__c);
            String deptAndCourseId = String.valueOf(depCourseGroup.Department__c) + String.valueOf(depCourseGroup.Course__c);
            if (deptAndCourseToDepCourseGroupsMap.get(deptAndCourseId) == null) {
                deptAndCourseToDepCourseGroupsMap.put(deptAndCourseId, new List<DepartmentCourseGroup__c>());
            }
            deptAndCourseToDepCourseGroupsMap.get(deptAndCourseId).add(depCourseGroup);
        }
        List<DepartmentCourse__c> depCourseList = [
            SELECT Id
                , Department__c
                , Course__c
            FROM DepartmentCourse__c
            WHERE 
                Department__c IN :deptIdSet AND
                Course__c IN :courseIdSet
        ];
        Map<String, Id> deptAndCourseToDepCourseMap = new Map<String, Id>();
        for (DepartmentCourse__c depCourse : depCourseList) {
            String deptAndCourseId = String.valueOf(depCourse.Department__c) + String.valueOf(depCourse.Course__c);
            deptAndCourseToDepCourseMap.put(deptAndCourseId, depCourse.Id);
        }
        for (String deptAndCourseId : deptAndCourseToDepCourseGroupsMap.keySet()) {
            List<DepartmentCourseGroup__c> depCourseGroups = deptAndCourseToDepCourseGroupsMap.get(deptAndCourseId);
            Id depCourseId = deptAndCourseToDepCourseMap.get(deptAndCourseId);
            for (DepartmentCourseGroup__c depCourseGroup : depCourseGroups) {
                if (depCourseId == null) {
                    depCourseGroup.addError(System.Label.DepartmentCourseGroupDepartmentCourseNotFound);
                } else {
                    depCourseGroup.DepartmentCourse__c = depCourseId;
                }
            }
        }
    }

    private static void validateDepartmentCourse(List<DepartmentCourseGroup__c> newList, Map<Id, DepartmentCourseGroup__c> oldMap) {
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
            Boolean isActiveDepCourse = depCourseMap.get(depCourseGroup.DepartmentCourse__c)?.IsActive__c != null
                                        ? depCourseMap.get(depCourseGroup.DepartmentCourse__c).IsActive__c
                                        : false;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depCourseGroup.Id);
            Boolean isInactivation = isUpdate && !depCourseGroup.IsActive__c;
            if (!isActiveDepCourse && !isInactivation) {
                depCourseGroup.DepartmentCourse__c.addError(System.Label.InactiveDepartmentCourse);
            }
        }
    }

    private static void validateDepartmentCourseGroup(List<DepartmentCourseGroup__c> newList, Map<Id, DepartmentCourseGroup__c> oldMap) {
        Map<Id, Map<Id, DepartmentCourseGroup__c>> depCourseToGroupToDepCourseGroupMap = new Map<Id, Map<Id, DepartmentCourseGroup__c>>();
        for (DepartmentCourseGroup__c depCourseGroup : newList) {
            depCourseToGroupToDepCourseGroupMap.put(depCourseGroup.DepartmentCourse__c, new Map<Id, DepartmentCourseGroup__c>());
            depCourseToGroupToDepCourseGroupMap.get(depCourseGroup.DepartmentCourse__c).put(depCourseGroup.StudentGroup__c, null);
        }
        for (DepartmentCourseGroup__c depCourseGroup : [SELECT DepartmentCourse__c, StudentGroup__c, IsActive__c 
                                                        FROM DepartmentCourseGroup__c 
                                                        WHERE DepartmentCourse__c IN :depCourseToGroupToDepCourseGroupMap.keySet()])
        {
            if (depCourseToGroupToDepCourseGroupMap.get(depCourseGroup.DepartmentCourse__c).containsKey(depCourseGroup.StudentGroup__c)) {
                depCourseToGroupToDepCourseGroupMap.get(depCourseGroup.DepartmentCourse__c).put(depCourseGroup.StudentGroup__c, depCourseGroup);
            }
        }
        for (DepartmentCourseGroup__c depCourseGroup : newList) {
            DepartmentCourseGroup__c duplDepCourseGroup = depCourseToGroupToDepCourseGroupMap.get(depCourseGroup.DepartmentCourse__c).get(depCourseGroup.StudentGroup__c);
            Boolean isDuplicate = duplDepCourseGroup != null;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depCourseGroup.Id);
            if (isUpdate && isDuplicate) {
                isDuplicate = oldMap.get(depCourseGroup.Id).Id != duplDepCourseGroup.Id;
            }
            Boolean isInactivation = isUpdate && !depCourseGroup.IsActive__c && oldMap.get(depCourseGroup.Id).IsActive__c;
            if (isDuplicate && !isInactivation) {
                depCourseGroup.addError(System.Label.DuplicateDepartmentCourseGroup);
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