public with sharing class DepartmentCourseGroupLessonTriggerHelper {
    
    public static void validate(List<DepartmentCourseGroupLesson__c> newList, Map<Id, DepartmentCourseGroupLesson__c> oldMap) {
        validateLesson(newList, oldMap);
        setCourse(newList);
        setDepartmentCourseGroup(newList);
        validateDepartmentCourseGroup(newList, oldMap);
        validateDepartmentCourseGroupLesson(newList, oldMap);
        validateDuplicate(newList, oldMap);
    }
    
    private static void validateLesson(List<DepartmentCourseGroupLesson__c> newList, Map<Id, DepartmentCourseGroupLesson__c> oldMap) {
        Set<Id> lessonIdSet = new Set<Id>();
        for (DepartmentCourseGroupLesson__c depCourseGroupLsn : newList) {
            lessonIdSet.add(depCourseGroupLsn.Lesson__c);
        }
        Map<Id, Lesson__c> lessonMap = new Map<Id, Lesson__c>([
            SELECT IsActive__c
            FROM Lesson__c
            WHERE Id IN :lessonIdSet
        ]);
        for (DepartmentCourseGroupLesson__c depCourseGroupLsn : newList) {
            Boolean isActiveLesson = lessonMap.get(depCourseGroupLsn.Lesson__c)?.IsActive__c != null
                                     ? lessonMap.get(depCourseGroupLsn.Lesson__c).IsActive__c
                                     : false;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depCourseGroupLsn.Id);
            Boolean isInactivation = isUpdate && !depCourseGroupLsn.IsActive__c;
            if (!isActiveLesson && !isInactivation) {
                depCourseGroupLsn.Lesson__c.addError(System.Label.InactiveLesson);
            }
        }
    }

    private static void setCourse(List<DepartmentCourseGroupLesson__c> newList) {
        Set<Id> lessonIdSet = new Set<Id>();
        for (DepartmentCourseGroupLesson__c depCourseGroupLsn : newList) {
            lessonIdSet.add(depCourseGroupLsn.Lesson__c);
        }
        Map<Id, Id> lessonToCourseMap = new Map<Id, Id>();
        for (Lesson__c lsn : [SELECT Course__c
                              FROM Lesson__c
                              WHERE Id IN :lessonIdSet])
        {
            lessonToCourseMap.put(lsn.Id, lsn.Course__c);
        }
        for (DepartmentCourseGroupLesson__c depCourseGroupLsn : newList) {
            depCourseGroupLsn.Course__c = lessonToCourseMap.get(depCourseGroupLsn.Lesson__c);
        }
    }


    private static void setDepartmentCourseGroup(List<DepartmentCourseGroupLesson__c> newList) {
        Map<String, List<DepartmentCourseGroupLesson__c>> groupAndCourseToLessonsMap = new Map<String, List<DepartmentCourseGroupLesson__c>>();
        Set<Id> groupIdSet = new Set<Id>();
        Set<Id> courseIdSet = new Set<Id>();
        for (DepartmentCourseGroupLesson__c lsn : newList) {
            groupIdSet.add(lsn.StudentGroup__c);
            courseIdSet.add(lsn.Course__c);
            String groupAndCourseId = String.valueOf(lsn.StudentGroup__c) + String.valueOf(lsn.Course__c);
            if (groupAndCourseToLessonsMap.get(groupAndCourseId) == null) {
                groupAndCourseToLessonsMap.put(groupAndCourseId, new List<DepartmentCourseGroupLesson__c>());
            }
            groupAndCourseToLessonsMap.get(groupAndCourseId).add(lsn);
        }
        List<DepartmentCourseGroup__c> depCourseGroupList = [
            SELECT Id
                , StudentGroup__c
                , DepartmentCourse__c
                , DepartmentCourse__r.Course__c
            FROM DepartmentCourseGroup__c
            WHERE
                StudentGroup__c IN :groupIdSet AND
                DepartmentCourse__r.Course__c IN :courseIdSet
        ];
        Map<String, Id> groupAndCourseToDepCourseGroupMap = new Map<String, Id>();
        for (DepartmentCourseGroup__c depCourseGroup : depCourseGroupList) {
            String groupAndCourseId = String.valueOf(depCourseGroup.StudentGroup__c) + String.valueOf(depCourseGroup.DepartmentCourse__r.Course__c);
            groupAndCourseToDepCourseGroupMap.put(groupAndCourseId, depCourseGroup.Id);
        }
        for (String groupAndCourseId : groupAndCourseToLessonsMap.keySet()) {
            List<DepartmentCourseGroupLesson__c> lessons = groupAndCourseToLessonsMap.get(groupAndCourseId);
            Id depCourseGroupId = groupAndCourseToDepCourseGroupMap.get(groupAndCourseId);
            for (DepartmentCourseGroupLesson__c lsn : lessons) {
                if (depCourseGroupId == null) {
                    lsn.addError(System.Label.LessonDepartmentCourseGroupNotFound);
                } else {
                    lsn.DepartmentCourseGroup__c = depCourseGroupId;
                }
            }
        }
    }

    private static void validateDepartmentCourseGroup(List<DepartmentCourseGroupLesson__c> newList, Map<Id, DepartmentCourseGroupLesson__c> oldMap) {
        Set<Id> depCourseGroupIdSet = new Set<Id>();
        for (DepartmentCourseGroupLesson__c lsn : newList) {
            depCourseGroupIdSet.add(lsn.DepartmentCourseGroup__c);
        }
        Map<Id, DepartmentCourseGroup__c> depCourseGroupMap = new Map<Id, DepartmentCourseGroup__c>([
            SELECT IsActive__c
            FROM DepartmentCourseGroup__c
            WHERE Id IN :depCourseGroupIdSet
        ]);
        for (DepartmentCourseGroupLesson__c lsn : newList) {
            Boolean isActiveDepCourseGroup = depCourseGroupMap.get(lsn.DepartmentCourseGroup__c)?.IsActive__c != null
                                            ? depCourseGroupMap.get(lsn.DepartmentCourseGroup__c).IsActive__c
                                            : false;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(lsn.Id);
            Boolean isInactivation = isUpdate && !lsn.IsActive__c;
            if (!isActiveDepCourseGroup && !isInactivation) {
                lsn.addError(System.Label.LessonDepartmentCourseGroupNotFound);
            }
        }
    }

    private static void validateDepartmentCourseGroupLesson(List<DepartmentCourseGroupLesson__c> newList, Map<Id, DepartmentCourseGroupLesson__c> oldMap) {
        // validate group time schedule, ensure this lesson does not overlap with another one
    }

    private static void validateDuplicate(List<DepartmentCourseGroupLesson__c> newList, Map<Id, DepartmentCourseGroupLesson__c> oldMap) {
        Map<Id, Map<Id, DepartmentCourseGroupLesson__c>> groupToLsnToGroupLsnMap = new Map<Id, Map<Id, DepartmentCourseGroupLesson__c>>();
        for (DepartmentCourseGroupLesson__c groupLsn : newList) {
            groupToLsnToGroupLsnMap.put(groupLsn.DepartmentCourseGroup__c, new Map<Id, DepartmentCourseGroupLesson__c>());
            groupToLsnToGroupLsnMap.get(groupLsn.DepartmentCourseGroup__c).put(groupLsn.Lesson__c, null);
        }
        for (DepartmentCourseGroupLesson__c groupLsn : [SELECT DepartmentCourseGroup__c, Lesson__c, IsActive__c 
                                                        FROM DepartmentCourseGroupLesson__c 
                                                        WHERE DepartmentCourseGroup__c IN :groupToLsnToGroupLsnMap.keySet()])
        {
            if (groupToLsnToGroupLsnMap.get(groupLsn.DepartmentCourseGroup__c).containsKey(groupLsn.Lesson__c)) {
                groupToLsnToGroupLsnMap.get(groupLsn.DepartmentCourseGroup__c).put(groupLsn.Lesson__c, groupLsn);
            }
        }
        for (DepartmentCourseGroupLesson__c groupLsn : newList) {
            DepartmentCourseGroupLesson__c duplGroupLsn = groupToLsnToGroupLsnMap.get(groupLsn.DepartmentCourseGroup__c).get(groupLsn.Lesson__c);
            Boolean isDuplicate = duplGroupLsn != null;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(groupLsn.Id);
            if (isUpdate && isDuplicate) {
                isDuplicate = oldMap.get(groupLsn.Id).Id != duplGroupLsn.Id;
            }
            Boolean isInactivation = isUpdate && !groupLsn.IsActive__c && oldMap.get(groupLsn.Id).IsActive__c;
            if (isDuplicate && !isInactivation) {
                groupLsn.addError(System.Label.DuplicateDepartmentCourseGroupLesson);
            }
        }
    }

    public static void createStudentAttendance(List<DepartmentCourseGroupLesson__c> newList) {
        Set<Id> groupIdSet = new Set<Id>();
        for (DepartmentCourseGroupLesson__c groupLsn : newList) {
            groupIdSet.add(groupLsn.StudentGroup__c);
        }
        Map<Id, List<Id>> groupToMemberStudentsMap = new Map<Id, List<Id>>();
        for (StudentGroupMember__c groupMember : [SELECT Group__c, Student__c
                                                  FROM StudentGroupMember__c
                                                  WHERE Group__c IN :groupIdSet AND IsActive__c = TRUE])
        {
            if (groupToMemberStudentsMap.get(groupMember.Group__c) == null) {
                groupToMemberStudentsMap.put(groupMember.Group__c, new List<Id>());
            }
            groupToMemberStudentsMap.get(groupMember.Group__c).add(groupMember.Student__c);
        }
        List<StudentLessonAttendance__c> attendanceListToInsert = new List<StudentLessonAttendance__c>();
        for (DepartmentCourseGroupLesson__c groupLsn : newList) {
            if (groupToMemberStudentsMap.get(groupLsn.StudentGroup__c) != null) {
                for (Id studId : groupToMemberStudentsMap.get(groupLsn.StudentGroup__c)) {
                    attendanceListToInsert.add(
                        new StudentLessonAttendance__c(
                            Student__c = studId,
                            StudentGroup__c = groupLsn.StudentGroup__c,
                            Lesson__c = groupLsn.Lesson__c
                        )
                    );
                }
            }
        }
        if (!attendanceListToInsert.isEmpty()) {
            insert attendanceListToInsert;
        }
    }
}