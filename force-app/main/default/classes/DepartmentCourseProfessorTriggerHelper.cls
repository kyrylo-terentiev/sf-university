public with sharing class DepartmentCourseProfessorTriggerHelper {
    
    public static void validate(List<DepartmentCourseProfessor__c> newList, Map<Id, DepartmentCourseProfessor__c> oldMap) {
        setDepartmentCourse(newList);
        setDepartmentProfessor(newList);
        validateDepartmentCourse(newList, oldMap);
        validateDepartmentProfessor(newList, oldMap);
        validateDepartmentCourseProfessor(newList, oldMap);
    }

    private static void setDepartmentCourse(List<DepartmentCourseProfessor__c> newList) {
        Map<String, List<DepartmentCourseProfessor__c>> deptAndCourseToDepCourseProfsMap = new Map<String, List<DepartmentCourseProfessor__c>>();
        Set<Id> deptIdSet = new Set<Id>();
        Set<Id> courseIdSet = new Set<Id>();
        for (DepartmentCourseProfessor__c depCourseProf : newList) {
            deptIdSet.add(depCourseProf.Department__c);
            courseIdSet.add(depCourseProf.Course__c);
            String deptAndCourseId = String.valueOf(depCourseProf.Department__c) + String.valueOf(depCourseProf.Course__c);
            if (deptAndCourseToDepCourseProfsMap.get(deptAndCourseId) == null) {
                deptAndCourseToDepCourseProfsMap.put(deptAndCourseId, new List<DepartmentCourseProfessor__c>());
            }
            deptAndCourseToDepCourseProfsMap.get(deptAndCourseId).add(depCourseProf);
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
        for (String deptAndCourseId : deptAndCourseToDepCourseProfsMap.keySet()) {
            List<DepartmentCourseProfessor__c> depCourseProfs = deptAndCourseToDepCourseProfsMap.get(deptAndCourseId);
            Id depCourseId = deptAndCourseToDepCourseMap.get(deptAndCourseId);
            for (DepartmentCourseProfessor__c depCourseProf : depCourseProfs) {
                if (depCourseId == null) {
                    depCourseProf.addError(System.Label.DepartmentCourseProfessorDepartmentCourseNotFound);
                } else {
                    depCourseProf.DepartmentCourse__c = depCourseId;
                }
            }
        }
    }

    private static void setDepartmentProfessor(List<DepartmentCourseProfessor__c> newList) {
        Map<String, List<DepartmentCourseProfessor__c>> deptAndProfToDepCourseProfsMap = new Map<String, List<DepartmentCourseProfessor__c>>();
        Set<Id> deptIdSet = new Set<Id>();
        Set<Id> profIdSet = new Set<Id>();
        for (DepartmentCourseProfessor__c depCourseProf : newList) {
            deptIdSet.add(depCourseProf.Department__c);
            profIdSet.add(depCourseProf.Professor__c);
            String deptAndProfId = String.valueOf(depCourseProf.Department__c) + String.valueOf(depCourseProf.Professor__c);
            if (deptAndProfToDepCourseProfsMap.get(deptAndProfId) == null) {
                deptAndProfToDepCourseProfsMap.put(deptAndProfId, new List<DepartmentCourseProfessor__c>());
            }
            deptAndProfToDepCourseProfsMap.get(deptAndProfId).add(depCourseProf);
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
        for (String deptAndProfId : deptAndProfToDepCourseProfsMap.keySet()) {
            List<DepartmentCourseProfessor__c> depCourseProfs = deptAndProfToDepCourseProfsMap.get(deptAndProfId);
            Id depProfId = deptAndProfToDepProfMap.get(deptAndProfId);
            for (DepartmentCourseProfessor__c depCourseProf : depCourseProfs) {
                if (depProfId == null) {
                    depCourseProf.addError(System.Label.DepartmentCourseProfessorDepartmentProfessorNotFound);
                } else {
                    depCourseProf.DepartmentProfessor__c = depProfId;
                }
            }
        }
    }

    private static void validateDepartmentProfessor(List<DepartmentCourseProfessor__c> newList, Map<Id, DepartmentCourseProfessor__c> oldMap) {
        Set<Id> depProfIdSet = new Set<Id>();
        for (DepartmentCourseProfessor__c depCourseProf : newList) {
            depProfIdSet.add(depCourseProf.DepartmentProfessor__c);
        }
        Map<Id, DepartmentProfessor__c> depProfMap = new Map<Id, DepartmentProfessor__c>([
            SELECT IsActive__c
            FROM DepartmentProfessor__c
            WHERE Id IN :depProfIdSet
        ]);
        for (DepartmentCourseProfessor__c depCourseProf : newList) {
            Boolean isActiveDepProf = depProfMap.get(depCourseProf.DepartmentProfessor__c)?.IsActive__c != null
                                      ? depProfMap.get(depCourseProf.DepartmentProfessor__c).IsActive__c
                                      : false;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depCourseProf.Id);
            Boolean isInactivation = isUpdate && !depCourseProf.IsActive__c;
            if (!isActiveDepProf && !isInactivation) {
                depCourseProf.DepartmentProfessor__c.addError(System.Label.InactiveDepartmentProfessor);
            }
        }
    }

    private static void validateDepartmentCourse(List<DepartmentCourseProfessor__c> newList, Map<Id, DepartmentCourseProfessor__c> oldMap) {
        Set<Id> depCourseIdSet = new Set<Id>();
        for (DepartmentCourseProfessor__c depCourseProf : newList) {
            depCourseIdSet.add(depCourseProf.DepartmentCourse__c);
        }
        Map<Id, DepartmentCourse__c> depCourseMap = new Map<Id, DepartmentCourse__c>([
            SELECT IsActive__c
            FROM DepartmentCourse__c
            WHERE Id IN :depCourseIdSet
        ]);
        for (DepartmentCourseProfessor__c depCourseProf : newList) {
            Boolean isActiveDepCourse = depCourseMap.get(depCourseProf.DepartmentCourse__c)?.IsActive__c != null
                                        ? depCourseMap.get(depCourseProf.DepartmentCourse__c).IsActive__c
                                        : false;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depCourseProf.Id);
            Boolean isInactivation = isUpdate && !depCourseProf.IsActive__c;
            if (!isActiveDepCourse && !isInactivation) {
                depCourseProf.DepartmentCourse__c.addError(System.Label.InactiveDepartmentCourse);
            }
        }
    }

    private static void validateDepartmentCourseProfessor(List<DepartmentCourseProfessor__c> newList, Map<Id, DepartmentCourseProfessor__c> oldMap) {
        Map<Id, Map<Id, DepartmentCourseProfessor__c>> courseToProfToDepCourseProf = new Map<Id, Map<Id, DepartmentCourseProfessor__c>>();
        for (DepartmentCourseProfessor__c depCourseProf : newList) {
            courseToProfToDepCourseProf.put(depCourseProf.DepartmentCourse__c, new Map<Id, DepartmentCourseProfessor__c>());
            courseToProfToDepCourseProf.get(depCourseProf.DepartmentCourse__c).put(depCourseProf.DepartmentProfessor__c, null);
        }
        for (DepartmentCourseProfessor__c depCourseProf : [SELECT DepartmentCourse__c, DepartmentProfessor__c, IsActive__c 
                                                        FROM DepartmentCourseProfessor__c 
                                                        WHERE DepartmentCourse__c IN :courseToProfToDepCourseProf.keySet()])
        {
            if (courseToProfToDepCourseProf.get(depCourseProf.DepartmentCourse__c).containsKey(depCourseProf.DepartmentProfessor__c)) {
                courseToProfToDepCourseProf.get(depCourseProf.DepartmentCourse__c).put(depCourseProf.DepartmentProfessor__c, depCourseProf);
            }
        }
        for (DepartmentCourseProfessor__c depCourseProf : newList) {
            DepartmentCourseProfessor__c duplDepCourseProf = courseToProfToDepCourseProf.get(depCourseProf.DepartmentCourse__c).get(depCourseProf.DepartmentProfessor__c);
            Boolean isDuplicate = duplDepCourseProf != null;
            Boolean isUpdate = oldMap != null && oldMap.containsKey(depCourseProf.Id);
            if (isUpdate && isDuplicate) {
                isDuplicate = oldMap.get(depCourseProf.Id).Id != duplDepCourseProf.Id;
            }
            Boolean isInactivation = isUpdate && !depCourseProf.IsActive__c && oldMap.get(depCourseProf.Id).IsActive__c;
            if (isDuplicate && !isInactivation) {
                depCourseProf.addError(System.Label.DuplicateDepartmentCourseProfessor);
            }
        }
    }

    public static void updateChildren(Map<Id, DepartmentCourseProfessor__c> newMap, Map<Id, DepartmentCourseProfessor__c> oldMap) {
        List<SObject> childrenToUpdate = new List<SObject>();
        childrenToUpdate.addAll(getUpdatedLessons(newMap, oldMap));
        if (!childrenToUpdate.isEmpty()) {
            update childrenToUpdate;
        }
    }

    private static List<Lesson__c> getUpdatedLessons(Map<Id, DepartmentCourseProfessor__c> newMap, Map<Id, DepartmentCourseProfessor__c> oldMap) {
        List<Lesson__c> lessonsToUpdate = new List<Lesson__c>();
        Map<Id, List<Lesson__c>> depCourseProfToLessonsMap = new Map<Id, List<Lesson__c>>();
        for (Lesson__c lsn : [SELECT DepartmentCourseProfessor__c, IsActive__c 
                              FROM Lesson__c 
                              WHERE DepartmentCourseProfessor__c IN :newMap.keySet()])
        {
            if (depCourseProfToLessonsMap.get(lsn.DepartmentCourseProfessor__c) == null) {
                depCourseProfToLessonsMap.put(lsn.DepartmentCourseProfessor__c, new List<Lesson__c>());
            }
            depCourseProfToLessonsMap.get(lsn.DepartmentCourseProfessor__c).add(lsn);
        }
        for (Id depCourseProfId : depCourseProfToLessonsMap.keySet()) {
            DepartmentCourseProfessor__c newDepCourseProf = newMap.get(depCourseProfId);
            DepartmentCourseProfessor__c oldDepCourseProf = oldMap.get(depCourseProfId);
            Boolean isInactivated = !newDepCourseProf.IsActive__c && oldDepCourseProf.IsActive__c;
            if (isInactivated) {
                for (Lesson__c lsn : depCourseProfToLessonsMap.get(depCourseProfId)) {
                    if (lsn.IsActive__c) {
                        lsn.IsActive__c = false;
                        lessonsToUpdate.add(lsn);
                    }
                }
            }
        }

        return lessonsToUpdate;
    }
}