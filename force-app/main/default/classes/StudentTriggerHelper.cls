public with sharing class StudentTriggerHelper {
    
    public static void setStudentName(List<Student__c> newList) {
        Map<Id, Student__c> accToStudMap = new Map<Id, Student__c>();
        for (Student__c stud : newList) {
            accToStudMap.put(stud.Account__c, stud);
        }
        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Name
            FROM Account
            WHERE Id IN :accToStudMap.keySet()
        ]);
        for (Id accId : accToStudMap.keySet()) {
            accToStudMap.get(accId).Name = accMap.get(accId).Name;
        }
    }

    public static void validateStudentId(List<Student__c> newList) {
        for (Student__c stud : newList) {
            if (!Utils.validateStudentId(stud.StudentID__c)) {
                stud.StudentID__c.addError(System.Label.InvalidStudentID);
            }
        }
    }

    public static void updateChildren(Map<Id, Student__c> newMap, Map<Id, Student__c> oldMap) {
        List<sObject> childrenToUpdate = new List<sObject>();
        childrenToUpdate.addAll(getUpdatedGroupMembers(newMap, oldMap));
        if (!childrenToUpdate.isEmpty()) {
            update childrenToUpdate;
        }
    }

    public static List<StudentGroupMember__c> getUpdatedGroupMembers(Map<Id, Student__c> newMap, Map<Id, Student__c> oldMap) {
        List<StudentGroupMember__c> groupMembersToUpdate = new List<StudentGroupMember__c>();
        Map<Id, List<StudentGroupMember__c>> studToGroupMembersMap = new Map<Id, List<StudentGroupMember__c>>();
        for (StudentGroupMember__c groupMember : [SELECT Student__c, Group__c, IsActive__c 
                                                  FROM StudentGroupMember__c 
                                                  WHERE Student__c IN :newMap.keySet()])
        {
            if (studToGroupMembersMap.get(groupMember.Student__c) == null) {
                studToGroupMembersMap.put(groupMember.Student__c, new List<StudentGroupMember__c>());
            }
            studToGroupMembersMap.get(groupMember.Student__c).add(groupMember);
        }
        for (Id studId : studToGroupMembersMap.keySet()) {
            Student__c newStud = newMap.get(studId);
            Student__c oldStud = oldMap.get(studId);
            Boolean isInactivated = !newStud.IsActive__c && oldStud.IsActive__c;
            if (isInactivated) {
                for (StudentGroupMember__c groupMember : studToGroupMembersMap.get(studId)) {
                    if (groupMember.IsActive__c) {
                        groupMember.IsActive__c = false;
                        groupMembersToUpdate.add(groupMember);
                    }
                }
            }
        }

        return groupMembersToUpdate;
    }
}
