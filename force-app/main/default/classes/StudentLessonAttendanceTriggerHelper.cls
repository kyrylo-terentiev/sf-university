public with sharing class StudentLessonAttendanceTriggerHelper {
     
    public static void validate(List<StudentLessonAttendance__c> newList, Map<Id, StudentLessonAttendance__c> oldMap) {
        setStudentGroupMember(newList);
        setStudentGroupLesson(newList);
        validateStudentGroupMember(newList, oldMap);
        validateStudentGroupLesson(newList, oldMap);
        validateDuplicate(newList, oldMap);
    }

    private static void setStudentGroupMember(List<StudentLessonAttendance__c> newList) {
        Map<String, List<StudentLessonAttendance__c>> studentAndGroupToAttendance = new Map<String, List<StudentLessonAttendance__c>>();
        Set<Id> studentIdSet = new Set<Id>();
        Set<Id> groupIdSet = new Set<Id>();
        for (StudentLessonAttendance__c attendance : newList) {
            studentIdSet.add(attendance.Student__c);
            groupIdSet.add(attendance.StudentGroup__c);
            String studentAndGroupId = String.valueOf(attendance.Student__c) + String.valueOf(attendance.StudentGroup__c);
            if (studentAndGroupToAttendance.get(studentAndGroupId) == null) {
                studentAndGroupToAttendance.put(studentAndGroupId, new List<StudentLessonAttendance__c>());
            }
            studentAndGroupToAttendance.get(studentAndGroupId).add(attendance);
        }
        List<StudentGroupMember__c> groupMemberList = [
            SELECT Id
                , Student__c
                , Group__c
            FROM StudentGroupMember__c
            WHERE 
                Student__c IN :studentIdSet AND
                Group__c IN :groupIdSet
        ];
        Map<String, Id> studentAndGroupToGroupMemberMap = new Map<String, Id>();
        for (StudentGroupMember__c member : groupMemberList) {
            String studentAndGroupId = String.valueOf(member.Student__c) + String.valueOf(member.Group__c);
            studentAndGroupToGroupMemberMap.put(studentAndGroupId, member.Id);
        }
        for (String studentAndGroupId : studentAndGroupToAttendance.keySet()) {
            List<StudentLessonAttendance__c> attendances = studentAndGroupToAttendance.get(studentAndGroupId);
            Id memberId = studentAndGroupToGroupMemberMap.get(studentAndGroupId);
            for (StudentLessonAttendance__c attendance : attendances) {
                if (memberId == null) {
                    attendance.addError(System.Label.StudentGroupMemberNotFound);
                } else {
                    attendance.StudentGroupMember__c = memberId;
                }
            }
        }
    }

    private static void setStudentGroupLesson(List<StudentLessonAttendance__c> newList) {
        Map<String, List<StudentLessonAttendance__c>> groupAndLessonToAttendance = new Map<String, List<StudentLessonAttendance__c>>();
        Set<Id> groupIdSet = new Set<Id>();
        Set<Id> lessonIdSet = new Set<Id>();
        for (StudentLessonAttendance__c attendance : newList) {
            groupIdSet.add(attendance.StudentGroup__c);
            lessonIdSet.add(attendance.Lesson__c);
            String groupAndLessonId = String.valueOf(attendance.StudentGroup__c) + String.valueOf(attendance.Lesson__c);
            if (groupAndLessonToAttendance.get(groupAndLessonId) == null) {
                groupAndLessonToAttendance.put(groupAndLessonId, new List<StudentLessonAttendance__c>());
            }
            groupAndLessonToAttendance.get(groupAndLessonId).add(attendance);
        }
        List<DepartmentCourseGroupLesson__c> groupLessonList = [
            SELECT Id
                , StudentGroup__c
                , Lesson__c
            FROM DepartmentCourseGroupLesson__c
            WHERE 
                StudentGroup__c IN :groupIdSet AND
                Lesson__c IN :lessonIdSet
        ];
        Map<String, Id> groupAndLessonToGroupLessonMap = new Map<String, Id>();
        for (DepartmentCourseGroupLesson__c groupLsn : groupLessonList) {
            String groupAndLessonId = String.valueOf(groupLsn.StudentGroup__c) + String.valueOf(groupLsn.Lesson__c);
            groupAndLessonToGroupLessonMap.put(groupAndLessonId, groupLsn.Id);
        }
        for (String groupAndLessonId : groupAndLessonToAttendance.keySet()) {
            List<StudentLessonAttendance__c> attendances = groupAndLessonToAttendance.get(groupAndLessonId);
            Id groupLessonId = groupAndLessonToGroupLessonMap.get(groupAndLessonId);
            for (StudentLessonAttendance__c attendance : attendances) {
                if (groupLessonId == null) {
                    attendance.addError(System.Label.StudentGroupLessonNotFound);
                } else {
                    attendance.DepartmentCourseGroupLesson__c = groupLessonId;
                }
            }
        }
    }

    private static void validateStudentGroupMember(List<StudentLessonAttendance__c> newList, Map<Id, StudentLessonAttendance__c> oldMap) {
        
    }

    private static void validateStudentGroupLesson(List<StudentLessonAttendance__c> newList, Map<Id, StudentLessonAttendance__c> oldMap) {
        
    }

    private static void validateDuplicate(List<StudentLessonAttendance__c> newList, Map<Id, StudentLessonAttendance__c> oldMap) {
        
    }
}