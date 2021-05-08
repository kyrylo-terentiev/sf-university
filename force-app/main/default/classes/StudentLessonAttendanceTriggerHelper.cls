public with sharing class StudentLessonAttendanceTriggerHelper {
     
    public static void validate(List<StudentLessonAttendance__c> newList, Map<Id, StudentLessonAttendance__c> oldMap) {
        setStudentGroupMember(newList);
        setStudentGroupLesson(newList);
        validateStudentGroupMember(newList, oldMap);
        validateStudentGroupLesson(newList, oldMap);
        setCourse(newList);
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
        Set<Id> groupMemberIdSet = new Set<Id>();
        for (StudentLessonAttendance__c attendance : newList) {
            groupMemberIdSet.add(attendance.StudentGroupMember__c);
        }
        Map<Id, StudentGroupMember__c> groupMemberMap = new Map<Id, StudentGroupMember__c>([
            SELECT IsActive__c
            FROM StudentGroupMember__c
            WHERE Id IN :groupMemberIdSet
        ]);
        for (StudentLessonAttendance__c attendance : newList) {
            Boolean isActiveGroupMember = groupMemberMap.get(attendance.StudentGroupMember__c)?.IsActive__c != null
                                          ? groupMemberMap.get(attendance.StudentGroupMember__c).IsActive__c
                                          : false;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(attendance.Id);
            if (!isActiveGroupMember && !isUpdate) {
                attendance.addError(System.Label.InactiveStudentGroupMember);
            }
        }
    }

    private static void validateStudentGroupLesson(List<StudentLessonAttendance__c> newList, Map<Id, StudentLessonAttendance__c> oldMap) {
        Set<Id> groupLessonIdSet = new Set<Id>();
        for (StudentLessonAttendance__c attendance : newList) {
            groupLessonIdSet.add(attendance.DepartmentCourseGroupLesson__c);
        }
        Map<Id, DepartmentCourseGroupLesson__c> groupLessonMap = new Map<Id, DepartmentCourseGroupLesson__c>([
            SELECT IsActive__c
            FROM DepartmentCourseGroupLesson__c
            WHERE Id IN :groupLessonIdSet
        ]);
        for (StudentLessonAttendance__c attendance : newList) {
            Boolean isActiveGroupLesson = groupLessonMap.get(attendance.DepartmentCourseGroupLesson__c)?.IsActive__c != null
                                          ? groupLessonMap.get(attendance.DepartmentCourseGroupLesson__c).IsActive__c
                                          : false;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(attendance.Id);
            if (!isActiveGroupLesson && !isUpdate) {
                attendance.addError(System.Label.InactiveStudentGroupLesson);
            }
        }
    }

    private static void setCourse(List<StudentLessonAttendance__c> newList) {
        Map<Id, List<StudentLessonAttendance__c>> lessonToAttendancesMap = new Map<Id, List<StudentLessonAttendance__c>>();
        for (StudentLessonAttendance__c attendance : newList) {
            if (lessonToAttendancesMap.get(attendance.Lesson__c) == null) {
                lessonToAttendancesMap.put(attendance.Lesson__c, new List<StudentLessonAttendance__c>());
            }
            lessonToAttendancesMap.get(attendance.Lesson__c).add(attendance);
        }
        Map<Id, Lesson__c> lessonMap = new Map<Id, Lesson__c>([
            SELECT Course__c 
            FROM Lesson__c
            WHERE Id IN :lessonToAttendancesMap.keySet()
        ]);
        for (Id lessonId : lessonToAttendancesMap.keySet()) {
            for (StudentLessonAttendance__c attendance : lessonToAttendancesMap.get(lessonId)) {
                attendance.Course__c = lessonMap.get(lessonId).Course__c;
            }
        }
    }

    private static void validateDuplicate(List<StudentLessonAttendance__c> newList, Map<Id, StudentLessonAttendance__c> oldMap) {
        Map<Id, Map<Id, StudentLessonAttendance__c>> studentToLessonToAttendanceMap = new Map<Id, Map<Id, StudentLessonAttendance__c>>();
        for (StudentLessonAttendance__c groupLsn : newList) {
            studentToLessonToAttendanceMap.put(groupLsn.Student__c, new Map<Id, StudentLessonAttendance__c>());
            studentToLessonToAttendanceMap.get(groupLsn.Student__c).put(groupLsn.Lesson__c, null);
        }
        for (StudentLessonAttendance__c attendance : [SELECT Student__c, Lesson__c 
                                                      FROM StudentLessonAttendance__c 
                                                      WHERE Student__c IN :studentToLessonToAttendanceMap.keySet()])
        {
            if (studentToLessonToAttendanceMap.get(attendance.Student__c).containsKey(attendance.Lesson__c)) {
                studentToLessonToAttendanceMap.get(attendance.Student__c).put(attendance.Lesson__c, attendance);
            }
        }
        for (StudentLessonAttendance__c attendance : newList) {
            StudentLessonAttendance__c duplAttendance = studentToLessonToAttendanceMap.get(attendance.Student__c).get(attendance.Lesson__c);
            Boolean isDuplicate = duplAttendance != null;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(attendance.Id);
            if (isUpdate && isDuplicate) {
                isDuplicate = oldMap.get(attendance.Id).Id != duplAttendance.Id;
            }
            if (isDuplicate) {
                attendance.addError(System.Label.StudentLessonAttendance);
            }
        }
    }

    public static void updateGroupLesson(List<StudentLessonAttendance__c> newList) {
        Set<Id> groupLessonIdSet = new Set<Id>();
        for (StudentLessonAttendance__c attendance : newList) {
            groupLessonIdSet.add(attendance.DepartmentCourseGroupLesson__c);
        }
        Map<Id, List<StudentLessonAttendance__c>> groupLessonToAttendances = new Map<Id, List<StudentLessonAttendance__c>>();
        for (StudentLessonAttendance__c attendance : [SELECT DepartmentCourseGroupLesson__c
                                                      FROM StudentLessonAttendance__c
                                                      WHERE Id IN :groupLessonIdSet
                                                        AND IsAttending__c = TRUE])
        {
            if (groupLessonToAttendances.get(attendance.DepartmentCourseGroupLesson__c) == null) {
                groupLessonToAttendances.put(attendance.DepartmentCourseGroupLesson__c, new List<StudentLessonAttendance__c>());
            }
            groupLessonToAttendances.get(attendance.DepartmentCourseGroupLesson__c).add(attendance);
        }
        List<DepartmentCourseGroupLesson__c> groupLessonsToUpdate = new List<DepartmentCourseGroupLesson__c>();
        for (Id groupLessonId : groupLessonToAttendances.keySet()) {
            Integer attendingStudents = groupLessonToAttendances.get(groupLessonId).size();
            groupLessonsToUpdate.add(
                new DepartmentCourseGroupLesson__c(
                    Id = groupLessonId,
                    AttendingStudents__c = attendingStudents
                )
            );
        }
        if (!groupLessonsToUpdate.isEmpty()) {
            update groupLessonsToUpdate;
        }
    }
}