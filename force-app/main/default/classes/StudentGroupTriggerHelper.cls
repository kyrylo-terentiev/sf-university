public with sharing class StudentGroupTriggerHelper {
    
    public static void validateHeadOfGroup(List<StudentGroup__c> newList) {
        Map<Id, Id> groupToHeadMap = new Map<Id, Id>();
        Map<Id, StudentGroup__c> groupMap = new Map<Id, StudentGroup__c>();
        for (StudentGroup__c studGroup : newList) {
            if (studGroup.Id != null) {
                groupMap.put(studGroup.Id, studGroup);
                groupToHeadMap.put(studGroup.Id, studGroup.HeadOfGroup__c);
            } else if (studGroup.HeadOfGroup__c != null) {
                studGroup.HeadOfGroup__c.addError(System.Label.InactiveHeadOfGroup);
            }
        }
        Map<Id, StudentGroupMember__c> studToMemberMap = new Map<Id, StudentGroupMember__c>();
        for (StudentGroupMember__c groupMember : [SELECT Group__c, Student__c, IsActive__c
                                                  FROM StudentGroupMember__c
                                                  WHERE Group__c IN: groupToHeadMap.keySet()])
        {
            studToMemberMap.put(groupMember.Student__c, groupMember);
        }
        for (Id groupId : groupMap.keySet()) {
            if (groupToHeadMap.get(groupId) != null) {
                StudentGroupMember__c headOfGroup = studToMemberMap.get(groupToHeadMap.get(groupId));
                if ((headOfGroup != null && !headOfGroup.IsActive__c) || (headOfGroup == null && groupMap.get(groupId).HeadOfGroup__c != null)) {
                    groupMap.get(groupId).HeadOfGroup__c.addError(System.Label.InactiveHeadOfGroup);
                }
            }
        }
    }

    public static void validateGroupCourator(List<StudentGroup__c> newList) {
        Map<String, String> groupToCouratorMap = new Map<String, String>();
        Map<String, StudentGroup__c> groupMap = new Map<String, StudentGroup__c>();
        Set<Id> departmentIdSet = new Set<Id>();
        Integer id = 0;
        for (StudentGroup__c studGroup : newList) {
            departmentIdSet.add(studGroup.Department__c);
            if (studGroup.GroupCourator__c != null) {
                groupMap.put(studGroup.Id != null ? String.valueOf(studGroup.Id) : String.valueOf(id), studGroup);
                groupToCouratorMap.put(studGroup.Id != null ? String.valueOf(studGroup.Id) : String.valueOf(id), studGroup.GroupCourator__c);
            }
            id++;
        }
        Map<Id, DepartmentProfessor__c> profToDepProf = new Map<Id, DepartmentProfessor__c>();
        for (DepartmentProfessor__c depProf : [SELECT Professor__c, IsActive__c
                                               FROM DepartmentProfessor__c
                                               WHERE Department__c IN: departmentIdSet])
        {
            profToDepProf.put(depProf.Professor__c, depProf);
        }
        for (String groupId : groupMap.keySet()) {
            if (groupToCouratorMap.get(groupId) != null) {
                DepartmentProfessor__c groupCourator = profToDepProf.get(groupToCouratorMap.get(groupId));
                if ((groupCourator != null && !groupCourator.IsActive__c) || (groupCourator == null && groupMap.get(groupId).GroupCourator__c != null)) {
                    groupMap.get(groupId).GroupCourator__c.addError(System.Label.InactiveGroupCourator);
                }
            }
        }
    }

    public static void updateChildren(Map<Id, StudentGroup__c> newMap, Map<Id, StudentGroup__c> oldMap) {
        List<sObject> childrenToUpdate = new List<sObject>();
        childrenToUpdate.addAll(getUpdatedGroupMembers(newMap, oldMap));
        childrenToUpdate.addAll(getUpdatedDepartmentCourseGroups(newMap, oldMap));
        if (!childrenToUpdate.isEmpty()) {
            update childrenToUpdate;
        }
    }

    public static List<StudentGroupMember__c> getUpdatedGroupMembers(Map<Id, StudentGroup__c> newMap, Map<Id, StudentGroup__c> oldMap) {
        List<StudentGroupMember__c> groupMembersToUpdate = new List<StudentGroupMember__c>();
        Map<Id, List<StudentGroupMember__c>> groupToGroupMembersMap = new Map<Id, List<StudentGroupMember__c>>();
        for (StudentGroupMember__c groupMember : [SELECT Student__c, Group__c, IsActive__c 
                                                  FROM StudentGroupMember__c 
                                                  WHERE Group__c IN :newMap.keySet()])
        {
            if (groupToGroupMembersMap.get(groupMember.Group__c) == null) {
                groupToGroupMembersMap.put(groupMember.Group__c, new List<StudentGroupMember__c>());
            }
            groupToGroupMembersMap.get(groupMember.Group__c).add(groupMember);
        }
        for (Id groupId : groupToGroupMembersMap.keySet()) {
            StudentGroup__c newGroup = newMap.get(groupId);
            StudentGroup__c oldGroup = oldMap.get(groupId);
            Boolean isInactivated = !newGroup.IsActive__c && oldGroup.IsActive__c;
            if (isInactivated) {
                for (StudentGroupMember__c groupMember : groupToGroupMembersMap.get(groupId)) {
                    if (groupMember.IsActive__c) {
                        groupMember.IsActive__c = false;
                        groupMembersToUpdate.add(groupMember);
                    }
                }
            }
        }

        return groupMembersToUpdate;
    }

    public static List<DepartmentCourseGroup__c> getUpdatedDepartmentCourseGroups(Map<Id, StudentGroup__c> newMap, Map<Id, StudentGroup__c> oldMap) {
        List<DepartmentCourseGroup__c> depCourseGroupsToUpdate = new List<DepartmentCourseGroup__c>();
        Map<Id, List<DepartmentCourseGroup__c>> groupToDepCourseGroupsMap = new Map<Id, List<DepartmentCourseGroup__c>>();
        for (DepartmentCourseGroup__c depCourseGroup : [SELECT StudentGroup__c, IsActive__c 
                                                  FROM DepartmentCourseGroup__c 
                                                  WHERE StudentGroup__c IN :newMap.keySet()])
        {
            if (groupToDepCourseGroupsMap.get(depCourseGroup.StudentGroup__c) == null) {
                groupToDepCourseGroupsMap.put(depCourseGroup.StudentGroup__c, new List<DepartmentCourseGroup__c>());
            }
            groupToDepCourseGroupsMap.get(depCourseGroup.StudentGroup__c).add(depCourseGroup);
        }
        for (Id groupId : groupToDepCourseGroupsMap.keySet()) {
            StudentGroup__c newGroup = newMap.get(groupId);
            StudentGroup__c oldGroup = oldMap.get(groupId);
            Boolean isInactivated = !newGroup.IsActive__c && oldGroup.IsActive__c;
            if (isInactivated) {
                for (DepartmentCourseGroup__c depCourseGroup : groupToDepCourseGroupsMap.get(groupId)) {
                    if (depCourseGroup.IsActive__c) {
                        depCourseGroup.IsActive__c = false;
                    }
                    depCourseGroupsToUpdate.add(depCourseGroup);
                }
            }
        }

        return depCourseGroupsToUpdate;
    }
}