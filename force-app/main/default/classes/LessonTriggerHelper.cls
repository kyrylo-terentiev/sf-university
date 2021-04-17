public with sharing class LessonTriggerHelper {

    public static void setDateTime(List<Lesson__c> newList) {
        for (Lesson__c lsn : newList) {
            lsn.StartDateTime__c = Utils.getDatetime(lsn.Date__c, lsn.StartTimePicklist__c);
            lsn.EndDateTime__c = Utils.getDatetime(lsn.Date__c, lsn.EndTimePicklist__c);
        }
    }

    public static void validate(List<Lesson__c> newList, Map<Id, Lesson__c> oldMap) {
        validateDepartmentCourse(newList, oldMap);
        validateDepartmentProfessor(newList, oldMap);
        validateDuplicate(newList);
    }

    private static void validateDepartmentCourse(List<Lesson__c> newList, Map<Id, Lesson__c> oldMap) {
        Set<Id> depCourseIdSet = new Set<Id>();
        for (Lesson__c lsn : newList) {
            depCourseIdSet.add(lsn.DepartmentCourse__c);
        }
        Map<Id, DepartmentCourse__c> depCourseMap = new Map<Id, DepartmentCourse__c>([
            SELECT IsActive__c
            FROM DepartmentCourse__c
            WHERE Id IN :depCourseIdSet
        ]);
        for (Lesson__c lsn : newList) {
            Boolean isActiveDepCourse = depCourseMap.get(lsn.DepartmentCourse__c).IsActive__c;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(lsn.Id);
            Boolean isInactivation = isUpdate && !lsn.IsActive__c;
            if (!isActiveDepCourse && !isInactivation) {
                lsn.DepartmentCourse__c.addError(System.Label.InactiveDepartmentCourse);
            }
        }
    }

    private static void validateDepartmentProfessor(List<Lesson__c> newList, Map<Id, Lesson__c> oldMap) {
        Set<Id> depProfIdSet = new Set<Id>();
        for (Lesson__c lsn : newList) {
            depProfIdSet.add(lsn.DepartmentProfessor__c);
        }
        Map<Id, DepartmentProfessor__c> depProfMap = new Map<Id, DepartmentProfessor__c>([
            SELECT IsActive__c
            FROM DepartmentProfessor__c
            WHERE Id IN :depProfIdSet
        ]);
        for (Lesson__c lsn : newList) {
            Boolean isActiveDepProf = depProfMap.get(lsn.DepartmentProfessor__c).IsActive__c;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(lsn.Id);
            Boolean isInactivation = isUpdate && !lsn.IsActive__c;
            if (!isActiveDepProf && !isInactivation) {
                lsn.DepartmentProfessor__c.addError(System.Label.InactiveDepartmentProfessor);
            }
        }
    }

    public static void setDepartmentCourseProfessor(List<Lesson__c> newList) {
        Map<String, List<Lesson__c>> courseAndProfToLessonsMap = new Map<String, List<Lesson__c>>();
        Set<Id> courseIdSet = new Set<Id>();
        Set<Id> profIdSet = new Set<Id>();
        for (Lesson__c lsn : newList) {
            courseIdSet.add(lsn.DepartmentCourse__c);
            profIdSet.add(lsn.DepartmentProfessor__c);
            String courseAndProfId = String.valueOf(lsn.DepartmentCourse__c) + String.valueOf(lsn.DepartmentProfessor__c);
            if (courseAndProfToLessonsMap.get(courseAndProfId) == null) {
                courseAndProfToLessonsMap.put(courseAndProfId, new List<Lesson__c>());
            }
            courseAndProfToLessonsMap.get(courseAndProfId).add(lsn);
        }
        List<DepartmentCourseProfessor__c> depCourseProfList = [
            SELECT Id
                , DepartmentCourse__c
                , DepartmentCourse__r.IsActive__c
                , DepartmentProfessor__c
                , DepartmentProfessor__r.IsActive__c
            FROM DepartmentCourseProfessor__c
            WHERE IsActive__c = TRUE AND
            (DepartmentProfessor__c IN :profIdSet AND DepartmentProfessor__r.IsActive__c = TRUE) AND
            (DepartmentCourse__c IN :courseIdSet AND DepartmentCourse__r.IsActive__c = TRUE)
        ];
        Map<String, Id> courseAndProfToDepCourseProfMap = new Map<String, Id>();
        for (DepartmentCourseProfessor__c depCourseProf : depCourseProfList) {
            String courseAndProfId = String.valueOf(depCourseProf.DepartmentCourse__c) + String.valueOf(depCourseProf.DepartmentProfessor__c);
            courseAndProfToDepCourseProfMap.put(courseAndProfId, depCourseProf.Id);
        }
        for (String courseAndProfId : courseAndProfToLessonsMap.keySet()) {
            List<Lesson__c> lessons = courseAndProfToLessonsMap.get(courseAndProfId);
            Id depCourseProfId = courseAndProfToDepCourseProfMap.get(courseAndProfId);
            if (depCourseProfId != null) {
                for (Lesson__c lsn : lessons) {
                    lsn.DepartmentCourseProfessor__c = depCourseProfId;
                }
            } else {
                for (Lesson__c lsn : lessons) {
                    lsn.addError(System.Label.LessonDepartmentCourseProfessorNotFound);
                }
            }
        }
    }


    private static void validateDuplicate(List<Lesson__c> newList) {
        Set<Id> depProfIdSet = new Set<Id>();
        Set<Date> dateSet = new Set<Date>();
        Set<String> orderNumberSet = new Set<String>();
        for (Lesson__c lsn : newList) {
            depProfIdSet.add(lsn.DepartmentProfessor__c);
            dateSet.add(lsn.Date__c);
            orderNumberSet.add(lsn.OrderNumber__c);
        }
        List<Lesson__c> existingLessons = [
            SELECT Id
                , DepartmentProfessor__c
                , Date__c 
                , OrderNumber__c
            FROM Lesson__c
            WHERE DepartmentProfessor__c IN :depProfIdSet AND
                Date__c IN :dateSet AND
                OrderNumber__c IN :orderNumberSet
        ];
        for (Lesson__c newLsn : newList) {
            for (Lesson__c oldLsn : existingLessons) {
                Boolean isSameRecord = newLsn.Id == oldLsn.Id;
                Boolean isSameDepProf = newLsn.DepartmentProfessor__c == oldLsn.DepartmentProfessor__c;
                Boolean isSameDate = newLsn.Date__c == oldLsn.Date__c;
                Boolean isSameOrderNumber = newLsn.OrderNumber__c == oldLsn.OrderNumber__c;
                if (!isSameRecord && isSameDepProf && isSameDate && isSameOrderNumber) {
                    newLsn.addError(System.Label.DuplicateLesson);
                }
            }
        }
    }

    public static void updateChildren(Map<Id, Lesson__c> newMap, Map<Id, Lesson__c> oldMap) {

    }
}