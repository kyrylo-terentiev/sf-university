public with sharing class DepartmentCourseGroupLessonTriggerHelper {
    
    public static void validate(List<DepartmentCourseGroupLesson__c> newList, Map<Id, DepartmentCourseGroupLesson__c> oldMap) {
        validateLesson(newList, oldMap);
        setProfessor(newList);
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

    private static void setProfessor(List<DepartmentCourseGroupLesson__c> newList) {
        Set<Id> lessonIdSet = new Set<Id>();
        for (DepartmentCourseGroupLesson__c depCourseGroupLsn : newList) {
            lessonIdSet.add(depCourseGroupLsn.Lesson__c);
        }
        Map<Id, Id> lessonToProfessorMap = new Map<Id, Id>();
        for (Lesson__c lsn : [SELECT Professor__c
                              FROM Lesson__c
                              WHERE Id IN :lessonIdSet])
        {
            lessonToProfessorMap.put(lsn.Id, lsn.Professor__c);
        }
        for (DepartmentCourseGroupLesson__c depCourseGroupLsn : newList) {
            depCourseGroupLsn.Professor__c = lessonToProfessorMap.get(depCourseGroupLsn.Lesson__c);
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

    public static void updateChildren(Map<Id, DepartmentCourseGroupLesson__c> newMap, Map<Id, DepartmentCourseGroupLesson__c> oldMap) {
        List<SObject> childrenToUpdate = new List<SObject>();
        childrenToUpdate.addAll(getUpdatedStudentLessonAttendances(newMap, oldMap));
        if (!childrenToUpdate.isEmpty()) {
            update childrenToUpdate;
        }
    }

    private static List<StudentLessonAttendance__c> getUpdatedStudentLessonAttendances(Map<Id, DepartmentCourseGroupLesson__c> newMap, Map<Id, DepartmentCourseGroupLesson__c> oldMap) {
        List<StudentLessonAttendance__c> studentAttendancesToUpdate = new List<StudentLessonAttendance__c>();
        Map<Id, List<StudentLessonAttendance__c>> groupLsnToStudentAttendancesMap = new Map<Id, List<StudentLessonAttendance__c>>();
        for (StudentLessonAttendance__c attendance : [SELECT DepartmentCourseGroupLesson__c, IsActive__c 
                                                   FROM StudentLessonAttendance__c 
                                                   WHERE DepartmentCourseGroupLesson__c IN :newMap.keySet()])
        {
            if (groupLsnToStudentAttendancesMap.get(attendance.DepartmentCourseGroupLesson__c) == null) {
                groupLsnToStudentAttendancesMap.put(attendance.DepartmentCourseGroupLesson__c, new List<StudentLessonAttendance__c>());
            }
            groupLsnToStudentAttendancesMap.get(attendance.DepartmentCourseGroupLesson__c).add(attendance);
        }
        for (Id groupLsnId : groupLsnToStudentAttendancesMap.keySet()) {
            DepartmentCourseGroupLesson__c newGroupLsn = newMap.get(groupLsnId);
            DepartmentCourseGroupLesson__c oldGroupLsn = oldMap.get(groupLsnId);
            Boolean isInactivated = !newGroupLsn.IsActive__c && oldGroupLsn.IsActive__c;
            if (isInactivated) {
                for (StudentLessonAttendance__c attendance : groupLsnToStudentAttendancesMap.get(groupLsnId)) {
                    if (attendance.IsActive__c) {
                        attendance.IsActive__c = false;
                        studentAttendancesToUpdate.add(attendance);
                    }
                }
            }
        }

        return studentAttendancesToUpdate;
    }

    public static void deleteChildren(Map<Id, DepartmentCourseGroupLesson__c> oldMap) {
        List<SObject> childrenToDelete = new List<SObject>();
        childrenToDelete.addAll(getStudentAttendancesToDelete(oldMap));
        if (!childrenToDelete.isEmpty()) {
            delete childrenToDelete;
        }
    }

    private static List<StudentLessonAttendance__c> getStudentAttendancesToDelete(Map<Id, DepartmentCourseGroupLesson__c> oldMap) {
        return [
            SELECT DepartmentCourseGroupLesson__c, IsActive__c 
            FROM StudentLessonAttendance__c 
            WHERE DepartmentCourseGroupLesson__c IN :oldMap.keySet()
        ];
    }

    public static void updateLesson(List<DepartmentCourseGroupLesson__c> newList) {
        Set<Id> lessonIdSet = new Set<Id>();
        for (DepartmentCourseGroupLesson__c groupLsn : newList) {
            lessonIdSet.add(groupLsn.Lesson__c);
        }
        Map<Id, List<DepartmentCourseGroupLesson__c>> lessonToGroupLessons = new Map<Id, List<DepartmentCourseGroupLesson__c>>();
        for (DepartmentCourseGroupLesson__c groupLsn : [SELECT Lesson__c, AttendingStudents__c
                                                      FROM DepartmentCourseGroupLesson__c
                                                      WHERE Lesson__c IN :lessonIdSet
                                                        AND IsActive__c = TRUE])
        {
            if (lessonToGroupLessons.get(groupLsn.Lesson__c) == null) {
                lessonToGroupLessons.put(groupLsn.Lesson__c, new List<DepartmentCourseGroupLesson__c>());
            }
            lessonToGroupLessons.get(groupLsn.Lesson__c).add(groupLsn);
        }
        List<Lesson__c> lessonsToUpdate = new List<Lesson__c>();
        for (Id lessonId : lessonToGroupLessons.keySet()) {
            Decimal attendingStudents = 0;
            for (DepartmentCourseGroupLesson__c groupLsn : lessonToGroupLessons.get(lessonId)) {
                attendingStudents += groupLsn.AttendingStudents__c;
            }
            lessonsToUpdate.add(
                new Lesson__c(
                    Id = lessonId,
                    AttendingStudents__c = attendingStudents
                )
            );
        }
        if (!lessonsToUpdate.isEmpty()) {
            update lessonsToUpdate;
        }
    }
}