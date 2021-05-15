public with sharing class CourseTriggerHelper {
    
    public static void updateChildren(Map<Id, Course__c> newMap, Map<Id, Course__c> oldMap) {
        List<SObject> childrenToUpdate = new List<SObject>();
        childrenToUpdate.addAll(getUpdatedDepartmentCourses(newMap, oldMap));
        if (!childrenToUpdate.isEmpty()) {
            update childrenToUpdate;
        }
    }

    public static List<DepartmentCourse__c> getUpdatedDepartmentCourses(Map<Id, Course__c> newMap, Map<Id, Course__c> oldMap) {
        List<DepartmentCourse__c> depCoursesToUpdate = new List<DepartmentCourse__c>();
        Map<Id, List<DepartmentCourse__c>> courseToDepCoursesMap = new Map<Id, List<DepartmentCourse__c>>();
        for (DepartmentCourse__c depCourse : [SELECT Course__c, IsActive__c 
                                                  FROM DepartmentCourse__c 
                                                  WHERE Course__c IN :newMap.keySet()])
        {
            if (courseToDepCoursesMap.get(depCourse.Course__c) == null) {
                courseToDepCoursesMap.put(depCourse.Course__c, new List<DepartmentCourse__c>());
            }
            courseToDepCoursesMap.get(depCourse.Course__c).add(depCourse);
        }
        for (Id profId : courseToDepCoursesMap.keySet()) {
            Course__c newCourse = newMap.get(profId);
            Course__c oldCourse = oldMap.get(profId);
            Boolean isInactivated = !newCourse.IsActive__c && oldCourse.IsActive__c;
            if (isInactivated) {
                for (DepartmentCourse__c depCourse : courseToDepCoursesMap.get(profId)) {
                    depCourse.IsActive__c = false;
                    depCoursesToUpdate.add(depCourse);
                }
            }
        }

        return depCoursesToUpdate;
    }
}