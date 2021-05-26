public with sharing class StudentGroupMemberTriggerHelper {

    public static void validateGroup(List<StudentGroupMember__c> newList, Map<Id, StudentGroupMember__c> oldMap) {
        Set<Id> groupIdSet = new Set<Id>();
        for (StudentGroupMember__c groupMember : newList) {
            groupIdSet.add(groupMember.Group__c);
        }
        Map<Id, StudentGroup__c> groupMap = new Map<Id, StudentGroup__c>([
            SELECT IsActive__c
            FROM StudentGroup__c
            WHERE Id IN :groupIdSet
        ]);
        for (StudentGroupMember__c groupMember : newList) {
            Boolean isActiveGroup = groupMap.get(groupMember.Group__c)?.IsActive__c != null
                                    ? groupMap.get(groupMember.Group__c).IsActive__c
                                    : false;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(groupMember.Id);
            Boolean isInactivation = isUpdate && !groupMember.IsActive__c && oldMap.get(groupMember.Id).IsActive__c;
            if (!isActiveGroup && !isInactivation) {
                groupMember.addError(System.Label.InactiveStudentGroup);
            }
        }
    }

    public static void validateStudent(List<StudentGroupMember__c> newList, Map<Id, StudentGroupMember__c> oldMap) {
        Set<Id> studentIdSet = new Set<Id>();
        for (StudentGroupMember__c groupMember : newList) {
            studentIdSet.add(groupMember.Student__c);
        }
        Map<Id, Student__c> studentMap = new Map<Id, Student__c>([
            SELECT IsActive__c
            FROM Student__c
            WHERE Id IN :studentIdSet
        ]);
        for (StudentGroupMember__c groupMember : newList) {
            Boolean isActiveStudent = studentMap.get(groupMember.Student__c)?.IsActive__c != null
                                      ? studentMap.get(groupMember.Student__c).IsActive__c
                                      : false;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(groupMember.Id);
            Boolean isInactivation = isUpdate && !groupMember.IsActive__c && oldMap.get(groupMember.Id).IsActive__c;
            if (!isActiveStudent && !isInactivation) {
                groupMember.addError(System.Label.InactiveStudent);
            }
        }
    }

    public static void validateGroupMember(List<StudentGroupMember__c> newList, Map<Id, StudentGroupMember__c> oldMap) {
        Map<Id, Map<Id, StudentGroupMember__c>> studentToGroupToMember = new Map<Id, Map<Id, StudentGroupMember__c>>();
        for (StudentGroupMember__c groupMember : newList) {
            studentToGroupToMember.put(groupMember.Student__c, new Map<Id, StudentGroupMember__c>());
            studentToGroupToMember.get(groupMember.Student__c).put(groupMember.Group__c, null);
        }
        for (StudentGroupMember__c groupMember : [SELECT Student__c, Group__c, IsActive__c 
                                                  FROM StudentGroupMember__c 
                                                  WHERE Student__c IN :studentToGroupToMember.keySet()])
        {
            if (studentToGroupToMember.get(groupMember.Student__c).containsKey(groupMember.Group__c)) {
                studentToGroupToMember.get(groupMember.Student__c).put(groupMember.Group__c, groupMember);
            }
        }
        for (StudentGroupMember__c groupMember : newList) {
            StudentGroupMember__c duplGroupMember = studentToGroupToMember.get(groupMember.Student__c).get(groupMember.Group__c);
            Boolean isDuplicate = duplGroupMember != null;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(groupMember.Id);
            if (isUpdate && isDuplicate) {
                isDuplicate = oldMap.get(groupMember.Id).Id != duplGroupMember.Id;
            }
            Boolean isInactivation = isUpdate && !groupMember.IsActive__c && oldMap.get(groupMember.Id).IsActive__c;
            if (isDuplicate && !isInactivation) {
                groupMember.addError(System.Label.DuplicateStudentGroupMember);
            }
        }
    }

    public static void updateChildren(Map<Id, StudentGroupMember__c> newMap, Map<Id, StudentGroupMember__c> oldMap) {
        List<SObject> childrenToUpdate = new List<SObject>();
        childrenToUpdate.addAll(getUpdatedGroups(newMap, oldMap));
        childrenToUpdate.addAll(getUpdatedStudentLessonAttendances(newMap, oldMap));
        if (!childrenToUpdate.isEmpty()) {
            update childrenToUpdate;
        }
    }

    private static List<StudentGroup__c> getUpdatedGroups(Map<Id, StudentGroupMember__c> newMap, Map<Id, StudentGroupMember__c> oldMap) {
        Map<Id, StudentGroupMember__c> studToGroupMemberMap = new Map<Id, StudentGroupMember__c>();
        for (StudentGroupMember__c groupMember : newMap.values()) {
            studToGroupMemberMap.put(groupMember.Student__c, groupMember);
        }
        List<StudentGroup__c> groupsToUpdate = new List<StudentGroup__c>();
        Map<Id, List<StudentGroup__c>> studToGroupsMap = new Map<Id, List<StudentGroup__c>>();
        for (StudentGroup__c studGroup : [SELECT HeadOfGroup__c, IsActive__c 
                                          FROM StudentGroup__c 
                                          WHERE HeadOfGroup__c IN :studToGroupMemberMap.keySet()])
        {
            if (studToGroupsMap.get(studGroup.HeadOfGroup__c) == null) {
                studToGroupsMap.put(studGroup.HeadOfGroup__c, new List<StudentGroup__c>());
            }
            studToGroupsMap.get(studGroup.HeadOfGroup__c).add(studGroup);
        }
        for (Id studId : studToGroupsMap.keySet()) {
            StudentGroupMember__c newMember = studToGroupMemberMap.get(studId);
            if (!newMember.IsActive__c) {
                for (StudentGroup__c studGroup : studToGroupsMap.get(studId)) {
                    studGroup.HeadOfGroup__c = null;
                    groupsToUpdate.add(studGroup);
                }
            }
        }

        return groupsToUpdate;
    }

    private static List<StudentLessonAttendance__c> getUpdatedStudentLessonAttendances(Map<Id, StudentGroupMember__c> newMap, Map<Id, StudentGroupMember__c> oldMap) {
        List<StudentLessonAttendance__c> studentAttendancesToUpdate = new List<StudentLessonAttendance__c>();
        Map<Id, List<StudentLessonAttendance__c>> groupMemberToStudentAttendancesMap = new Map<Id, List<StudentLessonAttendance__c>>();
        for (StudentLessonAttendance__c attendance : [SELECT StudentGroupMember__c, IsActive__c 
                                                   FROM StudentLessonAttendance__c 
                                                   WHERE StudentGroupMember__c IN :newMap.keySet()])
        {
            if (groupMemberToStudentAttendancesMap.get(attendance.StudentGroupMember__c) == null) {
                groupMemberToStudentAttendancesMap.put(attendance.StudentGroupMember__c, new List<StudentLessonAttendance__c>());
            }
            groupMemberToStudentAttendancesMap.get(attendance.StudentGroupMember__c).add(attendance);
        }
        for (Id groupMemberId : groupMemberToStudentAttendancesMap.keySet()) {
            StudentGroupMember__c newGroupMember = newMap.get(groupMemberId);
            StudentGroupMember__c oldGroupMember = oldMap.get(groupMemberId);
            Boolean isInactivated = !newGroupMember.IsActive__c && oldGroupMember.IsActive__c;
            if (isInactivated) {
                for (StudentLessonAttendance__c attendance : groupMemberToStudentAttendancesMap.get(groupMemberId)) {
                    if (attendance.IsActive__c) {
                        attendance.IsActive__c = false;
                        studentAttendancesToUpdate.add(attendance);
                    }
                }
            }
        }

        return studentAttendancesToUpdate;
    }
}