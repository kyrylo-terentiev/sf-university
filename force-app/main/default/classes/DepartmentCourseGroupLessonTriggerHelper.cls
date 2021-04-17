public with sharing class DepartmentCourseGroupLessonTriggerHelper {
    
    public static void validateLesson(List<DepartmentCourseGroupLesson__c> newList, Map<Id, DepartmentCourseGroupLesson__c> oldMap) {
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
            Boolean isActiveLesson = lessonMap.get(depCourseGroupLsn.Lesson__c).IsActive__c;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depCourseGroupLsn.Id);
            Boolean isInactivation = isUpdate && !depCourseGroupLsn.IsActive__c;
            if (!isActiveLesson && !isInactivation) {
                depCourseGroupLsn.Lesson__c.addError(System.Label.InactiveLesson);
            }
        }
    }

    public static void setDepartmentCourseGroup(List<DepartmentCourseGroupLesson__c> newList, Map<Id, DepartmentCourseGroupLesson__c> oldMap) {
        Map<String, List<DepartmentCourseGroupLesson__c>> groupAndCourseToLessonsMap = new Map<String, List<DepartmentCourseGroupLesson__c>>();
        Set<Id> groupIdSet = new Set<Id>();
        Set<Id> courseIdSet = new Set<Id>();
        for (DepartmentCourseGroupLesson__c lsn : newList) {
            groupIdSet.add(lsn.StudentGroup__c);
            courseIdSet.add(lsn.Lesson__r.Course__c);
            String groupAndCourseId = String.valueOf(lsn.StudentGroup__c) + String.valueOf(lsn.Lesson__r.Course__c);
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
            WHERE IsActive__c = TRUE AND
                (StudentGroup__c IN :groupIdSet AND StudentGroup__r.IsActive__c = TRUE) AND
                (DepartmentCourse__r.Course__c IN :courseIdSet AND DepartmentCourse__r.IsActive__c = TRUE)
        ];
        Map<String, Id> groupAndCourseToDepCourseGroupMap = new Map<String, Id>();
        for (DepartmentCourseGroup__c depCourseGroup : depCourseGroupList) {
            String groupAndCourseId = String.valueOf(depCourseGroup.StudentGroup__c) + String.valueOf(depCourseGroup.DepartmentCourse__r.Course__c);
            groupAndCourseToDepCourseGroupMap.put(groupAndCourseId, depCourseGroup.Id);
        }
        for (String groupAndCourseId : groupAndCourseToLessonsMap.keySet()) {
            List<DepartmentCourseGroupLesson__c> lessons = groupAndCourseToLessonsMap.get(groupAndCourseId);
            Id depCourseGroupId = groupAndCourseToDepCourseGroupMap.get(groupAndCourseId);
            if (depCourseGroupId != null) {
                for (DepartmentCourseGroupLesson__c lsn : lessons) {
                    lsn.DepartmentCourseGroup__c = depCourseGroupId;
                }
            } else {
                for (DepartmentCourseGroupLesson__c lsn : lessons) {
                    lsn.addError(System.Label.LessonDepartmentCourseGroupNotFound);
                }
            }
        }
    }
}