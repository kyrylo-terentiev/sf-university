public with sharing class StudentGroupTriggerHelper {
    
    public static void updateChildren(Map<Id, StudentGroup__c> newMap, Map<Id, StudentGroup__c> oldMap) {
        List<sObject> childrenToUpdate = new List<sObject>();
        childrenToUpdate.addAll(getUpdatedGroupMembers(newMap, oldMap));
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
}
