public with sharing class TaskTriggerHelper {
     
    public static void validate(List<Task__c> newList, Map<Id, Task__c> oldMap) {
        setDepartmentCourse(newList);
        validateLesson(newList, oldMap);
    }

    private static void setDepartmentCourse(List<Task__c> newList) {
        Map<String, List<Task__c>> deptAndCourseToTasksMap = new Map<String, List<Task__c>>();
        Set<Id> deptIdSet = new Set<Id>();
        Set<Id> courseIdSet = new Set<Id>();
        for (Task__c tsk : newList) {
            deptIdSet.add(tsk.Department__c);
            courseIdSet.add(tsk.Course__c);
            String deptAndCourseId = String.valueOf(tsk.Department__c) + String.valueOf(tsk.Course__c);
            if (deptAndCourseToTasksMap.get(deptAndCourseId) == null) {
                deptAndCourseToTasksMap.put(deptAndCourseId, new List<Task__c>());
            }
            deptAndCourseToTasksMap.get(deptAndCourseId).add(tsk);
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
        for (String deptAndCourseId : deptAndCourseToTasksMap.keySet()) {
            List<Task__c> tasks = deptAndCourseToTasksMap.get(deptAndCourseId);
            Id depCourseId = deptAndCourseToDepCourseMap.get(deptAndCourseId);
            for (Task__c tsk : tasks) {
                if (depCourseId == null) {
                    tsk.addError(System.Label.TaskDepartmentCourseNotFound);
                } else {
                    tsk.DepartmentCourse__c = depCourseId;
                }
            }
        }
    }

    private static void validateLesson(List<Task__c> newList, Map<Id, Task__c> oldMap) {
        Set<Id> lessonIdSet = new Set<Id>();
        for (Task__c tsk : newList) {
            if (tsk.Lesson__c != null) {
                lessonIdSet.add(tsk.Lesson__c);
            }
        }
        Map<Id, Lesson__c> lessonMap = new Map<Id, Lesson__c>([
            SELECT IsActive__c, DepartmentCourse__c
            FROM Lesson__c
            WHERE Id IN :lessonIdSet
        ]);
        for (Task__c tsk : newList) {
            if (tsk.Lesson__c != null) {
                Boolean isActiveLesson = lessonMap.get(tsk.Lesson__c)?.IsActive__c != null
                                 ? lessonMap.get(tsk.Lesson__c).IsActive__c
                                 : false;
                Boolean isUpdate = oldMap != null && !tsk.IsActive__c;
                Boolean isInactivation = isUpdate && !tsk.IsActive__c;
                if ((!isActiveLesson && !isInactivation)) {
                    tsk.Lesson__c.addError(System.Label.InactiveLesson);
                }
                Boolean isWrongDepartmentCourse = tsk.DepartmentCourse__c != lessonMap.get(tsk.Lesson__c).DepartmentCourse__c;
                if (isWrongDepartmentCourse) {
                    tsk.Lesson__c.addError(System.Label.WrongLessonForTask);
                }
            }
        }
    }

}