public with sharing class DepartmentCourseGroupTaskTriggerHelper {
     
    public static void validate(List<DepartmentCourseGroupTask__c> newList, Map<Id, DepartmentCourseGroupTask__c> oldMap) {
        validateTask(newList, oldMap);
        setCourse(newList);
        setDepartmentCourseGroup(newList);
        validateDepartmentCourseGroup(newList);
    }

    private static void validateTask(List<DepartmentCourseGroupTask__c> newList, Map<Id, DepartmentCourseGroupTask__c> oldMap) {
        Set<Id> taskIdSet = new Set<Id>();
        for (DepartmentCourseGroupTask__c groupTask : newList) {
            taskIdSet.add(groupTask.Task__c);
        }
        Map<Id, Task__c> taskMap = new Map<Id, Task__c>([
            SELECT IsActive__c
            FROM Task__c
            WHERE Id IN :taskIdSet
        ]);
        for (DepartmentCourseGroupTask__c groupTask : newList) {
            Boolean isActiveGroup = taskMap.get(groupTask.Task__c)?.IsActive__c != null
                                    ? taskMap.get(groupTask.Task__c).IsActive__c
                                    : false;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(groupTask.Id);
            Boolean isInactivation = isUpdate && !groupTask.IsActive__c && oldMap.get(groupTask.Id).IsActive__c;
            if (!isActiveGroup && !isInactivation) {
                groupTask.addError(System.Label.InactiveStudentGroup);
            }
        }
    }

    private static void setCourse(List<DepartmentCourseGroupTask__c> newList) {
        Set<Id> taskIdSet = new Set<Id>();
        for (DepartmentCourseGroupTask__c groupTask : newList) {
            taskIdSet.add(groupTask.Task__c);
        }
        Map<Id, Id> taskToCourseMap = new Map<Id, Id>();
        for (Task__c tsk : [SELECT Id, Course__c FROM Task__c WHERE Id IN :taskIdSet]) {
            taskToCourseMap.put(tsk.Id, tsk.Course__c);
        }
        for (DepartmentCourseGroupTask__c groupTask : newList) {
            groupTask.Course__c = taskToCourseMap.get(groupTask.Task__c);
        }
    }

    private static void setDepartmentCourseGroup(List<DepartmentCourseGroupTask__c> newList) {
        Map<String, List<DepartmentCourseGroupTask__c>> groupAndCourseToTasksMap = new Map<String, List<DepartmentCourseGroupTask__c>>();
        Set<Id> groupIdSet = new Set<Id>();
        Set<Id> courseIdSet = new Set<Id>();
        for (DepartmentCourseGroupTask__c tsk : newList) {
            groupIdSet.add(tsk.StudentGroup__c);
            courseIdSet.add(tsk.Course__c);
            String groupAndCourseId = String.valueOf(tsk.StudentGroup__c) + String.valueOf(tsk.Course__c);
            if (groupAndCourseToTasksMap.get(groupAndCourseId) == null) {
                groupAndCourseToTasksMap.put(groupAndCourseId, new List<DepartmentCourseGroupTask__c>());
            }
            groupAndCourseToTasksMap.get(groupAndCourseId).add(tsk);
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
                AND IsActive__c = TRUE
        ];
        Map<String, Id> groupAndCourseToDepCourseGroupMap = new Map<String, Id>();
        for (DepartmentCourseGroup__c depCourseGroup : depCourseGroupList) {
            String groupAndCourseId = String.valueOf(depCourseGroup.StudentGroup__c) + String.valueOf(depCourseGroup.DepartmentCourse__r.Course__c);
            groupAndCourseToDepCourseGroupMap.put(groupAndCourseId, depCourseGroup.Id);
        }
        for (String groupAndCourseId : groupAndCourseToTasksMap.keySet()) {
            List<DepartmentCourseGroupTask__c> tasks = groupAndCourseToTasksMap.get(groupAndCourseId);
            Id depCourseGroupId = groupAndCourseToDepCourseGroupMap.get(groupAndCourseId);
            for (DepartmentCourseGroupTask__c tsk : tasks) {
                if (depCourseGroupId == null) {
                    tsk.addError(System.Label.TaskDepartmentCourseGroupNotFound);
                } else {
                    tsk.DepartmentCourseGroup__c = depCourseGroupId;
                }
            }
        }
    }

    private static void validateDepartmentCourseGroup(List<DepartmentCourseGroupTask__c> newList) {
        Set<Id> taskIdSet = new Set<Id>();
        Set<Id> depCourseGroupIdSet = new Set<Id>();
        for (DepartmentCourseGroupTask__c groupTask : newList) {
            depCourseGroupIdSet.add(groupTask.DepartmentCourseGroup__c);
            taskIdSet.add(groupTask.Task__c);
        }
        Set<Id> lessonIdSet = new Set<Id>();
        Map<Id, Id> taskToLessonMap = new Map<Id, Id>();
        for (Task__c tsk : [SELECT Id, Lesson__c FROM Task__c WHERE Id IN :taskIdSet AND Lesson__c != NULL]) {
            lessonIdSet.add(tsk.Lesson__c);
            taskToLessonMap.put(tsk.Id, tsk.Lesson__c);
        }
        Map<Id, Map<Id, Id>> depCourseGroupToLsnToDepCourseGroupLsnMap = new Map<Id, Map<Id, Id>>();
        for (DepartmentCourseGroupLesson__c groupLsn : [SELECT Id, DepartmentCourseGroup__c, Lesson__c
                                                          FROM DepartmentCourseGroupLesson__c 
                                                          WHERE DepartmentCourseGroup__c IN :depCourseGroupIdSet AND
                                                            Lesson__c IN :lessonIdSet AND IsActive__c = TRUE]) {
            if (depCourseGroupToLsnToDepCourseGroupLsnMap.get(groupLsn.DepartmentCourseGroup__c) == null) {
                depCourseGroupToLsnToDepCourseGroupLsnMap.put(groupLsn.DepartmentCourseGroup__c, new Map<Id, Id>());
            }
            depCourseGroupToLsnToDepCourseGroupLsnMap.get(groupLsn.DepartmentCourseGroup__c).put(groupLsn.Lesson__c, groupLsn.Id);
        }
        for (DepartmentCourseGroupTask__c groupTask : newList) {
            if (taskToLessonMap.containsKey(groupTask.Task__c)) {
                Boolean isAttendingLesson = depCourseGroupToLsnToDepCourseGroupLsnMap.containsKey(groupTask.DepartmentCourseGroup__c)
                                            && depCourseGroupToLsnToDepCourseGroupLsnMap.get(groupTask.DepartmentCourseGroup__c).containsKey(taskToLessonMap.get(groupTask.Task__c));
                if (!isAttendingLesson) {
                    groupTask.addError(System.Label.TaskGroupNotAttendingLesson);
                }
            }
        }
    }
}