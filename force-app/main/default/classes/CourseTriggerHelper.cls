public with sharing class CourseTriggerHelper {
    
    public static void updateChildren(Map<Id, Course__c> newMap, Map<Id, Course__c> oldMap) {
        List<sObject> childrenToUpdate = new List<sObject>();
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
            Boolean isNameChanged = newCourse.Name != oldCourse.Name;
            Boolean isInactivated = !newCourse.IsActive__c && oldCourse.IsActive__c;
            if (isNameChanged || isInactivated) {
                for (DepartmentCourse__c depCourse : courseToDepCoursesMap.get(profId)) {
                    if (isNameChanged) depCourse.Name = newCourse.Name;
                    if (isInactivated) depCourse.IsActive__c = newCourse.IsActive__c;
                    depCoursesToUpdate.add(depCourse);
                }
            }
        }

        return depCoursesToUpdate;
    }
}
