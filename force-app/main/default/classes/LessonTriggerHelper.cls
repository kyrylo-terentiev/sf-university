public with sharing class LessonTriggerHelper {

    public static void setDateTime(List<Lesson__c> newList) {
        for (Lesson__c lsn : newList) {
            lsn.StartDateTime__c = Utils.getDatetime(lsn.Date__c, lsn.StartTimePicklist__c);
            lsn.EndDateTime__c = Utils.getDatetime(lsn.Date__c, lsn.EndTimePicklist__c);
        }
    }

    public static void validate(List<Lesson__c> newList, Map<Id, Lesson__c> oldMap) {
        setDepartmentCourseProfessor(newList);
        validateDepartmentCourseProfessor(newList, oldMap);
        validateDuplicate(newList);
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
                , DepartmentProfessor__c
            FROM DepartmentCourseProfessor__c
            WHERE
                DepartmentProfessor__c IN :profIdSet AND
                DepartmentCourse__c IN :courseIdSet
        ];
        Map<String, Id> courseAndProfToDepCourseProfMap = new Map<String, Id>();
        for (DepartmentCourseProfessor__c depCourseProf : depCourseProfList) {
            String courseAndProfId = String.valueOf(depCourseProf.DepartmentCourse__c) + String.valueOf(depCourseProf.DepartmentProfessor__c);
            courseAndProfToDepCourseProfMap.put(courseAndProfId, depCourseProf.Id);
        }
        for (String courseAndProfId : courseAndProfToLessonsMap.keySet()) {
            List<Lesson__c> lessons = courseAndProfToLessonsMap.get(courseAndProfId);
            Id depCourseProfId = courseAndProfToDepCourseProfMap.get(courseAndProfId);
            for (Lesson__c lsn : lessons) {
                if (depCourseProfId == null) {
                    lsn.addError(System.Label.LessonDepartmentCourseProfessorNotFound);
                } else {
                    lsn.DepartmentCourseProfessor__c = depCourseProfId;
                }
            }
        }
    }

    private static void validateDepartmentCourseProfessor(List<Lesson__c> newList, Map<Id, Lesson__c> oldMap) {
        Set<Id> depCourseProfIdSet = new Set<Id>();
        for (Lesson__c lsn : newList) {
            depCourseProfIdSet.add(lsn.DepartmentCourseProfessor__c);
        }
        Map<Id, DepartmentCourseProfessor__c> depCourseProfMap = new Map<Id, DepartmentCourseProfessor__c>([
            SELECT IsActive__c
            FROM DepartmentCourseProfessor__c
            WHERE Id IN :depCourseProfIdSet
        ]);
        for (Lesson__c lsn : newList) {
            Boolean isActiveDepCourseProf = depCourseProfMap.get(lsn.DepartmentCourseProfessor__c)?.IsActive__c != null
                                            ? depCourseProfMap.get(lsn.DepartmentCourseProfessor__c).IsActive__c
                                            : false;
            
            Boolean isUpdate = oldMap != null && oldMap.containsKey(lsn.Id);
            Boolean isInactivation = isUpdate && !lsn.IsActive__c;
            if (!isActiveDepCourseProf && !isInactivation) {
                lsn.DepartmentCourseProfessor__c.addError(System.Label.InactiveDepartmentCourseProfessor);
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