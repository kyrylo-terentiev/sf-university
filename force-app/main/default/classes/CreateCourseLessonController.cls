public with sharing class CreateCourseLessonController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Id> getAvailableGroupsForLesson(Id lessonId) {
        Map<String, Id> groupNameMap = new Map<String, Id>();
        Id depCourseId = [
            SELECT DepartmentCourse__c
            FROM Lesson__c
            WHERE Id = :lessonId
        ].DepartmentCourse__c;
        List<DepartmentCourseGroup__c> depCourseGroups = [
            SELECT Id
                , StudentGroup__c
                , StudentGroup__r.Name
            FROM DepartmentCourseGroup__c
            WHERE DepartmentCourse__c = :depCourseId AND IsActive__c = TRUE 
        ];
        for (DepartmentCourseGroup__c depCourseGroup : depCourseGroups) {
            groupNameMap.put(depCourseGroup.StudentGroup__r.Name, depCourseGroup.StudentGroup__c);
        }
        if (groupNameMap.isEmpty()) {
            throw new AuraHandledException('No available groups for this lesson found!');
        }
        
        return groupNameMap;
    }
}