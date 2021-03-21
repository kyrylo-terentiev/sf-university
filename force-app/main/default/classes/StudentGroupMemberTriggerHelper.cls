public with sharing class StudentGroupMemberTriggerHelper {

    public static void validateGroup(List<StudentGroupMember__c> newList) {
        Set<Id> groupIdSet = new Set<Id>();
        for (StudentGroupMember__c groupMember : newList) {
            groupIdSet.add(groupMember.Group__c);
        }
        Map<Id, StudentGroup__c> groupMap = new Map<Id, StudentGroup__c>([
            SELECT Id, IsActive__c
            FROM StudentGroup__c
            WHERE Id IN :groupIdSet
        ]);
        for (StudentGroupMember__c groupMember : newList) {
            if (!groupMap.get(groupMember.Group__c).IsActive__c) {
                groupMember.addError(System.Label.InactiveStudentGroup);
            }
        }
    }

    public static void validateStudent(List<StudentGroupMember__c> newList) {
        Set<Id> studentIdSet = new Set<Id>();
        for (StudentGroupMember__c groupMember : newList) {
            studentIdSet.add(groupMember.Student__c);
        }
        Map<Id, Student__c> studentMap = new Map<Id, Student__c>([
            SELECT Id, IsActive__c
            FROM Student__c
            WHERE Id IN :studentIdSet
        ]);
        for (StudentGroupMember__c groupMember : newList) {
            if (!studentMap.get(groupMember.Student__c).IsActive__c) {
                groupMember.addError(System.Label.InactiveStudent);
            }
        }
    }

    public static void validateGroupMember(List<StudentGroupMember__c> newList) {

    }
}
