public with sharing class LessonTriggerHelper {

    public static void setDateTime(List<Lesson__c> newList) {
        for (Lesson__c lsn : newList) {
            lsn.StartDateTime__c = Utils.getDatetime(lsn.Date__c, lsn.StartTimePicklist__c);
            lsn.EndDateTime__c = Utils.getDatetime(lsn.Date__c, lsn.EndTimePicklist__c);
        }
    }

    public static void validate(List<Lesson__c> newList, Map<Id, Lesson__c> oldMap) {
        setDepartmentCourse(newList);
        setDepartmentProfessor(newList);
        setDepartmentCourseProfessor(newList);
        validateDepartmentCourseProfessor(newList, oldMap);
        validateDuplicate(newList);
    }

    private static void setDepartmentCourse(List<Lesson__c> newList) {
        Map<String, List<Lesson__c>> deptAndCourseToLessonsMap = new Map<String, List<Lesson__c>>();
        Set<Id> deptIdSet = new Set<Id>();
        Set<Id> courseIdSet = new Set<Id>();
        for (Lesson__c lsn : newList) {
            deptIdSet.add(lsn.Department__c);
            courseIdSet.add(lsn.Course__c);
            String deptAndCourseId = String.valueOf(lsn.Department__c) + String.valueOf(lsn.Course__c);
            if (deptAndCourseToLessonsMap.get(deptAndCourseId) == null) {
                deptAndCourseToLessonsMap.put(deptAndCourseId, new List<Lesson__c>());
            }
            deptAndCourseToLessonsMap.get(deptAndCourseId).add(lsn);
        }
        List<DepartmentCourse__c> depCourseList = [
            SELECT Id
                , Department__c
                , Course__c
            FROM DepartmentCourse__c
            WHERE 
                Department__c IN :deptIdSet AND
                Course__c IN :courseIdSet
        ];
        Map<String, Id> deptAndCourseToDepCourseMap = new Map<String, Id>();
        for (DepartmentCourse__c depCourse : depCourseList) {
            String deptAndCourseId = String.valueOf(depCourse.Department__c) + String.valueOf(depCourse.Course__c);
            deptAndCourseToDepCourseMap.put(deptAndCourseId, depCourse.Id);
        }
        for (String deptAndCourseId : deptAndCourseToLessonsMap.keySet()) {
            List<Lesson__c> lessons = deptAndCourseToLessonsMap.get(deptAndCourseId);
            Id depCourseId = deptAndCourseToDepCourseMap.get(deptAndCourseId);
            for (Lesson__c lsn : lessons) {
                if (depCourseId == null) {
                    lsn.addError(System.Label.LessonDepartmentCourseNotFound);
                } else {
                    lsn.DepartmentCourse__c = depCourseId;
                }
            }
        }
    }

    private static void setDepartmentProfessor(List<Lesson__c> newList) {
        Map<String, List<Lesson__c>> deptAndProfToLessonsMap = new Map<String, List<Lesson__c>>();
        Set<Id> deptIdSet = new Set<Id>();
        Set<Id> profIdSet = new Set<Id>();
        for (Lesson__c lsn : newList) {
            deptIdSet.add(lsn.Department__c);
            profIdSet.add(lsn.Professor__c);
            String deptAndProfId = String.valueOf(lsn.Department__c) + String.valueOf(lsn.Professor__c);
            if (deptAndProfToLessonsMap.get(deptAndProfId) == null) {
                deptAndProfToLessonsMap.put(deptAndProfId, new List<Lesson__c>());
            }
            deptAndProfToLessonsMap.get(deptAndProfId).add(lsn);
        }
        List<DepartmentProfessor__c> depProfList = [
            SELECT Id
                , Department__c
                , Professor__c
            FROM DepartmentProfessor__c
            WHERE 
                Department__c IN :deptIdSet AND
                Professor__c IN :profIdSet
        ];
        Map<String, Id> deptAndProfToDepProfMap = new Map<String, Id>();
        for (DepartmentProfessor__c depProf : depProfList) {
            String deptAndProfId = String.valueOf(depProf.Department__c) + String.valueOf(depProf.Professor__c);
            deptAndProfToDepProfMap.put(deptAndProfId, depProf.Id);
        }
        for (String deptAndProfId : deptAndProfToLessonsMap.keySet()) {
            List<Lesson__c> lessons = deptAndProfToLessonsMap.get(deptAndProfId);
            Id depProfId = deptAndProfToDepProfMap.get(deptAndProfId);
            for (Lesson__c lsn : lessons) {
                if (depProfId == null) {
                    lsn.addError(System.Label.LessonDepartmentProfessorNotFound);
                } else {
                    lsn.DepartmentProfessor__c = depProfId;
                }
            }
        }
    }

    private static void setDepartmentCourseProfessor(List<Lesson__c> newList) {
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
        // update department course group lessons - deactivate (copy from department course group trigger)
    }
}